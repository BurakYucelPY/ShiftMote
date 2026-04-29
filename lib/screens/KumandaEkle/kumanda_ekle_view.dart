import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../Route/identify_routes.dart';
import '../../app_drawer.dart';
import 'kumanda_ekle.dart';

class KumandaEkleView extends StatelessWidget {
  const KumandaEkleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<KumandaEkleProvider>(
      builder: (context, p, _) {
        return PopScope(
          canPop: p.adim == EkleAdim.cihazTipi,
          onPopInvoked: (didPop) async {
            if (!didPop) await p.geri();
          },
          child: Scaffold(
            appBar: AppBar(
              leading: p.adim == EkleAdim.cihazTipi
                  ? IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => AppDrawer.open(),
                    )
                  : IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => p.geri(),
                    ),
              title: Text(_baslik(p.adim)),
            ),
            body: p.yukleniyor
                ? const Center(child: CircularProgressIndicator())
                : p.hata != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text('hata: ${p.hata}'),
                        ),
                      )
                    : p.adim == EkleAdim.ad
                        ? _AdAdimi(provider: p)
                        : _SecimListesi(provider: p),
          ),
        );
      },
    );
  }

  String _baslik(EkleAdim a) {
    switch (a) {
      case EkleAdim.cihazTipi:
        return 'ekle_page.cihaz_tipi_sec'.tr();
      case EkleAdim.marka:
        return 'ekle_page.marka_sec'.tr();
      case EkleAdim.model:
        return 'ekle_page.model_sec'.tr();
      case EkleAdim.ad:
        return 'ekle_page.isim_ver'.tr();
    }
  }
}

class _SecimListesi extends StatelessWidget {
  final KumandaEkleProvider provider;
  const _SecimListesi({required this.provider});

  @override
  Widget build(BuildContext context) {
    final liste = provider.filtreliSecenekler;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'genel.ara'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: provider.aramaGuncelle,
          ),
        ),
        if (liste.isEmpty)
          Expanded(child: Center(child: Text('genel.sonuc_yok'.tr())))
        else
          Expanded(
            child: ListView.builder(
              itemCount: liste.length,
              itemBuilder: (context, i) {
                final s = liste[i];
                return ListTile(
                  title: Text(s),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => provider.sec(s),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _AdAdimi extends StatefulWidget {
  final KumandaEkleProvider provider;
  const _AdAdimi({required this.provider});

  @override
  State<_AdAdimi> createState() => _AdAdimiState();
}

class _AdAdimiState extends State<_AdAdimi> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.provider.ad);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.provider;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${'ekle_page.marka'.tr()}: ${p.marka ?? '-'}'),
                  Text('${'ekle_page.cihaz_tipi'.tr()}: ${p.cihazTipi ?? '-'}'),
                  Text('${'ekle_page.model'.tr()}: ${p.model ?? '-'}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _ctrl,
            decoration: InputDecoration(
              labelText: 'ekle_page.kumanda_adi'.tr(),
              border: const OutlineInputBorder(),
            ),
            onChanged: p.adGuncelle,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: Text('kaydet'.tr()),
            onPressed: () async {
              final yeni = await p.kaydet();
              if (!context.mounted) return;
              if (yeni == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('ekle_page.eksik_bilgi'.tr())),
                );
                return;
              }
              context.goNamed(Rotalar.anasayfaName);
            },
          ),
        ],
      ),
    );
  }
}
