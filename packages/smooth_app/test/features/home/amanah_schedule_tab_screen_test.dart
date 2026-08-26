import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/features/authentication/domain/amanah_auth_user.dart';
import 'package:smooth_app/features/home/presentation/screen/amanah_home_shell.dart';
import 'package:smooth_app/features/home/presentation/screen/amanah_schedule_tab_screen.dart';
import 'package:smooth_app/features/schedule/data/amanah_schedule_store.dart';
import 'package:smooth_app/features/schedule/presentation/components/amanah_schedule_cards_and_drawers.dart';
import 'package:smooth_app/features/schedule/presentation/components/amanah_schedule_form_and_calendar_dialog.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  const AmanahAuthUser testUser = AmanahAuthUser(
    id: 'doc-001',
    role: AmanahUserRole.doctor,
    fullName: 'dr. Andika Perkasa',
    email: 'dokter@amanah.health',
    phone: '081234567890',
    password: 'password123',
  );

  setUp(() {
    AmanahScheduleStore.instance.reset();
  });

  Widget createScheduleScreen({Brightness brightness = Brightness.light}) {
    return MaterialApp(
      theme: ThemeData(
        brightness: brightness,
        fontFamily: 'PlusJakartaSans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A44FF),
          brightness: brightness,
        ),
      ),
      home: const AmanahScheduleTabScreen(),
    );
  }

  group('Amanah Schedule Tab Screen Tests', () {
    testWidgets(
      'Renders header, radial capacity gauge, date carousel strip, and patient showcase cards',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() => tester.view.reset());

        await tester.pumpWidget(createScheduleScreen());
        await tester.pumpAndSettle();

        // Screen Header
        expect(find.text('Jadwal Praktik'), findsOneWidget);

        // Radial Capacity Gauge
        expect(find.text('Kapasitas Hari Ini'), findsOneWidget);
        expect(find.text('Lihat Schedule'), findsOneWidget);

        // Booked Patients Showcase on Aug 26
        expect(find.text('Steven Pratama'), findsOneWidget);
        expect(find.text('Antrean #01'), findsWidgets);
        expect(find.text('Detail Pasien'), findsWidgets);
      },
    );

    testWidgets('Tapping Lihat Schedule opens Big Calendar Drawer', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createScheduleScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lihat Schedule'));
      await tester.pumpAndSettle();

      expect(find.byType(AmanahDocScheduleCalendarDrawer), findsOneWidget);
      expect(find.text('Kalender Jadwal Praktik'), findsOneWidget);
    });

    testWidgets('Tapping Detail Pasien opens patient complaint detail modal', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createScheduleScreen());
      await tester.pumpAndSettle();

      final Finder detailButtons = find.text('Detail Pasien');
      expect(detailButtons, findsWidgets);

      await tester.tap(detailButtons.first);
      await tester.pumpAndSettle();

      expect(find.byType(AmanahPatientDetailModal), findsOneWidget);
      expect(find.text('Detail Rekam Pasien'), findsOneWidget);
      expect(find.text('Keluhan & Catatan Medis Pasien'), findsOneWidget);
    });

    testWidgets('Tapping + icon button opens Add Schedule drawer', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createScheduleScreen());
      await tester.pumpAndSettle();

      final Finder addButtons = find.byIcon(Icons.add);
      expect(addButtons, findsOneWidget);

      await tester.tap(addButtons);
      await tester.pumpAndSettle();

      expect(find.byType(AmanahAddEditScheduleDrawer), findsOneWidget);
      expect(find.text('Tambah Jadwal'), findsWidgets);
      expect(find.text('Tanggal Praktik'), findsOneWidget);
      expect(find.text('Sesi Praktik & Jam'), findsOneWidget);
    });

    testWidgets(
      'Bottom navigation bar Jadwal tab navigates to Schedule Tab screen',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() => tester.view.reset());

        await tester.pumpWidget(
          const MaterialApp(home: AmanahHomeShell(user: testUser)),
        );
        await tester.pumpAndSettle();

        // Tap Jadwal in bottom navigation bar
        await tester.tap(find.text('Jadwal'));
        await tester.pumpAndSettle();

        expect(find.byType(AmanahScheduleTabScreen), findsOneWidget);
        expect(find.text('Kapasitas Hari Ini'), findsOneWidget);
      },
    );
  });
}

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _TestHttpClient();
  }
}

class _TestHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) =>
      Future<HttpClientRequest>.value(_TestHttpClientRequest());
}

class _TestHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  HttpHeaders headers = _TestHttpHeaders();

  @override
  Future<HttpClientResponse> close() =>
      Future<HttpClientResponse>.value(_TestHttpClientResponse());
}

class _TestHttpHeaders extends Fake implements HttpHeaders {
  @override
  List<String>? operator [](String name) => null;
}

class _TestHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  static final Uint8List _kTransparentImage = Uint8List.fromList(<int>[
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1F,
    0x15,
    0xC4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0A,
    0x49,
    0x44,
    0x41,
    0x54,
    0x78,
    0x9C,
    0x63,
    0x00,
    0x01,
    0x00,
    0x00,
    0x05,
    0x00,
    0x01,
    0x0D,
    0x0A,
    0x2D,
    0xB4,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
    0x42,
    0x60,
    0x82,
  ]);

  @override
  int get statusCode => 200;

  @override
  int get contentLength => _kTransparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  HttpHeaders get headers => _TestHttpHeaders();

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable(<List<int>>[
      _kTransparentImage,
    ]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
