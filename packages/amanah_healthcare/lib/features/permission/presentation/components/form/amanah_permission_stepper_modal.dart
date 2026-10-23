import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/time/time.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/permission/data/repositories/permission_repository_impl.dart';
import 'package:amanah_healthcare/features/permission/domain/amanah_permission_model.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/amanah_permission_form_data.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/eligible_session.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/permission_form_stage.dart';
import 'package:amanah_healthcare/features/permission/domain/repositories/permission_repository.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/form/stages/permission_date_mode_stage.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/form/stages/permission_date_stage.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/form/stages/permission_reason_stage.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/form/stages/permission_scope_stage.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/form/stages/permission_type_stage.dart';
import 'package:amanah_healthcare/features/permission/presentation/state/permission_draft_state.dart';
import 'package:amanah_healthcare/features/permission/presentation/theme/amanah_permission_tokens.dart';

/// Sequential content-replacement modal for staff leave permission application.
///
/// Features:
/// - Smooth content swapping across 4 stages (Type -> Date -> Scope -> Reason).
/// - Zero step numbers, progress bars, or stepper headers.
/// - Auto-advance on card selections (Stage 1 Type and Stage 3 Full Day).
/// - Clean back navigation preserving previous inputs.
class AmanahPermissionStepperModal extends StatefulWidget {
  final String doctorName;
  final String doctorRole;
  final String? avatarUrl;
  final PermissionRepository? repository;

  const AmanahPermissionStepperModal({
    super.key,
    required this.doctorName,
    required this.doctorRole,
    this.avatarUrl,
    this.repository,
  });

  /// Displays the sequential permission modal and returns form data upon completion.
  static Future<AmanahPermissionFormData?> show({
    required BuildContext context,
    required String doctorName,
    required String doctorRole,
    String? avatarUrl,
    PermissionRepository? repository,
  }) {
    return showAmanahBottomSheet<AmanahPermissionFormData>(
      context: context,
      builder: (BuildContext ctx) => AmanahPermissionStepperModal(
        doctorName: doctorName,
        doctorRole: doctorRole,
        avatarUrl: avatarUrl,
        repository: repository,
      ),
    );
  }

  @override
  State<AmanahPermissionStepperModal> createState() => _AmanahPermissionStepperModalState();
}

class _AmanahPermissionStepperModalState extends State<AmanahPermissionStepperModal> {
  late final PermissionRepository _repository;
  late final TextEditingController _reasonController;

  late PermissionDraftState _draft;
  List<EligibleSession> _eligibleSessions = const <EligibleSession>[];
  String? _errorMessage;
  bool _isTodayEligible = true;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? PermissionRepositoryImpl();
    _reasonController = TextEditingController();
    _draft = PermissionDraftState.initial();
    _checkTodayEligibility();
  }

  Future<void> _checkTodayEligibility() async {
    try {
      final String todayIso = formatIsoDateString(DateTime.now());
      final List<EligibleSession> sessions = await _repository.getEligibleSessions(todayIso);
      if (mounted) {
        setState(() {
          _isTodayEligible = sessions.isNotEmpty;
          if (!_isTodayEligible) {
            _draft = _draft.copyWith(isCustomDateRange: true);
          }
        });
      }
    } catch (_) {
      // Keep graceful default if check fails
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadEligibleSessions() async {
    setState(() => _draft = _draft.copyWith(isLoadingSessions: true));
    try {
      final String dateIso = formatIsoDateString(_draft.dateRange.startDate);
      final List<EligibleSession> sessions = await _repository.getEligibleSessions(dateIso);
      if (mounted) {
        setState(() {
          _eligibleSessions = sessions;
          _draft = _draft.copyWith(isLoadingSessions: false);
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _eligibleSessions = const <EligibleSession>[];
          _draft = _draft.copyWith(isLoadingSessions: false);
        });
      }
    }
  }

  String get _stageTitle {
    switch (_draft.stage) {
      case PermissionFormStage.type:
        return 'Pilih Jenis Perizinan';
      case PermissionFormStage.dateMode:
        return 'Pilih Waktu Perizinan';
      case PermissionFormStage.dateCustom:
        return 'Tentukan Rentang Tanggal';
      case PermissionFormStage.scope:
        return 'Pilih Lingkup Perizinan';
      case PermissionFormStage.reason:
        return 'Konfirmasi & Alasan Izin';
    }
  }

  void _handleTypeSelected(AmanahPermissionType type) {
    setState(() {
      _draft = _draft.copyWith(type: type, stage: PermissionFormStage.dateMode);
    });
  }

  void _handleDateTodaySelected() {
    final DateTime today = normalizeToCalendarDate(DateTime.now());
    setState(() {
      _draft = _draft.copyWith(
        dateRange: CalendarDateRange.singleDay(today),
        isCustomDateRange: false,
        stage: PermissionFormStage.scope,
      );
    });
    if (_draft.isSessionScope) {
      _loadEligibleSessions();
    }
  }

  void _handleDateCustomSelected() {
    setState(() {
      _draft = _draft.copyWith(isCustomDateRange: true, stage: PermissionFormStage.dateCustom);
    });
  }

  void _handleDateRangeChanged(CalendarDateRange newRange) {
    setState(() {
      _draft = _draft.copyWith(dateRange: newRange);
    });
    if (_draft.isSessionScope) {
      _loadEligibleSessions();
    }
  }

  void _handleDateStageContinue() {
    setState(() {
      _draft = _draft.copyWith(stage: PermissionFormStage.scope);
    });
    if (_draft.isSessionScope && _eligibleSessions.isEmpty) {
      _loadEligibleSessions();
    }
  }

  void _handleScopeSelected(String scope) {
    if (scope == 'full_day') {
      setState(() {
        _draft = _draft.copyWith(
          scope: scope,
          selectedSessions: const <EligibleSession>[],
          stage: PermissionFormStage.reason,
        );
      });
    } else {
      setState(() {
        _draft = _draft.copyWith(scope: scope);
      });
      _loadEligibleSessions();
    }
  }

  void _handleSessionToggled(EligibleSession session) {
    final List<EligibleSession> current = List<EligibleSession>.from(_draft.selectedSessions);
    final int index = current.indexWhere((EligibleSession s) => s.sessionId == session.sessionId);
    if (index >= 0) {
      current.removeAt(index);
    } else {
      current.add(session);
    }
    setState(() {
      _draft = _draft.copyWith(selectedSessions: current);
    });
  }

  void _handleScopeStageContinue() {
    setState(() {
      _draft = _draft.copyWith(stage: PermissionFormStage.reason);
    });
  }

  void _handleStepBack() {
    setState(() {
      _errorMessage = null;
      switch (_draft.stage) {
        case PermissionFormStage.type:
          Navigator.of(context).pop();
          break;
        case PermissionFormStage.dateMode:
          _draft = _draft.copyWith(stage: PermissionFormStage.type);
          break;
        case PermissionFormStage.dateCustom:
          _draft = _draft.copyWith(stage: PermissionFormStage.dateMode);
          break;
        case PermissionFormStage.scope:
          _draft = _draft.copyWith(
            stage: _draft.isCustomDateRange
                ? PermissionFormStage.dateCustom
                : PermissionFormStage.dateMode,
          );
          break;
        case PermissionFormStage.reason:
          _draft = _draft.copyWith(stage: PermissionFormStage.scope);
          break;
      }
    });
  }

  void _handleSubmit() {
    final String reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      setState(() => _errorMessage = 'Pesan / alasan perizinan wajib diisi');
      return;
    }
    if (reason.length < 8) {
      setState(() => _errorMessage = 'Tuliskan alasan minimal 8 karakter');
      return;
    }

    final AmanahPermissionFormData data = AmanahPermissionFormData(
      type: _draft.type,
      startDate: formatIsoDateString(_draft.dateRange.startDate),
      endDate: formatIsoDateString(_draft.dateRange.endDate),
      reason: reason,
      scope: _draft.scope,
      sessionIds: _draft.isSessionScope
          ? _draft.selectedSessions.map((EligibleSession s) => s.sessionId).toList()
          : null,
    );

    Navigator.of(context).pop(data);
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = dark
        ? AmanahPermissionTokens.textTitleDark
        : AmanahPermissionTokens.textTitleLight;

    return PopScope(
      canPop: _draft.stage == PermissionFormStage.type,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        _handleStepBack();
      },
      child: AmanahBottomSheetScaffold(
        title: _stageTitle,
        hugContent: true,
        bodyPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        trailing: _draft.stage != PermissionFormStage.type
            ? IconButton(
                icon: Icon(Icons.arrow_back_rounded, size: 20, color: textColor),
                onPressed: _handleStepBack,
                tooltip: 'Kembali ke tahap sebelumnya',
              )
            : IconButton(
                icon: Icon(Icons.close_rounded, size: 20, color: textColor),
                onPressed: () => Navigator.of(context).maybePop(),
                tooltip: 'Tutup',
              ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: KeyedSubtree(
            key: ValueKey<PermissionFormStage>(_draft.stage),
            child: _buildCurrentStage(context),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStage(BuildContext context) {
    switch (_draft.stage) {
      case PermissionFormStage.type:
        return PermissionTypeStage(selectedType: _draft.type, onTypeSelected: _handleTypeSelected);
      case PermissionFormStage.dateMode:
        return PermissionDateModeStage(
          dateRange: _draft.dateRange,
          isCustomDateRange: _draft.isCustomDateRange,
          isTodayEligible: _isTodayEligible,
          onTodaySelected: _handleDateTodaySelected,
          onCustomRangeSelected: _handleDateCustomSelected,
        );
      case PermissionFormStage.dateCustom:
        return PermissionDateStage(
          dateRange: _draft.dateRange,
          onDateRangeChanged: _handleDateRangeChanged,
          onContinue: _handleDateStageContinue,
        );
      case PermissionFormStage.scope:
        return PermissionScopeStage(
          scope: _draft.scope,
          eligibleSessions: _eligibleSessions,
          selectedSessions: _draft.selectedSessions,
          isLoadingSessions: _draft.isLoadingSessions,
          onScopeSelected: _handleScopeSelected,
          onSessionToggled: _handleSessionToggled,
          onContinue: _handleScopeStageContinue,
        );
      case PermissionFormStage.reason:
        return PermissionReasonStage(
          draft: _draft,
          reasonController: _reasonController,
          errorMessage: _errorMessage,
          onSubmit: _handleSubmit,
          onCancel: () => Navigator.of(context).pop(),
        );
    }
  }
}
