import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// irdb.tar.gz arsivini ilk acilista uygulamanin yerel klasorune cikarir.
/// Concurrent-safe: bircok eszamanli cagri ayni Future'i paylasir.
class IrdbBootstrap {
  static const String _versiyon = 'v1';
  static String? _root;
  static Future<String>? _devamEden;

  /// codes/ klasorunun bulundugu mutlak yolu doner.
  static Future<String> hazirla() {
    if (_root != null) return Future.value(_root!);
    return _devamEden ??= _calistir();
  }

  static Future<String> _calistir() async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      final tabanKlasor = p.join(docs.path, 'irdb', _versiyon);
      final marker = File(p.join(tabanKlasor, '.ok'));

      if (await marker.exists()) {
        _root = p.join(tabanKlasor, 'codes');
        await _ekstraKodlari(tabanKlasor);
        return _root!;
      }

      // Yarim kalmis bir cikarmadan kaldiysa temizle
      final taban = Directory(tabanKlasor);
      if (await taban.exists()) {
        await taban.delete(recursive: true);
      }

      final asset = await rootBundle.load('assets/irdb.tar.gz');
      final gz =
          asset.buffer.asUint8List(asset.offsetInBytes, asset.lengthInBytes);
      final tarBytes = GZipDecoder().decodeBytes(gz);
      final arsiv = TarDecoder().decodeBytes(tarBytes);

      int sayac = 0;
      for (final dosya in arsiv) {
        if (!dosya.isFile) continue;
        final hedef = File(p.join(tabanKlasor, dosya.name));
        await hedef.create(recursive: true);
        await hedef.writeAsBytes(dosya.content as List<int>);
        sayac++;
      }
      debugPrint('[IRDB] $sayac dosya cikarildi');

      await _ekstraKodlari(tabanKlasor);

      await marker.create(recursive: true);
      await marker.writeAsString('hazir');

      _root = p.join(tabanKlasor, 'codes');
      return _root!;
    } catch (e, st) {
      debugPrint('[IRDB] Cikarma hatasi: $e\n$st');
      _devamEden = null; // tekrar denenebilsin
      rethrow;
    }
  }

  /// IRDB tar.gz arsivinde olmayan model girdilerini canli dizine yazar.
  /// Idempotent: dosya zaten varsa atlar. Her uygulama acilisinda calisir.
  ///
  /// Epson projektorlerin buyuk cogunlugu (EB, EH, EX, PowerLite, Home
  /// Cinema, EMP serileri vs.) ayni NEC2 131,85 kodlarini kullanir.
  /// Mi Remote ve benzeri uygulamalar bu yuzden 10+ "model" sunar ama
  /// hepsi temelde ayni sinyali yayar — kullaniciya daha fazla secenek
  /// gosterip "deneme" akisinda guven verir. Birkac varyant ayrica gercek
  /// alt-protokol farkliliklarini icerir (NEC1, alternatif device kodu).
  static Future<void> _ekstraKodlari(String tabanKlasor) async {
    final hedefDir = p.join(tabanKlasor, 'codes/Epson/Projector');

    for (final v in _epsonModelleri) {
      try {
        final hedef = File(p.join(hedefDir, '${v.modelAdi}.csv'));
        if (await hedef.exists()) continue;
        await hedef.create(recursive: true);
        await hedef.writeAsString(v.icerikUret());
      } catch (e) {
        debugPrint('[IRDB] ekstra kod hatasi: ${v.modelAdi} → $e');
      }
    }
  }

  /// Epson projektor modelleri: cogu standard NEC2 131,85 kodu paylasir,
  /// sondaki birkac giris alternatif protokol/device varyantlaridir.
  static const List<_EpsonModel> _epsonModelleri = [
    _EpsonModel('EB-W31'),
    _EpsonModel('EB-S Series'),
    _EpsonModel('EB-X Series'),
    _EpsonModel('EB-U Series'),
    _EpsonModel('EH-TW Series'),
    _EpsonModel('EH-LS Series'),
    _EpsonModel('EX Series'),
    _EpsonModel('PowerLite Home Cinema'),
    _EpsonModel('PowerLite Pro'),
    _EpsonModel('PowerLite Series'),
    _EpsonModel('Home Cinema Series'),
    _EpsonModel('EMP Series'),
    // Alternatif varyantlar
    _EpsonModel('EB-Series (NEC1)', protokol: 'NEC1'),
    _EpsonModel('PowerLite (Alt)', device: 129, subdevice: 3),
    _EpsonModel('Older Series (Alt)', device: 129, subdevice: 3, protokol: 'NEC1'),
  ];
}

class _EpsonModel {
  final String modelAdi;
  final String protokol;
  final int device;
  final int subdevice;

  const _EpsonModel(
    this.modelAdi, {
    this.protokol = 'NEC2',
    this.device = 131,
    this.subdevice = 85,
  });

  String icerikUret() {
    final p = protokol;
    final d = device;
    final s = subdevice;
    final sb = StringBuffer('functionname,protocol,device,subdevice,function\n');
    void ekle(String ad, int fn) =>
        sb.writeln('$ad,$p,$d,$s,$fn');
    ekle('POWER', 144);
    ekle('KEY_POWER', 144);
    ekle('ON', 144);
    ekle('OFF', 145);
    ekle('KEY_VOLUMEUP', 152);
    ekle('VOLUME +', 152);
    ekle('KEY_VOLUMEDOWN', 153);
    ekle('VOLUME -', 153);
    ekle('KEY_MUTE', 147);
    ekle('A/V MUTE', 147);
    ekle('BLANK', 147);
    ekle('KEY_HDMI', 115);
    ekle('HDMI 1', 115);
    ekle('HDMI 2', 119);
    ekle('KEY_COMPUTER', 148);
    ekle('COMPUTER', 148);
    ekle('KEY_USB', 118);
    ekle('USB', 118);
    ekle('KEY_VIDEO', 112);
    ekle('VIDEO', 112);
    ekle('KEY_MENU', 154);
    ekle('MENU', 154);
    ekle('KEY_BACK', 132);
    ekle('KEY_ESC', 132);
    ekle('ESC', 132);
    ekle('KEY_OK', 133);
    ekle('KEY_ENTER', 133);
    ekle('ENTER', 133);
    ekle('SELECT', 133);
    ekle('KEY_UP', 176);
    ekle('UP', 176);
    ekle('KEY_DOWN', 178);
    ekle('DOWN', 178);
    ekle('KEY_LEFT', 179);
    ekle('LEFT', 179);
    ekle('KEY_RIGHT', 177);
    ekle('RIGHT', 177);
    ekle('KEY_ZOOM', 142);
    ekle('ZOOM', 142);
    ekle('KEY_FOCUS', 140);
    ekle('FOCUS', 140);
    ekle('SOURCE SEARCH', 140);
    ekle('KEY_AUTO', 158);
    ekle('AUTO', 158);
    ekle('KEY_FREEZE', 146);
    ekle('FREEZE', 146);
    ekle('KEY_HELP', 149);
    ekle('HELP', 149);
    ekle('KEY_ASPECT', 138);
    ekle('ASPECT', 138);
    ekle('KEY_COLOR_MODE', 143);
    ekle('COLOR MODE', 143);
    ekle('PATTERN', 150);
    ekle('USER', 159);
    ekle('GAMMA', 126);
    ekle('CONTRAST', 44);
    ekle('COLOR TEMP', 45);
    ekle('S-VIDEO', 156);
    ekle('COMPONENT', 113);
    ekle('PC', 157);
    ekle('MEMORY', 139);
    return sb.toString();
  }
}
