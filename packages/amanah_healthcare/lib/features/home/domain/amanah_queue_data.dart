class AmanahQueueCardData {
  const AmanahQueueCardData({
    required this.id,
    required this.queueNumber,
    required this.patientName,
    required this.complaint,
    required this.poly,
    required this.doctorName,
    required this.doctorImage,
    required this.priority,
    required this.timeSlot,
    required this.age,
    required this.gender,
    this.room = 'R. Periksa 101',
    this.status = 'Menunggu',
    this.watermarkAsset = 'assets/amanah/id_card/images/wm.svg',
    this.guardian,
  });

  final String id;
  final String queueNumber;
  final String patientName;
  final String complaint;
  final String poly;
  final String doctorName;
  final String doctorImage;
  final String priority;
  final String timeSlot;
  final int age;
  final String gender;
  final String room;
  final String status;
  final String watermarkAsset;
  final String? guardian;

  String get patientRm =>
      'RM-2026-${queueNumber.replaceAll('#', '').padLeft(4, '0')}';
}
