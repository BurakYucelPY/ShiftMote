import 'package:flutter/material.dart';

/// Tek tema (Klasik / Neumorphic). Kullanici icin secim yok.
/// `isClassic` her zaman true; widget'lar bu sayede klasik kod yolunu calistirir.
class ThemeProvider extends ChangeNotifier {
  bool get isClassic => true;
}
