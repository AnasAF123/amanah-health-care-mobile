import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

enum AmanahBannerType { error, success, info, warning }

class AmanahBottomBanner {
  AmanahBottomBanner._();

  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  static void show(
    BuildContext context, {
    required String message,
    AmanahBannerType type = AmanahBannerType.info,
    Duration duration = const Duration(milliseconds: 3500),
  }) {
    dismiss();

    final OverlayState overlay = Overlay.of(context, rootOverlay: true);

    final OverlayEntry entry = OverlayEntry(
      builder: (BuildContext ctx) => _AmanahBottomBannerWidget(
        message: message,
        type: type,
        onDismiss: dismiss,
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);

    _dismissTimer = Timer(duration, () {
      dismiss();
    });
  }

  static void error(BuildContext context, {required String message}) {
    show(context, message: message, type: AmanahBannerType.error);
  }

  static void success(BuildContext context, {required String message}) {
    show(context, message: message, type: AmanahBannerType.success);
  }

  static void info(BuildContext context, {required String message}) {
    show(context, message: message, type: AmanahBannerType.info);
  }

  static void warning(BuildContext context, {required String message}) {
    show(context, message: message, type: AmanahBannerType.warning);
  }

  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _AmanahBottomBannerWidget extends StatefulWidget {
  const _AmanahBottomBannerWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  final String message;
  final AmanahBannerType type;
  final VoidCallback onDismiss;

  @override
  State<_AmanahBottomBannerWidget> createState() =>
      _AmanahBottomBannerWidgetState();
}

class _AmanahBottomBannerWidgetState extends State<_AmanahBottomBannerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _accentColor => switch (widget.type) {
        AmanahBannerType.error => const Color(0xFFEF4444),
        AmanahBannerType.success => const Color(0xFF10B981),
        AmanahBannerType.info => const Color(0xFF0284C7),
        AmanahBannerType.warning => const Color(0xFFF59E0B),
      };

  IconData get _icon => switch (widget.type) {
        AmanahBannerType.error => Icons.error_outline_rounded,
        AmanahBannerType.success => Icons.check_circle_outline_rounded,
        AmanahBannerType.info => Icons.info_outline_rounded,
        AmanahBannerType.warning => Icons.warning_amber_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.paddingOf(context).bottom + 24;

    return Positioned(
      bottom: bottomPadding,
      left: 20,
      right: 20,
      child: Material(
        type: MaterialType.transparency,
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: widget.onDismiss,
              onVerticalDragUpdate: (DragUpdateDetails details) {
                if (details.primaryDelta != null && details.primaryDelta! > 4) {
                  widget.onDismiss();
                }
              },
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 440),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF18181B).withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _accentColor.withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 20,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(_icon, color: _accentColor, size: 20),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              widget.message,
                              style: const TextStyle(
                                color: Color(0xFFF4F4F5),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
