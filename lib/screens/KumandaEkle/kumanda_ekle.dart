import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../db/kumanda_deposu.dart';
import '../../ir/irdb_parser.dart';
import 'kumanda_ekle_view.dart';

enum EkleAdim { cihazTipi, marka, model, ad }

class KumandaEkleProvider extends ChangeNotifier {
  EkleAdim _adim = EkleAdim.cihazTipi;
  EkleAdim get adim => _adim;

  String? _cihazTipi;
  String? _marka;
  String? _model;
  String _ad = '';

  String? get cihazTipi => _cihazTipi;
  String? get marka => _marka;
  String? get model => _model;
  String get ad => _ad;

  bool _yukleniyor = false;
  bool get yukleniyor => _yukleniyor;

  String? _hata;
  String? get hata => _hata;

  List<String> _secenekler = const [];
  List<String> get secenekler => _secenekler;

  String _arama = '';
  String get arama => _arama;
  List<String> get filtreliSecenekler {
    if (_arama.isEmpty) return _secenekler;
    final q = _arama.toLowerCase();
    return _secenekler.where((s) => s.toLowerCase().contains(q)).toList();
  }

  Future<void> baslat() async {
    await _adimYukle(EkleAdim.cihazTipi);
  }

  Future<void> _adimYukle(EkleAdim yeni) async {
    _yukleniyor = true;
    _hata = null;
    _arama = '';
    notifyListeners();
    try {
      switch (yeni) {
        case EkleAdim.cihazTipi:
          _secenekler = await IrdbParser.cihazTipleri();
          break;
        case EkleAdim.marka:
          _secenekler = await IrdbParser.markalar(_cihazTipi!);
          break;
        case EkleAdim.model:
          _secenekler = await IrdbParser.modeller(_marka!, _cihazTipi!);
          break;
        case EkleAdim.ad:
          _secenekler = const [];
          break;
      }
      _adim = yeni;
    } catch (e) {
      _hata = e.toString();
    }
    _yukleniyor = false;
    notifyListeners();
  }

  Future<void> sec(String secim) async {
    switch (_adim) {
      case EkleAdim.cihazTipi:
        _cihazTipi = secim;
        await _adimYukle(EkleAdim.marka);
        break;
      case EkleAdim.marka:
        _marka = secim;
        await _adimYukle(EkleAdim.model);
        break;
      case EkleAdim.model:
        _model = secim;
        _ad = '$_marka $_cihazTipi';
        await _adimYukle(EkleAdim.ad);
        break;
      case EkleAdim.ad:
        break;
    }
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
      case EkleAdim.cihazTipi:
        return false; // sayfayi kapat
      case EkleAdim.marka:
        _marka = null;
        await _adimYukle(EkleAdim.cihazTipi);
        return true;
      case EkleAdim.model:
        _model = null;
        await _adimYukle(EkleAdim.marka);
        return true;
      case EkleAdim.ad:
        await _adimYukle(EkleAdim.model);
        return true;
    }
  }

  Future<Kumanda?> kaydet() async {
    if (_ad.trim().isEmpty ||
        _marka == null ||
        _cihazTipi == null ||
        _model == null) {
      return null;
    }
    return await KumandaDeposu.ekle(
      ad: _ad.trim(),
      marka: _marka!,
      cihazTipi: _cihazTipi!,
      model: _model!,
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
    _provider = KumandaEkleProvider()..baslat();
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
