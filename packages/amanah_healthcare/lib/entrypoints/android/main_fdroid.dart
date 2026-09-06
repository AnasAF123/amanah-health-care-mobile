import 'package:app_store_uri/app_store_uri.dart';
import 'package:scanner_zxing/scanner_zxing.dart';
import 'package:amanah_healthcare/helpers/entry_points_helper.dart';
import 'package:amanah_healthcare/main.dart';

/// Fdroid version with:
/// - Barcode decoding algorithm: ZXing
/// - Intent to launch the review
void main() {
  launchAmanahApp(
    barcodeScanner: const ScannerZXing(),
    appStore: URIAppStore(
      Uri.parse(
        'https://f-droid.org/en/packages/com.amanah.healthcare/',
      ),
    ),
    scannerLabel: ScannerLabel.ZXing,
    storeLabel: StoreLabel.FDroid,
  );
}
