import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/presence/presentation/screen/amanah_qr_scanner_tab_screen.dart';
import 'package:amanah_healthcare/helpers/global_vars.dart';
import 'package:scanner_shared/scanner_shared.dart';

class _FakeScannerHardwareController implements ScannerHardwareController {
  bool _torch = false;
  bool _front = false;
  final ValueNotifier<bool?> _torchNotifier = ValueNotifier<bool?>(false);

  @override
  bool get isFrontCamera => _front;

  @override
  bool get isTorchOn => _torch;

  @override
  Future<void> switchCamera() async {
    _front = !_front;
  }

  @override
  Future<void> toggleTorch() async {
    _torch = !_torch;
    _torchNotifier.value = _torch;
  }

  @override
  ValueNotifier<bool?> get torchState => _torchNotifier;
}

class _FakeScanner extends Scanner {
  const _FakeScanner({this.emitSynchronouslyInInit = false});

  final bool emitSynchronouslyInInit;

  @override
  String getType() => 'FakeScanner';

  @override
  Widget getScanner({
    required Future<bool> Function(String) onScan,
    required Future<void> Function() hapticFeedback,
    required Function(BuildContext)? onCameraFlashError,
    required Function(String msg, String category, {String? barcode, int? eventValue})
        trackCustomEvent,
    required bool hasMoreThanOneCamera,
    required Widget barcodeScannerIcon,
    required Widget torchOnIcon,
    required Widget torchOffIcon,
    Color? visorColor,
    String? toggleCameraModeTooltip,
    String? toggleFlashModeTooltip,
    EdgeInsetsGeometry? contentPadding,
    void Function(ScannerHardwareController controller)? onScannerCreated,
    bool showDefaultVisor = true,
    bool showDefaultBottomControls = true,
  }) {
    return _FakeScannerWidget(
      onScannerCreated: onScannerCreated,
      emitSynchronouslyInInit: emitSynchronouslyInInit,
    );
  }
}

class _FakeScannerWidget extends StatefulWidget {
  const _FakeScannerWidget({
    this.onScannerCreated,
    required this.emitSynchronouslyInInit,
  });

  final void Function(ScannerHardwareController controller)? onScannerCreated;
  final bool emitSynchronouslyInInit;

  @override
  State<_FakeScannerWidget> createState() => _FakeScannerWidgetState();
}

class _FakeScannerWidgetState extends State<_FakeScannerWidget> {
  final _FakeScannerHardwareController _controller =
      _FakeScannerHardwareController();

  @override
  void initState() {
    super.initState();
    if (widget.emitSynchronouslyInInit) {
      widget.onScannerCreated?.call(_controller);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onScannerCreated?.call(_controller);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(color: Colors.black);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GlobalVars.barcodeScanner = const _FakeScanner(emitSynchronouslyInInit: false);
  });

  testWidgets(
    'AmanahQrScannerTabScreen mounts cleanly without setState during build assertion',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmanahQrScannerTabScreen(
              enableCameraScanner: true,
              animateLaser: false,
            ),
          ),
        ),
      );

      // Verify no assertion was thrown during first layout/build
      expect(tester.takeException(), isNull);

      // Advance one frame for post-frame callbacks
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      expect(find.byType(AmanahQrScannerTabScreen), findsOneWidget);
    },
  );

  testWidgets(
    'AmanahQrScannerTabScreen handles synchronous producer emission safely via ValueNotifier without crash',
    (WidgetTester tester) async {
      GlobalVars.barcodeScanner =
          const _FakeScanner(emitSynchronouslyInInit: true);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmanahQrScannerTabScreen(
              enableCameraScanner: true,
              animateLaser: false,
            ),
          ),
        ),
      );

      // Even if producer emits synchronously, consumer uses ValueNotifier
      // so no setState is invoked on dirty parent
      expect(tester.takeException(), isNull);

      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    },
  );
}
