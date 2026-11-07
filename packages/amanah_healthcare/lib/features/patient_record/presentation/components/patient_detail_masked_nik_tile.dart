import 'dart:async';
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/patient_record/presentation/components/patient_detail_grouped_card.dart';

/// Interactive clinical list tile for sensitive NIK display with 100% Web Parity.
/// - Fully masked by default (16 bullet dots: `••••••••••••••••`)
/// - Trailing eye visibility toggle button
/// - Automatic re-masking countdown timer (15 seconds)
class PatientDetailMaskedNikTile extends StatefulWidget {
  const PatientDetailMaskedNikTile({
    super.key,
    required this.nik,
    this.label = 'Nomor Induk Kependudukan (NIK)',
    this.icon = Icons.badge_outlined,
    required this.isDark,
    this.showDivider = true,
    this.autoMaskSeconds = 15,
  });

  final String? nik;
  final String label;
  final IconData icon;
  final bool isDark;
  final bool showDivider;
  final int autoMaskSeconds;

  @override
  State<PatientDetailMaskedNikTile> createState() => _PatientDetailMaskedNikTileState();
}

class _PatientDetailMaskedNikTileState extends State<PatientDetailMaskedNikTile> {
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

    final Color primaryColor = widget.isDark
        ? AmanahColorTokens.surfaceLight
        : AmanahColorTokens.neutral900;
    final Color secondaryColor = widget.isDark
        ? AmanahColorTokens.neutral400
        : AmanahColorTokens.neutral500;
    final Color iconColor = widget.isDark
        ? AmanahColorTokens.neutral400
        : AmanahColorTokens.neutral600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                widget.icon,
                size: 20,
                color: iconColor,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      displayValue,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: _isRevealed ? 0.3 : 1.2,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: secondaryColor,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Visibility action controls
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (_isRevealed && _countdown != null && _countdown! > 0)
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: widget.isDark
                            ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.10)
                            : AmanahColorTokens.neutral100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${_countdown}s',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: widget.isDark
                              ? AmanahColorTokens.cyanLight
                              : AmanahColorTokens.brand,
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
                                  ? (widget.isDark
                                      ? AmanahColorTokens.cyanLight
                                      : AmanahColorTokens.brand)
                                  : secondaryColor)
                              : secondaryColor.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (widget.showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child: Divider(
              height: 1,
              thickness: 1,
              color: widget.isDark
                  ? AmanahColorTokens.neutral800.withValues(alpha: 0.6)
                  : AmanahColorTokens.neutral100,
            ),
          ),
      ],
    );
  }
}
