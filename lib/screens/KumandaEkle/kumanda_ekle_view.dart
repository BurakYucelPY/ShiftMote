import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../db/oda_deposu.dart';
import '../../ir/cihaz_kategorileri.dart';
import '../../theme/app_theme.dart';
import '../../theme/modern_presets.dart';
import '../../theme/theme_provider.dart';
import '../../widgets/ir_gosterge.dart';
import 'kumanda_ekle.dart';

class KumandaEkleView extends StatelessWidget {
  const KumandaEkleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<KumandaEkleProvider>(
      builder: (context, p, _) {
        return PopScope(
          canPop: p.adim == EkleAdim.kategori,
          onPopInvokedWithResult: (didPop, _) async {
            if (!didPop) await p.geri();
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text(_baslik(p.adim)),
              actions: p.adim == EkleAdim.dene
                  ? const [
                      Padding(
                        padding: EdgeInsets.only(right: 14),
                        child: Center(child: IrGosterge()),
                      ),
                    ]
                  : null,
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _icerik(context, p),
              ),
            ),
          ),
        );
      },
    );
  }

  String _baslik(EkleAdim a) {
    switch (a) {
      case EkleAdim.kategori: return 'kumanda_ekle.kategori_baslik'.tr();
      case EkleAdim.marka: return 'kumanda_ekle.marka_baslik'.tr();
      case EkleAdim.dene: return 'kumanda_ekle.dene_baslik'.tr();
      case EkleAdim.ad: return 'kumanda_ekle.ad_baslik'.tr();
    }
  }

  Widget _icerik(BuildContext context, KumandaEkleProvider p) {
    final hata = p.hata;
    if (hata != null) {
      return Center(child: Text(hata));
    }
    if (p.yukleniyor && p.adim != EkleAdim.dene) {
      return const Center(child: CircularProgressIndicator());
    }
    switch (p.adim) {
      case EkleAdim.kategori: return _Kategoriler(p: p);
      case EkleAdim.marka: return _Markalar(p: p);
      case EkleAdim.dene: return _Dene(p: p);
      case EkleAdim.ad: return _AdVer(p: p);
    }
  }
}

class _Kategoriler extends StatelessWidget {
  final KumandaEkleProvider p;
  const _Kategoriler({required this.p});

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    final isClassic = tp.isClassic;
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: CihazKategorileri.tumu.length,
      itemBuilder: (c, i) {
        final k = CihazKategorileri.tumu[i];
        return GestureDetector(
          onTap: () => p.kategoriSec(k),
          child: isClassic
              ? Neumorphic(
                  style: NeuPresets.button(depth: 5, radius: AppRadius.md),
                  child: _ic(context, k),
                )
              : Container(
                  decoration: ModernPresets.unselectedChip(radius: AppRadius.md),
                  child: _ic(context, k),
                ),
        );
      },
    );
  }

  Widget _ic(BuildContext c, CihazKategorisi k) => Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(k.ikon, color: AppColors.accent, size: 32),
            const SizedBox(height: 8),
            Text(k.etiketKey.tr(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(c).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

class _Markalar extends StatelessWidget {
  final KumandaEkleProvider p;
  const _Markalar({required this.p});

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    final isClassic = tp.isClassic;
    return Column(children: [
      isClassic
          ? Neumorphic(
              style: NeuPresets.pressed(radius: AppRadius.md),
              child: _arama(context),
            )
          : Container(
              decoration: ModernPresets.inset(radius: AppRadius.md),
              child: _arama(context),
            ),
      const SizedBox(height: 12),
      if (p.populerMevcut.isNotEmpty) ...[
        Align(
          alignment: Alignment.centerLeft,
          child: Text('kumanda_ekle.populer'.tr(),
              style: Theme.of(context).textTheme.bodySmall),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: p.populerMevcut
              .map((m) => GestureDetector(
                    onTap: () => p.markaSec(m),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: ModernPresets.selectedChip(
                          radius: AppRadius.sm),
                      child: Text(m,
                          style: const TextStyle(
                              color: AppColors.accent, fontSize: 12)),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 12),
      ],
      Expanded(
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: p.filtreliMarkalar.length,
          itemBuilder: (c, i) {
            final m = p.filtreliMarkalar[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => p.markaSec(m),
                child: isClassic
                    ? Neumorphic(
                        style: NeuPresets.button(
                            depth: 3, radius: AppRadius.md),
                        child: _markaIc(context, m),
                      )
                    : Container(
                        decoration: ModernPresets.card(),
                        child: _markaIc(context, m),
                      ),
              ),
            );
          },
        ),
      ),
    ]);
  }

  Widget _arama(BuildContext c) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'kumanda_ekle.marka_ara'.tr(),
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            prefixIcon: const Icon(Icons.search,
                color: AppColors.textSecondary, size: 20),
          ),
          onChanged: p.aramaGuncelle,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
      );

  Widget _markaIc(BuildContext c, String marka) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(children: [
          Expanded(
              child: Text(marka,
                  style: Theme.of(c)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w500))),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textSecondary),
        ]),
      );
}

class _Dene extends StatelessWidget {
  final KumandaEkleProvider p;
  const _Dene({required this.p});

  @override
  Widget build(BuildContext context) {
    if (p.bittim) {
      return _Bitti(p: p);
    }
    if (p.yukleniyor) {
      return const Center(child: CircularProgressIndicator());
    }
    if (p.modelToplam == 0) {
      return Center(
        child: Text('kumanda_ekle.model_yok'.tr(),
            style: Theme.of(context).textTheme.bodyMedium),
      );
    }
    final ilerleme = '${p.modelIndex + 1} / ${p.modelToplam}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Text('${p.marka}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(ilerleme,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 24),
        Text('kumanda_ekle.dene_aciklama'.tr(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _OkButonu(
              ikon: Icons.chevron_left_rounded,
              aktif: p.oncekiVarMi,
              onTap: p.oncekiModel,
            ),
            const SizedBox(width: 24),
            _GucButonu(p: p),
            const SizedBox(width: 24),
            _OkButonu(
              ikon: Icons.chevron_right_rounded,
              aktif: p.sonrakiVarMi,
              onTap: p.sonrakiModel,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('kumanda_ekle.guc'.tr(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium),
        const Spacer(),
        Text('kumanda_ekle.cihaz_tepki'.tr(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _CevapButonu(
                etiket: 'kumanda_ekle.hayir'.tr(),
                ikon: Icons.close_rounded,
                renk: AppColors.error,
                onTap: p.cevapHayir,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CevapButonu(
                etiket: 'kumanda_ekle.evet'.tr(),
                ikon: Icons.check_rounded,
                renk: AppColors.success,
                onTap: p.cevapEvet,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _GucButonu extends StatefulWidget {
  final KumandaEkleProvider p;
  const _GucButonu({required this.p});

  @override
  State<_GucButonu> createState() => _GucButonuState();
}

class _GucButonuState extends State<_GucButonu> {
  bool _basili = false;

  @override
  Widget build(BuildContext context) {
    final aktif = widget.p.powerHazir;
    return GestureDetector(
      onTapDown: aktif ? (_) => setState(() => _basili = true) : null,
      onTapCancel: aktif ? () => setState(() => _basili = false) : null,
      onTapUp: aktif
          ? (_) {
              setState(() => _basili = false);
              widget.p.gucGonder();
            }
          : null,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 80),
        scale: _basili ? 0.94 : 1.0,
        child: Neumorphic(
          style: NeuPresets.circle(
            depth: _basili ? -3 : 6,
            intensity: 0.6,
          ),
          child: SizedBox(
            width: 140,
            height: 140,
            child: Center(
              child: Icon(
                Icons.power_settings_new_rounded,
                size: 64,
                color: aktif ? AppColors.accent : AppColors.textTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OkButonu extends StatefulWidget {
  final IconData ikon;
  final bool aktif;
  final VoidCallback onTap;
  const _OkButonu({
    required this.ikon,
    required this.aktif,
    required this.onTap,
  });

  @override
  State<_OkButonu> createState() => _OkButonuState();
}

class _OkButonuState extends State<_OkButonu> {
  bool _basili = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.aktif ? (_) => setState(() => _basili = true) : null,
      onTapCancel: widget.aktif ? () => setState(() => _basili = false) : null,
      onTapUp: widget.aktif
          ? (_) {
              setState(() => _basili = false);
              widget.onTap();
            }
          : null,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 80),
        scale: _basili ? 0.92 : 1.0,
        child: Neumorphic(
          style: NeuPresets.circle(
            depth: _basili ? -2 : 4,
            intensity: 0.55,
          ),
          child: SizedBox(
            width: 56,
            height: 56,
            child: Center(
              child: Icon(
                widget.ikon,
                size: 28,
                color: widget.aktif
                    ? AppColors.textPrimary
                    : AppColors.textTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CevapButonu extends StatelessWidget {
  final String etiket;
  final IconData ikon;
  final Color renk;
  final VoidCallback onTap;
  const _CevapButonu({
    required this.etiket,
    required this.ikon,
    required this.renk,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Neumorphic(
        style: NeuPresets.button(depth: 4, radius: AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(ikon, color: renk, size: 22),
              const SizedBox(width: 8),
              Text(etiket,
                  style: TextStyle(
                      color: renk,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bitti extends StatelessWidget {
  final KumandaEkleProvider p;
  const _Bitti({required this.p});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded,
              size: 56, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text('kumanda_ekle.tum_modeller'.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('kumanda_ekle.geri_marka'.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => p.geri(),
            child: Neumorphic(
              style: NeuPresets.button(depth: 4),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                child: Text('geri'.tr(),
                    style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdVer extends StatefulWidget {
  final KumandaEkleProvider p;
  const _AdVer({required this.p});

  @override
  State<_AdVer> createState() => _AdVerState();
}

class _AdVerState extends State<_AdVer> {
  late TextEditingController _controller;
  List<Oda> _odalar = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.p.ad);
    _odalar = OdaDeposu.tumunu();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    final isClassic = tp.isClassic;
    final p = widget.p;
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Text('kumanda_ekle.ad_etiket'.tr(),
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        isClassic
            ? Neumorphic(
                style: NeuPresets.pressed(radius: AppRadius.md),
                child: _adInput())
            : Container(
                decoration: ModernPresets.inset(radius: AppRadius.md),
                child: _adInput()),
        const SizedBox(height: 24),
        if (_odalar.isNotEmpty) ...[
          Text('kumanda_ekle.oda_secin'.tr(),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _odaCip(null, 'kumanda_ekle.oda_yok'.tr(), p, isClassic),
              ..._odalar.map((o) => _odaCip(o.id, o.ad, p, isClassic)),
            ],
          ),
          const SizedBox(height: 24),
        ],
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: () async {
              final k = await p.kaydet();
              if (k != null && context.mounted) {
                context.go(
                    '/anasayfa/kumanda/${k.id}');
              }
            },
            child: isClassic
                ? Neumorphic(
                    style: NeuPresets.button(depth: 5),
                    child: _kaydetIc())
                : Container(
                    decoration: ModernPresets.button(), child: _kaydetIc()),
          ),
        ),
      ],
    );
  }

  Widget _adInput() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'kumanda_ekle.ad_hint'.tr(),
              hintStyle: const TextStyle(color: AppColors.textSecondary)),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
          onChanged: widget.p.adGuncelle,
        ),
      );

  Widget _odaCip(String? id, String etiket, KumandaEkleProvider p, bool isClassic) {
    final secili = p.odaId == id;
    return GestureDetector(
      onTap: () => p.odaSec(id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: secili
            ? ModernPresets.selectedChip(radius: AppRadius.md)
            : ModernPresets.unselectedChip(radius: AppRadius.md),
        child: Text(etiket,
            style: TextStyle(
                color: secili ? AppColors.accent : AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _kaydetIc() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Center(
          child: Text('genel.kaydet'.tr(),
              style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
        ),
      );
}
