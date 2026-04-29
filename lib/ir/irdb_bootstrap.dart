import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// irdb.tar.gz arsivini ilk acilista uygulamanin yerel klasorune cikarir.
class IrdbBootstrap {
  static const String _versiyon = 'v1';
  static String? _root;

  /// codes/ klasorunun bulundugu mutlak yolu doner.
  static Future<String> hazirla() async {
    if (_root != null) return _root!;

    final docs = await getApplicationDocumentsDirectory();
    final tabanKlasor = p.join(docs.path, 'irdb', _versiyon);
    final marker = File(p.join(tabanKlasor, '.ok'));

    if (await marker.exists()) {
      _root = p.join(tabanKlasor, 'codes');
      return _root!;
    }

    final asset = await rootBundle.load('assets/irdb.tar.gz');
    final gz = asset.buffer.asUint8List(asset.offsetInBytes, asset.lengthInBytes);
    final tarBytes = GZipDecoder().decodeBytes(gz);
    final arsiv = TarDecoder().decodeBytes(tarBytes);

    for (final dosya in arsiv) {
      if (!dosya.isFile) continue;
      final hedef = File(p.join(tabanKlasor, dosya.name));
      await hedef.create(recursive: true);
      await hedef.writeAsBytes(dosya.content as List<int>);
    }

    await marker.create(recursive: true);
    await marker.writeAsString('hazir');

    _root = p.join(tabanKlasor, 'codes');
    return _root!;
  }
}
