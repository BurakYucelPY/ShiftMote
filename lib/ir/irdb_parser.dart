import 'dart:io';

import 'package:path/path.dart' as p;

import 'irdb_bootstrap.dart';

class IrKomut {
  final String ad;
  final String protokol;
  final int device;
  final int subdevice;
  final int function;

  IrKomut({
    required this.ad,
    required this.protokol,
    required this.device,
    required this.subdevice,
    required this.function,
  });
}

class IrModel {
  final String dosya; // dev,subdev (.csv haric)
  final List<IrKomut> komutlar;
  IrModel({required this.dosya, required this.komutlar});
}

class IrdbParser {
  /// Tum cihaz tiplerini doner (markalar arasinda birlestirilmis, sirali).
  static Future<List<String>> cihazTipleri() async {
    final root = await IrdbBootstrap.hazirla();
    final tipler = <String>{};
    final dir = Directory(root);
    if (!await dir.exists()) return [];
    await for (final marka in dir.list()) {
      if (marka is! Directory) continue;
      await for (final tip in marka.list()) {
        if (tip is Directory) tipler.add(p.basename(tip.path));
      }
    }
    final list = tipler.toList()..sort();
    return list;
  }

  /// Belirli bir cihaz tipini destekleyen markalari doner.
  static Future<List<String>> markalar(String cihazTipi) async {
    final root = await IrdbBootstrap.hazirla();
    final markalar = <String>[];
    final dir = Directory(root);
    if (!await dir.exists()) return [];
    await for (final marka in dir.list()) {
      if (marka is! Directory) continue;
      final tipKlasor = Directory(p.join(marka.path, cihazTipi));
      if (await tipKlasor.exists()) {
        markalar.add(p.basename(marka.path));
      }
    }
    markalar.sort();
    return markalar;
  }

  /// Marka + cihaz tipi altindaki tum modelleri (CSV dosya isimleri, .csv haric) doner.
  static Future<List<String>> modeller(String marka, String cihazTipi) async {
    final root = await IrdbBootstrap.hazirla();
    final dir = Directory(p.join(root, marka, cihazTipi));
    if (!await dir.exists()) return [];
    final modeller = <String>[];
    await for (final f in dir.list()) {
      if (f is File && f.path.toLowerCase().endsWith('.csv')) {
        modeller.add(p.basenameWithoutExtension(f.path));
      }
    }
    modeller.sort();
    return modeller;
  }

  /// Bir modelin CSV'sini parse edip komut listesi doner.
  static Future<IrModel> modelYukle(
      String marka, String cihazTipi, String model) async {
    final root = await IrdbBootstrap.hazirla();
    final dosya = File(p.join(root, marka, cihazTipi, '$model.csv'));
    if (!await dosya.exists()) {
      return IrModel(dosya: model, komutlar: []);
    }

    final satirlar = await dosya.readAsLines();
    final komutlar = <IrKomut>[];
    for (int i = 0; i < satirlar.length; i++) {
      final satir = satirlar[i].trim();
      if (satir.isEmpty) continue;
      // Bas satir: functionname,protocol,device,subdevice,function
      if (i == 0 && satir.toLowerCase().startsWith('functionname')) continue;
      final parts = satir.split(',');
      if (parts.length < 5) continue;
      komutlar.add(IrKomut(
        ad: parts[0],
        protokol: parts[1],
        device: int.tryParse(parts[2]) ?? 0,
        subdevice: int.tryParse(parts[3]) ?? 0,
        function: int.tryParse(parts[4]) ?? 0,
      ));
    }
    return IrModel(dosya: model, komutlar: komutlar);
  }
}

/// Protokol -> raw timing donusumu. Yaygin NEC-tabanli protokoller destekleniyor.
class IrProtokol {
  /// Donus: (frekansHz, pattern). Desteklenmiyorsa null.
  static (int, List<int>)? komutaTimings(IrKomut k) {
    final p = k.protokol.toUpperCase();
    if (p == 'NEC' ||
        p == 'NEC1' ||
        p == 'NEC2' ||
        p == 'NECX' ||
        p == 'NECX1' ||
        p == 'NECX2') {
      return (38000, _necTimings(k.device, k.subdevice, k.function));
    }
    if (p == 'SAMSUNG' || p == 'SAMSUNG36') {
      return (38000, _samsungTimings(k.device, k.subdevice, k.function));
    }
    return null;
  }

  /// NEC / NECx ailesi: 9000us+4500us header, 4 byte (LSB first/byte),
  /// bit 0: 560us+560us, bit 1: 560us+1690us, trail 560us.
  /// NECx: addr1=device, addr2=subdevice (inversiyon yok).
  /// NEC klasik: addr ve ~addr seklinde, ama IRDB device/subdevice 'i NECx ile temsil ediyor.
  static List<int> _necTimings(int dev, int sub, int func) {
    final addr1 = dev & 0xFF;
    final addr2 = sub & 0xFF;
    final cmd = func & 0xFF;
    final cmdInv = (~func) & 0xFF;
    final bytes = [addr1, addr2, cmd, cmdInv];
    return _necLikePattern(headerMark: 9000, headerSpace: 4500, bytes: bytes);
  }

  /// Samsung: 4500us+4500us header, sonrasi NEC ile ayni.
  static List<int> _samsungTimings(int dev, int sub, int func) {
    final addr1 = dev & 0xFF;
    final addr2 = sub & 0xFF;
    final cmd = func & 0xFF;
    final cmdInv = (~func) & 0xFF;
    final bytes = [addr1, addr2, cmd, cmdInv];
    return _necLikePattern(headerMark: 4500, headerSpace: 4500, bytes: bytes);
  }

  static List<int> _necLikePattern({
    required int headerMark,
    required int headerSpace,
    required List<int> bytes,
  }) {
    const int birim = 560;
    const int birSpace = 1690;
    final pattern = <int>[headerMark, headerSpace];
    for (final b in bytes) {
      for (int i = 0; i < 8; i++) {
        final bit = (b >> i) & 1; // LSB first
        pattern.add(birim);
        pattern.add(bit == 1 ? birSpace : birim);
      }
    }
    pattern.add(birim);
    return pattern;
  }
}
