import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:amanah_healthcare/core/feedback/feedback.dart';

enum AmanahToastType { error, success, info }

class AmanahToaster {
  AmanahToaster._();

  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  static void show(
    BuildContext context, {
    required String message,
    AmanahToastType type = AmanahToastType.info,
    Duration duration = const Duration(milliseconds: 3500),
    bool needVibration = true,
  }) {
    dismiss();

    switch (type) {
      case AmanahToastType.success:
        unawaited(DefaultFeedbackService.instance.notifySuccess(needVibration: needVibration));
      case AmanahToastType.error:
        unawaited(DefaultFeedbackService.instance.notifyException(needVibration: needVibration));
      case AmanahToastType.info:
        unawaited(DefaultFeedbackService.instance.notifySystem(needVibration: needVibration));
    }

    final OverlayState overlay =
        Overlay.of(context, rootOverlay: true);

    final OverlayEntry entry = OverlayEntry(
      builder: (BuildContext ctx) => _AmanahToastWidget(
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
    show(context, message: message, type: AmanahToastType.error);
  }

  static void success(BuildContext context, {required String message}) {
    show(context, message: message, type: AmanahToastType.success);
  }

  static void info(BuildContext context, {required String message}) {
    show(context, message: message, type: AmanahToastType.info);
  }

  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _AmanahToastWidget extends StatefulWidget {
  const _AmanahToastWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  final String message;
  final AmanahToastType type;
  final VoidCallback onDismiss;

  @override
  State<_AmanahToastWidget> createState() => _AmanahToastWidgetState();
}

class _AmanahToastWidgetState extends State<_AmanahToastWidget>
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
      begin: const Offset(0, -0.6),
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
        AmanahToastType.error => const Color(0xFFEF4444),
        AmanahToastType.success => const Color(0xFF10B981),
        AmanahToastType.info => const Color(0xFF0284C7),
      };

  IconData get _icon => switch (widget.type) {
        AmanahToastType.error => Icons.error_outline_rounded,
        AmanahToastType.success => Icons.check_circle_outline_rounded,
        AmanahToastType.info => Icons.info_outline_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.paddingOf(context).top + 12;

    return Positioned(
      top: topPadding,
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
                if (details.primaryDelta != null && details.primaryDelta! < -4) {
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
                        vertical: 12,
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
                            offset: const Offset(0, 8),
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
