import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../db/kumanda_deposu.dart';
import '../../ir/cihaz_kategorileri.dart';
import '../../ir/ir_servis.dart';
import '../../ir/irdb_parser.dart';
import '../../ir/uzaktan_komut.dart';
import 'kumanda_ekle_view.dart';

enum EkleAdim { kategori, marka, dene, ad }

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

  List<String> _markalar = const [];
  List<String> get markalar => _markalar;
  List<KategoriModel> _modeller = const [];
  List<KategoriModel> get modeller => _modeller;

  // Dene ekrani durumu
  int _modelIndex = 0;
  int get modelIndex => _modelIndex;
  int get modelToplam => _modeller.length;

  int? _aktifFrekans;
  List<int>? _aktifPattern;
  bool get powerHazir => _aktifPattern != null;

  bool _gonderiyor = false;
  bool get gonderiyor => _gonderiyor;

  bool _bittim = false;
  bool get bittim => _bittim;

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
    _bittim = false;
    _adim = EkleAdim.dene;
    notifyListeners();
    try {
      _modeller = await IrdbParser.modellerKategoriden(m, _kategori!);
      _modelIndex = 0;
      await _ileriYukle();
    } catch (e) {
      _hata = e.toString();
    }
    _yukleniyor = false;
    notifyListeners();
  }

  bool get oncekiVarMi {
    if (_modeller.isEmpty || _modelIndex <= 0) return false;
    return true;
  }

  bool get sonrakiVarMi {
    if (_modeller.isEmpty) return false;
    return _modelIndex < _modeller.length - 1;
  }

  bool _modelOynanabilir(IrKomut? power) {
    if (power == null) return false;
    return IrProtokol.komutaTimings(power) != null;
  }

  /// _modelIndex'teki modeli yuklemeyi dene; uygun degilse ileri yonde
  /// bir sonraki uygun modeli bul.
  Future<void> _ileriYukle() async {
    _aktifFrekans = null;
    _aktifPattern = null;

    while (_modelIndex < _modeller.length) {
      final m = _modeller[_modelIndex];
      try {
        final irModel = await IrdbParser.modelYukle(
            m.marka, m.irdbKlasoru, m.dosya);
        final power = _powerBul(irModel.komutlar);
        if (_modelOynanabilir(power)) {
          final t = IrProtokol.komutaTimings(power!)!;
          _aktifFrekans = t.$1;
          _aktifPattern = t.$2;
          return;
        }
      } catch (_) {
        // bu modeli atla
      }
      _modelIndex++;
    }
    _bittim = true;
  }

  /// _modelIndex'teki modeli yuklemeyi dene; uygun degilse geri yonde
  /// onceki uygun modeli bul. Sona kadar bulamazsa basa donup ileri arar.
  Future<void> _geriYukle() async {
    _aktifFrekans = null;
    _aktifPattern = null;

    while (_modelIndex >= 0) {
      final m = _modeller[_modelIndex];
      try {
        final irModel = await IrdbParser.modelYukle(
            m.marka, m.irdbKlasoru, m.dosya);
        final power = _powerBul(irModel.komutlar);
        if (_modelOynanabilir(power)) {
          final t = IrProtokol.komutaTimings(power!)!;
          _aktifFrekans = t.$1;
          _aktifPattern = t.$2;
          return;
        }
      } catch (_) {
        // bu modeli atla
      }
      _modelIndex--;
    }
    // geride uygun model yok, basa don ve ileri ara
    _modelIndex = 0;
    await _ileriYukle();
  }

  /// Modelin "tepki" verdigi tespit edilebilsin diye yayilacak komut.
  /// Sira: explicit power → POWER/PWR keyword → ON/OFF → AC mod komutu →
  /// son care olarak listenin ilk komutu (cunku bir CSV'deki tum komutlar
  /// ayni protokol/cihaz kodunu paylasir; herhangi biri cihazi titretirse
  /// model dogrudur).
  IrKomut? _powerBul(List<IrKomut> komutlar) {
    if (komutlar.isEmpty) return null;

    // 1) Strict alias match
    final aliaslar = KomutEslestirme.tvAlias(TvKomut.power)
        .map((s) => s.toUpperCase())
        .toSet();
    for (final k in komutlar) {
      if (aliaslar.contains(k.ad.toUpperCase())) return k;
    }
    // 2) POWER / PWR icerigi
    for (final k in komutlar) {
      final u = k.ad.toUpperCase();
      if (u.contains('POWER') || u.contains('PWR')) return k;
    }
    // 3) ON / OFF varyantlari
    for (final k in komutlar) {
      final u = k.ad.toUpperCase();
      if (u == 'ON' ||
          u == 'OFF' ||
          u == 'ONOFF' ||
          u == 'ON_OFF' ||
          u == 'ON/OFF' ||
          u.endsWith('_ON') ||
          u.endsWith('_OFF') ||
          u.startsWith('ON_') ||
          u.startsWith('OFF_')) {
        return k;
      }
    }
    // 4) AC mod komutlari (state-based klimalar icin)
    for (final k in komutlar) {
      final u = k.ad.toUpperCase();
      if (u.startsWith('AUTO') ||
          u.startsWith('COOL') ||
          u.startsWith('HEAT') ||
          u.contains('_AUTO_') ||
          u.contains('_COOL_') ||
          u.contains('_HEAT_')) {
        return k;
      }
    }
    // 5) Son care: listedeki ilk komut (CSV'deki tum komutlar ayni cihaz
    // kodunu kullanir; cihaz herhangi birine tepki verirse model dogru
    // demektir).
    return komutlar.first;
  }

  /// Aktif modelin power komutunu IR ile yayar.
  Future<void> gucGonder() async {
    final f = _aktifFrekans;
    final p = _aktifPattern;
    if (f == null || p == null || _gonderiyor) return;
    _gonderiyor = true;
    notifyListeners();
    try {
      await IrServis.gonder(frekans: f, pattern: p);
    } catch (_) {
      // sessiz
    }
    _gonderiyor = false;
    notifyListeners();
  }

  /// Cihaz tepki vermedi → bir sonraki modele gec.
  Future<void> cevapHayir() async {
    await sonrakiModel();
  }

  /// Manuel: bir sonraki uygun modele gec.
  Future<void> sonrakiModel() async {
    if (_modeller.isEmpty) return;
    if (_modelIndex >= _modeller.length - 1) {
      _modelIndex = _modeller.length;
      _bittim = true;
      notifyListeners();
      return;
    }
    _modelIndex++;
    _yukleniyor = true;
    notifyListeners();
    await _ileriYukle();
    _yukleniyor = false;
    notifyListeners();
  }

  /// Manuel: onceki uygun modele gec.
  Future<void> oncekiModel() async {
    if (_modeller.isEmpty || _modelIndex <= 0) return;
    _modelIndex--;
    _yukleniyor = true;
    notifyListeners();
    await _geriYukle();
    _yukleniyor = false;
    notifyListeners();
  }

  /// Cihaz tepki verdi → bu modeli sec, ad verme adimina gec.
  void cevapEvet() {
    if (_modelIndex >= _modeller.length) return;
    _model = _modeller[_modelIndex];
    if (_kategori != null && _marka != null) {
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
      case EkleAdim.dene:
        _marka = null;
        _modeller = const [];
        _modelIndex = 0;
        _aktifFrekans = null;
        _aktifPattern = null;
        _bittim = false;
        _adim = EkleAdim.marka;
        notifyListeners();
        return true;
      case EkleAdim.ad:
        _model = null;
        _adim = EkleAdim.dene;
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
      kategoriAnahtari: kat.anahtar,
      irdbKlasoru: mod.irdbKlasoru,
      model: mod.dosya,
      odaId: _odaId,
    );
  }

  String? _odaId;
  String? get odaId => _odaId;
  void odaSec(String? id) {
    _odaId = id;
    notifyListeners();
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
