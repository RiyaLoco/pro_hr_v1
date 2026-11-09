import 'package:flutter_test/flutter_test.dart';
import 'package:test_flutter/data/models/res/payroll_model.dart';

void main() {
  group('Payslip allowance integration', () {
    test('uses the API allowance total when details are unavailable', () {
      final payslip = Payslip.fromJson({
        'id': 1,
        'basic_salary': '1000.00',
        'addition': '150.50',
        'tax': '50.00',
        'advanced_amount': '100.00',
        'net_salary': '1000.50',
      });

      expect(payslip.addition, 150.50);
      expect(payslip.earnings.map((item) => item.label), [
        'Basic Salary',
        'Additional/Allowance',
      ]);
      expect(payslip.earnings.first.amount, 1000);
      expect(payslip.earnings.last.amount, 150.50);
      expect(payslip.totalGross, 1150.50);
      expect(payslip.listGross, 1150.50);
      expect(payslip.deductions.last.label, 'Salary advance');
      expect(payslip.deductions.last.amount, 100);
      expect(payslip.totalDeductions, 150);
      expect(payslip.netTakeHome, 1000.50);
      expect(payslip.listNet, 1000.50);
    });

    test('counts named allowance details once alongside other earnings', () {
      final payslip = Payslip.fromJson({
        'basic_salary': '1000.00',
        'addition': '150.50',
        'net_salary': '1180.50',
        'details': [
          {
            'attr_name': 'Transport',
            'amount': '100.00',
            'type': 'Additional/Allowance',
          },
          {
            'attr_name': 'Meals',
            'amount': '50.50',
            'type': 'Additional/Allowance',
          },
          {'attr_name': 'Overtime', 'amount': '30.00', 'type': 'Overtime'},
        ],
      });

      expect(payslip.addition, 150.50);
      expect(payslip.earnings.map((item) => item.label), [
        'Basic Salary',
        'Transport',
        'Meals',
        'Overtime',
      ]);
      expect(payslip.totalGross, 1180.50);
      expect(payslip.listGross, 1180.50);
      expect(payslip.deductions, isEmpty);
    });

    test('accepts numeric allowance totals with empty details', () {
      final payslip = Payslip.fromJson({
        'basic_salary': 1000,
        'addition': 75.25,
        'net_salary': 1075.25,
        'details': [],
      });

      expect(payslip.addition, 75.25);
      expect(payslip.totalGross, 1075.25);
      expect(payslip.earnings.last.label, 'Additional/Allowance');
    });

    for (final addition in [null, '0.00', 0]) {
      test('does not add an allowance row for $addition', () {
        final payslip = Payslip.fromJson({
          'basic_salary': '1000.00',
          'addition': addition,
          'net_salary': '1000.00',
        });

        expect(payslip.addition, 0);
        expect(payslip.earnings.single.label, 'Basic Salary');
        expect(payslip.totalGross, 1000);
      });
    }

    for (final includeAddition in [false, true]) {
      test(
        'derives a missing or null total from allowance details ($includeAddition)',
        () {
          final payslip = Payslip.fromJson({
            'basic_salary': '1000.00',
            if (includeAddition) 'addition': null,
            'details': [
              {
                'attr_name': 'Housing',
                'amount': '125.25',
                'type': 'Additional/Allowance',
              },
              {'attr_name': 'Overtime', 'amount': '20.00', 'type': 'Overtime'},
            ],
          });

          expect(payslip.addition, 125.25);
          expect(payslip.totalGross, 1145.25);
          expect(payslip.earnings, hasLength(3));
        },
      );
    }

    test('keeps deductions separate and uses the server net salary', () {
      final payslip = Payslip.fromJson({
        'basic_salary': '1000.00',
        'addition': '150.00',
        'tax': '50.00',
        'advanced_amount': '100.00',
        'net_salary': '975.00',
        'details': [
          {'attr_name': 'Basic Salary', 'amount': '1000.00', 'type': 'Earning'},
          {
            'attr_name': 'Housing',
            'amount': '150.00',
            'type': 'Additional/Allowance',
          },
          {'attr_name': 'Tax', 'amount': '50.00', 'type': 'Tax'},
          {
            'attr_name': 'Salary advance',
            'amount': '100.00',
            'type': 'Advance',
          },
          {
            'attr_name': 'Unpaid leave',
            'amount': '-25.00',
            'type': 'Deduction',
          },
        ],
      });

      expect(payslip.addition, 150);
      expect(payslip.earnings, hasLength(2));
      expect(payslip.totalGross, 1150);
      expect(payslip.totalDeductions, 175);
      expect(payslip.netTakeHome, 975);
      expect(payslip.listNet, 975);
    });
  });
}
