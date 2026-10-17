import 'dart:async' as async;
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_queue_data.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_genie_effect.dart';

class AmanahQueueDockAnimator {
  final TickerProvider vsync;
  final VoidCallback onStateChange;

  AmanahQueueDockAnimator({
    required this.vsync,
    required this.onStateChange,
  });

  String activationStage = 'idle';
  String ejectionStage = 'idle';
  bool showSuccess = false;
  bool isGenieSettled = false;
  bool isGenieRunning = false;
  AmanahQueueCardData? selectedActiveCard;

  AnimationController? genieController;
  ui.Image? genieSnapshot;
  AmanahGenieDirection genieDirection = AmanahGenieDirection.open;

  final List<async.Timer> _ejectionTimers = <async.Timer>[];

  void clearEjectionTimers() {
    for (final async.Timer t in _ejectionTimers) {
      t.cancel();
    }
    _ejectionTimers.clear();
  }

  void disposeGenieController() {
    if (genieController != null) {
      genieController!.stop();
      genieController!.dispose();
      genieController = null;
    }
  }

  void dispose() {
    clearEjectionTimers();
    disposeGenieController();
    genieSnapshot?.dispose();
    genieSnapshot = null;
  }

  Future<void> triggerPlunge({
    required BuildContext context,
    required AmanahQueueCardData card,
    required Future<void> Function() onCallBackend,
  }) async {
    if (activationStage != 'idle' || isGenieRunning) {
      return;
    }
    final Size screenSize = MediaQuery.sizeOf(context);
    final double cardW = math.min(screenSize.width - 64, 320.0);
    final double cardH = cardW / 0.718;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    disposeGenieController();

    selectedActiveCard = card;
    activationStage = 'plunging';
    ejectionStage = 'atm_plunge';
    HapticFeedback.heavyImpact();
    onStateChange();

    await Future<void>.delayed(const Duration(milliseconds: 450));
    activationStage = 'activating';
    ejectionStage = 'idle';
    onStateChange();

    await onCallBackend();

    await Future<void>.delayed(const Duration(milliseconds: 1800));

    final ui.Image coverSnapshot = await generateCardCoverSnapshot(
      card: card,
      size: Size(cardW, cardH),
      isDark: isDark,
    );

    genieSnapshot?.dispose();
    genieSnapshot = coverSnapshot;
    genieDirection = AmanahGenieDirection.open;
    isGenieRunning = true;
    showSuccess = true;
    isGenieSettled = false;
    activationStage = 'idle';

    genieController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 600),
    );

    genieController!.addListener(onStateChange);
    genieController!.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        isGenieRunning = false;
        async.Timer(const Duration(milliseconds: 300), () {
          if (showSuccess) {
            isGenieSettled = true;
            onStateChange();
          }
        });
        disposeGenieController();
      }
    });

    genieController!.forward();
    onStateChange();
  }

  Future<void> closeOverlay({
    required BuildContext context,
    required VoidCallback onDismissComplete,
  }) async {
    if (isGenieRunning || selectedActiveCard == null) {
      return;
    }
    final Size screenSize = MediaQuery.sizeOf(context);
    final double cardW = math.min(screenSize.width - 64, 320.0);
    final double cardH = cardW / 0.718;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    disposeGenieController();
    isGenieSettled = false;
    onStateChange();

    final ui.Image coverSnapshot = await generateCardCoverSnapshot(
      card: selectedActiveCard!,
      size: Size(cardW, cardH),
      isDark: isDark,
    );

    genieSnapshot?.dispose();
    genieSnapshot = coverSnapshot;
    genieDirection = AmanahGenieDirection.minimize;
    isGenieRunning = true;

    genieController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 600),
    );

    genieController!.addListener(onStateChange);
    genieController!.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        isGenieRunning = false;
        showSuccess = false;
        activationStage = 'idle';
        ejectionStage = 'dock_appear';
        startEjectionChoreography();
        onDismissComplete();
        disposeGenieController();
      }
    });

    genieController!.forward();
    onStateChange();
  }

  void startEjectionChoreography() {
    clearEjectionTimers();

    _ejectionTimers.add(
      async.Timer(const Duration(milliseconds: 200), () {
        ejectionStage = 'rail_converge';
        onStateChange();
      }),
    );

    _ejectionTimers.add(
      async.Timer(const Duration(milliseconds: 850), () {
        ejectionStage = 'atm_peek';
        HapticFeedback.lightImpact();
        onStateChange();
      }),
    );

    _ejectionTimers.add(
      async.Timer(const Duration(milliseconds: 1350), () {
        ejectionStage = 'full_eject';
        onStateChange();
      }),
    );

    _ejectionTimers.add(
      async.Timer(const Duration(milliseconds: 2000), () {
        ejectionStage = 'idle';
        selectedActiveCard = null;
        HapticFeedback.mediumImpact();
        onStateChange();
      }),
    );
  }
}
