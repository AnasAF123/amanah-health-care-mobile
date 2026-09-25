class ScheduleFormSlot {
  const ScheduleFormSlot({
    required this.id,
    required this.from,
    required this.to,
    required this.room,
    required this.poli,
  });

  final String id;
  final String from;
  final String to;
  final String room;
  final String poli;

  ScheduleFormSlot copyWith({
    String? from,
    String? to,
    String? room,
    String? poli,
  }) {
    return ScheduleFormSlot(
      id: id,
      from: from ?? this.from,
      to: to ?? this.to,
      room: room ?? this.room,
      poli: poli ?? this.poli,
    );
  }
}

class ScheduleFormSession {
  const ScheduleFormSession({
    required this.id,
    required this.name,
    required this.sessionType,
    required this.active,
    required this.slots,
  });

  final String id;
  final String name;
  final String sessionType;
  final bool active;
  final List<ScheduleFormSlot> slots;

  ScheduleFormSession copyWith({
    bool? active,
    List<ScheduleFormSlot>? slots,
  }) {
    return ScheduleFormSession(
      id: id,
      name: name,
      sessionType: sessionType,
      active: active ?? this.active,
      slots: slots ?? this.slots,
    );
  }
}
