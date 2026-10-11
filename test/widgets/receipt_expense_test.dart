import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kakebo/core/documents/local_document_reader.dart';
import 'package:kakebo/core/time/calendar_date.dart';
import 'package:kakebo/data/kakebo_data_store.dart';
import 'package:kakebo/data/receipt_attachment_store.dart';
import 'package:kakebo/domain/expense_catalog.dart';
import 'package:kakebo/features/diary/expense_editor.dart';
import 'package:kakebo/l10n/app_localizations.dart';

class _SyntheticReader extends LocalDocumentReader {
  @override
  Future<String> readReceipt(String path) async =>
      'SKLEP PROBKA\nPARAGON FISKALNY\nDATA 12.09.2026\nDO ZAPŁATY 12,50';
}

class _PreparedReceiptStore extends ReceiptAttachmentStore {
  _PreparedReceiptStore(super.store, this.name);
  final String name;

  @override
  Future<String> persist(XFile image) async => name;
}

class _UnavailablePicker extends ImagePicker {
  _UnavailablePicker(this.denied);
  final bool denied;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    if (denied) throw PlatformException(code: 'camera_access_denied');
    return null;
  }
}

void main() {
  late Directory temp;
  late KakeboDataStore store;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('kakebo-receipt-');
    store = await KakeboDataStore.openAt(temp);
  });
  tearDown(() async {
    await store.close();
    await temp.delete(recursive: true);
  });

  testWidgets(
    'OCR suggestions require consent and save links a durable image',
    (tester) async {
      final source = File('test/fixtures/receipt.png').absolute;
      const prepared = '00000000-0000-4000-8000-000000000001.img';
      source.copySync(store.receiptFile(prepared).path);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('pl'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: ExpenseEditor(
              database: store.database,
              catalog: ExpenseCatalog(),
              initialDate: CalendarDate.parse('2026-09-11'),
              currency: 'PLN',
              receipts: _PreparedReceiptStore(store, prepared),
              initialReceipt: XFile(source.path),
              documentReader: _SyntheticReader(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(await store.database.allEntries(), isEmpty);
      expect(find.text('Dane z paragonu'), findsOneWidget);
      await tester.tap(find.text('Odrzuć'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('expense_amount')))
            .controller!
            .text,
        isEmpty,
      );
      await tester.ensureVisible(find.byKey(const Key('read_receipt')));
      await tester.tap(find.byKey(const Key('read_receipt')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('apply_receipt_suggestion')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('expense_amount')))
            .controller!
            .text,
        '12,50',
      );
      expect(await store.database.allEntries(), isEmpty);
      await tester.ensureVisible(find.byKey(const Key('category_NEEDS')));
      await tester.tap(find.byKey(const Key('category_NEEDS')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('subcategory_FOOD')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('save_expense')));
      await tester.pumpAndSettle();
      expect(find.text('Nie udało się zapisać wydatku.'), findsNothing);
      expect(find.text('Zapisywanie…'), findsNothing);
      final entry = (await store.database.allEntries()).single;
      expect(entry.amountGrosz, 1250);
      expect(entry.note, 'SKLEP PROBKA');
      expect(entry.dateEpochDay, CalendarDate.parse('2026-09-12').epochDay);
      expect(entry.receiptName, isNotNull);
      expect(store.receiptFile(entry.receiptName!).existsSync(), isTrue);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  test('missing image cannot create an attachment', () async {
    final receipts = ReceiptAttachmentStore(store);
    await expectLater(
      receipts.persist(XFile('${temp.path}/missing.jpg')),
      throwsA(isA<FileSystemException>()),
    );
    expect(await store.receiptsDirectory.list().toList(), isEmpty);
    expect(await store.database.allEntries(), isEmpty);
  });

  for (final denied in [false, true]) {
    testWidgets(
      denied
          ? 'permission denial creates no attachment'
          : 'cancelled camera creates no attachment',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('pl'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: Scaffold(
              body: ExpenseEditor(
                database: store.database,
                catalog: ExpenseCatalog(),
                initialDate: CalendarDate.parse('2026-09-11'),
                currency: 'PLN',
                receipts: ReceiptAttachmentStore(
                  store,
                  picker: _UnavailablePicker(denied),
                ),
              ),
            ),
          ),
        );
        await tester.ensureVisible(find.byKey(const Key('choose_receipt')));
        await tester.tap(find.byKey(const Key('choose_receipt')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Zrób zdjęcie'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('read_receipt')), findsNothing);
        expect(await store.database.allEntries(), isEmpty);
        expect(store.receiptsDirectory.listSync(), isEmpty);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  test('picked image is copied into the active bundle', () async {
    final source = File('test/fixtures/receipt.png').absolute;
    final name = await ReceiptAttachmentStore(store)
        .persist(XFile(source.path));
    expect(
      await store.receiptFile(name).readAsBytes(),
      await source.readAsBytes(),
    );
    await store.close();
    store = await KakeboDataStore.openAt(temp);
    expect(
      await store.receiptFile(name).readAsBytes(),
      await source.readAsBytes(),
    );
  });
}
