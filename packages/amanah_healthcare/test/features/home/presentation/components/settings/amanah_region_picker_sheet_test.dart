import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/authentication/domain/region_item.dart';
import 'package:amanah_healthcare/features/home/presentation/components/settings/amanah_region_picker_sheet.dart';

void main() {
  final List<RegionItem> mockProvinces = <RegionItem>[
    const RegionItem(id: '31', name: 'DKI JAKARTA'),
    const RegionItem(id: '32', name: 'JAWA BARAT'),
    const RegionItem(id: '33', name: 'JAWA TENGAH'),
    const RegionItem(id: '35', name: 'JAWA TIMUR'),
  ];

  Widget buildTestHost({
    required Future<List<RegionItem>> Function() loader,
    String? selectedId,
    ValueChanged<RegionItem?>? onSelected,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            return ElevatedButton(
              onPressed: () async {
                final RegionItem? result = await AmanahRegionPickerSheet.show(
                  context: context,
                  title: 'Pilih Provinsi',
                  loader: loader,
                  selectedId: selectedId,
                );
                onSelected?.call(result);
              },
              child: const Text('Buka Picker'),
            );
          },
        ),
      ),
    );
  }

  testWidgets(
    'AmanahRegionPickerSheet renders without RenderFlex unbounded height errors',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestHost(loader: () async => mockProvinces),
      );

      // Open sheet
      await tester.tap(find.text('Buka Picker'));
      await tester.pumpAndSettle();

      // Verify header and items render cleanly
      expect(find.text('Pilih Provinsi'), findsOneWidget);
      expect(find.text('DKI JAKARTA'), findsOneWidget);
      expect(find.text('JAWA BARAT'), findsOneWidget);
      expect(find.text('JAWA TENGAH'), findsOneWidget);
      expect(find.text('JAWA TIMUR'), findsOneWidget);

      // Verify no RenderFlex exception occurred (tester.takeException() is null)
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'AmanahRegionPickerSheet filters items when searching',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestHost(loader: () async => mockProvinces),
      );

      await tester.tap(find.text('Buka Picker'));
      await tester.pumpAndSettle();

      // Enter search text
      await tester.enterText(find.byType(TextField), 'BARAT');
      await tester.pumpAndSettle();

      // Verify filtered list
      expect(find.text('JAWA BARAT'), findsOneWidget);
      expect(find.text('DKI JAKARTA'), findsNothing);
      expect(find.text('JAWA TENGAH'), findsNothing);
    },
  );

  testWidgets(
    'AmanahRegionPickerSheet returns tapped item and closes',
    (WidgetTester tester) async {
      RegionItem? selected;
      await tester.pumpWidget(
        buildTestHost(
          loader: () async => mockProvinces,
          onSelected: (RegionItem? item) => selected = item,
        ),
      );

      await tester.tap(find.text('Buka Picker'));
      await tester.pumpAndSettle();

      // Tap JAWA BARAT
      await tester.tap(find.text('JAWA BARAT'));
      await tester.pumpAndSettle();

      // Verify sheet popped and returned item
      expect(selected, isNotNull);
      expect(selected!.id, '32');
      expect(selected!.name, 'JAWA BARAT');
      expect(find.text('Pilih Provinsi'), findsNothing);
    },
  );

  testWidgets(
    'AmanahRegionPickerSheet displays error state and retries',
    (WidgetTester tester) async {
      int attempts = 0;
      await tester.pumpWidget(
        buildTestHost(
          loader: () async {
            attempts++;
            if (attempts == 1) {
              throw Exception('Koneksi internet bermasalah');
            }
            return mockProvinces;
          },
        ),
      );

      await tester.tap(find.text('Buka Picker'));
      await tester.pumpAndSettle();

      // Verify error message and retry button
      expect(find.text('Koneksi internet bermasalah'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);

      // Tap retry
      await tester.tap(find.text('Coba Lagi'));
      await tester.pumpAndSettle();

      // Verify recovery
      expect(find.text('DKI JAKARTA'), findsOneWidget);
      expect(find.text('Koneksi internet bermasalah'), findsNothing);
    },
  );
}
