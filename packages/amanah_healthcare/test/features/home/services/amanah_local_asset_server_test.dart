import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/home/services/amanah_local_asset_server.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AmanahLocalAssetServer Tests', () {
    final AmanahLocalAssetServer server = AmanahLocalAssetServer.instance;

    HttpOverrides? originalOverrides;

    setUp(() {
      originalOverrides = HttpOverrides.current;
      HttpOverrides.global = null;
    });

    tearDown(() async {
      HttpOverrides.global = originalOverrides;
      await server.stop();
    });

    test('starts local server and returns valid loopback URI', () async {
      expect(server.isRunning, isFalse);

      final Uri baseUri = await server.getBaseUri();
      expect(server.isRunning, isTrue);
      expect(baseUri.scheme, equals('http'));
      expect(baseUri.host, equals('127.0.0.1'));
      expect(baseUri.port, isPositive);
      expect(server.port, equals(baseUri.port));

      // Calling getBaseUri again should return the same URI without restarting
      final Uri secondUri = await server.getBaseUri();
      expect(secondUri, equals(baseUri));
    });

    test('serves index.html with immutable caching headers', () async {
      final Uri baseUri = await server.getBaseUri();
      final HttpClient client = HttpClient();

      try {
        final HttpClientRequest request = await client.getUrl(
          baseUri.resolve('/index.html'),
        );
        final HttpClientResponse response = await request.close();

        expect(response.statusCode, equals(HttpStatus.ok));
        expect(response.headers.contentType?.mimeType, equals('text/html'));
        expect(
          response.headers.value(HttpHeaders.cacheControlHeader),
          contains('max-age=31536000'),
        );
        expect(
          response.headers.value(HttpHeaders.cacheControlHeader),
          contains('immutable'),
        );
        expect(
          response.headers.value('Access-Control-Allow-Origin'),
          equals('*'),
        );
      } finally {
        client.close();
      }
    });

    test('serves local vendor JS scripts with javascript content-type', () async {
      final Uri baseUri = await server.getBaseUri();
      final HttpClient client = HttpClient();

      try {
        final HttpClientRequest request = await client.getUrl(
          baseUri.resolve('/vendor/three.module.js'),
        );
        final HttpClientResponse response = await request.close();

        expect(response.statusCode, equals(HttpStatus.ok));
        expect(
          response.headers.contentType?.mimeType,
          equals('application/javascript'),
        );
      } finally {
        client.close();
      }
    });

    test('blocks directory traversal attacks with 404', () async {
      final Uri baseUri = await server.getBaseUri();
      final HttpClient client = HttpClient();

      try {
        final HttpClientRequest request = await client.getUrl(
          baseUri.resolve('/../pubspec.yaml'),
        );
        final HttpClientResponse response = await request.close();

        expect(response.statusCode, equals(HttpStatus.notFound));
      } finally {
        client.close();
      }
    });

    test('stops and can restart gracefully', () async {
      await server.getBaseUri();
      expect(server.isRunning, isTrue);

      await server.stop();
      expect(server.isRunning, isFalse);

      final Uri newUri = await server.getBaseUri();
      expect(server.isRunning, isTrue);
      expect(newUri.port, isPositive);
    });
  });
}
