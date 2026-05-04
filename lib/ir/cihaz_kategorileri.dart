import 'package:flutter/material.dart';

/// irdb'deki 1400+ ham kategori isimini, kullaniciya gosterilen 11 sade
/// Turkce kategoriye eslestirir.
class CihazKategorisi {
  /// Kalici anahtar (kayit ve tr key icin).
  final String anahtar;

  /// Cevirisi 'cihaz.<anahtar>' YAML key'inden alinir.
  final String etiketKey;

  final IconData ikon;

  /// Bu curated kategoriye dahil olan irdb klasor adlari.
  /// Bos liste ise "Diger" anlamina gelir (her seyi gosterir).
  final List<String> irdbAdlari;

  /// Marka secim ekraninda en uste cip olarak konacak markalar.
  final List<String> populerMarkalar;

  const CihazKategorisi({
    required this.anahtar,
    required this.etiketKey,
    required this.ikon,
    required this.irdbAdlari,
    required this.populerMarkalar,
  });
}

class CihazKategorileri {
  static const List<CihazKategorisi> tumu = [
    CihazKategorisi(
      anahtar: 'tv',
      etiketKey: 'cihaz.tv',
      ikon: Icons.tv,
      irdbAdlari: [
        'TV',
        'Plasma',
        'Unknown_TV',
        'HDTV',
        'HD',
        'Display',
        'Monitor',
      ],
      populerMarkalar: [
        'Samsung',
        'LG',
        'Sony',
        'Vestel',
        'Philips',
        'Panasonic',
        'Toshiba',
        'Sharp',
        'Hisense',
        'TCL',
      ],
    ),
    CihazKategorisi(
      anahtar: 'klima',
      etiketKey: 'cihaz.klima',
      ikon: Icons.ac_unit,
      irdbAdlari: [
        'Air Conditioner',
        'Klima',
        'Air conditioner',
        'AC',
      ],
      populerMarkalar: [
        'Mitsubishi',
        'Daikin',
        'LG',
        'Samsung',
        'Panasonic',
        'Toshiba',
        'Carrier',
        'Vestel',
        'Bosch',
        'Beko',
      ],
    ),
    CihazKategorisi(
      anahtar: 'projektor',
      etiketKey: 'cihaz.projektor',
      ikon: Icons.video_camera_back,
      irdbAdlari: [
        'Projector',
        'Video Projector',
      ],
      populerMarkalar: [
        'Epson',
        'BenQ',
        'Sony',
        'NEC',
        'Panasonic',
        'ViewSonic',
        'Optoma',
        'Hitachi',
        'Acer',
        'HP',
      ],
    ),
    CihazKategorisi(
      anahtar: 'ses',
      etiketKey: 'cihaz.ses',
      ikon: Icons.speaker,
      irdbAdlari: [
        'Receiver',
        'Amplifier',
        'Pre-Amplifier',
        'AV Processor',
        'AV Preamplifier',
        'Surround Processor',
        'Tuner',
        'Boombox',
        'CD Receiver',
        'Audio',
        '2-Channel Preamp',
        '6 Zone Receiver',
        'Distributed',
        'Digital Audio',
        'Processor',
        'Power Amplifier',
      ],
      populerMarkalar: [
        'Sony',
        'Yamaha',
        'Denon',
        'Onkyo',
        'Pioneer',
        'Marantz',
        'JBL',
        'Bose',
        'Harman',
      ],
    ),
    CihazKategorisi(
      anahtar: 'cd',
      etiketKey: 'cihaz.cd',
      ikon: Icons.album,
      irdbAdlari: [
        'CD Player',
        'CD Changer',
        'CD Jukebox',
        'CD Management',
        'Cassette Tape',
        'MP3 Player',
        'iPod',
        'Unknown_CD',
      ],
      populerMarkalar: [
        'Sony',
        'Pioneer',
        'Yamaha',
        'Denon',
        'Philips',
        'Onkyo',
      ],
    ),
    CihazKategorisi(
      anahtar: 'dvd',
      etiketKey: 'cihaz.dvd',
      ikon: Icons.disc_full,
      irdbAdlari: [
        'DVD Player',
        'DVD Changer',
        'DVD Jukebox',
        'DVD Library',
        'DVD Manager',
        'DVD Server',
        'DVD Pre-amp',
        'Blu-Ray',
        'HD DVD',
        'Laser Disc',
        'VCR',
        'Unknown_VCR',
        'Unknown_DVD',
      ],
      populerMarkalar: [
        'Sony',
        'Pioneer',
        'Panasonic',
        'LG',
        'Samsung',
        'Toshiba',
        'Philips',
        'Yamaha',
      ],
    ),
    CihazKategorisi(
      anahtar: 'uydu',
      etiketKey: 'cihaz.uydu',
      ikon: Icons.satellite_alt,
      irdbAdlari: [
        'Cable Box',
        'Satellite',
        'DSS',
        'Dish Network',
        'Basic Satellite',
        'DTV Decoder',
        'Digital Decoder',
        'Digital Media Receiver',
        'Decoder',
        'DVB-T',
        'DVBS-Receiver',
        'Cable Receiver',
        'Unknown_SAT',
        'Unknown_Digital',
        'Unknown_DVB',
      ],
      populerMarkalar: [
        'Vestel',
        'Philips',
        'Humax',
        'Hyundai',
        'Manhattan',
        'Motorola',
      ],
    ),
    CihazKategorisi(
      anahtar: 'akilli_kutu',
      etiketKey: 'cihaz.akilli_kutu',
      ikon: Icons.cast,
      irdbAdlari: [
        'Apple TV',
        'Streaming',
        'Smart TV Box',
        'Digital Radio',
      ],
      populerMarkalar: [
        'Apple',
        'Roku',
        'Amazon',
        'Google',
      ],
    ),
    CihazKategorisi(
      anahtar: 'vantilator',
      etiketKey: 'cihaz.vantilator',
      ikon: Icons.toys,
      irdbAdlari: [
        'Fan',
        'Ceiling Fan',
      ],
      populerMarkalar: [
        'Vestel',
        'Hunter',
        'Casablanca',
      ],
    ),
    CihazKategorisi(
      anahtar: 'kamera',
      etiketKey: 'cihaz.kamera',
      ikon: Icons.camera_alt,
      irdbAdlari: [
        'Camera',
        'Camcorder',
        'DV Cam',
        'Camera Multi Plex',
      ],
      populerMarkalar: [
        'Sony',
        'Canon',
        'Nikon',
        'Panasonic',
      ],
    ),
    CihazKategorisi(
      anahtar: 'diger',
      etiketKey: 'cihaz.diger',
      ikon: Icons.devices_other,
      irdbAdlari: [], // bos liste = digerleri (yukaridakilerde olmayanlar)
      populerMarkalar: [],
    ),
  ];

  static CihazKategorisi? bul(String anahtar) {
    for (final k in tumu) {
      if (k.anahtar == anahtar) return k;
    }
    return null;
  }
}
