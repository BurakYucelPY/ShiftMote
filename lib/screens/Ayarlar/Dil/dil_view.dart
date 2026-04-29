import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DilView extends StatelessWidget {
  const DilView({super.key});

  @override
  Widget build(BuildContext context) {
    final mevcut = context.locale.languageCode;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('dil'.tr()),
      ),
      body: ListView(
        children: [
          _dilSec(context, 'tr', 'dil_page.turkce'.tr(), mevcut == 'tr'),
          _dilSec(context, 'en', 'dil_page.ingilizce'.tr(), mevcut == 'en'),
        ],
      ),
    );
  }

  Widget _dilSec(BuildContext context, String kod, String etiket, bool secili) {
    return ListTile(
      leading: Icon(
        secili ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: secili ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(etiket),
      onTap: () async {
        await context.setLocale(Locale(kod));
        if (context.mounted) context.pop();
      },
    );
  }
}
