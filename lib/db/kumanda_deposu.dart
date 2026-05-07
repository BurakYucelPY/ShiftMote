import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Kumanda {
  final int id;
  String ad;
  final String marka;
  final String cihazTipi; // kullaniciya gosterilen etiket (lokalize)
  final String kategoriAnahtari; // 'tv' / 'klima' / 'projektor' / ... (icon+route lookup)
  final String irdbKlasoru; // ham irdb klasor adi (CSV bulmak icin)
  final String model; // CSV dosya adi (.csv haric), orn. "7,7"
  final DateTime olusturmaTarihi;
  bool favori;
  String? odaId;

  Kumanda({
    required this.id,
    required this.ad,
    required this.marka,
    required this.cihazTipi,
    required this.kategoriAnahtari,
    required this.irdbKlasoru,
    required this.model,
    required this.olusturmaTarihi,
    this.favori = false,
    this.odaId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'ad': ad,
        'marka': marka,
        'cihazTipi': cihazTipi,
        'kategoriAnahtari': kategoriAnahtari,
        'irdbKlasoru': irdbKlasoru,
        'model': model,
        'olusturmaTarihi': olusturmaTarihi.toIso8601String(),
        'favori': favori,
        'odaId': odaId,
      };

  factory Kumanda.fromJson(Map<String, dynamic> j) => Kumanda(
        id: j['id'] as int,
        ad: j['ad'] as String,
        marka: j['marka'] as String,
        cihazTipi: j['cihazTipi'] as String,
        kategoriAnahtari: (j['kategoriAnahtari'] as String?) ?? 'diger',
        // Geri uyumluluk: eski kayitlarda irdbKlasoru yok, cihazTipi'yi kullan
        irdbKlasoru:
            (j['irdbKlasoru'] as String?) ?? (j['cihazTipi'] as String),
        model: j['model'] as String,
        olusturmaTarihi: DateTime.parse(j['olusturmaTarihi'] as String),
        favori: (j['favori'] as bool?) ?? false,
        odaId: j['odaId'] as String?,
      );
}

/// Kayitli kumandalari SharedPreferences icinde JSON olarak saklar.
class KumandaDeposu {
  static const String _anahtar = 'kumandalar_v1';
  static SharedPreferences? _prefs;

  /// Liste her degistiginde tetiklenir; Anasayfa bunu dinleyip otomatik yeniler.
  static final ValueNotifier<int> degisim = ValueNotifier<int>(0);

  static Future<void> baslat() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static List<Kumanda> tumunu() {
    final p = _prefs;
    if (p == null) return const [];
    final raw = p.getString(_anahtar);
    if (raw == null || raw.isEmpty) return const [];
    final liste = (jsonDecode(raw) as List)
        .map((e) => Kumanda.fromJson(e as Map<String, dynamic>))
        .toList();
    return liste;
  }

  static Future<Kumanda> ekle({
    required String ad,
    required String marka,
    required String cihazTipi,
    required String kategoriAnahtari,
    required String irdbKlasoru,
    required String model,
    String? odaId,
  }) async {
    await baslat();
    final mevcut = tumunu();
    final yeniId =
        mevcut.isEmpty ? 1 : mevcut.map((k) => k.id).reduce((a, b) => a > b ? a : b) + 1;
    final yeni = Kumanda(
      id: yeniId,
      ad: ad,
      marka: marka,
      cihazTipi: cihazTipi,
      kategoriAnahtari: kategoriAnahtari,
      irdbKlasoru: irdbKlasoru,
      model: model,
      olusturmaTarihi: DateTime.now(),
      odaId: odaId,
    );
    final yeniListe = [...mevcut, yeni];
    await _kaydet(yeniListe);
    degisim.value++;
    return yeni;
  }

  static Future<void> sil(int id) async {
    await baslat();
    final yeniListe = tumunu().where((k) => k.id != id).toList();
    await _kaydet(yeniListe);
    degisim.value++;
  }

  static Kumanda? bul(int id) {
    for (final k in tumunu()) {
      if (k.id == id) return k;
    }
    return null;
  }

  static List<Kumanda> favoriler() => tumunu().where((k) => k.favori).toList();

  static List<Kumanda> odadakiler(String odaId) =>
      tumunu().where((k) => k.odaId == odaId).toList();

  static Future<void> favoriDegistir(int id, bool yeni) async {
    await baslat();
    final liste = tumunu();
    final i = liste.indexWhere((k) => k.id == id);
    if (i < 0) return;
    liste[i].favori = yeni;
    await _kaydet(liste);
    degisim.value++;
  }

  static Future<void> yenidenAdlandir(int id, String yeniAd) async {
    await baslat();
    final liste = tumunu();
    final i = liste.indexWhere((k) => k.id == id);
    if (i < 0) return;
    liste[i].ad = yeniAd;
    await _kaydet(liste);
    degisim.value++;
  }

  static Future<void> odayaTasi(int id, String? odaId) async {
    await baslat();
    final liste = tumunu();
    final i = liste.indexWhere((k) => k.id == id);
    if (i < 0) return;
    liste[i].odaId = odaId;
    await _kaydet(liste);
    degisim.value++;
  }

  static Future<void> _kaydet(List<Kumanda> liste) async {
    await _prefs!.setString(
        _anahtar, jsonEncode(liste.map((k) => k.toJson()).toList()));
  }
}
