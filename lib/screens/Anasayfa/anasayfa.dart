import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../db/kumanda_deposu.dart';
import 'anasayfa_view.dart';

class AnasayfaProvider extends ChangeNotifier {
  List<Kumanda> _kumandalar = [];
  List<Kumanda> get kumandalar => _kumandalar;

  void yenile() {
    _kumandalar = KumandaDeposu.tumunu();
    notifyListeners();
  }

  Future<void> sil(int id) async {
    await KumandaDeposu.sil(id);
    yenile();
  }
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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _provider.dispose();
    super.dispose();
  }

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
