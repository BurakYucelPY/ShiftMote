import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'anasayfa_view.dart';

class AnasayfaProvider extends ChangeNotifier {
  // Aşama 7'de ObjectBox bağlanacak
}

class Anasayfa extends StatefulWidget {
  const Anasayfa({super.key});

  @override
  State<Anasayfa> createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> {
  late final AnasayfaProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = AnasayfaProvider();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: const AnasayfaView(),
    );
  }
}
