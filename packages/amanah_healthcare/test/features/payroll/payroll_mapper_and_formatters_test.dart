import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_home_data.dart';
import 'package:amanah_healthcare/features/payroll/data/dto/payroll_period_dto.dart';
import 'package:amanah_healthcare/features/payroll/data/dto/staff_payroll_summary_dto.dart';
import 'package:amanah_healthcare/features/payroll/data/mappers/payroll_mapper.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/monthly_payroll_group.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/payroll_period.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/staff_payroll_summary.dart';
import 'package:amanah_healthcare/features/payroll/presentation/utils/payroll_formatters.dart';

void main() {
  group('PayrollFormatters Unit Tests', () {
    test('currency formats positive and negative IDR values correctly', () {
      expect(PayrollFormatters.currency(0), 'Rp 0');
      expect(PayrollFormatters.currency(150000), 'Rp 150.000');
      expect(PayrollFormatters.currency(27900000), 'Rp 27.900.000');
      expect(PayrollFormatters.currency(-12600000), '- Rp 12.600.000');
    });

    test('periodDateRange formats ISO dates using Core Time localizer', () {
      final String formatted = PayrollFormatters.periodDateRange('2026-10-01', '2026-10-31');
      expect(formatted, contains('Okt 2026'));
      expect(formatted, contains('–'));
    });

    test('statusLabel and statusVariant map canonical statuses correctly', () {
      expect(PayrollFormatters.statusLabel('calculated'), 'Terkalkulasi');
      expect(PayrollFormatters.statusVariant('calculated'), AmanahBadgeVariant.primary);

      expect(PayrollFormatters.statusLabel('finalized'), 'Ditutup buku');
      expect(PayrollFormatters.statusVariant('finalized'), AmanahBadgeVariant.success);

      expect(PayrollFormatters.statusLabel('draft'), 'Draf');
      expect(PayrollFormatters.statusVariant('draft'), AmanahBadgeVariant.warning);
    });

    test('entryTypeLabel returns plain human Indonesian descriptions', () {
      expect(PayrollFormatters.entryTypeLabel('base_scheduled'), 'Upah hari ini');
      expect(PayrollFormatters.entryTypeLabel('leave_deduction'), 'Gaji di potong');
      expect(PayrollFormatters.entryTypeLabel('replacement_addition'), 'Upah pengganti');
      expect(PayrollFormatters.entryTypeLabel('overtime_addition'), 'Upah lembur');
      expect(PayrollFormatters.entryTypeLabel('unknown'), 'Upah pelayanan');
    });
  });

  group('PayrollMapper Unit Tests', () {
    test('maps StaffPayrollSummaryDto to StaffPayrollSummary with enriched fields', () {
      final StaffPayrollSummaryDto dto = StaffPayrollSummaryDto.fromJson(<String, dynamic>{
        'staffId': 'staff-123',
        'staffCode': 'DOC-001',
        'fullName': 'dr. Ahmad Santoso',
        'staffType': 'doctor',
        'positionTitle': 'Dokter Umum',
        'departmentName': 'Poli Umum',
        'periodId': 'period-001',
        'periodName': 'Payroll Periode Oktober 2026',
        'periodStart': '2026-10-01',
        'periodEnd': '2026-10-31',
        'periodStatus': 'calculated',
        'calculatedAt': '2026-10-20T10:00:00.000Z',
        'baseHours': 270.0,
        'deductionHours': 84.0,
        'additionHours': 0.0,
        'baseEarnings': 40500000.0,
        'grossEarnings': 40500000.0,
        'leaveDeductions': 12600000.0,
        'replacementAdditions': 0.0,
        'netPayroll': 27900000.0,
        'entries': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'entry-1',
            'entryType': 'base_scheduled',
            'sourceType': 'attendance',
            'quantityHours': 270.0,
            'hourlyRate': 150000.0,
            'amount': 40500000.0,
            'description': 'Gaji pokok dinas terjadwal',
            'checkInAt': '2026-10-20 08:00:00.000+07',
            'checkOutAt': '2026-10-20 16:00:00.000+07',
            'isEarlyDeparture': false,
            'notes': null,
            'createdAt': '2026-10-20T10:00:00.000Z',
          },
          <String, dynamic>{
            'id': 'entry-2',
            'entryType': 'leave_deduction',
            'sourceType': 'attendance',
            'quantityHours': 84.0,
            'hourlyRate': 150000.0,
            'amount': 12600000.0,
            'description': 'Pemotongan cuti',
            'checkInAt': '2026-10-19 08:00:00.000+07',
            'checkOutAt': '2026-10-19 12:00:00.000+07',
            'isEarlyDeparture': true,
            'notes': 'Izin dinas luar / visit rujukan',
            'createdAt': '2026-10-20T10:00:00.000Z',
          },
        ],
      });

      final StaffPayrollSummary entity = PayrollMapper.toSummary(dto);

      expect(entity.staffId, 'staff-123');
      expect(entity.staffCode, 'DOC-001');
      expect(entity.fullName, 'dr. Ahmad Santoso');
      expect(entity.departmentName, 'Poli Umum');
      expect(entity.periodId, 'period-001');
      expect(entity.periodName, 'Payroll Periode Oktober 2026');
      expect(entity.baseHours, 270.0);
      expect(entity.deductionHours, 84.0);
      expect(entity.netPayroll, 27900000.0);
      expect(entity.entries.length, 2);
      expect(entity.earningsEntries.length, 1);
      expect(entity.deductionEntries.length, 1);
      expect(entity.entries.first.sourceType, 'attendance');
      expect(entity.entries.first.isBase, isTrue);
      expect(entity.entries.first.checkInAt, '2026-10-20 08:00:00.000+07');
      expect(entity.entries.first.checkOutAt, '2026-10-20 16:00:00.000+07');
      expect(entity.entries.first.isEarlyDeparture, isFalse);
      expect(entity.entries.last.isDeduction, isTrue);
      expect(entity.entries.last.isEarlyDeparture, isTrue);
      expect(entity.entries.last.notes, 'Izin dinas luar / visit rujukan');
    });

    test('maps PayrollPeriodDto to PayrollPeriod correctly', () {
      const PayrollPeriodDto dto = PayrollPeriodDto(
        id: 'p-1',
        periodName: 'Periode 1',
        periodStart: '2026-10-01',
        periodEnd: '2026-10-31',
        status: 'calculated',
        totalPayout: 417240000.0,
      );

      final PayrollPeriod entity = PayrollMapper.toPeriod(dto);

      expect(entity.id, 'p-1');
      expect(entity.periodName, 'Periode 1');
      expect(entity.status, 'calculated');
      expect(entity.totalPayout, 417240000.0);
    });

    test('maps MonthlyPayrollGroupDto to MonthlyPayrollGroup correctly', () {
      final MonthlyPayrollGroupDto dto = MonthlyPayrollGroupDto.fromJson(<String, dynamic>{
        'periodId': 'period-001',
        'periodName': 'Payroll Periode Oktober 2026',
        'periodStart': '2026-10-01',
        'periodEnd': '2026-10-31',
        'periodStatus': 'calculated',
        'monthLabel': 'oktober 2026',
        'totalNet': 4350000.0,
        'totalGross': 4500000.0,
        'totalDeductions': 150000.0,
        'totalHours': 30.0,
        'entries': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'entry-1',
            'entryType': 'base_scheduled',
            'sourceType': 'attendance',
            'quantityHours': 12.0,
            'hourlyRate': 150000.0,
            'amount': 1800000.0,
            'description': 'Upah hari ini - Pelayanan',
          },
        ],
      });

      final MonthlyPayrollGroup entity = PayrollMapper.toMonthlyGroup(dto);

      expect(entity.periodId, 'period-001');
      expect(entity.monthLabel, 'oktober 2026');
      expect(entity.totalNet, 4350000.0);
      expect(entity.totalGross, 4500000.0);
      expect(entity.totalDeductions, 150000.0);
      expect(entity.totalHours, 30.0);
      expect(entity.entries.length, 1);
      expect(entity.entries.first.isBase, isTrue);
    });
  });
}
