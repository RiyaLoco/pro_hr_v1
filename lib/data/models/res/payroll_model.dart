const List<String> _months = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

const List<String> _shortMonths = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Decimal columns arrive as strings like "350.00".
double _money(dynamic value) => double.tryParse('${value ?? ''}') ?? 0;

String? _text(dynamic value) {
  final text = value?.toString().trim();
  return (text == null || text.isEmpty || text == 'null') ? null : text;
}

/// 'yyyy-MM-dd...' -> date only.
DateTime? _parseDay(dynamic raw) {
  final text = _text(raw);
  if (text == null || text.length < 10) return null;
  return DateTime.tryParse(text.substring(0, 10));
}

DateTime? _parseDateTime(dynamic raw) {
  final text = _text(raw);
  if (text == null) return null;
  final parsed = DateTime.tryParse(text);
  if (parsed == null) return null;
  return parsed.isUtc ? parsed.toLocal() : parsed;
}

/// '10 Jul 2026'
String _formatDate(DateTime d) => '${d.day} ${_shortMonths[d.month - 1]} ${d.year}';

/// '1 – 31 Jul 2026', '26 Jun – 25 Jul 2026'
String _periodLabel(DateTime? from, DateTime? to) {
  if (from == null && to == null) return '';
  final start = from ?? to!;
  final end = to ?? from!;

  if (start.year == end.year && start.month == end.month) {
    return start.day == end.day
        ? _formatDate(end)
        : '${start.day} – ${end.day} ${_shortMonths[end.month - 1]} ${end.year}';
  }
  if (start.year == end.year) {
    return '${start.day} ${_shortMonths[start.month - 1]} – ${_formatDate(end)}';
  }
  return '${_formatDate(start)} – ${_formatDate(end)}';
}

/// The database spells "Acknowledged" two ways; show one.
String _normalizeStatus(dynamic raw) {
  final text = '${raw ?? ''}'.trim();
  switch (text.toLowerCase()) {
    case 'paid':
      return 'Paid';
    case 'approved':
    case 'approve':
      return 'Approved';
    case 'acknowledged':
    case 'acknoledged':
      return 'Acknowledged';
    case 'pending approval':
      return 'Pending Approval';
    case 'draft':
      return 'Draft';
    case 'rejected':
    case 'reject':
      return 'Rejected';
    default:
      return text.isEmpty ? 'Unknown' : text;
  }
}

/// payroll_details.type -> is this row a deduction?
/// ADJUST: put the words your admin uses for deductions in this list.
const List<String> _deductionWords = ['deduct', 'minus', 'tax', 'less', 'advance'];

bool _isDeduction(String? type) {
  final value = (type ?? '').toLowerCase();
  return _deductionWords.any(value.contains);
}

bool _hasLabel(List<PayslipLineItem> items, String word) =>
    items.any((item) => item.label.toLowerCase().contains(word));

/// One line on the payslip (an earning or a deduction).
class PayslipLineItem {
  final String label;
  final double amount;

  const PayslipLineItem({required this.label, required this.amount});
}

/// One payroll row from the API, shaped for the Payrolls list and the
/// Payslip detail screen.
class Payslip {
  final int id;
  final String month; // 'July 2026' (month the pay period ends in)
  final String periodLabel; // '1 – 31 Jul 2026'
  final String status; // 'Paid' | 'Approved' | 'Acknowledged' | ...
  final String processedLabel; // 'Processed on 10 Jul 2026'
  final double listNet;
  final double? listGross;
  final String paidOnLabel; // 'Paid on 10 Jul 2026' (verb follows the status)
  final double netTakeHome;
  final List<PayslipLineItem> earnings;
  final List<PayslipLineItem> deductions;
  final DateTime? periodEnd;

  const Payslip({
    required this.id,
    required this.month,
    required this.periodLabel,
    required this.status,
    required this.processedLabel,
    required this.listNet,
    this.listGross,
    required this.paidOnLabel,
    required this.netTakeHome,
    required this.earnings,
    required this.deductions,
    this.periodEnd,
  });

  double get totalGross => earnings.fold(0, (sum, item) => sum + item.amount);

  double get totalDeductions => deductions.fold(0, (sum, item) => sum + item.amount);

  /// Only these are shown to the employee.
  bool get isReleased => const {'Approved', 'Acknowledged', 'Paid'}.contains(status);

  factory Payslip.fromJson(Map<String, dynamic> json) {
    final earnings = <PayslipLineItem>[];
    final deductions = <PayslipLineItem>[];

    final details = json['details'];
    if (details is List) {
      for (final row in details.whereType<Map>()) {
        final label = _text(row['attr_name']) ?? 'Item';
        final amount = _money(row['amount']);
        if (_isDeduction(_text(row['type']))) {
          deductions.add(PayslipLineItem(label: label, amount: amount.abs()));
        } else {
          earnings.add(PayslipLineItem(label: label, amount: amount));
        }
      }
    }

    // ---- Columns on the payroll itself, unless already a detail row ----
    final basic = _money(json['basic_salary']);
    final tax = _money(json['tax']);
    final advance = _money(json['advanced_amount']);

    if (basic > 0 && !_hasLabel(earnings, 'basic')) {
      earnings.insert(0, PayslipLineItem(label: 'Basic Salary', amount: basic));
    }
    if (tax > 0 && !_hasLabel(deductions, 'tax')) {
      deductions.insert(0, PayslipLineItem(label: 'Tax', amount: tax));
    }
    if (advance > 0 && !_hasLabel(deductions, 'advance')) {
      deductions.add(PayslipLineItem(label: 'Salary advance', amount: advance));
    }

    // ---- Period and dates ----
    final from = _parseDay(json['for_date']);
    final to = _parseDay(json['to_date']);
    final periodEnd = to ?? from;

    final prepared = _parseDateTime(json['prepared_at']);
    final approved = _parseDateTime(json['approved_at']);
    final acked = _parseDateTime(json['acked_at']);
    final created = _parseDateTime(json['created_at']);
    final processed = acked ?? approved ?? prepared ?? created;

    // There is no "paid on" column, so the date comes from the last step
    // in the approval flow that has a date.
    final status = _normalizeStatus(json['status']);
    final String verb;
    final DateTime? statusDate;
    switch (status) {
      case 'Paid':
        verb = 'Paid';
        statusDate = acked ?? approved ?? processed;
        break;
      case 'Acknowledged':
        verb = 'Acknowledged';
        statusDate = acked ?? processed;
        break;
      case 'Approved':
        verb = 'Approved';
        statusDate = approved ?? processed;
        break;
      default:
        verb = 'Processed';
        statusDate = processed;
    }

    final net = _money(json['net_salary']);
    final payslip = Payslip(
      id: int.tryParse('${json['id']}') ?? 0,
      month: periodEnd == null ? 'Payslip' : '${_months[periodEnd.month - 1]} ${periodEnd.year}',
      periodLabel: _periodLabel(from, to),
      status: status,
      processedLabel: processed == null ? 'Processed' : 'Processed on ${_formatDate(processed)}',
      listNet: net,
      listGross: null, // set below, once the lines are known
      paidOnLabel: statusDate == null ? '' : '$verb on ${_formatDate(statusDate)}',
      netTakeHome: net,
      earnings: earnings,
      deductions: deductions,
      periodEnd: periodEnd,
    );

    final gross = payslip.totalGross;
    return gross > 0
        ? Payslip(
            id: payslip.id,
            month: payslip.month,
            periodLabel: payslip.periodLabel,
            status: payslip.status,
            processedLabel: payslip.processedLabel,
            listNet: payslip.listNet,
            listGross: gross,
            paidOnLabel: payslip.paidOnLabel,
            netTakeHome: payslip.netTakeHome,
            earnings: earnings,
            deductions: deductions,
            periodEnd: periodEnd,
          )
        : payslip;
  }
}