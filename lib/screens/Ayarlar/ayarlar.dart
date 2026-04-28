import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import 'ayarlar_view.dart';

class AyarlarProvider extends ChangeNotifier {
  bool _karanlikMod = false;
  bool get karanlikMod => _karanlikMod;

  void temaDegistir() {
    _karanlikMod = !_karanlikMod;
    notifyListeners();
  }

  ThemeData get acikTema => FlexColorScheme.light(
        scheme: FlexScheme.deepBlue,
        useMaterial3: true,
        subThemesData: const FlexSubThemesData(),
      ).toTheme;

  ThemeData get koyuTema => FlexColorScheme.dark(
        scheme: FlexScheme.deepBlue,
        useMaterial3: true,
        subThemesData: const FlexSubThemesData(),
      ).toTheme;
}

class Ayarlar extends StatefulWidget {
  const Ayarlar({super.key});

  @override
  State<Ayarlar> createState() => _AyarlarState();
}

class _AyarlarState extends State<Ayarlar> {
  @override
  Widget build(BuildContext context) {
    return const AyarlarView();
  }
}
