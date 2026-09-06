import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Singleton high-performance local HTTP server that serves web assets
/// (Three.js, Rapier WASM, GLB models, textures) from Flutter's [rootBundle]
/// with immutable long-lived HTTP caching headers.
class AmanahLocalAssetServer {
  AmanahLocalAssetServer._();

  static final AmanahLocalAssetServer instance = AmanahLocalAssetServer._();

  HttpServer? _server;
  Completer<Uri>? _startCompleter;

  bool get isRunning => _server != null;
  int? get port => _server?.port;

  /// Returns the base URI (e.g. `http://127.0.0.1:port`) for the running server.
  /// Starts the server if it has not been started yet.
  Future<Uri> getBaseUri() async {
    if (_server != null) {
      return Uri.parse('http://127.0.0.1:${_server!.port}');
    }

    if (_startCompleter != null) {
      return _startCompleter!.future;
    }

    _startCompleter = Completer<Uri>();
    try {
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      _server!.idleTimeout = null;
      _server!.listen(
        _handleRequest,
        onError: (Object error, StackTrace stack) {
          debugPrint('AmanahLocalAssetServer error: $error\n$stack');
        },
      );
      final Uri baseUri = Uri.parse('http://127.0.0.1:${_server!.port}');
      _startCompleter!.complete(baseUri);
      return baseUri;
    } catch (error, stack) {
      _startCompleter!.completeError(error, stack);
      _startCompleter = null;
      rethrow;
    }
  }

  Future<void> _handleRequest(HttpRequest request) async {
    final String? assetKey = _assetKeyForRequestPath(request.uri.path);

    try {
      if (assetKey == null) {
        request.response.statusCode = HttpStatus.notFound;
        request.response.write('Asset not found');
        return;
      }

      final ByteData data = await rootBundle.load(assetKey);
      final Uint8List bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );

      request.response.headers.contentType = _contentTypeFor(assetKey);
      request.response.headers.set(
        HttpHeaders.cacheControlHeader,
        'public, max-age=31536000, immutable',
      );
      request.response.headers.set('Access-Control-Allow-Origin', '*');
      request.response.add(bytes);
    } catch (error) {
      request.response.statusCode = HttpStatus.notFound;
      request.response.write('Asset not found: $assetKey');
    } finally {
      await request.response.close();
    }
  }

  String? _assetKeyForRequestPath(String requestPath) {
    String path = requestPath.isEmpty || requestPath == '/'
        ? '/index.html'
        : Uri.decodeComponent(requestPath);
    path = path.replaceAll(r'\', '/');
    if (path.contains('..')) {
      return null;
    }
    return 'assets/amanah/id_card/web${path.startsWith('/') ? path : '/$path'}';
  }

  ContentType _contentTypeFor(String assetKey) {
    if (assetKey.endsWith('.html')) {
      return ContentType.html;
    }
    if (assetKey.endsWith('.js')) {
      return ContentType('application', 'javascript', charset: 'utf-8');
    }
    if (assetKey.endsWith('.wasm')) {
      return ContentType('application', 'wasm');
    }
    if (assetKey.endsWith('.glb')) {
      return ContentType('model', 'gltf-binary');
    }
    if (assetKey.endsWith('.png')) {
      return ContentType('image', 'png');
    }
    if (assetKey.endsWith('.svg')) {
      return ContentType('image', 'svg+xml');
    }
    return ContentType.binary;
  }

  /// Stops the running server (useful for tests or teardown).
  Future<void> stop() async {
    if (_server != null) {
      await _server!.close(force: true);
      _server = null;
    }
    _startCompleter = null;
  }
}
