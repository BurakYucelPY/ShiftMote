import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/app_theme.dart';

class DilView extends StatelessWidget {
  const DilView({super.key});

  @override
  Widget build(BuildContext context) {
    final mevcut = context.locale.languageCode;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('dil'.tr())),
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
        color: secili ? AppColors.accent : AppColors.textSecondary,
      ),
      title: Text(etiket, style: const TextStyle(color: AppColors.textPrimary)),
      onTap: () async {
        await context.setLocale(Locale(kod));
        if (context.mounted) context.pop();
      },
    );
  }
}
