class Rotalar {
  // Bottom-nav (StatefulShellRoute branchleri)
  static const String anasayfaPath = '/anasayfa';
  static const String odalarPath = '/odalar';
  static const String favorilerPath = '/favoriler';

  // Detay ekranlari (sheet/push)
  static const String kumandaEklePath = '/kumanda-ekle';
  static const String odaEklePath = '/oda-ekle';
  static const String ayarlarPath = '/ayarlar';
  static const String hakkindaPath = '/hakkinda';
  static const String kumandaPath = 'kumanda/:id'; // /anasayfa altinda
  static const String odaDetayPath = 'oda/:id';    // /odalar altinda
  static const String dilPath = 'dil';             // /ayarlar altinda

  // Route adlari
  static const String anasayfaName = 'anasayfa';
  static const String odalarName = 'odalar';
  static const String favorilerName = 'favoriler';
  static const String kumandaEkleName = 'kumandaEkle';
  static const String odaEkleName = 'odaEkle';
  static const String odaDetayName = 'odaDetay';
  static const String kumandaName = 'kumanda';
  static const String ayarlarName = 'ayarlar';
  static const String dilName = 'dil';
  static const String hakkindaName = 'hakkinda';
}
