import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_empty_state.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/doctor_roster.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/weekly_schedule_accordion.dart';
import 'package:amanah_healthcare/features/schedule/presentation/state/schedule_roster_controller.dart';

class DoctorScheduleRosterSheet extends StatefulWidget {
  const DoctorScheduleRosterSheet({
    this.controller,
    this.isAdmin = false,
    super.key,
  });

  final ScheduleRosterController? controller;
  final bool isAdmin;

  static Future<void> show(
    BuildContext context, {
    ScheduleRosterController? controller,
    bool isAdmin = false,
  }) {
    return showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => DoctorScheduleRosterSheet(
        controller: controller,
        isAdmin: isAdmin,
      ),
    );
  }

  @override
  State<DoctorScheduleRosterSheet> createState() => _DoctorScheduleRosterSheetState();
}

class _DoctorScheduleRosterSheetState extends State<DoctorScheduleRosterSheet> {
  late final ScheduleRosterController _controller;
  bool _ownsController = false;
  DateTime? _focusedDate;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = ScheduleRosterController();
      _ownsController = true;
    }
    _controller.loadRoster();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: _controller,
      builder: (BuildContext context, _) {
        final DoctorRoster? roster = _controller.roster;
        final bool hasNoSessions = roster == null ||
            roster.days.isEmpty ||
            roster.days.every((DoctorRosterDay d) => d.sessions.isEmpty);

        return AmanahBottomSheetScaffold(
          title: 'Pengaturan Jadwal Shift',
          maxHeightFactor: 0.90,
          minHeight: 520,
          trailing: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () async {
              final DateTime now = DateTime.now();
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _focusedDate ?? now,
                firstDate: now.subtract(const Duration(days: 365)),
                lastDate: now.add(const Duration(days: 365)),
                builder: (BuildContext ctx, Widget? child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.fromSeed(
                        seedColor: dark ? AmanahColorTokens.tabActiveDark : AmanahColorTokens.brand,
                        brightness: dark ? Brightness.dark : Brightness.light,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null && mounted) {
                setState(() {
                  _focusedDate = picked;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _focusedDate != null
                    ? (dark
                          ? AmanahColorTokens.tabActiveDark.withValues(alpha: 0.15)
                          : AmanahColorTokens.brand.withValues(alpha: 0.12))
                    : (dark ? AmanahColorTokens.neutral800 : AmanahColorTokens.neutral100),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _focusedDate != null
                      ? (dark
                            ? AmanahColorTokens.tabActiveDark.withValues(alpha: 0.4)
                            : AmanahColorTokens.brand.withValues(alpha: 0.35))
                      : (dark ? AmanahColorTokens.neutral700 : AmanahColorTokens.neutral200),
                ),
              ),
              child: Icon(
                Icons.calendar_month_outlined,
                size: 19,
                color: _focusedDate != null
                    ? (dark ? AmanahColorTokens.tabActiveDark : AmanahColorTokens.brand)
                    : (dark ? AmanahColorTokens.neutral300 : AmanahColorTokens.neutral700),
              ),
            ),
          ),
          body: _controller.isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: CircularProgressIndicator(),
                  ),
                )
              : _controller.errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 40,
                          color: AmanahColorTokens.danger,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _controller.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, color: AmanahColorTokens.danger),
                        ),
                        const SizedBox(height: 16),
                        AmanahButton.secondary(
                          text: 'Coba Lagi',
                          size: AmanahButtonSize.small,
                          onPressed: _controller.loadRoster,
                        ),
                      ],
                    ),
                  ),
                )
              : hasNoSessions
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: AmanahEmptyState.box(
                    title: 'Belum Ada Shift Operasional',
                    message:
                        'Klinik belum memiliki master shift atau jadwal operasional yang terdaftar.',
                    variant: AmanahEmptyStateVariant.viewport,
                  ),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
                  child: WeeklyScheduleAccordion(
                    controller: _controller,
                    focusedDate: _focusedDate,
                    onClearFocusedDate: () {
                      setState(() {
                        _focusedDate = null;
                      });
                    },
                  ),
                ),
          footer: _controller.isLoading ||
                  _controller.errorMessage != null ||
                  hasNoSessions
              ? null
              : Row(
                  children: <Widget>[
                    if (widget.isAdmin && _controller.isOverride) ...<Widget>[
                      Expanded(
                        child: AmanahButton.secondary(
                          text: 'Reset Template',
                          isLoading: _controller.isResetting,
                          size: AmanahButtonSize.medium,
                          onPressed: () async {
                            final bool ok = await _controller.resetAllToTemplate(context);
                            if (ok && context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: AmanahButton.primary(
                        text: 'Simpan',
                        isLoading: _controller.isSaving,
                        isDisabled: !_controller.hasUnsavedChanges,
                        size: AmanahButtonSize.medium,
                        onPressed: () async {
                          final bool ok = await _controller.saveOverrides(context);
                          if (ok && context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
