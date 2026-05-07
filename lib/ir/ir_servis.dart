import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// IR yayim durumu — gostergeler bunu dinler.
enum IrDurumu {
  bos,        // bekleniyor
  yayinlandi, // basarili yayim (1-2 sn icin gosterilir)
  hata,       // basarisiz yayim
  irYok,      // donanimda IR yok
}

class IrDurumKaydi {
  final IrDurumu durum;
  final String? mesaj;
  final DateTime zaman;
  IrDurumKaydi(this.durum, {this.mesaj}) : zaman = DateTime.now();
}

class IrServis {
  static const MethodChannel _kanal = MethodChannel('shiftmote/ir');

  /// Son yayim/algilama durumu — UI bunu dinler.
  static final ValueNotifier<IrDurumKaydi> durum =
      ValueNotifier(IrDurumKaydi(IrDurumu.bos));

  static bool? _irVarMiCache;

  static Future<bool> irVarMi() async {
    if (_irVarMiCache != null) return _irVarMiCache!;
    try {
      final v = await _kanal.invokeMethod<bool>('hasIrEmitter');
      _irVarMiCache = v ?? false;
      if (!_irVarMiCache!) {
        durum.value = IrDurumKaydi(IrDurumu.irYok,
            mesaj: 'Cihazda IR emitter bulunamadi');
      }
      return _irVarMiCache!;
    } catch (e) {
      _irVarMiCache = false;
      durum.value = IrDurumKaydi(IrDurumu.hata, mesaj: e.toString());
      return false;
    }
  }

  static Future<void> gonder({
    required int frekans,
    required List<int> pattern,
  }) async {
    try {
      final sonuc = await _kanal.invokeMethod('transmit', {
        'frequency': frekans,
        'pattern': pattern,
      });
      if (kDebugMode) {
        debugPrint('[IR] gonder OK: $sonuc');
      }
      durum.value = IrDurumKaydi(IrDurumu.yayinlandi);
    } on PlatformException catch (e) {
      final msg = e.code == 'NO_IR'
          ? 'IR donanimi yok'
          : 'Yayim hatasi: ${e.message ?? e.code}';
      debugPrint('[IR] PlatformException: ${e.code} ${e.message}');
      durum.value = IrDurumKaydi(
        e.code == 'NO_IR' ? IrDurumu.irYok : IrDurumu.hata,
        mesaj: msg,
      );
      rethrow;
    } catch (e) {
      debugPrint('[IR] gonder hata: $e');
      durum.value = IrDurumKaydi(IrDurumu.hata, mesaj: e.toString());
      rethrow;
    }
  }
}
