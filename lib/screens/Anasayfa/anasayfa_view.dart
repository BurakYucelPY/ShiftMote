import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../Route/identify_routes.dart';
import '../../app_drawer.dart';
import '../../db/kumanda_deposu.dart';
import 'anasayfa.dart';

class AnasayfaView extends StatelessWidget {
  const AnasayfaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => AppDrawer.open(),
        ),
        title: Text('anasayfa'.tr()),
      ),
      body: Consumer<AnasayfaProvider>(
        builder: (context, p, _) {
          if (p.kumandalar.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.tv_off,
                      size: 80,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Henuz kumanda eklenmedi.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: Text('kumanda_ekle'.tr()),
                      onPressed: () =>
                          context.goNamed(Rotalar.kumandaEkleName),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: p.kumandalar.length,
            itemBuilder: (context, i) {
              final k = p.kumandalar[i];
              return Card(
                child: ListTile(
                  leading: Icon(
                    _ikonCihaz(k.cihazTipi),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(k.ad),
                  subtitle: Text('${k.marka} • ${k.cihazTipi} • ${k.model}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _silOnay(context, p, k),
                  ),
                  onTap: () => context.goNamed(
                    Rotalar.kumandaName,
                    pathParameters: {'id': k.id.toString()},
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _ikonCihaz(String tip) {
    final t = tip.toLowerCase();
    if (t.contains('tv')) return Icons.tv;
    if (t.contains('ac') || t.contains('air')) return Icons.ac_unit;
    if (t.contains('audio') || t.contains('speaker')) return Icons.speaker;
    if (t.contains('dvd') || t.contains('blu')) return Icons.album;
    return Icons.settings_remote;
  }

  void _silOnay(BuildContext context, AnasayfaProvider p, Kumanda k) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(k.ad),
        content: Text('${'sil'.tr()}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('iptal'.tr()),
          ),
          TextButton(
            onPressed: () {
              p.sil(k.id);
              Navigator.pop(ctx);
            },
            child: Text('sil'.tr()),
          ),
        ],
      ),
    );
  }
}
