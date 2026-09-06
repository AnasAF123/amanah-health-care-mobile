import 'package:app_store_google_play/app_store_google.dart';
import 'package:scanner_ml_kit/scanner_ml_kit.dart';
import 'package:amanah_healthcare/helpers/entry_points_helper.dart';
import 'package:amanah_healthcare/main.dart';

/// Google Play version with:
/// - Barcode decoding algorithm: MLKit
/// - Google Play app review SDK
void main() {
  launchAmanahApp(
    barcodeScanner: const ScannerMLKit(),
    appStore: GooglePlayStore(),
    scannerLabel: ScannerLabel.MLKit,
    storeLabel: StoreLabel.GooglePlayStore,
  );
}
