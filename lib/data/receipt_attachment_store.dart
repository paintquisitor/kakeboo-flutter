import 'dart:io';
import 'dart:math';
import 'dart:convert';

import 'package:image_picker/image_picker.dart';

import 'kakebo_data_store.dart';

/// Copies a picked image into the active local bundle before it is linked to an entry.
class ReceiptAttachmentStore {
  ReceiptAttachmentStore(this.store, {ImagePicker? picker})
    : picker = picker ?? ImagePicker();

  final KakeboDataStore store;
  final ImagePicker picker;

  Future<XFile?> pick(ImageSource source) =>
      picker.pickImage(source: source, imageQuality: 90);

  Future<XFile?> recoverLostImage() async {
    if (!Platform.isAndroid) return null;
    final response = await picker.retrieveLostData();
    if (response.isEmpty || response.exception != null) return null;
    final files = response.files;
    return files == null || files.isEmpty ? null : files.first;
  }

  Future<String> persist(XFile image) async {
    final source = File(image.path);
    final size = await source.length();
    if (size == 0 || size > 25 * 1024 * 1024) {
      throw const FormatException('Receipt image must be 1–25 MB');
    }
    final reader = await source.open();
    late final List<int> header;
    try {
      header = await reader.read(32);
    } finally {
      await reader.close();
    }
    final png =
        header.length >= 8 &&
        const [
          137,
          80,
          78,
          71,
          13,
          10,
          26,
          10,
        ].asMap().entries.every((entry) => header[entry.key] == entry.value);
    final jpeg =
        header.length >= 3 &&
        header[0] == 255 &&
        header[1] == 216 &&
        header[2] == 255;
    final gif =
        header.length >= 6 && latin1.decode(header.sublist(0, 3)) == 'GIF';
    final webp =
        header.length >= 12 &&
        latin1.decode(header.sublist(0, 4)) == 'RIFF' &&
        latin1.decode(header.sublist(8, 12)) == 'WEBP';
    final heif =
        header.length >= 12 &&
        latin1.decode(header.sublist(4, 8)) == 'ftyp' &&
        {
          'heic',
          'heix',
          'hevc',
          'mif1',
          'msf1',
        }.contains(latin1.decode(header.sublist(8, 12)));
    if (!(png || jpeg || gif || webp || heif)) {
      throw const FormatException('Unsupported receipt image');
    }
    final random = Random.secure();
    String hex(int bytes) => List.generate(
      bytes,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    final name =
        '${hex(4)}-${hex(2)}-4${hex(2).substring(1)}-'
        '${(8 + random.nextInt(4)).toRadixString(16)}${hex(2).substring(1)}-'
        '${hex(6)}.img';
    final target = store.receiptFile(name);
    await store.receiptsDirectory.create(recursive: true);
    final partial = File('${target.path}.part');
    try {
      await source.openRead().pipe(partial.openWrite());
      if (await partial.length() != size) {
        throw const FileSystemException('Incomplete receipt copy');
      }
      await partial.rename(target.path);
      return name;
    } finally {
      if (await partial.exists()) await partial.delete();
    }
  }
}
