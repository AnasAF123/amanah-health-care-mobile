import 'package:app_store_uri/app_store_uri.dart';
import 'package:scanner_zxing/scanner_zxing.dart';
import 'package:amanah_healthcare/helpers/entry_points_helper.dart';
import 'package:amanah_healthcare/main.dart';

/// Amazon App Store version with:
/// - Barcode decoding algorithm: ZXing
/// - Intent to launch the review
void main() {
  launchAmanahApp(
    barcodeScanner: const ScannerZXing(),
    appStore: URIAppStore(
      Uri.parse(
        'https://www.amazon.com/gp/mas/dl/android?p=com.amanah.healthcare',
      ),
    ),
    scannerLabel: ScannerLabel.ZXing,
    storeLabel: StoreLabel.AmazonAppStore,
  );
}
