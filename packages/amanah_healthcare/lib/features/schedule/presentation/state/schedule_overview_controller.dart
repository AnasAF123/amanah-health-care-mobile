import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/presentation/components/amanah_toaster.dart';
import 'package:amanah_healthcare/core/time/time.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_store.dart';
import 'package:amanah_healthcare/features/schedule/data/repositories/schedule_repository_impl.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/calendar_day_summary.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/session_patient.dart';
import 'package:amanah_healthcare/features/schedule/domain/failures/schedule_failure.dart';
import 'package:amanah_healthcare/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:amanah_healthcare/features/schedule/domain/usecases/get_booked_patients.dart';
import 'package:amanah_healthcare/features/schedule/domain/usecases/get_calendar_summary.dart';
import 'package:amanah_healthcare/features/schedule/domain/usecases/toggle_day_status.dart';

class ScheduleOverviewController extends ChangeNotifier {
  ScheduleOverviewController({
    ScheduleRepository? repository,
    GetBookedPatientsUseCase? getBookedPatientsUseCase,
    GetCalendarSummaryUseCase? getCalendarSummaryUseCase,
    ToggleDayStatusUseCase? toggleDayStatusUseCase,
    DateTime? initialDate,
  })  : _getBookedPatientsUseCase = getBookedPatientsUseCase ??
            GetBookedPatientsUseCase(repository ?? ScheduleRepositoryImpl()),
        _getCalendarSummaryUseCase = getCalendarSummaryUseCase ??
            GetCalendarSummaryUseCase(repository ?? ScheduleRepositoryImpl()),
        _toggleDayStatusUseCase = toggleDayStatusUseCase ??
            ToggleDayStatusUseCase(repository ?? ScheduleRepositoryImpl()),
        _selectedDate = initialDate ?? DateTime.now();

  final GetBookedPatientsUseCase _getBookedPatientsUseCase;
  final GetCalendarSummaryUseCase _getCalendarSummaryUseCase;
  final ToggleDayStatusUseCase _toggleDayStatusUseCase;

  DateTime _selectedDate;
  bool _isLoadingPatients = false;
  bool _isLoadingSummary = false;
  String? _errorMessage;
  List<SessionPatient> _bookedPatients = const <SessionPatient>[];
  final Map<String, CalendarDaySummary> _calendarSummaries =
      <String, CalendarDaySummary>{};

  DateTime get selectedDate => _selectedDate;
  bool get isLoadingPatients => _isLoadingPatients;
  bool get isLoadingSummary => _isLoadingSummary;
  bool get isLoading => _isLoadingPatients || _isLoadingSummary;
  String? get errorMessage => _errorMessage;
  List<SessionPatient> get bookedPatients => _bookedPatients;

  String _formatDateString(DateTime d) => formatIsoDateString(d);

  String _formatMonthString(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}';
  }

  CalendarDaySummary? get currentDaySummary =>
      _calendarSummaries[_formatDateString(_selectedDate)];

  bool get isCutiOnSelectedDate =>
      currentDaySummary?.isOnLeave ?? false;

  bool hasSchedulesForDate(DateTime date) {
    final String key = _formatDateString(date);
    return _calendarSummaries[key]?.hasSchedule ?? true;
  }

  bool isCutiForDate(DateTime date) {
    final String key = _formatDateString(date);
    return _calendarSummaries[key]?.isOnLeave ?? false;
  }

  Future<void> initialize() async {
    await Future.wait(<Future<void>>[
      loadCalendarSummaryForMonth(_selectedDate),
      loadBookedPatientsForDate(_selectedDate),
    ]);
  }

  void selectDate(DateTime newDate) {
    if (_selectedDate.year == newDate.year &&
        _selectedDate.month == newDate.month &&
        _selectedDate.day == newDate.day) {
      return;
    }

    final bool monthChanged = _selectedDate.year != newDate.year ||
        _selectedDate.month != newDate.month;

    _selectedDate = newDate;
    notifyListeners();

    if (monthChanged) {
      loadCalendarSummaryForMonth(newDate);
    }
    loadBookedPatientsForDate(newDate);
  }

  Future<void> loadBookedPatientsForDate(DateTime date) async {
    _isLoadingPatients = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String dateStr = _formatDateString(date);
      final List<SessionPatient> list = await _getBookedPatientsUseCase(
        GetBookedPatientsParams(date: dateStr),
      );
      _bookedPatients = list;
    } catch (e) {
      _errorMessage = e is ScheduleFailure ? e.message : e.toString();
    } finally {
      _isLoadingPatients = false;
      notifyListeners();
    }
  }

  Future<void> loadCalendarSummaryForMonth(DateTime monthDate) async {
    _isLoadingSummary = true;
    notifyListeners();

    try {
      final String monthStr = _formatMonthString(monthDate);
      final List<CalendarDaySummary> list = await _getCalendarSummaryUseCase(
        GetCalendarSummaryParams(month: monthStr),
      );
      for (final CalendarDaySummary item in list) {
        _calendarSummaries[item.date] = item;
      }
    } catch (e) {
      // Non-fatal, fallback to neutral indicators
    } finally {
      _isLoadingSummary = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await Future.wait(<Future<void>>[
      loadCalendarSummaryForMonth(_selectedDate),
      loadBookedPatientsForDate(_selectedDate),
    ]);
  }

  Future<bool> reopenSchedule(BuildContext context, DateTime date) async {
    try {
      final String dateStr = _formatDateString(date);
      await _toggleDayStatusUseCase(
        ToggleDayStatusParams(
          date: dateStr,
          isClosed: false,
        ),
      );

      await refresh();
      await AmanahScheduleStore.instance.syncTodaySchedules();

      if (context.mounted) {
        AmanahToaster.success(
          context,
          message: 'Jadwal praktik berhasil dibuka kembali',
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        final String msg = e is ScheduleFailure ? e.message : e.toString();
        AmanahToaster.error(context, message: msg);
      }
      return false;
    }
  }
}
