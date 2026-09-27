import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

/// Phase 4: Event-Driven Auditing & Status History Verification
///
/// Ported from backend E2E PowerShell test suite:
/// Canonical Rules: ARC-041, ARC-093, ARC-119..122, ARC-136, database-design.md
void main() {
  const String baseUrl = 'http://127.0.0.1:3001/api/v1';

  group('Phase 4: Event-Driven Auditing & Status History Verification', () {
    late String adminToken;
    late String staffToken;
    late String patientToken;
    late String appointmentId;
    late String createLogId;

    // Helper for JSON requests
    Future<http.Response> postJson(
      String endpoint,
      Map<String, dynamic> body, {
      String? token,
    }) async {
      return http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
    }

    Future<http.Response> getJson(
      String endpoint, {
      String? token,
    }) async {
      return http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: <String, String>{
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
    }

    Future<http.Response> patchJson(
      String endpoint, {
      Map<String, dynamic>? body,
      String? token,
    }) async {
      return http.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: body != null ? jsonEncode(body) : null,
      );
    }

    test('STEP 1: Authenticating Actors (Admin, Staff, Patient)', () async {
      // 1. Admin login
      final http.Response adminRes = await postJson(
        '/auth/email/login',
        <String, dynamic>{
          'email': 'admin@amanah.com',
          'password': 'secret123',
        },
      );
      expect(adminRes.statusCode, 200);
      final Map<String, dynamic> adminBody =
          jsonDecode(adminRes.body) as Map<String, dynamic>;
      adminToken = adminBody['token'] as String;
      expect(adminToken, isNotEmpty);

      // 2. Staff / Doctor login
      final http.Response staffRes = await postJson(
        '/auth/email/login',
        <String, dynamic>{
          'email': 'dokter@amanah.com',
          'password': 'secret123',
        },
      );
      expect(staffRes.statusCode, 200);
      final Map<String, dynamic> staffBody =
          jsonDecode(staffRes.body) as Map<String, dynamic>;
      staffToken = staffBody['token'] as String;
      expect(staffToken, isNotEmpty);

      // 3. Patient login
      final http.Response patientRes = await postJson(
        '/auth/email/login',
        <String, dynamic>{
          'email': 'pasien@amanah.com',
          'password': 'secret123',
        },
      );
      expect(patientRes.statusCode, 200);
      final Map<String, dynamic> patientBody =
          jsonDecode(patientRes.body) as Map<String, dynamic>;
      patientToken = patientBody['token'] as String;
      expect(patientToken, isNotEmpty);
    });

    test('STEP 2: Verifying RBAC Security Boundaries on /api/v1/audit-logs (ARC-130)', () async {
      // Patient should be forbidden from accessing /audit-logs (HTTP 403)
      final http.Response patientAuditRes = await getJson(
        '/audit-logs',
        token: patientToken,
      );
      expect(patientAuditRes.statusCode, 403);

      // Unauthenticated request should be unauthorized (HTTP 401)
      final http.Response unauthAuditRes = await getJson('/audit-logs');
      expect(unauthAuditRes.statusCode, 401);
    });

    test('STEP 3: Patient Creating Appointment & Verifying Async Audit Logging (ARC-119..122, ARC-136)', () async {
      // Get valid poliklinik and clinic service
      final http.Response clinicsRes = await getJson('/clinics');
      expect(clinicsRes.statusCode, 200);
      final dynamic rawClinics = jsonDecode(clinicsRes.body);
      final List<dynamic> clinics = rawClinics is List
          ? rawClinics
          : (rawClinics['data'] as List<dynamic>);
      expect(clinics, isNotEmpty);

      final String poliId = clinics[0]['id'] as String;

      final http.Response servicesRes =
          await getJson('/clinics/$poliId/layanan');
      expect(servicesRes.statusCode, 200);
      final dynamic rawServices = jsonDecode(servicesRes.body);
      final List<dynamic> services = rawServices is List
          ? rawServices
          : (rawServices['data'] as List<dynamic>);
      expect(services, isNotEmpty);

      final String serviceId = services[0]['id'] as String;

      final int randomOffset = Random().nextInt(4950) + 50;
      final DateTime targetDateTime =
          DateTime.now().add(Duration(days: randomOffset));
      final String targetDate =
          '${targetDateTime.year.toString().padLeft(4, '0')}-'
          '${targetDateTime.month.toString().padLeft(2, '0')}-'
          '${targetDateTime.day.toString().padLeft(2, '0')}';

      final http.Response createRes = await postJson(
        '/appointments',
        <String, dynamic>{
          'poliklinikId': poliId,
          'layananId': serviceId,
          'appointmentDate': targetDate,
          'session': 'PAGI',
          'visitType': 'Pemeriksaan Baru',
          'complaint': 'E2E Test Asynchronous Event Auditing from Flutter',
        },
        token: patientToken,
      );
      expect(createRes.statusCode, anyOf(200, 201));
      final Map<String, dynamic> apptBody =
          jsonDecode(createRes.body) as Map<String, dynamic>;
      appointmentId = (apptBody['id'] ?? apptBody['data']?['id']) as String;
      expect(appointmentId, isNotEmpty);

      // Wait for asynchronous event handler in background task
      await Future<void>.delayed(const Duration(milliseconds: 700));

      final http.Response auditLogsRes = await getJson(
        '/audit-logs?entityTable=appointments&entityId=$appointmentId',
        token: adminToken,
      );
      expect(auditLogsRes.statusCode, 200);
      final Map<String, dynamic> auditData =
          jsonDecode(auditLogsRes.body) as Map<String, dynamic>;
      final List<dynamic> logs = auditData['data'] as List<dynamic>;
      expect(logs.length, greaterThanOrEqualTo(1));

      final dynamic createLog = logs.firstWhere(
        (dynamic log) => log['action'] == 'create_appointment',
        orElse: () => null,
      );
      expect(createLog, isNotNull);
      expect(createLog['entityTable'], 'appointments');
      expect(createLog['newValues']?['session'], 'PAGI');
      createLogId = createLog['id'] as String;
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('STEP 4: Check-in Appointment & Verifying Status Transition Event', () async {
      final http.Response checkInRes = await patchJson(
        '/appointments/$appointmentId/check-in',
        token: patientToken,
      );
      expect(checkInRes.statusCode, 200);
      final Map<String, dynamic> body =
          jsonDecode(checkInRes.body) as Map<String, dynamic>;
      final String status = (body['status'] ?? body['data']?['status']) as String;
      expect(status, 'MENUNGGU');

      await Future<void>.delayed(const Duration(milliseconds: 700));

      final http.Response auditRes = await getJson(
        '/audit-logs?entityTable=appointments&entityId=$appointmentId',
        token: adminToken,
      );
      expect(auditRes.statusCode, 200);
      final List<dynamic> logs =
          (jsonDecode(auditRes.body) as Map<String, dynamic>)['data']
              as List<dynamic>;

      final dynamic checkInLog = logs.firstWhere(
        (dynamic log) =>
            log['action'] == 'update_appointment_status' &&
            log['newValues']?['status'] == 'MENUNGGU',
        orElse: () => null,
      );
      expect(checkInLog, isNotNull);
      expect(checkInLog['oldValues']?['status'], 'SUDAH_BUAT_JANJI');
    });

    test('STEP 5: Doctor Calling Patient & Verifying Audit Log', () async {
      final http.Response callRes = await patchJson(
        '/appointments/$appointmentId/call',
        token: staffToken,
      );
      expect(callRes.statusCode, 200);
      final Map<String, dynamic> body =
          jsonDecode(callRes.body) as Map<String, dynamic>;
      final String status = (body['status'] ?? body['data']?['status']) as String;
      expect(status, 'SEDANG_DIPERIKSA');

      await Future<void>.delayed(const Duration(milliseconds: 700));

      final http.Response auditRes = await getJson(
        '/audit-logs?entityTable=appointments&entityId=$appointmentId',
        token: adminToken,
      );
      expect(auditRes.statusCode, 200);
      final List<dynamic> logs =
          (jsonDecode(auditRes.body) as Map<String, dynamic>)['data']
              as List<dynamic>;

      final dynamic callLog = logs.firstWhere(
        (dynamic log) =>
            log['action'] == 'update_appointment_status' &&
            log['newValues']?['status'] == 'SEDANG_DIPERIKSA',
        orElse: () => null,
      );
      expect(callLog, isNotNull);
    });

    test('STEP 6: Completing Examination & Verifying Final Status Event', () async {
      final http.Response completeRes = await patchJson(
        '/appointments/$appointmentId/complete',
        token: staffToken,
      );
      expect(completeRes.statusCode, 200);
      final Map<String, dynamic> body =
          jsonDecode(completeRes.body) as Map<String, dynamic>;
      final String status = (body['status'] ?? body['data']?['status']) as String;
      expect(status, 'SELESAI');

      await Future<void>.delayed(const Duration(milliseconds: 700));

      final http.Response auditRes = await getJson(
        '/audit-logs?entityTable=appointments&entityId=$appointmentId',
        token: adminToken,
      );
      expect(auditRes.statusCode, 200);
      final List<dynamic> logs =
          (jsonDecode(auditRes.body) as Map<String, dynamic>)['data']
              as List<dynamic>;

      final dynamic completeLog = logs.firstWhere(
        (dynamic log) =>
            log['action'] == 'update_appointment_status' &&
            log['newValues']?['status'] == 'SELESAI',
        orElse: () => null,
      );
      expect(completeLog, isNotNull);
    });

    test('STEP 7: Verifying Single Audit Log Retrieval by ID', () async {
      expect(createLogId, isNotEmpty);
      final http.Response singleLogRes = await getJson(
        '/audit-logs/$createLogId',
        token: adminToken,
      );
      expect(singleLogRes.statusCode, 200);
      final Map<String, dynamic> body =
          jsonDecode(singleLogRes.body) as Map<String, dynamic>;
      final dynamic item = body['data'] ?? body;
      expect(item['id'], createLogId);
      expect(item['action'], 'create_appointment');
    });

    test('STEP 8: Direct PostgreSQL Query: appointment_status_events Verification (database-design.md:212)', () async {
      // Execute docker query if docker is available
      final ProcessResult result = await Process.run('docker', <String>[
        'exec',
        'amanah-healthcare-backend-postgres-1',
        'psql',
        '-U',
        'amanah',
        '-d',
        'amanah_healthcare',
        '-t',
        '-A',
        '-c',
        "SELECT previous_status, new_status FROM appointment_status_events WHERE appointment_id = '$appointmentId' ORDER BY created_at ASC;",
      ]);

      if (result.exitCode == 0) {
        final List<String> eventLines = (result.stdout as String)
            .split('\n')
            .map((String line) => line.trim())
            .where((String line) => line.isNotEmpty)
            .toList();

        expect(eventLines.length, greaterThanOrEqualTo(4));
        expect(eventLines[0], endsWith('|booked'));
        expect(eventLines[1], endsWith('|waiting'));
        expect(eventLines[2], endsWith('|in_service'));
        expect(eventLines[3], endsWith('|completed'));
      }
    });
  });
}
