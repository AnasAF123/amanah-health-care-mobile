import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_edit_profile_drawer.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';

void main() {
  group('AmanahBottomSheetScaffold Global Tap-Outside Dismissal Tests', () {
    testWidgets('Tapping outside the drawer dismisses the drawer', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () {
                    showAmanahBottomSheet<void>(
                      context: context,
                      builder: (BuildContext ctx) {
                        return const AmanahBottomSheetScaffold(
                          title: 'Test Modal Drawer',
                          subtitle: 'Testing outside tap',
                          fixedHeightFactor: 0.5,
                          body: Center(child: Text('Drawer Body Content')),
                        );
                      },
                    );
                  },
                  child: const Text('Open Drawer'),
                );
              },
            ),
          ),
        ),
      );

      // Open drawer
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();

      expect(find.byType(AmanahBottomSheetScaffold), findsOneWidget);
      expect(find.text('Test Modal Drawer'), findsOneWidget);
      expect(find.text('Drawer Body Content'), findsOneWidget);

      // Tap outside the drawer (top area of screen, e.g. y = 50)
      await tester.tapAt(const Offset(200, 50));
      await tester.pumpAndSettle();

      // Drawer should be dismissed
      expect(find.byType(AmanahBottomSheetScaffold), findsNothing);
      expect(find.text('Test Modal Drawer'), findsNothing);
    });

    testWidgets('Tapping inside the drawer does NOT dismiss the drawer', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      int buttonTapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () {
                    showAmanahBottomSheet<void>(
                      context: context,
                      builder: (BuildContext ctx) {
                        return AmanahBottomSheetScaffold(
                          title: 'Test Modal Drawer',
                          fixedHeightFactor: 0.5,
                          body: Column(
                            children: <Widget>[
                              const Text('Drawer Body Content'),
                              ElevatedButton(
                                onPressed: () => buttonTapCount++,
                                child: const Text('Inside Button'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: const Text('Open Drawer'),
                );
              },
            ),
          ),
        ),
      );

      // Open drawer
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();

      expect(find.byType(AmanahBottomSheetScaffold), findsOneWidget);

      // Tap inside button
      await tester.tap(find.text('Inside Button'));
      await tester.pumpAndSettle();

      expect(buttonTapCount, 1);
      // Drawer is still visible!
      expect(find.byType(AmanahBottomSheetScaffold), findsOneWidget);

      // Tap on empty space inside drawer content
      await tester.tap(find.text('Drawer Body Content'));
      await tester.pumpAndSettle();

      // Drawer is STILL visible!
      expect(find.byType(AmanahBottomSheetScaffold), findsOneWidget);
    });
  });

  group('AmanahAvatarPhotoSheet Tests', () {
    testWidgets('Renders all options correctly when hasCustomAvatar is false', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () => AmanahAvatarPhotoSheet.show(context),
                  child: const Text('Open Avatar Sheet'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Avatar Sheet'));
      await tester.pumpAndSettle();

      expect(find.byType(AmanahAvatarPhotoSheet), findsOneWidget);
      expect(find.text('Foto Profil Dokter'), findsOneWidget);
      expect(
        find.text('Pilih kamera, galeri, file disk, atau preset avatar'),
        findsOneWidget,
      );
      expect(find.text('Ambil Foto dari Kamera'), findsOneWidget);
      expect(find.text('Pilih dari Galeri Perangkat'), findsOneWidget);
      expect(find.text('Pilih dari File Explorer / Disk HP'), findsOneWidget);
      expect(find.text('Atau Pilih Preset Avatar Klinis'), findsOneWidget);
      expect(find.text('Gunakan Foto Default'), findsOneWidget);

      // Tap outside to close
      await tester.tapAt(const Offset(200, 50));
      await tester.pumpAndSettle();

      expect(find.byType(AmanahAvatarPhotoSheet), findsNothing);
    });

    testWidgets('Renders Hapus Foto Profil option when hasCustomAvatar is true', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      AmanahAvatarPhotoResult? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () async {
                    result = await AmanahAvatarPhotoSheet.show(
                      context,
                      hasCustomAvatar: true,
                    );
                  },
                  child: const Text('Open Custom Avatar Sheet'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Custom Avatar Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Hapus Foto Profil (Gunakan Inisial)'), findsOneWidget);
      expect(find.text('Gunakan Foto Default'), findsNothing);

      // Tap Hapus Foto Profil
      await tester.tap(find.text('Hapus Foto Profil (Gunakan Inisial)'));
      await tester.pumpAndSettle();

      expect(find.byType(AmanahAvatarPhotoSheet), findsNothing);
      expect(result, isNotNull);
      expect(result!.isReset, isTrue);
      expect(result!.isDelete, isTrue);
    });
  });
}
