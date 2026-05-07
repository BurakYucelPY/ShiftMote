import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:provider/provider.dart';

import 'Route/routing.dart';
import 'db/kumanda_deposu.dart';
import 'db/oda_deposu.dart';
import 'ir/irdb_bootstrap.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await KumandaDeposu.baslat();
  await OdaDeposu.baslat();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // IRDB arsivini ilk acilista bir kerede cikar; ilk cihaz ekleme akisi
  // anlik liste gosterebilsin diye bekliyoruz.
  await IrdbBootstrap.hazirla();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('tr'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('tr'),
      assetLoader: const YamlAssetLoader(),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
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
    return MaterialApp.router(
      title: 'ShiftMote',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      theme: AppTheme.darkTheme,
      routerConfig: router,
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        return NeumorphicTheme(
          themeMode: ThemeMode.dark,
          darkTheme: AppTheme.neumorphicDark,
          theme: AppTheme.neumorphicDark,
          child: child,
        );
      },
    );
  }
}
