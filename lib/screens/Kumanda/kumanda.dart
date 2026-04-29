import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../db/kumanda_deposu.dart';
import '../../ir/ir_servis.dart';
import '../../ir/irdb_parser.dart';
import 'kumanda_view.dart';

class KumandaProvider extends ChangeNotifier {
  final int kumandaId;
  KumandaProvider({required this.kumandaId});

  Kumanda? _kumanda;
  IrModel? _model;
  bool _yukleniyor = true;
  String? _hata;
  String _sonAksiyon = '';
  bool _irVar = false;

  Kumanda? get kumanda => _kumanda;
  IrModel? get model => _model;
  bool get yukleniyor => _yukleniyor;
  String? get hata => _hata;
  String get sonAksiyon => _sonAksiyon;
  bool get irVar => _irVar;

  Future<void> baslat() async {
    _kumanda = KumandaDeposu.bul(kumandaId);
    if (_kumanda == null) {
      _hata = 'Kumanda bulunamadi (id=$kumandaId)';
      _yukleniyor = false;
      notifyListeners();
      return;
    }

    _irVar = await IrServis.irVarMi();

    try {
      _model = await IrdbParser.modelYukle(
        _kumanda!.marka,
        _kumanda!.cihazTipi,
        _kumanda!.model,
      );
    } catch (e) {
      _hata = 'CSV okunamadi: $e';
    }

    _yukleniyor = false;
    notifyListeners();
  }

  Future<void> yay(IrKomut k) async {
    if (!_irVar) {
      _sonAksiyon = 'kumanda_page.ir_yok'.tr();
      notifyListeners();
      return;
    }
    final timing = IrProtokol.komutaTimings(k);
    if (timing == null) {
      _sonAksiyon = '${'kumanda_page.protokol_desteklenmiyor'.tr()}: ${k.protokol}';
      notifyListeners();
      return;
    }
    try {
      await IrServis.gonder(frekans: timing.$1, pattern: timing.$2);
      _sonAksiyon = k.ad;
    } catch (e) {
      _sonAksiyon = '${'genel.hata'.tr()}: $e';
    }
    notifyListeners();
  }
}

class KumandaSayfasi extends StatefulWidget {
  final int kumandaId;
  const KumandaSayfasi({super.key, required this.kumandaId});

  @override
  State<KumandaSayfasi> createState() => _KumandaSayfasiState();
}

class _KumandaSayfasiState extends State<KumandaSayfasi> {
  late final KumandaProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = KumandaProvider(kumandaId: widget.kumandaId)..baslat();
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
      child: const KumandaView(),
    );
  }
}
