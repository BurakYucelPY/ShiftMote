import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../db/kumanda_deposu.dart';
import '../../ir/ir_servis.dart';
import '../../ir/irdb_parser.dart';
import '../../ir/uzaktan_komut.dart';
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
        _kumanda!.irdbKlasoru,
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

  /// Verilen alias listesinden CSV'de var olan ilk komutu doner.
  IrKomut? _bul(List<String> aliaslar) {
    final mod = _model;
    if (mod == null) return null;
    final komutlar = mod.komutlar;

    // 1) Tam eslesme (kucuk harf duyarsiz)
    for (final alias in aliaslar) {
      final hedef = alias.toLowerCase();
      for (final k in komutlar) {
        if (k.ad.toLowerCase() == hedef) return k;
      }
    }

    // 2) Normalize edilmis eslesme — IRDB CSV'lerinde aynı butona
    // farkli formatla refer edilir: "VOLUME +", "INPUT HDMI 1",
    // "CURSER DOWN" (Epson'da CURSOR yerine yazim hatasi olarak
    // CURSER de kullaniliyor), "KEY_DOWN" vs.
    String normalize(String s) {
      var n = s.toLowerCase();
      // +/- isaretlerini up/down semantigine cevir
      n = n.replaceAll('+', 'up').replaceAll('-', 'down');
      // Kalan ozel karakterleri ve bosluklari sil
      n = n.replaceAll(RegExp(r'[\s_/.\\]'), '');
      // Anlamsiz prefix'leri sil (kompakt kelimelerden once)
      const prefixes = [
        'input', 'key', 'cursor', 'curser', 'source',
      ];
      for (final prefix in prefixes) {
        if (n.startsWith(prefix) && n.length > prefix.length) {
          n = n.substring(prefix.length);
          break;
        }
      }
      return n;
    }

    for (final alias in aliaslar) {
      final hedef = normalize(alias);
      if (hedef.isEmpty) continue;
      for (final k in komutlar) {
        if (normalize(k.ad) == hedef) return k;
      }
    }
    return null;
  }

  /// Bir TV butonuna karsilik gelen IRDB komutu var mi?
  bool tvDestekli(TvKomut k) => _bul(KomutEslestirme.tvAlias(k)) != null;
  bool klimaDestekli(KlimaKomut k) => _bul(KomutEslestirme.klimaAlias(k)) != null;
  bool projektorDestekli(ProjektorKomut k) =>
      _bul(KomutEslestirme.projektorAlias(k)) != null;

  void _komutYok(String etiket, List<String> aliaslar) {
    _sonAksiyon = 'kumanda_page.komut_yok'.tr();
    notifyListeners();
    // Kullaniciya gorunur hata: bu modelde bu komut yok.
    // Mesaj olarak alias listesini gosteriyoruz ki tani kolay olsun.
    final mevcut = _model?.komutlar
            .map((k) => k.ad)
            .take(40)
            .join(', ') ??
        '(model yok)';
    IrServis.durum.value = IrDurumKaydi(
      IrDurumu.hata,
      mesaj: 'Bu modelde "$etiket" yok.\n'
          'Aranan: ${aliaslar.join(", ")}\n'
          'CSV\'deki ilk komutlar: $mevcut',
    );
  }

  Future<void> yayTv(TvKomut k) async {
    final aliaslar = KomutEslestirme.tvAlias(k);
    final komut = _bul(aliaslar);
    if (komut == null) {
      _komutYok('TV.${k.name}', aliaslar);
      return;
    }
    await yay(komut);
  }

  Future<void> yayKlima(KlimaKomut k) async {
    final aliaslar = KomutEslestirme.klimaAlias(k);
    final komut = _bul(aliaslar);
    if (komut == null) {
      _komutYok('Klima.${k.name}', aliaslar);
      return;
    }
    await yay(komut);
  }

  Future<void> yayProjektor(ProjektorKomut k) async {
    final aliaslar = KomutEslestirme.projektorAlias(k);
    final komut = _bul(aliaslar);
    if (komut == null) {
      _komutYok('Projektor.${k.name}', aliaslar);
      return;
    }
    await yay(komut);
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
