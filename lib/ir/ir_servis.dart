import 'package:flutter/services.dart';

class IrServis {
  static const MethodChannel _kanal = MethodChannel('shiftmote/ir');

  static Future<bool> irVarMi() async {
    try {
      final v = await _kanal.invokeMethod<bool>('hasIrEmitter');
      return v ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> gonder({
    required int frekans,
    required List<int> pattern,
  }) async {
    await _kanal.invokeMethod('transmit', {
      'frequency': frekans,
      'pattern': pattern,
    });
  }

  /// Samsung 32-bit (NEC benzeri) protokolde verilen 32-bit kodu raw timing
  /// dizisine cevirir. Frekans 38000 Hz olarak yayilmali.
  static List<int> samsungTimings(int kod32bit) {
    const int header = 4500;
    const int birimMark = 560;
    const int sifirSpace = 560;
    const int birSpace = 1690;

    final List<int> p = [header, header];
    for (int i = 31; i >= 0; i--) {
      final bit = (kod32bit >> i) & 1;
      p.add(birimMark);
      p.add(bit == 1 ? birSpace : sifirSpace);
    }
    p.add(birimMark); // trail
    return p;
  }
}
