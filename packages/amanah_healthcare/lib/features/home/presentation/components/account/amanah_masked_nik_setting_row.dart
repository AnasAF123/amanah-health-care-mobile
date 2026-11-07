import 'dart:async';
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/patient_record/presentation/components/patient_detail_grouped_card.dart';

/// Interactive Settings Row for NIK with full masking, eye toggle, and auto-mask timer.
/// Seamlessly pairs with [AmanahSettingSection].
class AmanahMaskedNikSettingRow extends StatefulWidget {
  const AmanahMaskedNikSettingRow({
    super.key,
    required this.nik,
    this.label = 'NIK (Nomor Induk Kependudukan)',
    required this.onEdit,
    this.autoMaskSeconds = 15,
  });

  final String? nik;
  final String label;
  final VoidCallback onEdit;
  final int autoMaskSeconds;

  @override
  State<AmanahMaskedNikSettingRow> createState() => _AmanahMaskedNikSettingRowState();
}

class _AmanahMaskedNikSettingRowState extends State<AmanahMaskedNikSettingRow> {
  bool _isRevealed = false;
  int? _countdown;
  Timer? _timer;
  Timer? _periodicTimer;

  @override
  void dispose() {
    _clearTimers();
    super.dispose();
  }

  void _clearTimers() {
    _timer?.cancel();
    _timer = null;
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  void _toggleReveal() {
    if (_isRevealed) {
      _clearTimers();
      setState(() {
        _isRevealed = false;
        _countdown = null;
      });
      return;
    }

    _clearTimers();
    setState(() {
      _isRevealed = true;
      _countdown = widget.autoMaskSeconds;
    });

    _periodicTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_countdown != null && _countdown! > 1) {
          _countdown = _countdown! - 1;
        } else {
          _countdown = null;
        }
      });
    });

    _timer = Timer(Duration(seconds: widget.autoMaskSeconds), () {
      if (!mounted) return;
      _clearTimers();
      setState(() {
        _isRevealed = false;
        _countdown = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final String raw = widget.nik?.trim() ?? '';
    final String displayValue = _isRevealed
        ? (raw.isNotEmpty ? raw : '-')
        : PatientDataMasker.maskNik(raw);

    final Color labelColor = AmanahThemeTokens.textTertiary(context);
    final Color valueColor = AmanahThemeTokens.textPrimary(context);
    final Color actionColor = AmanahThemeTokens.textTertiary(context);

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: <Widget>[
            Expanded(
              child: InkWell(
                onTap: widget.onEdit,
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: labelColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayValue,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: valueColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: _isRevealed ? 0.3 : 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Eye toggle button with timer badge
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (_isRevealed && _countdown != null && _countdown! > 0)
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AmanahThemeTokens.surfaceHighlight(context),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AmanahThemeTokens.outline(context),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${_countdown}s',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AmanahThemeTokens.accent(context),
                      ),
                    ),
                  ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: raw.isNotEmpty ? _toggleReveal : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        _isRevealed ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 19,
                        color: raw.isNotEmpty
                            ? (_isRevealed
                                ? AmanahThemeTokens.accent(context)
                                : actionColor)
                            : actionColor.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onEdit,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: actionColor.withValues(alpha: 0.50),
                      ),
                    ),
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
