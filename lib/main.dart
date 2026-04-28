import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Route/routing.dart';
import 'screens/Ayarlar/ayarlar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('tr'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('tr'),
      assetLoader: const YamlAssetLoader(),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AyarlarProvider()),
        ],
        child: const ShiftMoteApp(),
      ),
    ),
  );
}

class ShiftMoteApp extends StatelessWidget {
  const ShiftMoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AyarlarProvider>(
      builder: (context, ayar, _) => MaterialApp.router(
        title: 'ShiftMote',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        routerConfig: router,
        theme: ayar.acikTema,
        darkTheme: ayar.koyuTema,
        themeMode: ayar.karanlikMod ? ThemeMode.dark : ThemeMode.light,
      ),
    );
  }
}
