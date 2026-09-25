import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/domain/slot_occupied_info.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/drawers/amanah_slot_occupied_detail_drawer.dart';

class RescheduleStartTimePicker extends StatelessWidget {
  const RescheduleStartTimePicker({
    required this.selectedStartTime,
    required this.onTimeSelected,
    this.disabledTimes = const <String>[],
    this.optionSubtitles = const <String, String>{},
    this.occupiedDetails = const <String, SlotOccupiedInfo>{},
    required this.dark,
    super.key,
  });

  final String? selectedStartTime;
  final ValueChanged<String> onTimeSelected;
  final List<String> disabledTimes;
  final Map<String, String> optionSubtitles;
  final Map<String, SlotOccupiedInfo> occupiedDetails;
  final bool dark;

  static List<String> buildTimeOptions() {
    final List<String> options = <String>[];
    for (int hour = 7; hour <= 21; hour++) {
      final String hStr = hour.toString().padLeft(2, '0');
      options.add('$hStr:00');
      options.add('$hStr:30');
    }
    return options;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> times = buildTimeOptions();
    final bool hasSubtitles = optionSubtitles.isNotEmpty;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        showAmanahBottomSheet<String>(
          context: context,
          builder: (BuildContext ctx) => AmanahBottomSheetScaffold(
            title: 'Pilih Jam Mulai Target',
            subtitle: 'Waktu yang bentrok dinonaktifkan otomatis',
            fixedHeightFactor: 0.70,
            bodyPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            body: GridView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: times.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisExtent: hasSubtitles ? 52 : 44,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (BuildContext context, int index) {
                final String t = times[index];
                final bool isDisabled = disabledTimes.any(
                  (String d) => d.trim().toLowerCase() == t.trim().toLowerCase(),
                );
                final bool isSelected = !isDisabled && t == selectedStartTime;
                final String? subtitle = optionSubtitles[t];
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: isDisabled
                      ? () {
                          final SlotOccupiedInfo? info = occupiedDetails[t];
                          AmanahSlotOccupiedDetailDrawer.show(
                            ctx,
                            time: t,
                            info: info,
                            subtitle: subtitle,
                          );
                        }
                      : () => Navigator.of(ctx).pop(t),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (dark
                              ? AmanahColorTokens.tabActiveDark
                              : AmanahColorTokens.brand)
                          : isDisabled
                          ? (dark
                              ? AmanahColorTokens.pureWhite.withValues(alpha: 0.02)
                              : AmanahColorTokens.neutral100)
                          : (dark
                              ? AmanahColorTokens.pureWhite.withValues(alpha: 0.05)
                              : AmanahColorTokens.neutral100),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? (dark
                                ? AmanahColorTokens.tabActiveDark
                                : AmanahColorTokens.brand)
                            : (dark
                                ? AmanahColorTokens.pureWhite.withValues(alpha: 0.08)
                                : AmanahColorTokens.neutral200),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          t,
                          style: TextStyle(
                            color: isSelected
                                ? (dark
                                    ? AmanahColorTokens.canvasDark
                                    : AmanahColorTokens.surfaceLight)
                                : isDisabled
                                ? (dark
                                    ? AmanahColorTokens.neutral600
                                    : AmanahColorTokens.neutral400)
                                : (dark
                                    ? AmanahColorTokens.pureWhite
                                    : AmanahColorTokens.neutral900),
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : (isDisabled ? FontWeight.w500 : FontWeight.w600),
                          ),
                        ),
                        if (subtitle != null && subtitle.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected
                                  ? (dark
                                      ? AmanahColorTokens.canvasDark.withValues(alpha: 0.8)
                                      : AmanahColorTokens.surfaceLight.withValues(alpha: 0.8))
                                  : (dark
                                      ? AmanahColorTokens.neutral500
                                      : AmanahColorTokens.neutral400),
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ).then((String? selected) {
          if (selected != null) {
            onTimeSelected(selected);
          }
        });
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: dark
              ? AmanahColorTokens.pureWhite.withValues(alpha: 0.05)
              : AmanahColorTokens.surfaceSecondaryLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: dark
                ? AmanahColorTokens.pureWhite.withValues(alpha: 0.10)
                : AmanahColorTokens.neutral200,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(
                selectedStartTime ?? 'Pilih Jam Mulai',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selectedStartTime == null
                      ? (dark
                          ? AmanahColorTokens.neutral500
                          : AmanahColorTokens.neutral400)
                      : (dark
                          ? AmanahColorTokens.pureWhite
                          : AmanahColorTokens.neutral900),
                  fontSize: 13,
                  fontWeight: selectedStartTime == null
                      ? FontWeight.w500
                      : FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AmanahColorTokens.neutral400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class RescheduleRoomPicker extends StatelessWidget {
  const RescheduleRoomPicker({
    required this.availableRooms,
    required this.selectedRoom,
    required this.onRoomSelected,
    required this.dark,
    super.key,
  });

  final List<ClinicRoomReference> availableRooms;
  final ClinicRoomReference? selectedRoom;
  final ValueChanged<ClinicRoomReference> onRoomSelected;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        showAmanahBottomSheet<ClinicRoomReference>(
          context: context,
          builder: (BuildContext ctx) => AmanahBottomSheetScaffold(
            title: 'Pilih Ruang Praktik Target',
            fixedHeightFactor: 0.60,
            bodyPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            body: ListView.separated(
              shrinkWrap: true,
              itemCount: availableRooms.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 6),
              itemBuilder: (BuildContext context, int index) {
                final ClinicRoomReference room = availableRooms[index];
                final bool isSelected = room.id == selectedRoom?.id;
                final bool isOccupied = room.isOccupied;
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.of(ctx).pop(room),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (dark
                              ? AmanahColorTokens.tabActiveDark
                              : AmanahColorTokens.brand)
                          : (dark
                              ? AmanahColorTokens.pureWhite.withValues(alpha: 0.04)
                              : AmanahColorTokens.surfaceLight),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? (dark
                                ? AmanahColorTokens.tabActiveDark
                                : AmanahColorTokens.brand)
                            : (dark
                                ? AmanahColorTokens.pureWhite.withValues(alpha: 0.08)
                                : AmanahColorTokens.neutral200),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                room.name,
                                style: TextStyle(
                                  color: isSelected
                                      ? (dark
                                          ? AmanahColorTokens.canvasDark
                                          : AmanahColorTokens.surfaceLight)
                                      : (dark
                                          ? AmanahColorTokens.pureWhite
                                          : AmanahColorTokens.neutral900),
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                ),
                              ),
                              if (isOccupied) ...<Widget>[
                                const SizedBox(height: 2),
                                Text(
                                  'Sedang Terpakai',
                                  style: TextStyle(
                                    color: isSelected
                                        ? (dark
                                            ? AmanahColorTokens.canvasDark.withValues(alpha: 0.8)
                                            : AmanahColorTokens.surfaceLight.withValues(alpha: 0.8))
                                        : AmanahColorTokens.warning,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: dark
                                ? AmanahColorTokens.canvasDark
                                : AmanahColorTokens.surfaceLight,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ).then((ClinicRoomReference? selected) {
          if (selected != null) {
            onRoomSelected(selected);
          }
        });
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: dark
              ? AmanahColorTokens.pureWhite.withValues(alpha: 0.05)
              : AmanahColorTokens.surfaceSecondaryLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: dark
                ? AmanahColorTokens.pureWhite.withValues(alpha: 0.10)
                : AmanahColorTokens.neutral200,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(
                selectedRoom?.name ?? 'Pilih Ruang Praktik',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selectedRoom == null
                      ? (dark
                          ? AmanahColorTokens.neutral500
                          : AmanahColorTokens.neutral400)
                      : (dark
                          ? AmanahColorTokens.pureWhite
                          : AmanahColorTokens.neutral900),
                  fontSize: 13,
                  fontWeight: selectedRoom == null
                      ? FontWeight.w500
                      : FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AmanahColorTokens.neutral400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

void showRescheduleErrorDialog(
  BuildContext context,
  String message, {
  String? title,
}) {
  showAmanahBottomSheet<void>(
    context: context,
    builder: (BuildContext ctx) {
      final bool dark = Theme.of(ctx).brightness == Brightness.dark;
      return AmanahBottomSheetScaffold(
        title: title ?? 'Peringatan Reschedule',
        subtitle: 'Validasi Sistem Manajemen Praktik',
        maxHeightFactor: 0.45,
        footer: AmanahButton.primary(
          text: 'Mengerti',
          isFullWidth: true,
          onPressed: () => Navigator.of(ctx).pop(),
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AmanahColorTokens.warning.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AmanahColorTokens.warning.withValues(alpha: 0.40),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(
                Icons.warning_amber_rounded,
                color: AmanahColorTokens.warning,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: dark
                        ? AmanahColorTokens.pureWhite
                        : AmanahColorTokens.neutral900,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
