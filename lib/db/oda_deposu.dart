import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Oda {
  final String id;
  String ad;
  String ikonAnahtari;
  final DateTime olusturmaTarihi;

  Oda({
    required this.id,
    required this.ad,
    required this.ikonAnahtari,
    required this.olusturmaTarihi,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'ad': ad,
        'ikonAnahtari': ikonAnahtari,
        'olusturmaTarihi': olusturmaTarihi.toIso8601String(),
      };

  factory Oda.fromJson(Map<String, dynamic> j) => Oda(
        id: j['id'] as String,
        ad: j['ad'] as String,
        ikonAnahtari: (j['ikonAnahtari'] as String?) ?? 'salon',
        olusturmaTarihi: DateTime.parse(j['olusturmaTarihi'] as String),
      );
}

class OdaDeposu {
  static const String _anahtar = 'odalar_v1';
  static SharedPreferences? _prefs;
  static final ValueNotifier<int> degisim = ValueNotifier<int>(0);

  static Future<void> baslat() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static List<Oda> tumunu() {
    final p = _prefs;
    if (p == null) return const [];
    final raw = p.getString(_anahtar);
    if (raw == null || raw.isEmpty) return const [];
    return (jsonDecode(raw) as List)
        .map((e) => Oda.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Oda? bul(String id) {
    for (final o in tumunu()) {
      if (o.id == id) return o;
    }
    return null;
  }

  static Future<Oda> ekle({
    required String ad,
    required String ikonAnahtari,
  }) async {
    await baslat();
    final yeni = Oda(
      id: 'oda_${DateTime.now().millisecondsSinceEpoch}',
      ad: ad,
      ikonAnahtari: ikonAnahtari,
      olusturmaTarihi: DateTime.now(),
    );
    final liste = [...tumunu(), yeni];
    await _kaydet(liste);
    degisim.value++;
    return yeni;
  }

  static Future<void> sil(String id) async {
    await baslat();
    final liste = tumunu().where((o) => o.id != id).toList();
    await _kaydet(liste);
    degisim.value++;
  }

  static Future<void> guncelle(String id,
      {String? ad, String? ikonAnahtari}) async {
    await baslat();
    final liste = tumunu();
    final i = liste.indexWhere((o) => o.id == id);
    if (i < 0) return;
    if (ad != null) liste[i].ad = ad;
    if (ikonAnahtari != null) liste[i].ikonAnahtari = ikonAnahtari;
    await _kaydet(liste);
    degisim.value++;
  }

  static Future<void> _kaydet(List<Oda> liste) async {
    await _prefs!.setString(
        _anahtar, jsonEncode(liste.map((o) => o.toJson()).toList()));
  }
}
