import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/time/contracts/time_service.dart';
import 'package:amanah_healthcare/core/time/services/default_time_service.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/patient_record/data/repositories/intake_repository_impl.dart';
import 'package:amanah_healthcare/features/patient_record/domain/entities/patient_intake_record.dart';
import 'package:amanah_healthcare/features/patient_record/domain/usecases/get_maternal_history_use_case.dart';

/// Interactive Sub-Drawer Modal dynamically fetching and displaying patient's maternal consultations timeline.
class MaternalTimelineSheet extends StatefulWidget {
  const MaternalTimelineSheet({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.isDark,
    this.timeService,
    this.getMaternalHistoryUseCase,
  });

  final String patientId;
  final String patientName;
  final bool isDark;
  final TimeService? timeService;
  final GetMaternalHistoryUseCase? getMaternalHistoryUseCase;

  static void show(
    BuildContext context, {
    required String patientId,
    required String patientName,
    required bool isDark,
    TimeService? timeService,
  }) {
    showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => MaternalTimelineSheet(
        patientId: patientId,
        patientName: patientName,
        isDark: isDark,
        timeService: timeService,
      ),
    );
  }

  @override
  State<MaternalTimelineSheet> createState() => _MaternalTimelineSheetState();
}

class _MaternalTimelineSheetState extends State<MaternalTimelineSheet> {
  late final GetMaternalHistoryUseCase _useCase;
  late final TimeService _timeService;

  bool _isLoading = true;
  String? _errorMessage;
  List<MaternalTimelineItem> _timeline = const <MaternalTimelineItem>[];

  @override
  void initState() {
    super.initState();
    _useCase =
        widget.getMaternalHistoryUseCase ?? GetMaternalHistoryUseCase(IntakeRepositoryImpl());
    _timeService = widget.timeService ?? DefaultTimeService();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<MaternalTimelineItem> items = await _useCase(widget.patientId);
      if (mounted) {
        setState(() {
          _timeline = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return '-';
    try {
      final DateTime dt = DateTime.parse(dateStr.trim()).toLocal();
      return _timeService.formatDate(dt, style: 'human_full');
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AmanahBottomSheetScaffold(
      title: 'Riwayat Asuhan Kehamilan',
      fixedHeightFactor: 0.88,
      minHeight: 500,
      bodyPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(
              color: widget.isDark
                  ? AmanahColorTokens.tabActiveDark
                  : AmanahColorTokens.brandPrimary,
            ),
            const SizedBox(height: 16),
            Text(
              'Mengambil riwayat rekam medis ibu...',
              style: TextStyle(
                color: widget.isDark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral600,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.error_outline_rounded, size: 44, color: AmanahColorTokens.danger),
              const SizedBox(height: 12),
              Text(
                'Gagal Memuat Riwayat',
                style: TextStyle(
                  color: widget.isDark
                      ? AmanahColorTokens.surfaceLight
                      : AmanahColorTokens.neutral900,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: widget.isDark
                      ? AmanahColorTokens.neutral400
                      : AmanahColorTokens.neutral600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              AmanahButton.secondary(text: 'Coba Lagi', onPressed: _fetchHistory),
            ],
          ),
        ),
      );
    }

    if (_timeline.isEmpty) {
      return Center(
        child: Text(
          'Belum ada riwayat formulir asuhan kehamilan terdahulu untuk pasien ini.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: widget.isDark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral600,
            fontSize: 13,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Ditemukan ${_timeline.length} sesi pemeriksaan asuhan kehamilan terdahulu untuk ${widget.patientName}.',
              style: TextStyle(
                color: widget.isDark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral600,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
          ..._timeline.map((MaternalTimelineItem item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? AmanahColorTokens.surfaceSecondaryDark
                    : AmanahColorTokens.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isDark
                      ? AmanahColorTokens.neutral800
                      : AmanahColorTokens.neutral200,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? AmanahColorTokens.neutral800.withValues(alpha: 0.4)
                          : AmanahColorTokens.neutral100.withValues(alpha: 0.6),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: widget.isDark
                              ? AmanahColorTokens.tabActiveDark
                              : AmanahColorTokens.brandPrimary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _formatDate(item.createdAt),
                            style: TextStyle(
                              color: widget.isDark
                                  ? AmanahColorTokens.surfaceLight
                                  : AmanahColorTokens.neutral900,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (item.gpa != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: widget.isDark
                                  ? AmanahColorTokens.tabActiveDark.withValues(alpha: 0.16)
                                  : AmanahColorTokens.brand.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: widget.isDark
                                    ? AmanahColorTokens.tabActiveDark.withValues(alpha: 0.32)
                                    : AmanahColorTokens.brand.withValues(alpha: 0.20),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              item.gpa!,
                              style: TextStyle(
                                color: widget.isDark
                                    ? AmanahColorTokens.tabActiveDark
                                    : AmanahColorTokens.brandPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Content Body
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: <Widget>[
                        _buildTimelineRow(
                          icon: Icons.hourglass_bottom_rounded,
                          label: 'Usia Kehamilan',
                          value: item.gestationalAgeFormatted ?? '-',
                        ),
                        const SizedBox(height: 8),
                        _buildTimelineRow(
                          icon: Icons.event_available_rounded,
                          label: 'Taksiran Persalinan (HPL)',
                          value: item.estimatedDueDate ?? '-',
                        ),
                        const SizedBox(height: 8),
                        _buildTimelineRow(
                          icon: Icons.event_note_rounded,
                          label: 'HPHT',
                          value: item.hpht ?? '-',
                        ),
                        if (item.partnerName != null &&
                            item.partnerName!.trim().isNotEmpty) ...<Widget>[
                          const SizedBox(height: 8),
                          _buildTimelineRow(
                            icon: Icons.favorite_border_rounded,
                            label: 'Suami / Pasangan',
                            value: item.partnerName!,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTimelineRow({required IconData icon, required String label, required String value}) {
    return Row(
      children: <Widget>[
        Icon(
          icon,
          size: 16,
          color: widget.isDark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: widget.isDark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: widget.isDark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.neutral900,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
