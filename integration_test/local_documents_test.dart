import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kakebo/core/documents/local_document_reader.dart';

import '../test/support/legacy_backup_probe.dart';

// Inputs supplied at compile time: synthetic test files are not app assets.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('local OCR, PDF ordering and legacy ZIP on device', (
    tester,
  ) async {
    final report = <String, Object?>{'platform': Platform.operatingSystem};
    final directory = await Directory.systemTemp.createTemp('kakebo-f02-');
    final resultFile = File(
      '${Directory.systemTemp.path}/kakebo-f02-result.json',
    );
    try {
      if (const bool.fromEnvironment('OFFLINE')) {
        try {
          final socket = await Socket.connect(
            InternetAddress('1.1.1.1'),
            443,
            timeout: const Duration(seconds: 5),
          );
          socket.destroy();
          fail('Network unexpectedly available');
        } on SocketException catch (error) {
          // A timeout/refusal alone does not prove offline mode.
          expect(error.osError?.errorCode, isIn([1, 13, 50, 51, 65, 101, 113]));
          report['networkBlockedErrno'] = error.osError?.errorCode;
        }
      }
      final receipt = File('${directory.path}/receipt.png');
      await receipt.writeAsBytes(
        base64Decode(const String.fromEnvironment('receipt')),
      );
      final pdf = File('${directory.path}/statement.pdf');
      await pdf.writeAsBytes(
        base64Decode(const String.fromEnvironment('statement')),
      );
      final reader = LocalDocumentReader();
      final receiptText = await reader.readReceipt(receipt.path);
      report['receiptText'] = receiptText;
      expect(receiptText.split('\n').first, 'SKLEP TESTOWY');
      expect(receiptText, contains('2026-09-28'));
      expect(receiptText, contains('SUMA PLN 20,00'));

      final pdfText = await reader.readPdf(pdf.path);
      report['pdfText'] = pdfText;
      final expected = (jsonDecode(
        utf8.decode(base64Decode(const String.fromEnvironment('expected'))),
      ) as List).cast<String>();
      final rows = pdfText
          .split('\n')
          .where((line) => !line.startsWith('WYCIĄG TESTOWY'))
          .toList();
      expect(rows, expected);

      final invalid = File('${directory.path}/invalid.pdf');
      await invalid.writeAsString('This is not a PDF');
      await expectLater(
        reader.readPdf(invalid.path),
        throwsA(isA<PlatformException>()),
      );
      final backup = readLegacyFixture(
        base64Decode(const String.fromEnvironment('backup')),
      );
      final entries = backup.manifest['tables']['entries'] as List;
      expect(entries.map((e) => e['amountGrosz']), [2000, 125000]);
      expect(
        backup.receipts[entries.first['receiptName']],
        await receipt.readAsBytes(),
      );
      // Also recognize the .img receipt recovered from the old ZIP.
      final recovered = File('${directory.path}/restored.img');
      await recovered.writeAsBytes(backup.receipts.values.single);
      expect(await reader.readReceipt(recovered.path), receiptText);
      report['backup'] = {
        'format': 1,
        'tables': 6,
        'entries': 2,
        'amountMinor': 127000,
        'receiptBytesMatch': true,
      };
      report['result'] = 'passed';
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('F02: OCR / PDF / ZIP — OK')),
          ),
        ),
      );
      await tester.pumpAndSettle();
    } catch (error) {
      report['result'] = 'failed';
      report['error'] = error.toString();
      rethrow;
    } finally {
      await resultFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(report),
      );
      await directory.delete(recursive: true);
    }
  });
}
