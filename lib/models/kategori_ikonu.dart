import 'package:flutter/material.dart';

import '../ir/cihaz_kategorileri.dart';

class KategoriIkonu {
  static IconData ikon(String anahtar) {
    for (final k in CihazKategorileri.tumu) {
      if (k.anahtar == anahtar) return k.ikon;
    }
    return Icons.devices_other_rounded;
  }

  static CihazKategorisi? kategori(String anahtar) {
    for (final k in CihazKategorileri.tumu) {
      if (k.anahtar == anahtar) return k;
    }
    return null;
  }
}
