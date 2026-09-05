import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/features/authentication/domain/amanah_auth_user.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_bottom_navigation_bar.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_pull_to_refresh.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_screen_header.dart';
import 'package:smooth_app/features/home/presentation/screen/amanah_account_tab_screen.dart';
import 'package:smooth_app/features/permission/presentation/screen/amanah_leave_permission_tab_screen.dart';

void main() {
  const AmanahAuthUser testUser = AmanahAuthUser(
    id: 'u123',
    role: AmanahUserRole.doctor,
    fullName: 'dr. Rayhan Pratama, Sp.A',
    email: 'rayhan.pratama@rsamanah.co.id',
    phone: '+62 812-3456-7890',
    password: 'password123',
  );

  group('AmanahPullToRefresh Unit & Interaction Tests', () {
    testWidgets('Renders scrollable child and triggers onRefresh when dragged past threshold', (
      WidgetTester tester,
    ) async {
      bool refreshed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AmanahPullToRefresh(
              onRefresh: () async {
                refreshed = true;
              },
              child: ListView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                children: const <Widget>[
                  SizedBox(height: 100, child: Text('Item 1')),
                  SizedBox(height: 100, child: Text('Item 2')),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(refreshed, isFalse);

      // Drag downward to pull-to-refresh
      final TestGesture gesture = await tester.startGesture(const Offset(200, 200));
      await gesture.moveBy(const Offset(0, 150));
      await tester.pump();

      // Indicator painter should be active
      expect(find.byType(CustomPaint), findsWidgets);

      // Release to trigger refresh
      await gesture.up();
      await tester.pump();

      expect(refreshed, isTrue);

      // Settle back to idle
      await tester.pump(const Duration(milliseconds: 600));
    });

    testWidgets('AmanahLeavePermissionTabScreen mounts AmanahPullToRefresh in Expanded', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmanahLeavePermissionTabScreen(),
          ),
        ),
      );

      expect(find.byType(AmanahPullToRefresh), findsOneWidget);
      expect(find.byType(AmanahScreenHeader), findsOneWidget);
    });

    testWidgets('AmanahAccountTabScreen mounts pinned AmanahScreenHeader and AmanahPullToRefresh in Expanded', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AmanahAccountTabScreen(
              user: testUser,
              onMenuItemTap: (_) {},
              onLogout: () {},
            ),
          ),
        ),
      );

      expect(find.byType(AmanahScreenHeader), findsOneWidget);
      expect(find.text('Profil Dokter'), findsOneWidget);
      expect(find.byType(AmanahPullToRefresh), findsOneWidget);

      // The header is outside the pull-to-refresh widget and pinned in a Column
      final Finder columnFinder = find.byType(Column).first;
      final Column columnWidget = tester.widget<Column>(columnFinder);
      expect(columnWidget.children.first, isA<AmanahScreenHeader>());
      expect(columnWidget.children[1], isA<Expanded>());
    });

    testWidgets('AmanahBottomNavigationBar QR button has no boxShadow/glow', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AmanahBottomNavigationBar(
              selectedTab: AmanahHomeTab.home,
              onTabSelected: (_) {},
            ),
          ),
        ),
      );

      // Find the QR scan button container
      final Finder scanSemantics = find.bySemanticsLabel('Pindai QR Presensi');
      expect(scanSemantics, findsOneWidget);

      final Finder scanContainer = find.descendant(
        of: scanSemantics,
        matching: find.byType(Container),
      ).first;

      final Container containerWidget = tester.widget<Container>(scanContainer);
      final BoxDecoration decoration = containerWidget.decoration! as BoxDecoration;

      // Glow boxShadow must be null/empty
      expect(decoration.boxShadow, isNull);
    });
  });
}
