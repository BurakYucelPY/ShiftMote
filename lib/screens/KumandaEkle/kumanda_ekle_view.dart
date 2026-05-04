import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../Route/identify_routes.dart';
import '../../app_drawer.dart';
import '../../ir/cihaz_kategorileri.dart';
import '../../ir/irdb_parser.dart';
import 'kumanda_ekle.dart';

class KumandaEkleView extends StatelessWidget {
  const KumandaEkleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<KumandaEkleProvider>(
      builder: (context, p, _) {
        return PopScope(
          canPop: p.adim == EkleAdim.kategori,
          onPopInvoked: (didPop) async {
            if (!didPop) await p.geri();
          },
          child: Scaffold(
            appBar: AppBar(
              leading: p.adim == EkleAdim.kategori
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
            body: _govde(context, p),
          ),
        );
      },
    );
  }

  String _baslik(EkleAdim a) {
    switch (a) {
      case EkleAdim.kategori:
        return 'ekle_page.kategori_sec'.tr();
      case EkleAdim.marka:
        return 'ekle_page.marka_sec'.tr();
      case EkleAdim.model:
        return 'ekle_page.model_sec'.tr();
      case EkleAdim.ad:
        return 'ekle_page.isim_ver'.tr();
    }
  }

  Widget _govde(BuildContext context, KumandaEkleProvider p) {
    if (p.yukleniyor) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text('genel.yukleniyor'.tr()),
          ],
        ),
      );
    }
    if (p.hata != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text('${'genel.hata'.tr()}: ${p.hata}'),
        ),
      );
    }
    switch (p.adim) {
      case EkleAdim.kategori:
        return _KategoriGrid(provider: p);
      case EkleAdim.marka:
        return _MarkaListesi(provider: p);
      case EkleAdim.model:
        return _ModelListesi(provider: p);
      case EkleAdim.ad:
        return _AdAdimi(provider: p);
    }
  }
}

class _KategoriGrid extends StatelessWidget {
  final KumandaEkleProvider provider;
  const _KategoriGrid({required this.provider});

  @override
  Widget build(BuildContext context) {
    const tum = CihazKategorileri.tumu;
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.4,
      ),
      itemCount: tum.length,
      itemBuilder: (context, i) {
        final k = tum[i];
        return Material(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => provider.kategoriSec(k),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    k.ikon,
                    size: 36,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    k.etiketKey.tr(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MarkaListesi extends StatelessWidget {
  final KumandaEkleProvider provider;
  const _MarkaListesi({required this.provider});

  @override
  Widget build(BuildContext context) {
    final filtreli = provider.filtreliMarkalar;
    final populer = provider.populerMevcut;
    final aramaAktif = provider.arama.isNotEmpty;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'genel.ara'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            ),
            onChanged: provider.aramaGuncelle,
          ),
        ),
        Expanded(
          child: filtreli.isEmpty
              ? Center(child: Text('genel.sonuc_yok'.tr()))
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    if (!aramaAktif && populer.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'ekle_page.populer_markalar'.tr(),
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: populer
                            .map((m) => ActionChip(
                                  label: Text(m),
                                  onPressed: () => provider.markaSec(m),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          'ekle_page.tumu'.tr(),
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),
                    ],
                    ...filtreli.map(
                      (m) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(m),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => provider.markaSec(m),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _ModelListesi extends StatelessWidget {
  final KumandaEkleProvider provider;
  const _ModelListesi({required this.provider});

  @override
  Widget build(BuildContext context) {
    final liste = provider.modeller;
    if (liste.isEmpty) {
      return Center(child: Text('genel.sonuc_yok'.tr()));
    }
    // Birden fazla irdb klasoru varsa basliklarla grupla
    final klasorler = <String, List<KategoriModel>>{};
    for (final m in liste) {
      klasorler.putIfAbsent(m.irdbKlasoru, () => []).add(m);
    }
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        for (final entry in klasorler.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
            child: Text(
              entry.key,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          ...entry.value.map(
            (m) => ListTile(
              title: Text(m.dosya),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => provider.modelSec(m),
            ),
          ),
        ],
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
                  Text(
                      '${'ekle_page.kategori'.tr()}: ${p.kategori?.etiketKey.tr() ?? '-'}'),
                  Text('${'ekle_page.marka'.tr()}: ${p.marka ?? '-'}'),
                  Text('${'ekle_page.model'.tr()}: ${p.model?.dosya ?? '-'}'),
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
