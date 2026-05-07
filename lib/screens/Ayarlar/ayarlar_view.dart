import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';

import '../../Route/identify_routes.dart';
import '../../theme/app_theme.dart';

class AyarlarView extends StatelessWidget {
  const AyarlarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('ayarlar.baslik'.tr())),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            _satir(
              context,
              ikon: Icons.language_rounded,
              etiket: 'ayarlar.dil'.tr(),
              onTap: () => context
                  .push('${Rotalar.ayarlarPath}/${Rotalar.dilPath}'),
            ),
            const SizedBox(height: 12),
            _satir(
              context,
              ikon: Icons.info_outline_rounded,
              etiket: 'ayarlar.hakkinda'.tr(),
              onTap: () => context.push(Rotalar.hakkindaPath),
            ),
          ],
        ),
      ),
    );
  }

  Widget _satir(BuildContext context,
      {required IconData ikon,
      required String etiket,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Neumorphic(
        style: NeuPresets.button(depth: 3, radius: AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(children: [
            Icon(ikon, color: AppColors.accent, size: 20),
            const SizedBox(width: 14),
            Expanded(
                child: Text(etiket,
                    style: Theme.of(context).textTheme.titleMedium)),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary),
          ]),
        ),
      ),
    );
  }
}
