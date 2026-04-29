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
}
