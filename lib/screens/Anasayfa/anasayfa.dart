import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../db/kumanda_deposu.dart';
import '../../db/oda_deposu.dart';
import 'anasayfa_view.dart';

class AnasayfaProvider extends ChangeNotifier {
  List<Kumanda> _kumandalar = [];
  List<Oda> _odalar = [];

  List<Kumanda> get kumandalar => _kumandalar;
  List<Oda> get odalar => _odalar;

  void yenile() {
    _kumandalar = KumandaDeposu.tumunu();
    _odalar = OdaDeposu.tumunu();
    notifyListeners();
  }

  Future<void> sil(int id) async {
    await KumandaDeposu.sil(id);
    yenile();
  }

  Future<void> favoriDegistir(int id, bool yeni) async {
    await KumandaDeposu.favoriDegistir(id, yeni);
    yenile();
  }

  int cihazSayisiOda(String odaId) =>
      _kumandalar.where((k) => k.odaId == odaId).length;
}

class Anasayfa extends StatefulWidget {
  const Anasayfa({super.key});

  @override
  State<Anasayfa> createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> with WidgetsBindingObserver {
  late final AnasayfaProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = AnasayfaProvider()..yenile();
    WidgetsBinding.instance.addObserver(this);
    KumandaDeposu.degisim.addListener(_yenile);
    OdaDeposu.degisim.addListener(_yenile);
  }

  @override
  void dispose() {
    KumandaDeposu.degisim.removeListener(_yenile);
    OdaDeposu.degisim.removeListener(_yenile);
    WidgetsBinding.instance.removeObserver(this);
    _provider.dispose();
    super.dispose();
  }

  void _yenile() => _provider.yenile();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _provider.yenile();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: const AnasayfaView(),
    );
  }
}
