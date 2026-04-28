import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ayarlar.dart';

class AyarlarView extends StatelessWidget {
  const AyarlarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ayarlar'.tr())),
      body: Consumer<AyarlarProvider>(
        builder: (context, ayar, _) => ListView(
          children: [
            SwitchListTile(
              title: Text('ayarlar'.tr()),
              value: ayar.karanlikMod,
              onChanged: (_) => ayar.temaDegistir(),
            ),
          ],
        ),
      ),
    );
  }
}
