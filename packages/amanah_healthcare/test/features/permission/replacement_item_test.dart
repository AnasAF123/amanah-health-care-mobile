import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/replacement_item.dart';

void main() {
  group('ReplacementItem Domain Entity Tests', () {
    test('Correctly maps statusBadgeText into clean Title Case labels', () {
      final ReplacementItem openItem = ReplacementItem(
        id: 'rep-1',
        leaveRequestId: 'leave-1',
        sessionId: 'session-1',
        workDate: '2026-10-25',
        originalStaffProfileId: 'staff-1',
        originalStaffName: 'dr. Santoso',
        originalStaffRole: 'Dokter Umum',
        status: 'open',
        createdAt: DateTime(2026, 10, 20),
        startTime: '06:00:00',
        endTime: '12:00:00',
      );

      expect(openItem.isOpen, isTrue);
      expect(openItem.statusBadgeText('staff-2', 'Budi'), 'Terbuka');
      expect(openItem.startTimeShort, '06:00');
      expect(openItem.endTimeShort, '12:00');
      expect(openItem.formattedTimeRange, '06:00 - 12:00 WIB');

      final ReplacementItem claimedByMeItem = ReplacementItem(
        id: 'rep-2',
        leaveRequestId: 'leave-2',
        sessionId: 'session-2',
        workDate: '2026-10-26',
        originalStaffProfileId: 'staff-1',
        originalStaffName: 'dr. Santoso',
        originalStaffRole: 'Dokter Umum',
        claimedByStaffProfileId: 'staff-current',
        claimedByName: 'dr. Sarah',
        status: 'claimed',
        createdAt: DateTime(2026, 10, 20),
        startTime: '12:00:00',
        endTime: '18:00:00',
      );

      expect(claimedByMeItem.isClaimed, isTrue);
      expect(claimedByMeItem.isClaimedByMe('staff-current'), isTrue);
      expect(claimedByMeItem.statusBadgeText('staff-current', 'dr. Sarah'), 'Jadwal Anda');

      final ReplacementItem claimedByOtherItem = ReplacementItem(
        id: 'rep-3',
        leaveRequestId: 'leave-3',
        sessionId: 'session-3',
        workDate: '2026-10-27',
        originalStaffProfileId: 'staff-1',
        originalStaffName: 'dr. Santoso',
        claimedByStaffProfileId: 'staff-other',
        claimedByName: 'dr. Budi',
        status: 'claimed',
        createdAt: DateTime(2026, 10, 20),
      );

      expect(claimedByOtherItem.isClaimedByOther('staff-current'), isTrue);
      expect(claimedByOtherItem.statusBadgeText('staff-current', 'dr. Sarah'), 'Diklaim');
    });
  });
}
