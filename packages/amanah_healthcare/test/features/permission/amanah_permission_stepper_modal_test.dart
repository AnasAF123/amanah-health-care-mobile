import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/eligible_session.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/leave_request_entity.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/replacement_item.dart';
import 'package:amanah_healthcare/features/permission/domain/repositories/permission_repository.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/form/amanah_permission_stepper_modal.dart';

class MockPermissionRepository implements PermissionRepository {
  @override
  Future<List<LeaveRequestEntity>> getMyLeaves() async =>
      const <LeaveRequestEntity>[];

  @override
  Future<List<EligibleSession>> getEligibleSessions(String date) async =>
      const <EligibleSession>[
        EligibleSession(
          sessionId: 'sess-pagi',
          sessionCode: 'pagi',
          sessionLabel: 'Pagi',
          startsAt: '06:00',
          endsAt: '12:00',
          workDate: '2026-10-22',
        ),
        EligibleSession(
          sessionId: 'sess-siang',
          sessionCode: 'siang',
          sessionLabel: 'Siang',
          startsAt: '12:00',
          endsAt: '18:00',
          workDate: '2026-10-22',
        ),
      ];

  static final LeaveRequestEntity _dummyLeave = LeaveRequestEntity(
    id: 'leave-1',
    staffId: 'staff-1',
    startDate: '2026-10-22',
    endDate: '2026-10-23',
    durationDays: 2,
    reason: 'Izin Sakit',
    type: 'izinSakit',
    scope: 'full_day',
    decisionSource: 'system',
    status: 'menunggu',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  static final ReplacementItem _dummyReplacement = ReplacementItem(
    id: 'rep-1',
    leaveRequestId: 'leave-1',
    sessionId: 'sess-1',
    workDate: '2026-10-22',
    originalStaffProfileId: 'staff-1',
    status: 'open',
    createdAt: DateTime.now(),
  );

  @override
  Future<LeaveRequestEntity> requestLeave({
    required String startDate,
    required String endDate,
    required String reason,
    String? type,
    String? scope,
    List<String>? sessionIds,
  }) async =>
      _dummyLeave;

  @override
  Future<LeaveRequestEntity> cancelLeave(String id) async => _dummyLeave;

  @override
  Future<List<ReplacementItem>> getAvailableReplacements() async =>
      const <ReplacementItem>[];

  @override
  Future<ReplacementItem> claimReplacement(String id) async =>
      _dummyReplacement;
}

void main() {
  group('AmanahPermissionStepperModal Sequential Flow', () {
    testWidgets('Sequential flow auto-advances through stages with reflective header and date choices',
        (WidgetTester tester) async {
      final MockPermissionRepository mockRepo = MockPermissionRepository();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AmanahPermissionStepperModal(
              doctorName: 'dr. Zikri Fadhil',
              doctorRole: 'Dokter Umum',
              repository: mockRepo,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header matches current Stage 1 Title and NO step numbers or progress bars
      expect(find.text('Pilih Jenis Perizinan'), findsOneWidget);
      expect(find.text('Langkah 1'), findsNothing);
      expect(find.text('Step 1'), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);

      // Verify leave types are present
      expect(find.text('Cuti Tahunan'), findsOneWidget);
      expect(find.text('Izin Sakit'), findsOneWidget);

      // Auto-advance: Tap 'Izin Sakit'
      await tester.tap(find.text('Izin Sakit'));
      await tester.pumpAndSettle();

      // STAGE 2: Should auto-advance to Date Mode stage with reflective header
      expect(find.text('Pilih Waktu Perizinan'), findsOneWidget);
      expect(find.text('Hari Ini'), findsOneWidget);
      expect(find.text('Rentang Tanggal'), findsOneWidget);

      // Branch A: Tap 'Hari Ini' -> Fast auto-advance to Scope stage!
      await tester.tap(find.text('Hari Ini'));
      await tester.pumpAndSettle();

      // STAGE 3: Should show Scope stage with reflective header
      expect(find.text('Pilih Lingkup Perizinan'), findsOneWidget);
      expect(find.text('1 Hari Penuh'), findsOneWidget);
      expect(find.text('Sesi Tertentu'), findsOneWidget);

      // Back navigation test: Click back button in header from Scope
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      // Should be back at Date Mode ('Pilih Waktu Perizinan')
      expect(find.text('Pilih Waktu Perizinan'), findsOneWidget);
      expect(find.text('Hari Ini'), findsOneWidget);
      expect(find.text('Rentang Tanggal'), findsOneWidget);

      // Branch B: Tap 'Rentang Tanggal' -> Advance to custom range picker stage
      await tester.tap(find.text('Rentang Tanggal'));
      await tester.pumpAndSettle();

      // Custom Range Stage: Header is 'Tentukan Rentang Tanggal'
      expect(find.text('Tentukan Rentang Tanggal'), findsOneWidget);
      expect(find.text('Tanggal Mulai'), findsOneWidget);
      expect(find.text('Tanggal Selesai'), findsOneWidget);

      // Advance to Scope stage via continue button
      await tester.tap(find.text('Lanjutkan ke Lingkup'));
      await tester.pumpAndSettle();

      // Should be in Scope stage
      expect(find.text('Pilih Lingkup Perizinan'), findsOneWidget);

      // Auto-advance: Tap '1 Hari Penuh'
      await tester.tap(find.text('1 Hari Penuh'));
      await tester.pumpAndSettle();

      // STAGE 4: Reason & Recap stage with reflective header
      expect(find.text('Konfirmasi & Alasan Izin'), findsOneWidget);
      expect(find.text('Izin Sakit'), findsOneWidget); // Recap badge
      expect(find.text('1 Hari Penuh'), findsOneWidget); // Recap scope
      expect(find.text('Kirim Pengajuan Izin'), findsOneWidget);

      // Back navigation test: Click back button in header from Reason
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      // Should be back at Stage 3 (Scope)
      expect(find.text('Pilih Lingkup Perizinan'), findsOneWidget);
    });

    testWidgets('PopScope intercepts back navigation and prevents accidental modal dismissal',
        (WidgetTester tester) async {
      final MockPermissionRepository mockRepo = MockPermissionRepository();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AmanahPermissionStepperModal(
              doctorName: 'dr. Zikri Fadhil',
              doctorRole: 'Dokter Umum',
              repository: mockRepo,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // At Stage 1: canPop should be true (at root stage)
      final PopScope popScopeStage1 = tester.widget<PopScope>(
        find.byWidgetPredicate((Widget w) => w is PopScope),
      );
      expect(popScopeStage1.canPop, isTrue);

      // Advance to Stage 2 (Date Mode)
      await tester.tap(find.text('Cuti Tahunan'));
      await tester.pumpAndSettle();

      // At Stage 2: canPop MUST be false (prevent accidental dismissal!)
      final PopScope popScopeStage2 = tester.widget<PopScope>(
        find.byWidgetPredicate((Widget w) => w is PopScope),
      );
      expect(popScopeStage2.canPop, isFalse);

      // Simulate system back invocation on PopScope
      popScopeStage2.onPopInvokedWithResult?.call(false, null);
      await tester.pumpAndSettle();

      // Should safely step back to Stage 1 instead of dismissing!
      expect(find.text('Pilih Jenis Perizinan'), findsOneWidget);
      expect(find.byType(AmanahPermissionStepperModal), findsOneWidget);
    });
  });
}
