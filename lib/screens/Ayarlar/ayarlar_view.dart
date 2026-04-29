import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../Route/identify_routes.dart';
import '../../app_drawer.dart';
import 'ayarlar.dart';

class AyarlarView extends StatelessWidget {
  const AyarlarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => AppDrawer.open(),
        ),
        title: Text('ayarlar'.tr()),
      ),
      body: Consumer<AyarlarProvider>(
        builder: (context, ayar, _) => ListView(
          children: [
            ListTile(
              leading: Icon(
                ayar.karanlikMod ? Icons.dark_mode : Icons.light_mode,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text('ayarlar_page.tema'.tr()),
              subtitle: Text(
                ayar.karanlikMod
                    ? 'ayarlar_page.karanlik_mod'.tr()
                    : 'ayarlar_page.acik_mod'.tr(),
              ),
              trailing: Switch(
                value: ayar.karanlikMod,
                onChanged: (_) => ayar.temaDegistir(),
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.language,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text('ayarlar_page.dil_secim'.tr()),
              subtitle: Text(_dilEtiketi(context.locale.languageCode)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.goNamed(Rotalar.dilName),
            ),
          ],
        ),
      ),
    );
  }

  String _dilEtiketi(String code) {
    switch (code) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      default:
        return code;
    }
  }
}
