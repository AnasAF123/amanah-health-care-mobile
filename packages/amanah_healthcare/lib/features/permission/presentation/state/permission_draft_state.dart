import 'package:amanah_healthcare/core/time/time.dart';
import 'package:amanah_healthcare/features/permission/domain/amanah_permission_model.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/eligible_session.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/permission_form_stage.dart';

/// Immutable draft state for the sequential staff permission form.
class PermissionDraftState {
  final PermissionFormStage stage;
  final AmanahPermissionType type;
  final CalendarDateRange dateRange;
  final bool isCustomDateRange;
  final String scope; // 'full_day' or 'session'
  final List<EligibleSession> selectedSessions;
  final String reason;
  final bool isSubmitting;
  final bool isLoadingSessions;

  const PermissionDraftState({
    required this.stage,
    required this.type,
    required this.dateRange,
    required this.isCustomDateRange,
    required this.scope,
    required this.selectedSessions,
    required this.reason,
    required this.isSubmitting,
    required this.isLoadingSessions,
  });

  /// Factory creating an initial draft with normalized dates.
  factory PermissionDraftState.initial({DateTime? initialDate}) {
    final DateTime now = initialDate ?? DateTime.now();
    final DateTime today = normalizeToCalendarDate(now);

    return PermissionDraftState(
      stage: PermissionFormStage.type,
      type: AmanahPermissionType.cutiTahunan,
      dateRange: CalendarDateRange.singleDay(today),
      isCustomDateRange: false,
      scope: 'full_day',
      selectedSessions: const <EligibleSession>[],
      reason: '',
      isSubmitting: false,
      isLoadingSessions: false,
    );
  }

  bool get isFullDay => scope == 'full_day';
  bool get isSessionScope => scope == 'session';
  int get durationDays => dateRange.durationDays;

  PermissionDraftState copyWith({
    PermissionFormStage? stage,
    AmanahPermissionType? type,
    CalendarDateRange? dateRange,
    bool? isCustomDateRange,
    String? scope,
    List<EligibleSession>? selectedSessions,
    String? reason,
    bool? isSubmitting,
    bool? isLoadingSessions,
  }) {
    return PermissionDraftState(
      stage: stage ?? this.stage,
      type: type ?? this.type,
      dateRange: dateRange ?? this.dateRange,
      isCustomDateRange: isCustomDateRange ?? this.isCustomDateRange,
      scope: scope ?? this.scope,
      selectedSessions: selectedSessions ?? this.selectedSessions,
      reason: reason ?? this.reason,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isLoadingSessions: isLoadingSessions ?? this.isLoadingSessions,
    );
  }
}
