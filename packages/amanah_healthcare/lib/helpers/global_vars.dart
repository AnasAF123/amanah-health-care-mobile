import 'package:flutter/material.dart';
import 'package:app_store_shared/app_store_shared.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:amanah_healthcare/helpers/entry_points_helper.dart';

class GlobalVars {
  GlobalVars._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static late Scanner barcodeScanner;
  static late AppStore appStore;
  static late StoreLabel storeLabel;
  static late ScannerLabel scannerLabel;
}
