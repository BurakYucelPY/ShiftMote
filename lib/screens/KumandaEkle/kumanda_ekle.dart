import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../db/kumanda_deposu.dart';
import '../../ir/cihaz_kategorileri.dart';
import '../../ir/irdb_parser.dart';
import 'kumanda_ekle_view.dart';

enum EkleAdim { kategori, marka, model, ad }

class KumandaEkleProvider extends ChangeNotifier {
  EkleAdim _adim = EkleAdim.kategori;
  EkleAdim get adim => _adim;

  CihazKategorisi? _kategori;
  String? _marka;
  KategoriModel? _model;
  String _ad = '';

  CihazKategorisi? get kategori => _kategori;
  String? get marka => _marka;
  KategoriModel? get model => _model;
  String get ad => _ad;

  bool _yukleniyor = false;
  bool get yukleniyor => _yukleniyor;

  String? _hata;
  String? get hata => _hata;

  // Adim 2'de markalar, Adim 3'te modeller
  List<String> _markalar = const [];
  List<String> get markalar => _markalar;
  List<KategoriModel> _modeller = const [];
  List<KategoriModel> get modeller => _modeller;

  String _arama = '';
  String get arama => _arama;

  List<String> get filtreliMarkalar {
    if (_arama.isEmpty) return _markalar;
    final q = _arama.toLowerCase();
    return _markalar.where((m) => m.toLowerCase().contains(q)).toList();
  }

  List<String> get populerMevcut {
    final kat = _kategori;
    if (kat == null) return const [];
    final set = _markalar.toSet();
    return kat.populerMarkalar.where(set.contains).toList();
  }

  Future<void> kategoriSec(CihazKategorisi kat) async {
    _kategori = kat;
    _yukleniyor = true;
    _hata = null;
    _arama = '';
    _adim = EkleAdim.marka;
    notifyListeners();
    try {
      _markalar = await IrdbParser.markalarKategoriden(kat);
    } catch (e) {
      _hata = e.toString();
    }
    _yukleniyor = false;
    notifyListeners();
  }

  Future<void> markaSec(String m) async {
    _marka = m;
    _yukleniyor = true;
    _hata = null;
    _arama = '';
    _adim = EkleAdim.model;
    notifyListeners();
    try {
      _modeller = await IrdbParser.modellerKategoriden(m, _kategori!);
    } catch (e) {
      _hata = e.toString();
    }
    _yukleniyor = false;
    notifyListeners();
  }

  void modelSec(KategoriModel m) {
    _model = m;
    _ad = '$_marka ${_kategori?.etiketKey.split('.').last ?? ''}'.trim();
    // Daha okunakli varsayilan ad
    if (_kategori != null) {
      _ad = '$_marka ${_kategori!.etiketKey.tr()}'.trim();
    }
    _adim = EkleAdim.ad;
    notifyListeners();
  }

  void aramaGuncelle(String s) {
    _arama = s;
    notifyListeners();
  }

  void adGuncelle(String s) {
    _ad = s;
    notifyListeners();
  }

  Future<bool> geri() async {
    switch (_adim) {
      case EkleAdim.kategori:
        return false;
      case EkleAdim.marka:
        _kategori = null;
        _markalar = const [];
        _adim = EkleAdim.kategori;
        notifyListeners();
        return true;
      case EkleAdim.model:
        _marka = null;
        _modeller = const [];
        _adim = EkleAdim.marka;
        notifyListeners();
        return true;
      case EkleAdim.ad:
        _model = null;
        _adim = EkleAdim.model;
        notifyListeners();
        return true;
    }
  }

  Future<Kumanda?> kaydet() async {
    final kat = _kategori;
    final mar = _marka;
    final mod = _model;
    if (_ad.trim().isEmpty || kat == null || mar == null || mod == null) {
      return null;
    }
    return await KumandaDeposu.ekle(
      ad: _ad.trim(),
      marka: mar,
      cihazTipi: kat.etiketKey.tr(),
      irdbKlasoru: mod.irdbKlasoru,
      model: mod.dosya,
    );
  }
}

class KumandaEkle extends StatefulWidget {
  const KumandaEkle({super.key});

  @override
  State<KumandaEkle> createState() => _KumandaEkleState();
}

class _KumandaEkleState extends State<KumandaEkle> {
  late final KumandaEkleProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = KumandaEkleProvider();
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
      child: const KumandaEkleView(),
    );
  }
}
