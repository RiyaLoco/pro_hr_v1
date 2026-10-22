
const List<String> _shortMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec'
];

String _formatDate(DateTime date) =>
  '${_shortMonths[date.month - 1]} ${date.day}, ${date.year}';

String _trimNumber(double value) => value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');

DateTime? _parseDate(dynamic raw){
  final text = '${raw ?? ''}';
  if(text.length < 10) return null;
  return DateTime.tryParse(text.substring(0, 10));
}

String? _name(dynamic related, String key){
  if(related is! Map) return null;
  final value = related[key].toString().trim();
  return (value.isEmpty) ? null : value;
}

String _plainText(dynamic raw){
  var text = '${raw ?? ''}';
  if(text.isEmpty) return '';
  text = text
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</(p|div|h[1-6]|ul|ol)>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</li>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '• ')
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&mdash;', '—')
      .replaceAll('&ndash;', '–')
      .replaceAll('&bull;', '•')
      .replaceAll('&rsquo;', '’')
      .replaceAll('&lsquo;', '‘')
      .replaceAll('&rdquo;', '”')
      .replaceAll('&ldquo;', '“')
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .replaceAll(RegExp(r'[ \t]+\n'), '\n')
      .replaceAll(RegExp(r'\n[ \t]+'), '\n')
      .replaceAll(RegExp(r'[ \t]{2,}'), ' ')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n');
  return text.trim();
}

class Recruitment{
  final String uuid;
  final String title;
  final String? posterUrl;
  final String description;
  final String jobDescription;
  final String education;
  final String experience;
  final double? salaryMin;
  final double? salaryMax;
  final DateTime? openDate;
  final DateTime? deadline;
  final int? requiredCount;
  final String status;
  final String? department;
  final String? position;
  final String? branch;
  final String? employmentType;
  final String? shift;

  const Recruitment({
    required this.uuid,
    required this.title,
    this.posterUrl,
    this.description = '',
    this.jobDescription = '',
    this.education = '',
    this.experience = '',
    this.salaryMin,
    this.salaryMax,
    this.openDate,
    this.deadline,
    this.requiredCount,
    this.status = 'Open',
    this.department,
    this.position,
    this.branch,
    this.employmentType,
    this.shift,
  });

  factory Recruitment.fromJson(Map<String, dynamic> json){
    final poster = json['poster_url'] ?.toString().trim();
    return Recruitment(
      uuid: '${json['uuid']}',
      title: '${json['title'] ?? ''}',
      posterUrl: (poster == null || poster.isEmpty) ? null : poster,
      description: _plainText(json['description']),
      jobDescription: _plainText(json['job_description']),
      education: _plainText(json['education']),
      experience: _plainText(json['experience']),
      salaryMin: double.tryParse('${json['salary_min']}'),
      salaryMax: double.tryParse('${json['salary_max']}'),
      openDate: _parseDate(json['open_date']),
      deadline: _parseDate(json['deadline']),
      requiredCount: int.tryParse('${json['required_count']}'),
      status: '${json['status'] ?? 'Open'}',
      department: _name(json['department'], 'name'),
      position: _name(json['position'], 'name'),
      branch: _name(json['branch'], 'name'),
      employmentType: _name(json['employment_type'], 'name'),
      shift: _name(json['shift'], 'shift_name'),
    );
  }

  String? get salaryLabel{
    const symbol = '\$';
    final min = salaryMin;
    final max = salaryMax;
    if(min == null && max == null) return null;
    if(min != null && max != null){
      return '$symbol${_trimNumber(min)} - $symbol${_trimNumber(max)}';
    }
    if(min != null) return 'From $symbol${_trimNumber(min)}';
    return 'Up to $symbol${_trimNumber(max!)}';
  }

  String? get openDateLabel => openDate == null ? null : _formatDate(openDate!);

  String? get deadlineLabel {
    final d = deadline;
    if (d == null) return null;
    final now = DateTime.now();
    final days = DateTime(d.year, d.month, d.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    final base = _formatDate(d);
    if (days < 0) return '$base (closed)';
    if (days == 0) return '$base (closes today)';
    return '$base ($days ${days == 1 ? 'day' : 'days'} left)';
  }
}
