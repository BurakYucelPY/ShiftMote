import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../db/kumanda_deposu.dart';
import '../theme/app_theme.dart';

/// Cihazi yeniden adlandirma dialog'u acar.
Future<void> cihazYenidenAdlandir(BuildContext context, Kumanda k) async {
  final yeniAd = await showDialog<String>(
    context: context,
    builder: (c) => _YenidenAdlandirDialog(eskiAd: k.ad),
  );
  if (yeniAd != null && yeniAd.isNotEmpty && yeniAd != k.ad) {
    HapticFeedback.lightImpact();
    await KumandaDeposu.yenidenAdlandir(k.id, yeniAd);
  }
}

class _YenidenAdlandirDialog extends StatefulWidget {
  final String eskiAd;
  const _YenidenAdlandirDialog({required this.eskiAd});

  @override
  State<_YenidenAdlandirDialog> createState() =>
      _YenidenAdlandirDialogState();
}

class _YenidenAdlandirDialogState extends State<_YenidenAdlandirDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.eskiAd);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text('genel.yeniden_adlandir'.tr()),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'kumanda_ekle.ad_etiket'.tr(),
          hintStyle: const TextStyle(color: AppColors.textSecondary),
        ),
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('genel.iptal'.tr())),
        TextButton(
            onPressed: () =>
                Navigator.pop(context, _controller.text.trim()),
            child: Text('genel.kaydet'.tr(),
                style: const TextStyle(color: AppColors.accent))),
      ],
    );
  }
}

/// Cihazi onayla ve sil.
Future<void> cihazSil(BuildContext context, Kumanda k) async {
  final onay = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text('genel.sil'.tr()),
      content: Text('cihaz.silme_onay'.tr(args: [k.ad]),
          style: const TextStyle(color: AppColors.textPrimary)),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text('genel.iptal'.tr())),
        TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text('genel.sil'.tr(),
                style: const TextStyle(color: AppColors.error))),
      ],
    ),
  );
  if (onay == true) {
    HapticFeedback.mediumImpact();
    await KumandaDeposu.sil(k.id);
  }
}
