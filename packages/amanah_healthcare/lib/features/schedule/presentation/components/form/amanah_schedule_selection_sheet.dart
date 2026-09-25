import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/slot_occupied_info.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/drawers/amanah_slot_occupied_detail_drawer.dart';

class AmanahScheduleSelectionSheet extends StatefulWidget {
  const AmanahScheduleSelectionSheet({
    required this.title,
    required this.subtitle,
    required this.currentValue,
    required this.options,
    this.disabledOptions = const <String>[],
    this.optionSubtitles = const <String, String>{},
    this.occupiedDetails = const <String, SlotOccupiedInfo>{},
    this.sessionId,
    this.isTimePicker = false,
    super.key,
  });

  final String title;
  final String subtitle;
  final String currentValue;
  final List<String> options;
  final List<String> disabledOptions;
  final Map<String, String> optionSubtitles;
  final Map<String, SlotOccupiedInfo> occupiedDetails;
  final String? sessionId;
  final bool isTimePicker;

  @override
  State<AmanahScheduleSelectionSheet> createState() =>
      _AmanahScheduleSelectionSheetState();
}

class _AmanahScheduleSelectionSheetState
    extends State<AmanahScheduleSelectionSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final String query = _controller.text.trim().toLowerCase();
    final List<String> filtered = widget.options
        .where((String option) => option.toLowerCase().contains(query))
        .toList();
    final Color selectedAccent = dark
        ? AmanahColorTokens.tabActiveDark
        : AmanahColorTokens.brand;
    final Color selectedForeground = dark
        ? AmanahColorTokens.canvasDark
        : AmanahColorTokens.surfaceLight;

    return AmanahBottomSheetScaffold(
      title: widget.title,
      subtitle: widget.subtitle.isEmpty ? null : widget.subtitle,
      fixedHeightFactor: 0.85,
      bodyPadding: EdgeInsets.zero,
      extendBodyBehindHeader: true,
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          AmanahSpacing.xxl,
          AmanahSpacing.lg,
          AmanahSpacing.xxl,
          AmanahSpacing.xxl + MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (!widget.isTimePicker) ...<Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: dark
                            ? AmanahColorTokens.pureWhite.withValues(
                                alpha: 0.05,
                              )
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: dark
                              ? AmanahColorTokens.pureWhite.withValues(
                                  alpha: 0.15,
                                )
                              : AmanahColorTokens.neutral200,
                        ),
                      ),
                      child: TextField(
                        controller: _controller,
                        textAlignVertical: TextAlignVertical.center,
                        onChanged: (String val) => setState(() {}),
                        style: TextStyle(
                          color: dark
                              ? AmanahColorTokens.pureWhite
                              : AmanahColorTokens.neutral900,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          isCollapsed: true,
                          hintText: 'Cari atau ketik manual...',
                          hintStyle: TextStyle(
                            color: dark
                                ? AmanahColorTokens.neutral500
                                : AmanahColorTokens.neutral400,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            size: 18,
                            color: AmanahColorTokens.neutral400,
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 38,
                            minHeight: 40,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 11,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_controller.text.trim().isNotEmpty) ...<Widget>[
                    const SizedBox(width: 8),
                    AmanahButton.primary(
                      text: 'Gunakan',
                      size: AmanahButtonSize.small,
                      onPressed: () {
                        Navigator.of(context).pop(_controller.text.trim());
                      },
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
            ],
            Text(
              widget.isTimePicker ? 'Pilihan Waktu Shift' : 'Pilihan Tersedia',
              style: TextStyle(
                color: dark
                    ? AmanahColorTokens.neutral400
                    : AmanahColorTokens.neutral500,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada pilihan ditemukan',
                        style: TextStyle(
                          color: AmanahColorTokens.neutral400,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: filtered.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent:
                            widget.optionSubtitles.isNotEmpty ? 52 : 44,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        final String option = filtered[index];
                        final bool isPlaceholder =
                            widget.currentValue.trim().isEmpty ||
                            widget.currentValue == 'Pilih Jam' ||
                            widget.currentValue == 'Pilih Ruang Praktik' ||
                            widget.currentValue == 'Pilih Poliklinik' ||
                            widget.currentValue == '-';
                        final bool isDisabled =
                            widget.disabledOptions.any(
                              (String d) =>
                                  d.trim().toLowerCase() ==
                                  option.trim().toLowerCase(),
                            );
                        final bool isSelected =
                            !isPlaceholder &&
                            !isDisabled &&
                            widget.currentValue.trim().toLowerCase() ==
                                option.trim().toLowerCase();
                        final String? subtitle = widget.optionSubtitles[option];

                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: isDisabled
                              ? () {
                                  final SlotOccupiedInfo? info =
                                      widget.occupiedDetails[option];
                                  AmanahSlotOccupiedDetailDrawer.show(
                                    context,
                                    time: option,
                                    info: info,
                                    subtitle: subtitle,
                                  );
                                }
                              : () => Navigator.of(context).pop(option),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 140),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? selectedAccent
                                  : isDisabled
                                  ? (dark
                                      ? AmanahColorTokens.pureWhite
                                          .withValues(alpha: 0.02)
                                      : AmanahColorTokens.neutral100)
                                  : (dark
                                      ? AmanahColorTokens.pureWhite
                                          .withValues(alpha: 0.05)
                                      : AmanahColorTokens.surfaceLight),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? selectedAccent
                                    : (dark
                                        ? AmanahColorTokens.pureWhite
                                            .withValues(alpha: 0.10)
                                        : AmanahColorTokens.neutral200),
                              ),
                              boxShadow: isSelected
                                  ? <BoxShadow>[
                                      BoxShadow(
                                        color: selectedAccent.withValues(
                                          alpha: 0.25,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        option,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: isSelected
                                              ? selectedForeground
                                              : isDisabled
                                              ? (dark
                                                  ? AmanahColorTokens.neutral600
                                                  : AmanahColorTokens.neutral400)
                                              : (dark
                                                  ? AmanahColorTokens.pureWhite
                                                  : AmanahColorTokens.neutral900),
                                          fontSize: 12,
                                          fontWeight: isSelected
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                        ),
                                      ),
                                      if (subtitle != null &&
                                          subtitle.isNotEmpty) ...<Widget>[
                                        const SizedBox(height: 2),
                                        Text(
                                          subtitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: isSelected
                                                ? selectedForeground
                                                    .withValues(alpha: 0.8)
                                                : (dark
                                                    ? AmanahColorTokens.neutral500
                                                    : AmanahColorTokens.neutral400),
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 15,
                                    color: selectedForeground,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
