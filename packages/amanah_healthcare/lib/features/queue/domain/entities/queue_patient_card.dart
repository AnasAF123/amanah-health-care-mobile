import 'package:amanah_healthcare/features/home/domain/amanah_queue_data.dart';

/// Domain entity representing a clinical patient card in the practitioner queue.
class QueuePatientCard {
  const QueuePatientCard({
    required this.id,
    this.appointmentId,
    this.patientId,
    required this.queueNumber,
    required this.patientName,
    required this.complaint,
    required this.poly,
    required this.room,
    required this.doctorName,
    required this.doctorImage,
    required this.priority,
    required this.timeSlot,
    required this.age,
    required this.gender,
    required this.status,
    required this.patientRm,
    this.guardian,
    this.allowedActions = const <String>[],
  });

  final String id;
  final String? appointmentId;
  final String? patientId;
  final String queueNumber;
  final String patientName;
  final String complaint;
  final String poly;
  final String room;
  final String doctorName;
  final String doctorImage;
  final String priority;
  final String timeSlot;
  final int age;
  final String gender;
  final String status;
  final String patientRm;
  final String? guardian;
  final List<String> allowedActions;

  String get effectiveAppointmentId =>
      (appointmentId != null && appointmentId!.isNotEmpty) ? appointmentId! : id;

  String get effectivePatientId =>
      (patientId != null && patientId!.isNotEmpty) ? patientId! : id;

  static String _mapStatusToLabel(String status) {
    switch (status.toLowerCase()) {
      case 'waiting':
        return 'Menunggu';
      case 'booked':
        return 'Sudah Buat Janji';
      case 'checked_in':
        return 'Hadir di Klinik';
      case 'in_service':
        return 'Sedang Diperiksa';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      case 'no_show':
        return 'Tidak Hadir';
      default:
        return status;
    }
  }

  /// Translates domain entity to presentation model for the 3D Queue Dock.
  AmanahQueueCardData toUiCard() {
    return AmanahQueueCardData(
      id: effectiveAppointmentId,
      appointmentId: effectiveAppointmentId,
      patientId: effectivePatientId,
      queueNumber: queueNumber,
      patientName: patientName,
      complaint: complaint,
      poly: poly,
      doctorName: doctorName,
      doctorImage: doctorImage,
      priority: priority,
      timeSlot: timeSlot,
      age: age,
      gender: gender,
      room: room,
      status: _mapStatusToLabel(status),
      guardian: guardian,
      allowedActions: allowedActions,
    );
  }
}
