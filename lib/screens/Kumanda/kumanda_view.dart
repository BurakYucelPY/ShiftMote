import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../ir/irdb_parser.dart';
import 'kumanda.dart';

class KumandaView extends StatelessWidget {
  const KumandaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<KumandaProvider>(
      builder: (context, p, _) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            title: Text(p.kumanda?.ad ?? 'Kumanda'),
          ),
          body: _govde(context, p),
        );
      },
    );
  }

  Widget _govde(BuildContext context, KumandaProvider p) {
    if (p.yukleniyor) {
      return const Center(child: CircularProgressIndicator());
    }
    if (p.hata != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(p.hata!),
        ),
      );
    }
    final komutlar = p.model?.komutlar ?? const [];
    if (komutlar.isEmpty) {
      return Center(child: Text('kumanda_page.komut_yok'.tr()));
    }
    return Column(
      children: [
        if (!p.irVar)
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.errorContainer,
            padding: const EdgeInsets.all(8),
            child: Text(
              'genel.ir_yok_uyari'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.0,
            ),
            itemCount: komutlar.length,
            itemBuilder: (context, i) {
              final k = komutlar[i];
              return _KomutButonu(komut: k, onTap: () => p.yay(k));
            },
          ),
        ),
        if (p.sonAksiyon.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Text(
              p.sonAksiyon,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
      ],
    );
  }
}

class _KomutButonu extends StatelessWidget {
  final IrKomut komut;
  final VoidCallback onTap;
  const _KomutButonu({required this.komut, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ikon = _ikonBul(komut.ad);
    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (ikon != null)
                Icon(
                  ikon,
                  size: 28,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              if (ikon != null) const SizedBox(height: 4),
              Text(
                komut.ad,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData? _ikonBul(String ad) {
    final a = ad.toUpperCase();
    if (a == 'POWER' || a.contains('POWER')) return Icons.power_settings_new;
    if (a.contains('VOLUME') && (a.contains('UP') || a.contains('+'))) {
      return Icons.volume_up;
    }
    if (a.contains('VOLUME') && (a.contains('DOWN') || a.contains('-'))) {
      return Icons.volume_down;
    }
    if (a == 'MUTE' || a.contains('MUTE')) return Icons.volume_off;
    if (a.contains('CHANNEL') && (a.contains('UP') || a.contains('+'))) {
      return Icons.arrow_upward;
    }
    if (a.contains('CHANNEL') && (a.contains('DOWN') || a.contains('-'))) {
      return Icons.arrow_downward;
    }
    if (a.contains('PLAY')) return Icons.play_arrow;
    if (a.contains('PAUSE')) return Icons.pause;
    if (a.contains('STOP')) return Icons.stop;
    if (a.contains('NEXT') || a.contains('FORWARD')) return Icons.skip_next;
    if (a.contains('PREV') || a.contains('REWIND')) return Icons.skip_previous;
    if (a.contains('MENU')) return Icons.menu;
    if (a.contains('OK') || a == 'ENTER' || a == 'SELECT') return Icons.check;
    if (a.contains('UP')) return Icons.keyboard_arrow_up;
    if (a.contains('DOWN')) return Icons.keyboard_arrow_down;
    if (a.contains('LEFT')) return Icons.keyboard_arrow_left;
    if (a.contains('RIGHT')) return Icons.keyboard_arrow_right;
    if (a.contains('HOME')) return Icons.home;
    if (a.contains('BACK') || a.contains('EXIT')) return Icons.arrow_back;
    if (a.contains('INPUT') || a.contains('SOURCE')) return Icons.input;
    return null;
  }
}
