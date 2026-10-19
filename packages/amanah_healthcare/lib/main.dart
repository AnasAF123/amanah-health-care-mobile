import 'dart:async';
import 'dart:io';

import 'package:app_store_apple_store/app_store_apple.dart';
import 'package:app_store_google_play/app_store_google.dart';
import 'package:app_store_shared/app_store_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_better_auth/flutter_better_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:scanner_ml_kit/scanner_ml_kit.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:amanah_healthcare/core/init/amanah_core_initializer.dart';
import 'package:amanah_healthcare/features/authentication/presentation/screen/auth_bottom_sheet_screen.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_typography_tokens.dart';
import 'package:amanah_healthcare/helpers/entry_points_helper.dart';
import 'package:amanah_healthcare/helpers/global_vars.dart';
import 'package:amanah_healthcare/helpers/permission_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isIOS || Platform.isMacOS) {
    launchAmanahApp(
      barcodeScanner: const ScannerMLKit(),
      appStore: AppleAppStore('588797948'),
      storeLabel: StoreLabel.AppleAppStore,
      scannerLabel: ScannerLabel.MLKit,
    );
  } else {
    // Default to Android Google Play / generic target
    launchAmanahApp(
      barcodeScanner: const ScannerMLKit(),
      appStore: GooglePlayStore(),
      scannerLabel: ScannerLabel.MLKit,
      storeLabel: StoreLabel.GooglePlayStore,
    );
  }
}

Future<void> launchAmanahApp({
  required Scanner barcodeScanner,
  required AppStore appStore,
  required StoreLabel storeLabel,
  required ScannerLabel scannerLabel,
  bool screenshots = false,
}) async {
  GlobalVars.barcodeScanner = barcodeScanner;
  GlobalVars.appStore = appStore;
  GlobalVars.storeLabel = storeLabel;
  GlobalVars.scannerLabel = scannerLabel;

  await AmanahCoreInitializer.initialize();

  runApp(const AmanahApp());
}

class AmanahApp extends StatefulWidget {
  const AmanahApp({super.key});

  @override
  State<AmanahApp> createState() => _AmanahAppState();
}

class _AmanahAppState extends State<AmanahApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<PermissionListener>(
          create: (_) => PermissionListener(permission: Permission.camera),
          lazy: true,
        ),
      ],
      child: BetterAuthProvider(
        child: MaterialApp(
          navigatorKey: GlobalVars.navigatorKey,
          debugShowCheckedModeBanner: true,
          title: 'Amanah Healthcare',
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: AmanahTypographyTokens.fontFamily,
            brightness: Brightness.light,
            scaffoldBackgroundColor: AmanahColorTokens.canvasLight,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AmanahColorTokens.brand,
              brightness: Brightness.light,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            fontFamily: AmanahTypographyTokens.fontFamily,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AmanahColorTokens.canvasDark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AmanahColorTokens.brand,
              brightness: Brightness.dark,
            ),
          ),
          themeMode: ThemeMode.system,
          home: const AuthBottomSheetScreen(),
        ),
      ),
    );
  }
}

typedef SmoothApp = AmanahApp;
const launchSmoothApp = launchAmanahApp;
