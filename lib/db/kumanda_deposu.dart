import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Kumanda {
  final int id;
  final String ad;
  final String marka;
  final String cihazTipi;
  final String model; // CSV dosya adi (.csv haric), orn. "7,7"
  final DateTime olusturmaTarihi;

  Kumanda({
    required this.id,
    required this.ad,
    required this.marka,
    required this.cihazTipi,
    required this.model,
    required this.olusturmaTarihi,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'ad': ad,
        'marka': marka,
        'cihazTipi': cihazTipi,
        'model': model,
        'olusturmaTarihi': olusturmaTarihi.toIso8601String(),
      };

  factory Kumanda.fromJson(Map<String, dynamic> j) => Kumanda(
        id: j['id'] as int,
        ad: j['ad'] as String,
        marka: j['marka'] as String,
        cihazTipi: j['cihazTipi'] as String,
        model: j['model'] as String,
        olusturmaTarihi: DateTime.parse(j['olusturmaTarihi'] as String),
      );
}

/// Kayitli kumandalari SharedPreferences icinde JSON olarak saklar.
class KumandaDeposu {
  static const String _anahtar = 'kumandalar_v1';
  static SharedPreferences? _prefs;

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
    required String model,
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
      model: model,
      olusturmaTarihi: DateTime.now(),
    );
    final yeniListe = [...mevcut, yeni];
    await _prefs!
        .setString(_anahtar, jsonEncode(yeniListe.map((k) => k.toJson()).toList()));
    return yeni;
  }

  static Future<void> sil(int id) async {
    await baslat();
    final yeniListe = tumunu().where((k) => k.id != id).toList();
    await _prefs!
        .setString(_anahtar, jsonEncode(yeniListe.map((k) => k.toJson()).toList()));
  }

  static Kumanda? bul(int id) {
    for (final k in tumunu()) {
      if (k.id == id) return k;
    }
    return null;
  }
}
