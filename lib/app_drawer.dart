import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'Route/identify_routes.dart';

abstract class AppDrawer {
  static GlobalKey<ScaffoldState>? _key;
  static GlobalKey<ScaffoldState> get key =>
      _key ??= GlobalKey<ScaffoldState>();

  static void open() => key.currentState?.openDrawer();
  static void close() => key.currentState?.closeDrawer();

  static Widget build(BuildContext context) => Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'app_adi'.tr(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home,
                  color: Theme.of(context).colorScheme.primary),
              title: Text('anasayfa'.tr()),
              onTap: () {
                Navigator.pop(context);
                context.goNamed(Rotalar.anasayfaName);
              },
            ),
            ListTile(
              leading: Icon(Icons.add_circle_outline,
                  color: Theme.of(context).colorScheme.primary),
              title: Text('kumanda_ekle'.tr()),
              onTap: () {
                Navigator.pop(context);
                context.goNamed(Rotalar.kumandaEkleName);
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.settings,
                  color: Theme.of(context).colorScheme.primary),
              title: Text('ayarlar'.tr()),
              onTap: () {
                Navigator.pop(context);
                context.goNamed(Rotalar.ayarlarName);
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary),
              title: Text('hakkinda'.tr()),
              onTap: () {
                Navigator.pop(context);
                context.goNamed(Rotalar.hakkindaName);
              },
            ),
          ],
        ),
      );
}
