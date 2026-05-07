import 'package:flutter/material.dart';

class OdaIkonu {
  final String anahtar;
  final String etiketTr;
  final String etiketEn;
  final IconData ikon;

  const OdaIkonu({
    required this.anahtar,
    required this.etiketTr,
    required this.etiketEn,
    required this.ikon,
  });
}

class OdaIkonlari {
  static const List<OdaIkonu> tumu = [
    OdaIkonu(anahtar: 'salon', etiketTr: 'Salon', etiketEn: 'Living Room', ikon: Icons.weekend_rounded),
    OdaIkonu(anahtar: 'yatak', etiketTr: 'Yatak Odası', etiketEn: 'Bedroom', ikon: Icons.bed_rounded),
    OdaIkonu(anahtar: 'mutfak', etiketTr: 'Mutfak', etiketEn: 'Kitchen', ikon: Icons.kitchen_rounded),
    OdaIkonu(anahtar: 'ofis', etiketTr: 'Ofis', etiketEn: 'Office', ikon: Icons.desktop_windows_rounded),
    OdaIkonu(anahtar: 'banyo', etiketTr: 'Banyo', etiketEn: 'Bathroom', ikon: Icons.bathtub_rounded),
    OdaIkonu(anahtar: 'cocuk', etiketTr: 'Çocuk Odası', etiketEn: "Children's Room", ikon: Icons.child_care_rounded),
    OdaIkonu(anahtar: 'yemek', etiketTr: 'Yemek Odası', etiketEn: 'Dining Room', ikon: Icons.dining_rounded),
    OdaIkonu(anahtar: 'garaj', etiketTr: 'Garaj', etiketEn: 'Garage', ikon: Icons.garage_rounded),
    OdaIkonu(anahtar: 'toplanti', etiketTr: 'Toplantı Odası', etiketEn: 'Meeting Room', ikon: Icons.meeting_room_rounded),
    OdaIkonu(anahtar: 'balkon', etiketTr: 'Balkon', etiketEn: 'Balcony', ikon: Icons.balcony_rounded),
  ];

  static OdaIkonu bul(String anahtar) {
    return tumu.firstWhere(
      (i) => i.anahtar == anahtar,
      orElse: () => tumu.first,
    );
  }

  static IconData ikon(String anahtar) => bul(anahtar).ikon;
}
