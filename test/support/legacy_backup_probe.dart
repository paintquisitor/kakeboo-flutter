import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// F02 compatibility probe for trusted synthetic fixtures only. Does not restore
/// or write anything. Production staging, bounded decompression and relational
/// validation belong to F04; this probe must never receive user-selected files.
({Map<String, dynamic> manifest, Map<String, Uint8List> receipts})
readLegacyFixture(Uint8List bytes) {
  final decoder = ZipDecoder();
  final archive = decoder.decodeBytes(bytes);
  final names = decoder.directory.fileHeaders.map((file) => file.filename);
  if (names.toSet().length != names.length) {
    throw const FormatException('Duplicate archive entries');
  }
  Map<String, dynamic>? manifest;
  final receipts = <String, Uint8List>{};
  for (final file in archive) {
    if (!file.isFile || file.isSymbolicLink) {
      throw const FormatException('Not a regular file');
    }
    final content = file.readBytes()!;
    // archive's verify argument currently does not check CRC; check explicitly.
    if (getCrc32(content) != file.crc32) {
      throw const FormatException('Corrupt archive entry');
    }
    if (file.name == 'kakebo.json') {
      manifest = jsonDecode(utf8.decode(content)) as Map<String, dynamic>;
    } else if (RegExp(r'^receipts/[a-f0-9-]{36}\.img$').hasMatch(file.name)) {
      receipts[file.name.substring('receipts/'.length)] = content;
    } else {
      throw const FormatException('Unexpected archive path');
    }
  }
  if (manifest == null || manifest['format'] != 1) {
    throw const FormatException('Unsupported backup');
  }
  return (manifest: manifest, receipts: receipts);
}
