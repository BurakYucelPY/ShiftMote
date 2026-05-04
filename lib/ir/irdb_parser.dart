import 'dart:io';

import 'package:path/path.dart' as p;

import 'cihaz_kategorileri.dart';
import 'irdb_bootstrap.dart';

/// Bir markanin bir curated kategoriye ait spesifik bir model dosyasini
/// (hangi irdb klasoru altinda durdugu dahil) tarif eder.
class KategoriModel {
  final String marka;
  final String irdbKlasoru; // ham irdb klasor adi (orn. 'TV', 'Plasma')
  final String dosya; // CSV adi (.csv haric)
  KategoriModel({
    required this.marka,
    required this.irdbKlasoru,
    required this.dosya,
  });
}

class IrKomut {
  final String ad;
  final String protokol;
  final int device;
  final int subdevice;
  final int function;

  IrKomut({
    required this.ad,
    required this.protokol,
    required this.device,
    required this.subdevice,
    required this.function,
  });
}

class IrModel {
  final String dosya; // dev,subdev (.csv haric)
  final List<IrKomut> komutlar;
  IrModel({required this.dosya, required this.komutlar});
}

class IrdbParser {
  /// Tum cihaz tiplerini doner (markalar arasinda birlestirilmis, sirali).
  static Future<List<String>> cihazTipleri() async {
    final root = await IrdbBootstrap.hazirla();
    final tipler = <String>{};
    final dir = Directory(root);
    if (!await dir.exists()) return [];
    await for (final marka in dir.list()) {
      if (marka is! Directory) continue;
      await for (final tip in marka.list()) {
        if (tip is Directory) tipler.add(p.basename(tip.path));
      }
    }
    final list = tipler.toList()..sort();
    return list;
  }

  /// Belirli bir cihaz tipini destekleyen markalari doner.
  static Future<List<String>> markalar(String cihazTipi) async {
    final root = await IrdbBootstrap.hazirla();
    final markalar = <String>[];
    final dir = Directory(root);
    if (!await dir.exists()) return [];
    await for (final marka in dir.list()) {
      if (marka is! Directory) continue;
      final tipKlasor = Directory(p.join(marka.path, cihazTipi));
      if (await tipKlasor.exists()) {
        markalar.add(p.basename(marka.path));
      }
    }
    markalar.sort();
    return markalar;
  }

  /// Marka + cihaz tipi altindaki tum modelleri (CSV dosya isimleri, .csv haric) doner.
  static Future<List<String>> modeller(String marka, String cihazTipi) async {
    final root = await IrdbBootstrap.hazirla();
    final dir = Directory(p.join(root, marka, cihazTipi));
    if (!await dir.exists()) return [];
    final modeller = <String>[];
    await for (final f in dir.list()) {
      if (f is File && f.path.toLowerCase().endsWith('.csv')) {
        modeller.add(p.basenameWithoutExtension(f.path));
      }
    }
    modeller.sort();
    return modeller;
  }

  /// Curated kategoriden marka listesi doner. Birden fazla irdb klasorunu
  /// tarar ve set ile dedupe yapar.
  static Future<List<String>> markalarKategoriden(
      CihazKategorisi kat) async {
    final root = await IrdbBootstrap.hazirla();
    final dir = Directory(root);
    if (!await dir.exists()) return [];

    // Hangi ham klasor adlarini tarayacagiz?
    final aranan = <String>{};
    if (kat.irdbAdlari.isEmpty) {
      // 'Diger' kategorisi: 10 kategori disindaki TUM klasor adlarini topla
      final hepsi = <String>{};
      await for (final marka in dir.list()) {
        if (marka is! Directory) continue;
        await for (final tip in marka.list()) {
          if (tip is Directory) hepsi.add(p.basename(tip.path));
        }
      }
      // Yukaridaki ana 10 kategoriye ait olanlari hepsiden cikar
      final kapsanan = <String>{};
      for (final k in CihazKategorileri.tumu) {
        kapsanan.addAll(k.irdbAdlari);
      }
      aranan.addAll(hepsi.difference(kapsanan));
    } else {
      aranan.addAll(kat.irdbAdlari);
    }

    final markalar = <String>{};
    await for (final marka in dir.list()) {
      if (marka is! Directory) continue;
      // Bu markanin altinda aranan klasor adlarinden biri var mi?
      await for (final tip in marka.list()) {
        if (tip is Directory && aranan.contains(p.basename(tip.path))) {
          markalar.add(p.basename(marka.path));
          break;
        }
      }
    }
    final list = markalar.toList()..sort();
    return list;
  }

  /// Bir markanin bir curated kategorideki tum modellerini doner.
  /// Birden fazla irdb klasorunden gelebilir (ornek: Samsung TV ve Samsung Plasma).
  static Future<List<KategoriModel>> modellerKategoriden(
      String marka, CihazKategorisi kat) async {
    final root = await IrdbBootstrap.hazirla();
    final markaDir = Directory(p.join(root, marka));
    if (!await markaDir.exists()) return [];

    final aranan = <String>{};
    if (kat.irdbAdlari.isEmpty) {
      // 'Diger': 10 kategoriye ait olmayan tum tip klasorlerini al
      final kapsanan = <String>{};
      for (final k in CihazKategorileri.tumu) {
        kapsanan.addAll(k.irdbAdlari);
      }
      await for (final tip in markaDir.list()) {
        if (tip is Directory) {
          final ad = p.basename(tip.path);
          if (!kapsanan.contains(ad)) aranan.add(ad);
        }
      }
    } else {
      aranan.addAll(kat.irdbAdlari);
    }

    final sonuc = <KategoriModel>[];
    for (final klasor in aranan) {
      final tipDir = Directory(p.join(markaDir.path, klasor));
      if (!await tipDir.exists()) continue;
      await for (final f in tipDir.list()) {
        if (f is File && f.path.toLowerCase().endsWith('.csv')) {
          sonuc.add(KategoriModel(
            marka: marka,
            irdbKlasoru: klasor,
            dosya: p.basenameWithoutExtension(f.path),
          ));
        }
      }
    }
    sonuc.sort((a, b) {
      final c = a.irdbKlasoru.compareTo(b.irdbKlasoru);
      return c != 0 ? c : a.dosya.compareTo(b.dosya);
    });
    return sonuc;
  }

  /// Bir modelin CSV'sini parse edip komut listesi doner.
  static Future<IrModel> modelYukle(
      String marka, String cihazTipi, String model) async {
    final root = await IrdbBootstrap.hazirla();
    final dosya = File(p.join(root, marka, cihazTipi, '$model.csv'));
    if (!await dosya.exists()) {
      return IrModel(dosya: model, komutlar: []);
    }

    final satirlar = await dosya.readAsLines();
    final komutlar = <IrKomut>[];
    for (int i = 0; i < satirlar.length; i++) {
      final satir = satirlar[i].trim();
      if (satir.isEmpty) continue;
      // Bas satir: functionname,protocol,device,subdevice,function
      if (i == 0 && satir.toLowerCase().startsWith('functionname')) continue;
      final parts = satir.split(',');
      if (parts.length < 5) continue;
      komutlar.add(IrKomut(
        ad: parts[0],
        protokol: parts[1],
        device: int.tryParse(parts[2]) ?? 0,
        subdevice: int.tryParse(parts[3]) ?? 0,
        function: int.tryParse(parts[4]) ?? 0,
      ));
    }
    return IrModel(dosya: model, komutlar: komutlar);
  }
}

/// Protokol -> raw timing donusumu.
/// Spec referans: hifi-remote.com DecodeIR + IRP notation.
/// Donus: (frekansHz, pattern). Desteklenmiyorsa null.
class IrProtokol {
  static (int, List<int>)? komutaTimings(IrKomut k) {
    final p =
        k.protokol.toUpperCase().replaceAll(' ', '').replaceAll('UNIT=0', '');
    final d = k.device, s = k.subdevice, f = k.function;

    // ----- NEC ailesi (38 kHz, 564us) -----
    if (p == 'NEC' || p == 'NEC1' || p == 'NEC2') return _nec1(d, s, f);
    if (p.startsWith('NEC1-Y') ||
        p == 'NEC1-F16' ||
        p == 'NEC2-F16' ||
        p == 'NEC1-RNC') return _nec1(d, s, f);
    if (p == 'NECX' || p == 'NECX1' || p == 'NECX2') return _necX(d, s, f);
    if (p == 'PIONEER') return _pioneer(d, s, f);

    // ----- JVC -----
    if (p == 'JVC' || p.startsWith('JVC{')) return _jvc(d, f);

    // ----- Sony 12/15/20 -----
    if (p == 'SONY12') return _sony(d: d, f: f, sub: s, bits: 12);
    if (p == 'SONY15') return _sony(d: d, f: f, sub: s, bits: 15);
    if (p == 'SONY20') return _sony(d: d, f: f, sub: s, bits: 20);

    // ----- Philips RC ailesi -----
    if (p == 'RC5' || p == 'RC5X') return _rc5(d, f);
    if (p == 'RC6') return _rc6(d, f);
    if (p == 'MCE') return _rc6(d, f); // RC6-mode-6 simplified

    // ----- Panasonic -----
    if (p == 'PANASONIC' || p == 'PANASONIC_OLD' || p.startsWith('PANASONIC{')) {
      return _panasonic(d, s, f);
    }

    // ----- Mitsubishi -----
    if (p == 'MITSUBISHI') return _mitsubishi(d, f);

    // ----- Aiwa -----
    if (p == 'AIWA') return _aiwa(d, s, f);

    // ----- Denon / Sharp (cift yari-frame) -----
    if (p == 'DENON' || p == 'DENON-K' || p.startsWith('DENON{')) {
      return _denon(d, f);
    }
    if (p == 'SHARP' || p.startsWith('SHARP{')) return _sharp(d, f);

    // ----- RECS80 -----
    if (p == 'RECS80') return _recs80(d, f);

    // ----- Samsung36 / Samsung -----
    if (p == 'SAMSUNG36' || p == 'SAMSUNG') return _samsung36(d, s, f);

    return null;
  }

  // ─────────── Yardimcilar ───────────

  /// Bir tamsayi degerden bit listesi cikarir. lsbFirst=true ise en dusuk
  /// anlamli bit dizinin basinda olur.
  static List<int> _bitler(int v, int n, {required bool lsbFirst}) {
    final out = <int>[];
    if (lsbFirst) {
      for (int i = 0; i < n; i++) {
        out.add((v >> i) & 1);
      }
    } else {
      for (int i = n - 1; i >= 0; i--) {
        out.add((v >> i) & 1);
      }
    }
    return out;
  }

  /// SPACE_ENC encoding (NEC, JVC, Panasonic, Sony bit-encoding vs):
  ///   bit 0 = mark (unit) + space (unit * sifirKat)
  ///   bit 1 = mark (unit) + space (unit * birKat)
  /// Sonunda trail = mark (unit * trailMark).
  static List<int> _spaceEnc({
    int? hMark,
    int? hSpace,
    required int unit,
    required List<int> bits,
    int sifirKat = 1,
    int birKat = 3,
    int trailMark = 1,
  }) {
    final p = <int>[];
    if (hMark != null) {
      p.add(hMark);
      if (hSpace != null) p.add(hSpace);
    }
    for (final b in bits) {
      p.add(unit);
      p.add(b == 1 ? unit * birKat : unit * sifirKat);
    }
    if (trailMark > 0) p.add(unit * trailMark);
    return p;
  }

  /// Manchester (biphase) encoding (RC5):
  ///   zeroBitMarkFirst=true : bit 0 = mark+space, bit 1 = space+mark (RC5)
  ///   zeroBitMarkFirst=false: bit 0 = space+mark, bit 1 = mark+space (RC6)
  /// Komsu ayni-state olan parcalar birlestirilir, sonuc pulse,space,pulse,...
  /// dizisidir. Bastaki space dusurulur (ConsumerIrManager pulse ile baslar).
  static List<int> _manchester({
    required int unit,
    required List<int> bits,
    required bool zeroBitMarkFirst,
  }) {
    // states: her eleman [state(0/1), yarımBirim sayisi]
    final states = <List<int>>[];
    void add(int state, int hu) {
      if (states.isNotEmpty && states.last[0] == state) {
        states.last[1] += hu;
      } else {
        states.add([state, hu]);
      }
    }

    for (final b in bits) {
      final markFirst =
          (b == 0 && zeroBitMarkFirst) || (b == 1 && !zeroBitMarkFirst);
      if (markFirst) {
        add(1, 1);
        add(0, 1);
      } else {
        add(0, 1);
        add(1, 1);
      }
    }

    // Bastaki space'i dus
    int idx = 0;
    if (states.isNotEmpty && states.first[0] == 0) idx = 1;

    final p = <int>[];
    for (int i = idx; i < states.length; i++) {
      p.add(states[i][1] * unit);
    }
    return p;
  }

  // ─────────── Protokoller ───────────

  /// NEC1/NEC2: {38k,564,LSB} hdr=16,-8 D:8 S:8 F:8 ~F:8 tr=1
  static (int, List<int>) _nec1(int d, int s, int f) {
    final bits = <int>[
      ..._bitler(d & 0xFF, 8, lsbFirst: true),
      ..._bitler(s & 0xFF, 8, lsbFirst: true),
      ..._bitler(f & 0xFF, 8, lsbFirst: true),
      ..._bitler((~f) & 0xFF, 8, lsbFirst: true),
    ];
    return (38000, _spaceEnc(hMark: 9000, hSpace: 4500, unit: 564, bits: bits));
  }

  /// NECx1/NECx2: {38k,564,LSB} hdr=8,-8 ... (header NEC1'den farkli)
  static (int, List<int>) _necX(int d, int s, int f) {
    final bits = <int>[
      ..._bitler(d & 0xFF, 8, lsbFirst: true),
      ..._bitler(s & 0xFF, 8, lsbFirst: true),
      ..._bitler(f & 0xFF, 8, lsbFirst: true),
      ..._bitler((~f) & 0xFF, 8, lsbFirst: true),
    ];
    return (38000, _spaceEnc(hMark: 4500, hSpace: 4500, unit: 564, bits: bits));
  }

  /// Pioneer: NEC1 ile aynı, sadece 40 kHz.
  static (int, List<int>) _pioneer(int d, int s, int f) {
    final r = _nec1(d, s, f);
    return (40000, r.$2);
  }

  /// JVC: {38k,525,LSB} hdr=16,-8 D:8 F:8 tr=1
  /// (irdb subdevice'i kullanmiyor, sadece D ve F)
  static (int, List<int>) _jvc(int d, int f) {
    final bits = <int>[
      ..._bitler(d & 0xFF, 8, lsbFirst: true),
      ..._bitler(f & 0xFF, 8, lsbFirst: true),
    ];
    return (38000, _spaceEnc(hMark: 8400, hSpace: 4200, unit: 525, bits: bits));
  }

  /// Sony 12/15/20: {40k,600,LSB}
  ///   hdr = 4 unit mark + 1 unit space (2400/600)
  ///   bit 0 = 600 mark + 600 space
  ///   bit 1 = 1200 mark + 600 space
  ///   no trail. 3 frame tekrari yapilir (^45m total).
  static (int, List<int>) _sony({
    required int d,
    required int f,
    required int sub,
    required int bits,
  }) {
    final fields = <int>[];
    fields.addAll(_bitler(f & 0x7F, 7, lsbFirst: true));
    if (bits == 12) {
      fields.addAll(_bitler(d & 0x1F, 5, lsbFirst: true));
    } else if (bits == 15) {
      fields.addAll(_bitler(d & 0xFF, 8, lsbFirst: true));
    } else {
      // 20
      fields.addAll(_bitler(d & 0x1F, 5, lsbFirst: true));
      fields.addAll(_bitler(sub & 0xFF, 8, lsbFirst: true));
    }

    // Tek frame: header mark, header space, then bit-mark, gap, bit-mark, gap, ..., bit-mark
    final body = <int>[2400, 600];
    for (int i = 0; i < fields.length; i++) {
      body.add(fields[i] == 1 ? 1200 : 600);
      if (i < fields.length - 1) body.add(600);
    }
    final bodyDur = body.fold<int>(0, (a, b) => a + b);

    // 3 kez tekrar et, her frame arasi ^45m olacak sekilde gap
    final p = <int>[];
    for (int i = 0; i < 3; i++) {
      p.addAll(body);
      if (i < 2) {
        final gap = 45000 - bodyDur;
        p.add(gap > 600 ? gap : 600);
      }
    }
    return (40000, p);
  }

  /// RC5: {36k,889,MSB} no hdr, bits = 1 + ~F:1:6 + T:1 + D:5 + F:6
  ///   bit 0 = mark+space, bit 1 = space+mark (Manchester)
  static (int, List<int>) _rc5(int d, int f) {
    final fieldBit = ((~f) >> 6) & 1; // 7. biti tamamlayan field bit
    const toggleBit = 0;
    final bits = <int>[
      1, // start bit
      fieldBit,
      toggleBit,
      ..._bitler(d & 0x1F, 5, lsbFirst: false),
      ..._bitler(f & 0x3F, 6, lsbFirst: false),
    ];
    return (36000, _manchester(unit: 889, bits: bits, zeroBitMarkFirst: true));
  }

  /// RC6: {36k,444,MSB} hdr=6,-2 then 1:1 + 0:3 + T:1(double) + D:8 + F:8
  ///   bit 0 = space+mark, bit 1 = mark+space (Manchester, ters)
  /// Toggle bit cift genislikli (2 yarim birim).
  static (int, List<int>) _rc6(int d, int f) {
    final p = <int>[2664, 888]; // header: 6*444, 2*444

    // states list for the data portion (Manchester merge)
    final states = <List<int>>[];
    void add(int state, int hu) {
      if (states.isNotEmpty && states.last[0] == state) {
        states.last[1] += hu;
      } else {
        states.add([state, hu]);
      }
    }

    void manch(int bit, {int wide = 1}) {
      // RC6: bit 0 = space first, bit 1 = mark first
      if (bit == 1) {
        add(1, wide);
        add(0, wide);
      } else {
        add(0, wide);
        add(1, wide);
      }
    }

    // start bit (always 1)
    manch(1);
    // mode bits 0:3 (3 zero bits)
    for (int i = 0; i < 3; i++) {
      manch(0);
    }
    // toggle bit (0), double width
    manch(0, wide: 2);
    // D:8 MSB
    for (final b in _bitler(d & 0xFF, 8, lsbFirst: false)) {
      manch(b);
    }
    // F:8 MSB
    for (final b in _bitler(f & 0xFF, 8, lsbFirst: false)) {
      manch(b);
    }

    // Header space ile bittik. Veri ilk durumu (1, 1) olmali (start bit = mark first).
    // Yine de guvenlik icin: ilk durum space ise dus.
    int idx = 0;
    if (states.isNotEmpty && states.first[0] == 0) idx = 1;
    for (int i = idx; i < states.length; i++) {
      p.add(states[i][1] * 444);
    }
    return (36000, p);
  }

  /// Panasonic: {37k,432,LSB} hdr=8,-4 prefix 0x02 0x20, sonra D:8 S:8 F:8 (D^S^F):8 tr=1
  static (int, List<int>) _panasonic(int d, int s, int f) {
    final cks = (d ^ s ^ f) & 0xFF;
    final bits = <int>[
      ..._bitler(0x02, 8, lsbFirst: true),
      ..._bitler(0x20, 8, lsbFirst: true),
      ..._bitler(d & 0xFF, 8, lsbFirst: true),
      ..._bitler(s & 0xFF, 8, lsbFirst: true),
      ..._bitler(f & 0xFF, 8, lsbFirst: true),
      ..._bitler(cks, 8, lsbFirst: true),
    ];
    return (37000, _spaceEnc(hMark: 3456, hSpace: 1728, unit: 432, bits: bits));
  }

  /// Mitsubishi: {32.6k,300,LSB} no hdr, D:8 F:8, bit 0 = 1,-3, bit 1 = 1,-7, tr=1+gap
  static (int, List<int>) _mitsubishi(int d, int f) {
    final bits = <int>[
      ..._bitler(d & 0xFF, 8, lsbFirst: true),
      ..._bitler(f & 0xFF, 8, lsbFirst: true),
    ];
    final p = <int>[];
    for (final b in bits) {
      p.add(300);
      p.add(b == 1 ? 2100 : 900); // 1*300=300, 3*300=900, 7*300=2100
    }
    p.add(300); // trail
    p.add(24000); // 80 unit gap
    return (33000, p); // 32.6 -> 33 (en yakin tam sayi)
  }

  /// Aiwa: {38k,550,LSB} hdr=16,-8 D:8 S:5 ~D:8 ~S:5 F:8 ~F:8 tr=1
  static (int, List<int>) _aiwa(int d, int s, int f) {
    final bits = <int>[
      ..._bitler(d & 0xFF, 8, lsbFirst: true),
      ..._bitler(s & 0x1F, 5, lsbFirst: true),
      ..._bitler((~d) & 0xFF, 8, lsbFirst: true),
      ..._bitler((~s) & 0x1F, 5, lsbFirst: true),
      ..._bitler(f & 0xFF, 8, lsbFirst: true),
      ..._bitler((~f) & 0xFF, 8, lsbFirst: true),
    ];
    return (38000, _spaceEnc(hMark: 8800, hSpace: 4400, unit: 550, bits: bits));
  }

  /// Denon: {38k,264,LSB} no hdr, iki yari-frame:
  ///   1) D:5 F:8 0:2 (constant 00)
  ///   2) D:5 ~F:8 3:2 (constant 11)
  /// Bit 0 = 1,-3, Bit 1 = 1,-7. Iki frame arasi 165 unit gap.
  static (int, List<int>) _denon(int d, int f) {
    final first = <int>[
      ..._bitler(d & 0x1F, 5, lsbFirst: true),
      ..._bitler(f & 0xFF, 8, lsbFirst: true),
      0, 0, // 0:2 sabit
    ];
    final second = <int>[
      ..._bitler(d & 0x1F, 5, lsbFirst: true),
      ..._bitler((~f) & 0xFF, 8, lsbFirst: true),
      1, 1, // 3:2 sabit (binary 11)
    ];
    final p = <int>[];
    for (final b in first) {
      p.add(264);
      p.add(b == 1 ? 1848 : 792);
    }
    p.add(264); // trail
    p.add(264 * 165); // 165-unit gap
    for (final b in second) {
      p.add(264);
      p.add(b == 1 ? 1848 : 792);
    }
    p.add(264); // trail
    return (38000, p);
  }

  /// Sharp: Denon ile ayni timing, sadece sabit bitler farkli (1:2 / 2:2)
  static (int, List<int>) _sharp(int d, int f) {
    final first = <int>[
      ..._bitler(d & 0x1F, 5, lsbFirst: true),
      ..._bitler(f & 0xFF, 8, lsbFirst: true),
      1, 0, // 1:2 = LSB-first 1,0 (binary 01)
    ];
    final second = <int>[
      ..._bitler(d & 0x1F, 5, lsbFirst: true),
      ..._bitler((~f) & 0xFF, 8, lsbFirst: true),
      0, 1, // 2:2 = LSB-first 0,1 (binary 10)
    ];
    final p = <int>[];
    for (final b in first) {
      p.add(264);
      p.add(b == 1 ? 1848 : 792);
    }
    p.add(264);
    p.add(264 * 165);
    for (final b in second) {
      p.add(264);
      p.add(b == 1 ? 1848 : 792);
    }
    p.add(264);
    return (38000, p);
  }

  /// RECS80: {38k,158,MSB} no hdr, bits = 1:1 + T:1 + D:3 + F:6
  /// bit 0 = 1,-31 (158/4898), bit 1 = 1,-47 (158/7426)
  static (int, List<int>) _recs80(int d, int f) {
    const toggleBit = 0;
    final bits = <int>[
      1, // start
      toggleBit,
      ..._bitler(d & 0x07, 3, lsbFirst: false),
      ..._bitler(f & 0x3F, 6, lsbFirst: false),
    ];
    final p = <int>[];
    for (final b in bits) {
      p.add(158);
      p.add(b == 1 ? 158 * 47 : 158 * 31);
    }
    p.add(158); // trail
    return (38000, p);
  }

  /// Samsung36: {38k,500,LSB} hdr=9,-9 (4500/4500), iki yari:
  ///   1) D:8 S:8 + 1, -9 (orta gap)
  ///   2) E:4 (irdb'de yok, 0) F:8 ~F:8 + tr=1
  /// Bit 0 = 1,-1, Bit 1 = 1,-3
  static (int, List<int>) _samsung36(int d, int s, int f) {
    final firstBits = <int>[
      ..._bitler(d & 0xFF, 8, lsbFirst: true),
      ..._bitler(s & 0xFF, 8, lsbFirst: true),
    ];
    final secondBits = <int>[
      ..._bitler(0 & 0x0F, 4, lsbFirst: true), // E = 0 (irdb sunmuyor)
      ..._bitler(f & 0xFF, 8, lsbFirst: true),
      ..._bitler((~f) & 0xFF, 8, lsbFirst: true),
    ];
    final p = <int>[4500, 4500]; // header
    for (final b in firstBits) {
      p.add(500);
      p.add(b == 1 ? 1500 : 500);
    }
    p.add(500); // 1 unit mark
    p.add(4500); // 9 unit space (orta gap)
    for (final b in secondBits) {
      p.add(500);
      p.add(b == 1 ? 1500 : 500);
    }
    p.add(500); // trail
    return (38000, p);
  }
}
