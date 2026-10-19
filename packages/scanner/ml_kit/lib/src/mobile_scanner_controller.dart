import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:torch_light/torch_light.dart';

class CustomScannerController implements ScannerHardwareController {
  CustomScannerController({required MobileScannerController controller})
    : _controller = controller,
      _torchState = TorchState(),
      _availableCamerasState = AvailableCamerasState(),
      _cameraFacingState = CameraFacingState() {
    _detectTorch();
  }

  final MobileScannerController _controller;
  final TorchState _torchState;
  final AvailableCamerasState _availableCamerasState;
  final CameraFacingState _cameraFacingState;
  final ValueNotifier<double> _zoomState = ValueNotifier<double>(0.0);

  bool _isStarted = false;
  bool _isStarting = false;
  bool _isClosing = false;
  bool _isClosed = false;
  bool _isListening = false;
  bool _pendingStart = false;
  bool _pendingStop = false;
  double _currentZoom = 0.0;

  Future<void> start() async {
    if (isStarted) {
      return;
    }
    if (_isClosing) {
      _pendingStart = true;
      _pendingStop = false;
      return;
    }
    if (_isStarting) {
      return;
    }

    _isStarting = true;
    _isClosed = false;
    _pendingStart = false;

    try {
      if (!_isListening) {
        _controller.addListener(_onControllerChanged);
        _isListening = true;
      }
      await _controller.start();
      _isStarted = true;
      _onControllerChanged();

      if (isTorchOn) {
        Future<void>.delayed(const Duration(milliseconds: 250), () {
          turnTorchOn();
        });
      }
    } catch (_) {
      if (_isListening) {
        _controller.removeListener(_onControllerChanged);
        _isListening = false;
      }
      _isStarted = false;
    } finally {
      _isStarting = false;
      if (_pendingStop) {
        _pendingStop = false;
        unawaited(stop());
      }
    }
  }

  void _onControllerChanged() {
    _availableCamerasState.value = _controller.value.availableCameras ?? 0;
    _cameraFacingState.value = _controller.facing;
    final double reportedZoom = _controller.value.zoomScale;
    if (reportedZoom >= 0.0 && reportedZoom <= 1.0) {
      if (_currentZoom != reportedZoom) {
        _currentZoom = reportedZoom;
        _zoomState.value = reportedZoom;
      }
    }
  }

  MobileScannerController get controller => _controller;

  bool get isStarted => _isStarted;

  bool get isClosing => _isClosing;

  bool get isClosed => _isClosed;

  Future<void> stop() async {
    if (isClosed) {
      return;
    }
    if (_isStarting) {
      _pendingStop = true;
      _pendingStart = false;
      return;
    }
    if (_isClosing) {
      return;
    }

    _isClosing = true;
    _pendingStop = false;
    _isStarted = false;

    try {
      await _controller.stop();
      if (_isListening) {
        _controller.removeListener(_onControllerChanged);
        _isListening = false;
      }
      _isClosed = true;
    } catch (_) {
    } finally {
      _isClosing = false;
      if (_pendingStart) {
        _pendingStart = false;
        unawaited(start());
      }
    }
  }

  @override
  double get currentZoom => _currentZoom;

  @override
  ValueNotifier<double> get zoomState => _zoomState;

  @override
  Future<void> setZoomScale(double zoomScale) async {
    final double clamped = zoomScale.clamp(0.0, 1.0);
    _currentZoom = clamped;
    _zoomState.value = clamped;
    try {
      await _controller.setZoomScale(clamped);
    } catch (_) {}
  }

  @override
  Future<void> resetZoomScale() async {
    _currentZoom = 0.0;
    _zoomState.value = 0.0;
    try {
      await _controller.resetZoomScale();
    } catch (_) {}
  }

  @override
  Future<void> pauseCamera() => stop();

  @override
  Future<void> resumeCamera() => start();

  bool get hasTorch => _torchState.value != null;

  ValueNotifier<bool?> get hasTorchState => _torchState;

  @override
  bool get isTorchOn => _torchState.value == true;

  void turnTorchOff() {
    if (isTorchOn) {
      _controller.toggleTorch();
      _torchState.value = false;
    }
  }

  void turnTorchOn() {
    if (!isTorchOn) {
      _controller.toggleTorch();
      _torchState.value = true;
    }
  }

  @override
  Future<void> toggleTorch() async {
    if (isTorchOn) {
      turnTorchOff();
    } else {
      turnTorchOn();
    }
  }

  ValueNotifier<int> get availableCameras => _availableCamerasState;
  ValueNotifier<CameraFacing> get cameraFacing => _cameraFacingState;

  @override
  ValueNotifier<bool?> get torchState => _torchState;

  @override
  bool get isFrontCamera => _controller.facing == CameraFacing.front;

  @override
  Future<void> switchCamera() => toggleCamera();

  Future<void> toggleCamera() async {
    await _controller.switchCamera();
    if (_controller.facing == CameraFacing.front) {
      _torchState.value = null;
      _cameraFacingState.value = CameraFacing.front;
    } else if (_controller.facing == CameraFacing.back) {
      _torchState.value = false;
      _cameraFacingState.value = CameraFacing.back;
    }
  }

  Future<void> _detectTorch() async {
    try {
      final bool isTorchAvailable = await TorchLight.isTorchAvailable();
      if (isTorchAvailable) {
        _torchState.value = false;
      } else {
        _torchState.value = null;
      }
    } on Exception catch (_) {}
  }

  Future<void> dispose() => _controller.dispose();
}

class TorchState extends ValueNotifier<bool?> {
  TorchState({bool? value}) : super(value);
}

class AvailableCamerasState extends ValueNotifier<int> {
  AvailableCamerasState() : super(0);
}

class CameraFacingState extends ValueNotifier<CameraFacing> {
  CameraFacingState() : super(CameraFacing.back);
}
