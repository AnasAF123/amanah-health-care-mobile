import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';

enum CanonicalAppointmentStatus {
  booked,
  waiting,
  inService,
  completed,
  cancelled,
  late,
}

class AppointmentStatusDescriptor {
  const AppointmentStatusDescriptor({
    required this.code,
    required this.label,
    required this.badge,
    required this.description,
    required this.badgeVariant,
    this.isTerminal = false,
    this.isInService = false,
    this.isWaiting = false,
    this.isBooked = false,
  });

  final CanonicalAppointmentStatus code;
  final String label;
  final String badge;
  final String description;
  final AmanahBadgeVariant badgeVariant;
  final bool isTerminal;
  final bool isInService;
  final bool isWaiting;
  final bool isBooked;

  static const Map<CanonicalAppointmentStatus, AppointmentStatusDescriptor> registry = {
    CanonicalAppointmentStatus.booked: AppointmentStatusDescriptor(
      code: CanonicalAppointmentStatus.booked,
      label: 'Sudah Buat Janji',
      badge: 'Sudah Buat Janji',
      description: 'Pasien telah menjadwalkan janji temu dan menunggu konfirmasi kehadiran',
      badgeVariant: AmanahBadgeVariant.primary,
      isBooked: true,
    ),
    CanonicalAppointmentStatus.waiting: AppointmentStatusDescriptor(
      code: CanonicalAppointmentStatus.waiting,
      label: 'Menunggu',
      badge: 'Menunggu',
      description: 'Pasien berada di ruang tunggu antrean pemeriksaan',
      badgeVariant: AmanahBadgeVariant.primary,
      isWaiting: true,
    ),
    CanonicalAppointmentStatus.inService: AppointmentStatusDescriptor(
      code: CanonicalAppointmentStatus.inService,
      label: 'Sedang Diperiksa',
      badge: 'Sedang Diperiksa',
      description: 'Pasien sedang dalam ruang konsultasi dengan dokter',
      badgeVariant: AmanahBadgeVariant.trend,
      isInService: true,
    ),
    CanonicalAppointmentStatus.completed: AppointmentStatusDescriptor(
      code: CanonicalAppointmentStatus.completed,
      label: 'Selesai',
      badge: 'Selesai',
      description: 'Pemeriksaan selesai, rekam medis telah diperbarui',
      badgeVariant: AmanahBadgeVariant.success,
      isTerminal: true,
    ),
    CanonicalAppointmentStatus.cancelled: AppointmentStatusDescriptor(
      code: CanonicalAppointmentStatus.cancelled,
      label: 'Dibatalkan',
      badge: 'Dibatalkan',
      description: 'Janji temu dibatalkan oleh pasien atau pihak klinik',
      badgeVariant: AmanahBadgeVariant.warning,
      isTerminal: true,
    ),
    CanonicalAppointmentStatus.late: AppointmentStatusDescriptor(
      code: CanonicalAppointmentStatus.late,
      label: 'Terlambat',
      badge: 'Terlambat',
      description: 'Pasien belum hadir melebihi batas toleransi waktu',
      badgeVariant: AmanahBadgeVariant.warning,
      isTerminal: true,
    ),
  };

  static const Map<String, CanonicalAppointmentStatus> aliases = {
    'BOOK': CanonicalAppointmentStatus.booked,
    'BOOKED': CanonicalAppointmentStatus.booked,
    'SUDAH_BUAT_JANJI': CanonicalAppointmentStatus.booked,
    'WAITING': CanonicalAppointmentStatus.waiting,
    'MENUNGGU': CanonicalAppointmentStatus.waiting,
    'CHECKED_IN': CanonicalAppointmentStatus.waiting,
    'IN_SERVICE': CanonicalAppointmentStatus.inService,
    'SEDANG_DIPERIKSA': CanonicalAppointmentStatus.inService,
    'SEDANG_PERIKSA': CanonicalAppointmentStatus.inService,
    'DI_SESI': CanonicalAppointmentStatus.inService,
    'SERVING': CanonicalAppointmentStatus.inService,
    'COMPLETED': CanonicalAppointmentStatus.completed,
    'SELESAI': CanonicalAppointmentStatus.completed,
    'CANCELLED': CanonicalAppointmentStatus.cancelled,
    'BATAL': CanonicalAppointmentStatus.cancelled,
    'DIBATALKAN': CanonicalAppointmentStatus.cancelled,
    'TIDAK_ADA_DOKTER': CanonicalAppointmentStatus.cancelled,
    'LATE': CanonicalAppointmentStatus.late,
    'TERLAMBAT': CanonicalAppointmentStatus.late,
    'NO_SHOW': CanonicalAppointmentStatus.late,
    'TIDAK_HADIR': CanonicalAppointmentStatus.late,
  };

  static AppointmentStatusDescriptor resolve(String? rawStatus) {
    if (rawStatus == null || rawStatus.trim().isEmpty) {
      return registry[CanonicalAppointmentStatus.waiting]!;
    }
    final String key = rawStatus.trim().toUpperCase().replaceAll(' ', '_');
    final CanonicalAppointmentStatus canonical = aliases[key] ?? CanonicalAppointmentStatus.waiting;
    return registry[canonical]!;
  }
}
