import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../ir/ir_servis.dart';
import '../../ir/irdb_parser.dart';
import 'ir_test_view.dart';

class IrTestProvider extends ChangeNotifier {
  bool _yukleniyor = true;
  bool _irVar = false;
  String _sonMesaj = '';

  bool get yukleniyor => _yukleniyor;
  bool get irVar => _irVar;
  String get sonMesaj => _sonMesaj;

  Future<void> baslat() async {
    _irVar = await IrServis.irVarMi();
    _yukleniyor = false;
    _sonMesaj = _irVar
        ? 'IR donanimi tespit edildi.'
        : 'Bu cihazda IR emitter yok veya erisilemedi.';
    notifyListeners();
  }

  Future<void> samsungPowerYay() async {
    if (!_irVar) {
      _sonMesaj = 'IR donanimi yok, yayim yapilamadi.';
      notifyListeners();
      return;
    }
    try {
      // Samsung-specific timing (4500/4500 header) - 0xE0E040BF
      final pattern = IrServis.samsungTimings(0xE0E040BF);
      await IrServis.gonder(frekans: 38000, pattern: pattern);
      _sonMesaj = 'Samsung TV power kodu yayildi (sabit timing).';
    } catch (e) {
      _sonMesaj = 'Yayim hatasi: $e';
    }
    notifyListeners();
  }

  /// Parser yolundan: irdb'den Samsung TV 7,7 dosyasini yukle, POWER komutunu yay.
  Future<void> parserYoluylaYay() async {
    if (!_irVar) {
      _sonMesaj = 'IR donanimi yok, yayim yapilamadi.';
      notifyListeners();
      return;
    }
    try {
      final model = await IrdbParser.modelYukle('Samsung', 'TV', '7,7');
      if (model.komutlar.isEmpty) {
        _sonMesaj = 'Samsung/TV/7,7.csv bulunamadi veya bos.';
        notifyListeners();
        return;
      }
      final power = model.komutlar.firstWhere(
        (k) => k.ad.toUpperCase() == 'POWER',
        orElse: () => model.komutlar.first,
      );
      final timing = IrProtokol.komutaTimings(power);
      if (timing == null) {
        _sonMesaj = 'Protokol desteklenmiyor: ${power.protokol}';
        notifyListeners();
        return;
      }
      await IrServis.gonder(frekans: timing.$1, pattern: timing.$2);
      _sonMesaj =
          'irdb POWER yayildi (${power.protokol}, ${model.komutlar.length} komut bulundu).';
    } catch (e) {
      _sonMesaj = 'Parser yayim hatasi: $e';
    }
    notifyListeners();
  }
}

class IrTest extends StatefulWidget {
  const IrTest({super.key});

  @override
  State<IrTest> createState() => _IrTestState();
}

class _IrTestState extends State<IrTest> {
  late final IrTestProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = IrTestProvider();
    _provider.baslat();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: const IrTestView(),
    );
  }
}
