import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_booked_patient_card.dart';

void main() {
  const DoctorSchedule mockSchedule = DoctorSchedule(
    id: 'sch-1',
    title: 'Sesi SIANG',
    date: 'Sabtu, 17 Okt 2026',
    time: '12:00',
    poli: 'Poli Umum',
    room: 'Ruang Poli Umum 1',
    badge: 'Terdaftar',
    badgeVariant: AmanahBadgeVariant.primary,
  );

  Widget createCardWidget(BookedPatient patient) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: AmanahBookedPatientCard(
            patient: patient,
            schedule: mockSchedule,
            imageIndex: 0,
            onTapDetail: () {},
          ),
        ),
      ),
    );
  }

  testWidgets('renders Estimasi Giliran when patient is not completed', (
    WidgetTester tester,
  ) async {
    const BookedPatient uncompletedPatient = BookedPatient(
      id: 'apt-1',
      patientName: 'Riza',
      patientRm: 'RM-123',
      patientAge: '24',
      patientComplaint: 'Batuk pilek',
      queueNumber: 'USG-S001',
      timeSlot: '12:00 - 18:00',
      badge: 'Menunggu',
      badgeVariant: AmanahBadgeVariant.primary,
      status: 'BOOKED',
      etaRange: '18:00 - 18:30 WIB',
      poliklinikName: 'Poli Umum',
    );

    await tester.pumpWidget(createCardWidget(uncompletedPatient));
    await tester.pumpAndSettle();

    expect(find.text('Estimasi Giliran'), findsOneWidget);
    expect(find.text('18:00 - 18:30 WIB'), findsOneWidget);
    expect(find.text('Poli Umum'), findsOneWidget);
    expect(find.text('Ruang Poli Umum 1'), findsOneWidget);

    // Mulai & Selesai should NOT be rendered when uncompleted
    expect(find.text('Mulai'), findsNothing);
    expect(find.text('Selesai'), findsNothing);
  });

  testWidgets('renders Mulai & Selesai when patient is completed', (
    WidgetTester tester,
  ) async {
    const BookedPatient completedPatient = BookedPatient(
      id: 'apt-2',
      patientName: 'Riza Selesai',
      patientRm: 'RM-123',
      patientAge: '24',
      patientComplaint: 'Batuk pilek',
      queueNumber: 'USG-S001',
      timeSlot: '12:00 - 18:00',
      badge: 'Selesai',
      badgeVariant: AmanahBadgeVariant.success,
      status: 'COMPLETED',
      actualStartedAt: '2026-10-17T11:00:00.000Z',
      actualCompletedAt: '2026-10-17T11:25:00.000Z',
      poliklinikName: 'Poli Umum',
    );

    await tester.pumpWidget(createCardWidget(completedPatient));
    await tester.pumpAndSettle();

    expect(find.text('Mulai'), findsOneWidget);
    // 'Selesai' appears in both the status badge and the column label
    expect(find.text('Selesai'), findsNWidgets(2));
    expect(find.text('Estimasi Giliran'), findsNothing);
  });
}
