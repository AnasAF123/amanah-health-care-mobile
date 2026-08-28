import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_app/features/schedule/data/amanah_schedule_store.dart';
import 'package:smooth_app/features/schedule/domain/amanah_schedule_model.dart';
import 'package:smooth_app/features/schedule/presentation/components/amanah_schedule_cards_and_drawers.dart';

class AmanahQueueDockScreen extends StatefulWidget {
  const AmanahQueueDockScreen({super.key});

  static Route<void> route() {
    return PageRouteBuilder<void>(
      pageBuilder: (_, _, _) => const AmanahQueueDockScreen(),
      transitionsBuilder:
          (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            return FadeTransition(opacity: animation, child: child);
          },
    );
  }

  @override
  State<AmanahQueueDockScreen> createState() => _AmanahQueueDockScreenState();
}

class _AmanahQueueDockScreenState extends State<AmanahQueueDockScreen> {
  final AmanahScheduleStore _store = AmanahScheduleStore.instance;
  int _currentIndex = 1;
  double _horizontalDrag = 0;
  double _verticalDrag = 0;
  bool _isActivating = false;
  bool _showOverlay = false;
  _QueuePatientEntry? _selectedEntry;

  @override
  void initState() {
    super.initState();
    _store.addListener(_handleStoreChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_handleStoreChanged);
    super.dispose();
  }

  void _handleStoreChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  List<_QueuePatientEntry> get _entries {
    return _store
        .getAllBookedPatientsForDate(AmanahScheduleStore.baseToday)
        .map(
          (({BookedPatient patient, DoctorSchedule schedule}) item) =>
              _QueuePatientEntry(
                patient: item.patient,
                schedule: item.schedule,
              ),
        )
        .toList(growable: false);
  }

  void _moveBy(int delta, int length) {
    if (length == 0) {
      return;
    }
    setState(() {
      _currentIndex = (_currentIndex + delta).clamp(0, length - 1);
      _horizontalDrag = 0;
      _verticalDrag = 0;
    });
  }

  void _activate(_QueuePatientEntry entry) {
    if (_isActivating) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      _selectedEntry = entry;
      _isActivating = true;
      _verticalDrag = 0;
      _horizontalDrag = 0;
    });
    Future<void>.delayed(const Duration(milliseconds: 360), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _isActivating = false;
        _showOverlay = true;
      });
    });
  }

  void _closeOverlay() {
    setState(() {
      _showOverlay = false;
      _selectedEntry = null;
    });
  }

  void _processSelected() {
    final _QueuePatientEntry? selected = _selectedEntry;
    _closeOverlay();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          selected == null
              ? 'Antrean diproses'
              : '${selected.patient.queueNumber} dipanggil untuk diproses',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<_QueuePatientEntry> entries = _entries;
    final int currentIndex = entries.isEmpty
        ? 0
        : _currentIndex.clamp(0, entries.length - 1);
    final _QueuePatientEntry? currentEntry = entries.isEmpty
        ? null
        : entries[currentIndex];
    final bool readyToActivate = _verticalDrag >= 45;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: _QueueAuroraBackground()),
          SafeArea(
            child: Column(
              children: <Widget>[
                _QueueDockHeader(
                  title: _isActivating
                      ? 'Memproses antrean'
                      : readyToActivate
                      ? 'Lepaskan untuk proses antrean'
                      : 'Pilih antrean pasien',
                  onBack: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 12),
                _QueueDockTopLabel(totalCount: entries.length),
                Expanded(
                  child: entries.isEmpty
                      ? const _QueueEmptyState()
                      : GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onHorizontalDragUpdate: (DragUpdateDetails details) {
                            setState(() {
                              _horizontalDrag += details.delta.dx;
                            });
                          },
                          onHorizontalDragEnd: (DragEndDetails details) {
                            final double velocity =
                                details.primaryVelocity ?? 0;
                            if (_horizontalDrag < -48 || velocity < -480) {
                              _moveBy(1, entries.length);
                            } else if (_horizontalDrag > 48 || velocity > 480) {
                              _moveBy(-1, entries.length);
                            } else {
                              setState(() => _horizontalDrag = 0);
                            }
                          },
                          onVerticalDragUpdate: (DragUpdateDetails details) {
                            setState(() {
                              _verticalDrag = (_verticalDrag + details.delta.dy)
                                  .clamp(0, 120);
                            });
                          },
                          onVerticalDragEnd: (_) {
                            if (_verticalDrag >= 45 && currentEntry != null) {
                              _activate(currentEntry);
                            } else {
                              setState(() => _verticalDrag = 0);
                            }
                          },
                          onTap: currentEntry == null
                              ? null
                              : () => _activate(currentEntry),
                          child: _QueueDockDeck(
                            entries: entries,
                            currentIndex: currentIndex,
                            horizontalDrag: _horizontalDrag,
                            verticalDrag: _verticalDrag,
                            isActivating: _isActivating,
                          ),
                        ),
                ),
                _BottomNotchedDock(isArmed: readyToActivate),
              ],
            ),
          ),
          if (_showOverlay && _selectedEntry != null)
            _QueueActivationOverlay(
              entry: _selectedEntry!,
              onClose: _closeOverlay,
              onProcess: _processSelected,
              onOpenDetail: () => AmanahPatientDetailModal.show(
                context,
                _selectedEntry!.patient,
                _selectedEntry!.schedule,
              ),
            ),
        ],
      ),
    );
  }
}

class _QueuePatientEntry {
  const _QueuePatientEntry({required this.patient, required this.schedule});

  final BookedPatient patient;
  final DoctorSchedule schedule;
}

class _QueueDockHeader extends StatelessWidget {
  const _QueueDockHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
              color: const Color(0xFF1E293B),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Text(
                  title,
                  key: ValueKey<String>(title),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: Color(0xFF1E293B),
              ),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              itemBuilder: (BuildContext context) =>
                  const <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'guide',
                      child: Text('Panduan antrean'),
                    ),
                    PopupMenuItem<String>(
                      value: 'history',
                      child: Text('Riwayat antrean'),
                    ),
                  ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QueueDockTopLabel extends StatelessWidget {
  const _QueueDockTopLabel({required this.totalCount});

  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0xFF0A44FF).withValues(alpha: 0.16),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: const Icon(
            Icons.medical_services_outlined,
            color: Color(0xFF0A44FF),
            size: 24,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '$totalCount antrean tersedia',
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _QueueEmptyState extends StatelessWidget {
  const _QueueEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Belum ada antrean pasien',
        style: TextStyle(
          color: Color(0xFF64748B),
          fontFamily: 'PlusJakartaSans',
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _QueueDockDeck extends StatelessWidget {
  const _QueueDockDeck({
    required this.entries,
    required this.currentIndex,
    required this.horizontalDrag,
    required this.verticalDrag,
    required this.isActivating,
  });

  final List<_QueuePatientEntry> entries;
  final int currentIndex;
  final double horizontalDrag;
  final double verticalDrag;
  final bool isActivating;

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.sizeOf(context);
    final double dragUnits = horizontalDrag / 230;
    final List<Widget> cards = <Widget>[];

    for (int index = 0; index < entries.length; index += 1) {
      final double distance = index - currentIndex - dragUnits;
      if (distance.abs() > 3.2) {
        continue;
      }
      final bool active = index == currentIndex;
      final double angle = distance * 19.5 * math.pi / 180;
      final double translateX = math.sin(angle) * 172;
      final double translateY =
          18 + (1 - math.cos(angle)) * 88 + (active ? verticalDrag : 0);
      final double rotationZ = (distance * 13) * math.pi / 180;
      final double scale = (1 - distance.abs() * 0.055).clamp(0.78, 1.0);
      final double opacity = (1 - distance.abs() * 0.22).clamp(0.24, 1.0);

      cards.add(
        AnimatedPositioned(
          key: ValueKey<String>(entries[index].patient.id),
          duration: const Duration(milliseconds: 210),
          curve: Curves.easeOutCubic,
          left: (screen.width - 212) / 2 + translateX,
          top: 44 + translateY,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: isActivating && active ? 0 : opacity,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateY(-distance * 8 * math.pi / 180)
                ..rotateZ(rotationZ)
                ..scaleByDouble(scale, scale, 1, 1),
              child: _QueueCardMaster(entry: entries[index], revealed: false),
            ),
          ),
        ),
      );
    }

    cards.sort((Widget a, Widget b) {
      final ValueKey<String> aKey = a.key! as ValueKey<String>;
      final ValueKey<String> bKey = b.key! as ValueKey<String>;
      final int aIndex = entries.indexWhere(
        (_QueuePatientEntry entry) => entry.patient.id == aKey.value,
      );
      final int bIndex = entries.indexWhere(
        (_QueuePatientEntry entry) => entry.patient.id == bKey.value,
      );
      return (currentIndex - bIndex).abs().compareTo(
        (currentIndex - aIndex).abs(),
      );
    });

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _QueueRailPainter()),
          ),
        ),
        ...cards,
      ],
    );
  }
}

class _QueueActivationOverlay extends StatelessWidget {
  const _QueueActivationOverlay({
    required this.entry,
    required this.onClose,
    required this.onProcess,
    required this.onOpenDetail,
  });

  final _QueuePatientEntry entry;
  final VoidCallback onClose;
  final VoidCallback onProcess;
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = MediaQuery.paddingOf(context);
    return Positioned.fill(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        builder: (BuildContext context, double value, Widget? child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 18),
              child: child,
            ),
          );
        },
        child: ColoredBox(
          color: const Color(0xF2F8FAFF),
          child: Stack(
            children: <Widget>[
              const Positioned.fill(child: _QueueAuroraBackground()),
              SafeArea(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 56,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: <Widget>[
                            IconButton(
                              onPressed: onClose,
                              icon: const Icon(Icons.arrow_back_rounded),
                              color: const Color(0xFF1E293B),
                            ),
                            const Expanded(
                              child: Text(
                                'Antrean terpilih',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: GestureDetector(
                          onTap: onOpenDetail,
                          child: _QueueCardMaster(entry: entry, revealed: true),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        0,
                        20,
                        24 + padding.bottom,
                      ),
                      child: Column(
                        children: <Widget>[
                          _QueuePrimaryButton(
                            label: 'Panggil & Proses Pasien',
                            icon: Icons.call_made_rounded,
                            onTap: onProcess,
                          ),
                          const SizedBox(height: 12),
                          _QueueSecondaryButton(
                            label: 'Pilih Antrean Lain',
                            onTap: onClose,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QueueCardMaster extends StatelessWidget {
  const _QueueCardMaster({required this.entry, required this.revealed});

  final _QueuePatientEntry entry;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    final double width = revealed
        ? math.min(MediaQuery.sizeOf(context).width - 70, 320)
        : 212;
    final double height = revealed ? width / 0.718 : 335;

    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Colors.white, Color(0xFFF8FAFF), Color(0xFFEDF2FF)],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.80)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: revealed ? 0.18 : 0.12),
              blurRadius: revealed ? 34 : 28,
              offset: Offset(0, revealed ? 18 : 14),
              spreadRadius: -12,
            ),
            BoxShadow(
              color: const Color(0xFF0A44FF).withValues(alpha: 0.10),
              blurRadius: 34,
              offset: const Offset(0, 16),
              spreadRadius: -16,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: <Widget>[
              const Positioned.fill(
                child: CustomPaint(painter: _PixelTexturePainter()),
              ),
              Positioned(
                top: revealed ? -26 : -22,
                left: revealed ? -44 : -36,
                child: CustomPaint(
                  size: Size(revealed ? 210 : 152, revealed ? 210 : 152),
                  painter: const _QueueWatermarkPainter(),
                ),
              ),
              if (revealed) ...<Widget>[
                const Positioned(
                  top: 18,
                  right: 18,
                  child: _QueueStatusPill(label: 'ANTREAN AKTIF'),
                ),
                Positioned(
                  top: 30,
                  left: 20,
                  child: _QueueBadge(
                    number: entry.patient.queueNumber,
                    size: 44,
                  ),
                ),
                Positioned(
                  left: 22,
                  top: 86,
                  child: Text(
                    entry.patient.queueNumber,
                    style: const TextStyle(
                      color: Color(0xFF0A44FF),
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      height: 0.96,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                Positioned(
                  right: -18,
                  top: 78,
                  width: width * 0.62,
                  bottom: 78,
                  child: _PatientHeroImage(patient: entry.patient),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: _QueueCardPatientSummary(entry: entry),
                ),
              ] else ...<Widget>[
                Positioned(
                  top: 18,
                  left: 18,
                  child: _QueueBadge(
                    number: entry.patient.queueNumber,
                    size: 42,
                  ),
                ),
                Center(
                  child: Text(
                    entry.patient.queueNumber,
                    style: const TextStyle(
                      color: Color(0xFF0A44FF),
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      height: 0.9,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 18,
                  child: Text(
                    entry.schedule.poli,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QueueCardPatientSummary extends StatelessWidget {
  const _QueueCardPatientSummary({required this.entry});

  final _QueuePatientEntry entry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 27,
              height: 27,
              decoration: const BoxDecoration(
                color: Color(0xFF0A44FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.north_east_rounded,
                color: Colors.white,
                size: 15,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                entry.patient.patientName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF020617),
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  height: 1.12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Text(
          entry.patient.patientComplaint,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontFamily: 'PlusJakartaSans',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            entry.schedule.poli,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0A44FF),
              fontFamily: 'PlusJakartaSans',
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _PatientHeroImage extends StatelessWidget {
  const _PatientHeroImage({required this.patient});

  final BookedPatient patient;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Image.network(
        patient.avatarUrl ??
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=300&auto=format&fit=crop',
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
          return DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFFDBEAFE), Color(0xFFBFDBFE)],
              ),
            ),
            child: Center(
              child: Text(
                patient.patientName.isEmpty
                    ? 'P'
                    : patient.patientName.substring(0, 1),
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QueueStatusPill extends StatelessWidget {
  const _QueueStatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF1D4ED8),
          fontFamily: 'PlusJakartaSans',
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _QueuePrimaryButton extends StatelessWidget {
  const _QueuePrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFF0A44FF), Color(0xFF2563EB)],
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0xFF0A44FF).withValues(alpha: 0.32),
                blurRadius: 24,
                offset: const Offset(0, 12),
                spreadRadius: -10,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 9),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QueueSecondaryButton extends StatelessWidget {
  const _QueueSecondaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNotchedDock extends StatelessWidget {
  const _BottomNotchedDock({required this.isArmed});

  final bool isArmed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 122,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 84,
            child: CustomPaint(painter: _BottomNotchedDockPainter()),
          ),
          Positioned(
            top: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isArmed ? const Color(0xFF0A44FF) : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isArmed ? const Color(0xFF0A44FF) : Colors.white,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                    spreadRadius: -8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isArmed ? Colors.white : const Color(0xFF0A44FF),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Tarik antrean ke bawah untuk proses',
                    style: TextStyle(
                      color: isArmed ? Colors.white : const Color(0xFF334155),
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueBadge extends StatelessWidget {
  const _QueueBadge({required this.number, required this.size});

  final String number;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 1.18),
      painter: _QueueBadgePainter(number),
    );
  }
}

class _QueueAuroraBackground extends StatelessWidget {
  const _QueueAuroraBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.10),
          radius: 0.86,
          colors: <Color>[
            const Color(0xFFDBEAFE).withValues(alpha: 0.88),
            const Color(0xFFEFF6FF).withValues(alpha: 0.58),
            const Color(0xFFF8FAFF),
          ],
          stops: const <double>[0, 0.50, 1],
        ),
      ),
    );
  }
}

class _QueueRailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFF0A44FF).withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final Path path = Path()
      ..moveTo(size.width * -0.10, size.height * 0.76)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.40,
        size.width * 1.10,
        size.height * 0.76,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PixelTexturePainter extends CustomPainter {
  const _PixelTexturePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint blue = Paint()
      ..color = const Color(0xFF0A44FF).withValues(alpha: 0.09);
    final Paint cyan = Paint()
      ..color = const Color(0xFF00D4FF).withValues(alpha: 0.08);
    for (double y = 22; y < size.height; y += 28) {
      for (double x = 18; x < size.width; x += 30) {
        final bool alternate = ((x + y) ~/ 30).isEven;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, alternate ? 11 : 7, alternate ? 11 : 7),
            const Radius.circular(3),
          ),
          alternate ? blue : cyan,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QueueWatermarkPainter extends CustomPainter {
  const _QueueWatermarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFF0A44FF).withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;
    final Offset center = Offset(size.width * 0.48, size.height * 0.48);
    final double radius = size.shortestSide * 0.28;
    canvas.drawCircle(center, radius, paint);
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.12, size.height * 0.72)
        ..lineTo(size.width * 0.40, size.height * 0.48)
        ..lineTo(size.width * 0.44, size.height * 0.82)
        ..close(),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.54, size.height * 0.14)
        ..lineTo(size.width * 0.90, size.height * 0.20)
        ..lineTo(size.width * 0.62, size.height * 0.50)
        ..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QueueBadgePainter extends CustomPainter {
  const _QueueBadgePainter(this.number);

  final String number;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint shadow = Paint()
      ..color = const Color(0xFF0A44FF).withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final Rect oval = Rect.fromLTWH(
      size.width * 0.11,
      0,
      size.width * 0.78,
      size.width * 0.78,
    );
    canvas.drawOval(oval.shift(const Offset(0, 3)), shadow);

    final Paint fill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF00D4FF), Color(0xFF0A44FF)],
      ).createShader(oval);
    canvas.drawOval(oval, fill);

    final Paint ribbon = Paint()..color = const Color(0xFF0A44FF);
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.27, size.width * 0.58)
        ..lineTo(size.width * 0.43, size.height)
        ..lineTo(size.width * 0.50, size.width * 0.66)
        ..close(),
      ribbon,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.73, size.width * 0.58)
        ..lineTo(size.width * 0.57, size.height)
        ..lineTo(size.width * 0.50, size.width * 0.66)
        ..close(),
      ribbon,
    );

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: number.replaceAll('#', ''),
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'PlusJakartaSans',
          fontSize: 15,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        oval.center.dx - textPainter.width / 2,
        oval.center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _QueueBadgePainter oldDelegate) {
    return oldDelegate.number != number;
  }
}

class _BottomNotchedDockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint base = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color(0xFFE2E8F0),
          Color(0xFFCBD5E1),
          Color(0xFF94A3B8),
        ],
      ).createShader(rect);
    final Path path = Path()
      ..moveTo(0, size.height * 0.40)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.06,
        size.width * 0.50,
        size.height * 0.28,
      )
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.06,
        size.width,
        size.height * 0.40,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, base);

    final Paint cavity = Paint()
      ..color = const Color(0xFF0F172A).withValues(alpha: 0.20)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.40),
        width: 112,
        height: 28,
      ),
      cavity,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
