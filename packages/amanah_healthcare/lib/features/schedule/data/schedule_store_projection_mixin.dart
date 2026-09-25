import 'package:flutter/foundation.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_repository.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';

mixin ScheduleStoreProjectionMixin on ChangeNotifier {
  AmanahScheduleRepository get repository;
  void setLoading(bool loading);
  void setErrorMessage(String? error);
  void setLastConflict(AmanahScheduleConflictException? conflict);
  Future<List<DoctorSchedule>> loadSchedulesForDate(
    DateTime date, {
    String? doctorId,
    bool forceRefresh = false,
  });

  String _mixinFormatDateKey(DateTime date) {
    final String y = date.year.toString().padLeft(4, '0');
    final String m = date.month.toString().padLeft(2, '0');
    final String d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  ClinicScheduleOptionsReference? _scheduleOptions;
  List<ScheduleContext> _scheduleContexts = const <ScheduleContext>[];
  List<ClinicRoomReference> _rooms = const <ClinicRoomReference>[];
  ScheduleProjection? _currentProjection;
  ScheduleOccupancyOverviewData? _occupancyOverview;
  ScheduleFormBootstrapData? _formBootstrap;
  ScheduleSlotAvailabilityData? _slotAvailability;

  ClinicScheduleOptionsReference? get scheduleOptions => _scheduleOptions;
  List<ScheduleContext> get scheduleContexts => _scheduleContexts;
  List<ClinicRoomReference> get rooms => _rooms;
  ScheduleProjection? get currentProjection => _currentProjection;
  ScheduleOccupancyOverviewData? get occupancyOverview => _occupancyOverview;
  ScheduleFormBootstrapData? get formBootstrap => _formBootstrap;
  ScheduleSlotAvailabilityData? get slotAvailability => _slotAvailability;

  void clearProjection() {
    _currentProjection = null;
    notifyListeners();
  }

  void clearOccupancyOverview() {
    _occupancyOverview = null;
    notifyListeners();
  }

  void resetProjectionState() {
    _scheduleOptions = null;
    _scheduleContexts = const <ScheduleContext>[];
    _rooms = const <ClinicRoomReference>[];
    _currentProjection = null;
    _occupancyOverview = null;
    _formBootstrap = null;
    _slotAvailability = null;
  }

  Future<ScheduleFormBootstrapData?> loadFormBootstrap({
    required DateTime date,
    String? scheduleId,
  }) async {
    try {
      final ScheduleFormBootstrapData data =
          await repository.fetchFormBootstrap(
        date: _mixinFormatDateKey(date),
        scheduleId: scheduleId,
      );
      _formBootstrap = data;
      _rooms = data.rooms;
      notifyListeners();
      return data;
    } catch (_) {
      return null;
    }
  }

  Future<ScheduleSlotAvailabilityData?> loadSlotAvailability({
    required DateTime date,
    required String shift,
    required String roomId,
    String? scheduleId,
  }) async {
    try {
      final ScheduleSlotAvailabilityData data =
          await repository.fetchSlotAvailability(
        date: _mixinFormatDateKey(date),
        shift: shift,
        roomId: roomId,
        scheduleId: scheduleId,
      );
      _slotAvailability = data;
      notifyListeners();
      return data;
    } catch (_) {
      return null;
    }
  }

  Future<List<ClinicRoomReference>> loadRooms({
    DateTime? date,
    String? startTime,
    String? endTime,
  }) async {
    try {
      final List<ClinicRoomReference> res = await repository.fetchReferenceRooms(
        date: date != null ? _mixinFormatDateKey(date) : null,
        startTime: startTime,
        endTime: endTime,
      );
      _rooms = res;
      notifyListeners();
      return res;
    } catch (_) {
      return const <ClinicRoomReference>[];
    }
  }

  Future<List<ClinicPoliklinikReference>> loadPolikliniks() async {
    try {
      return await repository.fetchReferencePolikliniks();
    } catch (_) {
      return const <ClinicPoliklinikReference>[];
    }
  }

  Future<ClinicScheduleOptionsReference?> loadScheduleOptions() async {
    try {
      final ClinicScheduleOptionsReference options =
          await repository.fetchReferenceOptions();
      _scheduleOptions = options;
      notifyListeners();
      return options;
    } catch (_) {
      return null;
    }
  }

  Future<List<ScheduleContext>> loadScheduleContexts(DateTime date) async {
    setLoading(true);
    setErrorMessage(null);
    await Future<void>.value();
    notifyListeners();

    try {
      final List<ScheduleContext> contexts =
          await repository.fetchScheduleContexts(date: _mixinFormatDateKey(date));
      _scheduleContexts = contexts;
      setLoading(false);
      notifyListeners();
      return contexts;
    } catch (e) {
      setLoading(false);
      setErrorMessage(e.toString());
      notifyListeners();
      return _scheduleContexts;
    }
  }

  Future<ScheduleOccupancyOverviewData?> loadOccupancyOverview({
    required DateTime date,
    String? roomId,
  }) async {
    try {
      final ScheduleOccupancyOverviewData data =
          await repository.fetchOccupancyOverview(
        date: _mixinFormatDateKey(date),
        roomId: roomId,
      );
      _occupancyOverview = data;
      notifyListeners();
      return data;
    } catch (e) {
      _occupancyOverview = null;
      notifyListeners();
      return null;
    }
  }

  Future<ScheduleProjection?> loadProjection({
    required DateTime date,
    required String scheduleContextId,
    required String startTime,
    String? roomId,
    String? serviceId,
  }) async {
    try {
      final ScheduleProjection projection = await repository.fetchProjection(
        date: _mixinFormatDateKey(date),
        scheduleContextId: scheduleContextId,
        startTime: startTime,
        roomId: roomId,
        serviceId: serviceId,
      );
      _currentProjection = projection;
      notifyListeners();
      return projection;
    } catch (e) {
      setErrorMessage(e.toString());
      notifyListeners();
      return null;
    }
  }

  Future<DoctorSchedule> createAvailability({
    required DateTime date,
    required String scheduleContextId,
    required String startTime,
    String? roomId,
    String? poliklinikId,
    String? serviceId,
    String? notes,
  }) async {
    setLoading(true);
    setErrorMessage(null);
    setLastConflict(null);
    await Future<void>.value();
    notifyListeners();

    try {
      final DoctorSchedule schedule = await repository.createAvailability(
        date: _mixinFormatDateKey(date),
        scheduleContextId: scheduleContextId,
        startTime: startTime,
        roomId: roomId,
        poliklinikId: poliklinikId,
        serviceId: serviceId,
        notes: notes,
      );

      await loadSchedulesForDate(date, forceRefresh: true);
      setLoading(false);
      notifyListeners();
      return schedule;
    } on AmanahScheduleConflictException catch (e) {
      setLoading(false);
      setLastConflict(e);
      setErrorMessage(e.message);
      notifyListeners();
      rethrow;
    } catch (e) {
      setLoading(false);
      setErrorMessage(e.toString());
      notifyListeners();
      rethrow;
    }
  }
}
