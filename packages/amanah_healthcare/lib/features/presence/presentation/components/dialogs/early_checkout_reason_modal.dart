import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Modal bottom sheet presented when staff attempts early check-out,
/// requiring a mandatory reason note before attendance calculation.
class EarlyCheckoutReasonModal extends StatefulWidget {
  const EarlyCheckoutReasonModal({
    super.key,
    this.initialReason,
  });

  final String? initialReason;

  static Future<String?> show(
    BuildContext context, {
    String? initialReason,
  }) {
    return showAmanahBottomSheet<String>(
      context: context,
      builder: (BuildContext ctx) => EarlyCheckoutReasonModal(
        initialReason: initialReason,
      ),
    );
  }

  @override
  State<EarlyCheckoutReasonModal> createState() =>
      _EarlyCheckoutReasonModalState();
}

class _EarlyCheckoutReasonModalState extends State<EarlyCheckoutReasonModal> {
  late final TextEditingController _textController;
  String _selectedChip = '';

  static const List<String> _quickReasons = <String>[
    'Sakit Mendadak',
    'Keperluan Mendesak',
    'Tugas Luar / Rujukan',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialReason ?? '');
    if (widget.initialReason != null &&
        _quickReasons.contains(widget.initialReason)) {
      _selectedChip = widget.initialReason!;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onChipSelected(String reason) {
    setState(() {
      _selectedChip = reason;
      if (reason != 'Lainnya') {
        _textController.text = reason;
      } else {
        _textController.clear();
      }
    });
  }

  void _submit() {
    final String text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Mohon masukkan alasan kepulangan lebih awal.',
            style: TextStyle(fontSize: 12),
          ),
          backgroundColor: AmanahColorTokens.destructive,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final Color surfaceColor =
        dark ? AmanahColorTokens.cardDark : AmanahColorTokens.surfaceLight;
    final Color textColor =
        dark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.neutral900;
    final Color subtextColor =
        dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral600;
    final Color borderColor = dark
        ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.12)
        : AmanahColorTokens.neutral200;

    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Grab handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: dark
                      ? AmanahColorTokens.neutral700
                      : AmanahColorTokens.neutral300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header with Alert Icon
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AmanahColorTokens.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: AmanahColorTokens.warning,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Konfirmasi Pulang Cepat',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Jadwal shift dinas Anda belum selesai',
                        style: TextStyle(
                          fontSize: 12,
                          color: subtextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'Anda melakukan presensi pulang sebelum jendela normal dinas. Catatan alasan kepulangan wajib diisi untuk verifikasi:',
              style: TextStyle(
                fontSize: 12.5,
                color: subtextColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),

            // Quick Reason Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickReasons.map((String reason) {
                final bool isSelected = _selectedChip == reason;
                return ChoiceChip(
                  label: Text(
                    reason,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AmanahColorTokens.brand
                          : textColor,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) => _onChipSelected(reason),
                  selectedColor:
                      AmanahColorTokens.brand.withValues(alpha: 0.12),
                  backgroundColor: dark
                      ? AmanahColorTokens.surfaceDark
                      : AmanahColorTokens.neutral100,
                  side: BorderSide(
                    color: isSelected
                        ? AmanahColorTokens.brand
                        : borderColor,
                    width: isSelected ? 1.4 : 1.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  showCheckmark: false,
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Text Field
            TextField(
              controller: _textController,
              maxLines: 3,
              style: TextStyle(fontSize: 13, color: textColor),
              decoration: InputDecoration(
                hintText: 'Tuliskan rincian alasan izin pulang awal...',
                hintStyle: TextStyle(fontSize: 12, color: subtextColor),
                contentPadding: const EdgeInsets.all(12),
                filled: true,
                fillColor: dark
                    ? AmanahColorTokens.surfaceDark
                    : AmanahColorTokens.neutral50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AmanahColorTokens.brand,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Buttons
            Row(
              children: <Widget>[
                Expanded(
                  child: AmanahButton(
                    text: 'Batal',
                    variant: AmanahButtonVariant.outline,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AmanahButton(
                    text: 'Kirim Checkout',
                    variant: AmanahButtonVariant.primary,
                    leadingIcon: Icons.logout_rounded,
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
