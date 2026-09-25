import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_empty_state.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_store.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/cards/amanah_booked_patient_card.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/drawers/amanah_patient_detail_modal.dart';

/// Tab component displaying the history of completed and past patient consultations.
///
/// Fully interactive for doctors to review past medical records and consultation outcomes.
class PresenceHistoryPatientTab extends StatefulWidget {
  const PresenceHistoryPatientTab({
    this.patients,
    super.key,
  });

  final List<({BookedPatient patient, DoctorSchedule schedule})>? patients;

  @override
  State<PresenceHistoryPatientTab> createState() =>
      _PresenceHistoryPatientTabState();
}

class _PresenceHistoryPatientTabState extends State<PresenceHistoryPatientTab> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<({BookedPatient patient, DoctorSchedule schedule})> get _sourcePatients {
    if (widget.patients != null) {
      return widget.patients!;
    }
    final List<({BookedPatient patient, DoctorSchedule schedule})> fromStore =
        AmanahScheduleStore.instance.getAllHistoricalPatients();
    if (fromStore.isNotEmpty) {
      return fromStore;
    }
    // Fallback sample past patient record so the tab is never empty on test/demo
    const DoctorSchedule mockPastSchedule = DoctorSchedule(
      id: 'hist-sched-01',
      title: 'Sesi Pagi',
      date: 'Kamis, 24 September 2026',
      scheduleDate: '2026-09-24',
      time: '08:00 - 11:30 WIB',
      poli: 'Poli Umum',
      room: 'Ruang 101, Gedung A',
      slotCount: '1',
      slotText: '1 Pasien',
      badge: 'Selesai',
      badgeVariant: AmanahBadgeVariant.success,
    );
    return const <({BookedPatient patient, DoctorSchedule schedule})>[
      (
        patient: BookedPatient(
          id: 'hist-pat-01',
          patientName: 'Siti Rahmawati',
          patientAge: '32 Thn',
          patientRm: 'RM-2026-0982',
          patientComplaint: 'Kontrol hasil lab darah lengkap dan evaluasi terapi',
          queueNumber: '#01',
          timeSlot: '08:00 - 08:30 WIB',
          badge: 'Selesai',
          badgeVariant: AmanahBadgeVariant.success,
          status: 'completed',
        ),
        schedule: mockPastSchedule,
      ),
    ];
  }

  List<({BookedPatient patient, DoctorSchedule schedule})> get _filteredPatients {
    final List<({BookedPatient patient, DoctorSchedule schedule})> all =
        _sourcePatients;
    if (_searchQuery.trim().isEmpty) {
      return all;
    }
    final String query = _searchQuery.toLowerCase();
    return all.where((({BookedPatient patient, DoctorSchedule schedule}) item) {
      final String name = item.patient.patientName.toLowerCase();
      final String rm = item.patient.patientRm.toLowerCase();
      final String complaint = item.patient.patientComplaint.toLowerCase();
      return name.contains(query) || rm.contains(query) || complaint.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    final Color textColor =
        dark ? AmanahColorTokens.pureWhite : AmanahColorTokens.neutral900;
    final Color subtextColor =
        dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500;

    final List<({BookedPatient patient, DoctorSchedule schedule})> patients =
        _filteredPatients;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header: Title and subtitle count
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Riwayat Pasien',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${patients.length} Pasien Telah Selesai Konsultasi',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: subtextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Search Field
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: dark
                  ? AmanahColorTokens.pureWhite.withValues(alpha: 0.05)
                  : AmanahColorTokens.surfaceLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: dark
                    ? AmanahColorTokens.pureWhite.withValues(alpha: 0.10)
                    : AmanahColorTokens.neutral200,
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (String val) => setState(() => _searchQuery = val),
              style: TextStyle(
                fontSize: 13,
                color: textColor,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                hintText: 'Cari nama pasien, no. RM, atau keluhan...',
                hintStyle: TextStyle(
                  fontSize: 12.5,
                  color: subtextColor,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: subtextColor,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (patients.isEmpty)
            AmanahEmptyState.box(
              title: _searchQuery.isNotEmpty
                  ? 'Pasien Tidak Ditemukan'
                  : 'Belum Ada Riwayat Pasien',
              message: _searchQuery.isNotEmpty
                  ? 'Tidak ditemukan pasien riwayat dengan kata kunci "$_searchQuery".'
                  : 'Pasien yang telah selesai menjalani konsultasi atau melewati waktu praktik akan otomatis tercatat di tab ini.',
              actionText: _searchQuery.isNotEmpty ? 'Hapus Pencarian' : null,
              onAction: _searchQuery.isNotEmpty
                  ? () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    }
                  : null,
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: patients.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 14),
              itemBuilder: (BuildContext context, int index) {
                final ({BookedPatient patient, DoctorSchedule schedule}) item =
                    patients[index];
                return AmanahBookedPatientCard(
                  patient: item.patient,
                  schedule: item.schedule,
                  imageIndex: index,
                  onTapDetail: () {
                    AmanahPatientDetailModal.show(
                      context,
                      item.patient,
                      item.schedule,
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}
