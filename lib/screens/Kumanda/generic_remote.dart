import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

import '../../ir/irdb_parser.dart';
import '../../ir/komut_siniflandirici.dart';
import '../../theme/app_theme.dart';
import '../../theme/modern_presets.dart';
import '../../theme/theme_provider.dart';
import '../../widgets/ir_gosterge.dart';
import '../../widgets/neu_button.dart';
import 'kumanda.dart';

/// TV/Klima/Projektor disindaki kategoriler icin (Ses, DVD, Uydu, Vantilator,
/// vb.) — CSV'deki komutlari semantik olarak gruplandirip uygun kumanda
/// duzeniyle gosterir. Sadece o cihazda **var olan** bolumler cizilir.
class GenericRemote extends StatelessWidget {
  final KumandaProvider provider;
  final ThemeProvider themeProvider;
  const GenericRemote(
      {super.key, required this.provider, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    final k = provider.kumanda!;
    final komutlar = provider.model?.komutlar ?? const <IrKomut>[];
    final s = SiniflandirilmisKomutlar.olustur(komutlar);
    final isClassic = themeProvider.isClassic;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(k.ad),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Center(child: IrGosterge()),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
                child: Text(k.marka,
                    style: Theme.of(context).textTheme.bodyMedium)),
          ),
        ],
      ),
      body: komutlar.isEmpty
          ? _bos(context)
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                child: Column(children: [
                  if (s.power != null || s.kaynakVar) _ustSira(context, s),
                  if (s.sesVar || s.kanalVar) ...[
                    const SizedBox(height: 24),
                    _sesKanalSatiri(context, s),
                  ],
                  if (s.dpadVar) ...[
                    const SizedBox(height: 24),
                    _dpad(context, s),
                  ],
                  if (s.menuVar) ...[
                    const SizedBox(height: 24),
                    _menuSatiri(context, s, isClassic),
                  ],
                  if (s.oynatmaVar) ...[
                    const SizedBox(height: 24),
                    _oynatmaSatiri(context, s, isClassic),
                  ],
                  if (s.renkVar) ...[
                    const SizedBox(height: 20),
                    _renkSatiri(context, s, isClassic),
                  ],
                  if (s.kaynaklar.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _kaynakBolumu(context, s, isClassic),
                  ],
                  if (s.sayiVar) ...[
                    const SizedBox(height: 24),
                    _numpad(context, s, isClassic),
                  ],
                  if (s.fanEkstraVar) ...[
                    const SizedBox(height: 24),
                    _fanEkstraBolumu(context, s),
                  ],
                  if (s.kalan.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _kalanBolumu(context, s.kalan, isClassic),
                  ],
                  const SizedBox(height: 16),
                ]),
              ),
            ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // BOLUMLER
  // ────────────────────────────────────────────────────────────

  Widget _ustSira(BuildContext context, SiniflandirilmisKomutlar s) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (s.power != null)
          NeuButton(
              icon: Icons.power_settings_new_rounded,
              onPressed: () => provider.yay(s.power!),
              isPower: true,
              size: 56,
              themeProvider: themeProvider)
        else
          const SizedBox(width: 56),
        if (s.eject != null)
          NeuButton(
              icon: Icons.eject_rounded,
              onPressed: () => provider.yay(s.eject!),
              size: 48,
              themeProvider: themeProvider),
        if (s.source != null)
          NeuButton(
              icon: Icons.input_rounded,
              onPressed: () => provider.yay(s.source!),
              size: 48,
              themeProvider: themeProvider)
        else
          const SizedBox(width: 48),
      ],
    );
  }

  Widget _sesKanalSatiri(BuildContext context, SiniflandirilmisKomutlar s) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (s.kanalVar)
          _ikiliKolon(
            context,
            etiket: 'tv.kanal'.tr(),
            ust: s.channelUp,
            ustIkon: Icons.keyboard_arrow_up_rounded,
            alt: s.channelDown,
            altIkon: Icons.keyboard_arrow_down_rounded,
          ),
        if (s.sesVar)
          _ikiliKolon(
            context,
            etiket: 'tv.ses'.tr(),
            ust: s.volumeUp,
            ustIkon: Icons.volume_up_rounded,
            orta: s.mute,
            ortaIkon: Icons.volume_off_rounded,
            alt: s.volumeDown,
            altIkon: Icons.volume_down_rounded,
          ),
      ],
    );
  }

  Widget _ikiliKolon(
    BuildContext context, {
    required String etiket,
    IrKomut? ust,
    required IconData ustIkon,
    IrKomut? orta,
    IconData? ortaIkon,
    IrKomut? alt,
    required IconData altIkon,
  }) {
    final tp = themeProvider;
    return Column(children: [
      Text(etiket, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 10),
      if (ust != null)
        NeuButton(
            icon: ustIkon,
            onPressed: () => provider.yay(ust),
            size: 50,
            themeProvider: tp)
      else
        const SizedBox(height: 50),
      const SizedBox(height: 8),
      if (orta != null && ortaIkon != null)
        NeuButton(
            icon: ortaIkon,
            onPressed: () => provider.yay(orta),
            size: 42,
            themeProvider: tp)
      else
        const SizedBox(height: 8),
      const SizedBox(height: 8),
      if (alt != null)
        NeuButton(
            icon: altIkon,
            onPressed: () => provider.yay(alt),
            size: 50,
            themeProvider: tp)
      else
        const SizedBox(height: 50),
    ]);
  }

  Widget _dpad(BuildContext context, SiniflandirilmisKomutlar s) {
    final tp = themeProvider;
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(alignment: Alignment.center, children: [
        themeProvider.isClassic
            ? Neumorphic(
                style: NeuPresets.circlePressed(depth: -3),
                child: const SizedBox(width: 160, height: 160))
            : Container(
                width: 160,
                height: 160,
                decoration: ModernPresets.circleInset()),
        if (s.up != null)
          Positioned(
              top: 6,
              child: NeuButton(
                  icon: Icons.keyboard_arrow_up_rounded,
                  onPressed: () => provider.yay(s.up!),
                  size: 42,
                  themeProvider: tp)),
        if (s.down != null)
          Positioned(
              bottom: 6,
              child: NeuButton(
                  icon: Icons.keyboard_arrow_down_rounded,
                  onPressed: () => provider.yay(s.down!),
                  size: 42,
                  themeProvider: tp)),
        if (s.left != null)
          Positioned(
              left: 6,
              child: NeuButton(
                  icon: Icons.keyboard_arrow_left_rounded,
                  onPressed: () => provider.yay(s.left!),
                  size: 42,
                  themeProvider: tp)),
        if (s.right != null)
          Positioned(
              right: 6,
              child: NeuButton(
                  icon: Icons.keyboard_arrow_right_rounded,
                  onPressed: () => provider.yay(s.right!),
                  size: 42,
                  themeProvider: tp)),
        if (s.ok != null)
          NeuButton(
              label: 'OK',
              onPressed: () => provider.yay(s.ok!),
              size: 52,
              isAccent: true,
              themeProvider: tp),
      ]),
    );
  }

  Widget _menuSatiri(
      BuildContext context, SiniflandirilmisKomutlar s, bool isClassic) {
    final tp = themeProvider;
    final btnlar = <Widget>[];
    if (s.menu != null) {
      btnlar.add(NeuButton(
          icon: Icons.menu_rounded,
          onPressed: () => provider.yay(s.menu!),
          size: 46,
          themeProvider: tp));
    }
    if (s.home != null) {
      btnlar.add(NeuButton(
          icon: Icons.home_rounded,
          onPressed: () => provider.yay(s.home!),
          size: 46,
          themeProvider: tp));
    }
    if (s.back != null) {
      btnlar.add(NeuButton(
          icon: Icons.arrow_back_rounded,
          onPressed: () => provider.yay(s.back!),
          size: 46,
          themeProvider: tp));
    }
    if (s.exit != null) {
      btnlar.add(NeuButton(
          icon: Icons.close_rounded,
          onPressed: () => provider.yay(s.exit!),
          size: 46,
          themeProvider: tp));
    }
    if (s.info != null) {
      btnlar.add(NeuButton(
          icon: Icons.info_outline_rounded,
          onPressed: () => provider.yay(s.info!),
          size: 46,
          themeProvider: tp));
    }
    final kart = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: btnlar,
      ),
    );
    return isClassic
        ? Neumorphic(style: NeuPresets.card(depth: 2), child: kart)
        : Container(decoration: ModernPresets.card(), child: kart);
  }

  Widget _oynatmaSatiri(
      BuildContext context, SiniflandirilmisKomutlar s, bool isClassic) {
    final tp = themeProvider;
    final btnlar = <Widget>[];
    void add(IrKomut? k, IconData icon) {
      if (k != null) {
        btnlar.add(NeuButton(
            icon: icon,
            onPressed: () => provider.yay(k),
            size: 44,
            themeProvider: tp));
      }
    }

    add(s.prev, Icons.skip_previous_rounded);
    add(s.rewind, Icons.fast_rewind_rounded);
    add(s.play, Icons.play_arrow_rounded);
    add(s.pause, Icons.pause_rounded);
    add(s.stop, Icons.stop_rounded);
    add(s.forward, Icons.fast_forward_rounded);
    add(s.next, Icons.skip_next_rounded);
    add(s.record, Icons.fiber_manual_record_rounded);

    final kart = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: btnlar,
      ),
    );
    return isClassic
        ? Neumorphic(style: NeuPresets.card(depth: 2), child: kart)
        : Container(decoration: ModernPresets.card(), child: kart);
  }

  Widget _renkSatiri(
      BuildContext context, SiniflandirilmisKomutlar s, bool isClassic) {
    Widget cip(IrKomut? k, Color renk) {
      if (k == null) return const SizedBox.shrink();
      return Expanded(
        child: GestureDetector(
          onTap: () => provider.yay(k),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 36,
            decoration: BoxDecoration(
              color: renk.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(children: [
        cip(s.red, const Color(0xFFEF4444)),
        cip(s.green, const Color(0xFF22C55E)),
        cip(s.yellow, const Color(0xFFEAB308)),
        cip(s.blue, const Color(0xFF3B82F6)),
      ]),
    );
  }

  Widget _kaynakBolumu(
      BuildContext context, SiniflandirilmisKomutlar s, bool isClassic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('projektor.kaynak'.tr(),
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: s.kaynaklar
              .map((k) => GestureDetector(
                    onTap: () => provider.yay(k.komut),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: ModernPresets.unselectedChip(
                          radius: AppRadius.md),
                      child: Text(k.etiket,
                          style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _numpad(
      BuildContext context, SiniflandirilmisKomutlar s, bool isClassic) {
    final tp = themeProvider;
    // Sayilari 1-2-3 / 4-5-6 / 7-8-9 / .-0-. olarak diz
    final adByValue = {
      for (final k in s.sayilar) _sayiCikar(k.ad): k,
    };

    Widget hucre(int n) {
      final k = adByValue[n];
      if (k == null) return const SizedBox();
      return NeuButton(
          label: '$n',
          onPressed: () => provider.yay(k),
          size: 48,
          themeProvider: tp);
    }

    final grid = Padding(
      padding: const EdgeInsets.all(14),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.5,
        children: [
          hucre(1), hucre(2), hucre(3),
          hucre(4), hucre(5), hucre(6),
          hucre(7), hucre(8), hucre(9),
          const SizedBox(), hucre(0), const SizedBox(),
        ],
      ),
    );
    return isClassic
        ? Neumorphic(style: NeuPresets.card(depth: 2), child: grid)
        : Container(decoration: ModernPresets.card(), child: grid);
  }

  int _sayiCikar(String ad) {
    final m = RegExp(r'(\d)').firstMatch(ad);
    if (m == null) return -1;
    return int.tryParse(m.group(1)!) ?? -1;
  }

  Widget _kalanBolumu(
      BuildContext context, List<IrKomut> kalan, bool isClassic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('kumanda_page.diger'.tr(),
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.6,
          ),
          itemCount: kalan.length,
          itemBuilder: (c, i) {
            final komut = kalan[i];
            return BasilabilirKart(
              etiket: _kisaltAd(komut.ad),
              onPressed: () => provider.yay(komut),
            );
          },
        ),
      ],
    );
  }

  String _kisaltAd(String s) {
    return s.replaceAll('KEY_', '').replaceAll('_', ' ');
  }

  Widget _fanEkstraBolumu(
      BuildContext context, SiniflandirilmisKomutlar s) {
    final ogeler = <_FanOge>[
      if (s.fanMode != null)
        _FanOge(Icons.tune_rounded, 'kumanda_page.fan_mode'.tr(), s.fanMode!),
      if (s.speed != null)
        _FanOge(Icons.speed_rounded, 'kumanda_page.speed'.tr(), s.speed!),
      if (s.oscillation != null)
        _FanOge(Icons.swap_horiz_rounded, 'kumanda_page.oscillation'.tr(),
            s.oscillation!),
      if (s.timer != null)
        _FanOge(Icons.access_time_rounded, 'kumanda_page.timer'.tr(),
            s.timer!),
      if (s.light != null)
        _FanOge(Icons.lightbulb_outline_rounded,
            'kumanda_page.light'.tr(), s.light!),
      if (s.sleep != null)
        _FanOge(Icons.bedtime_outlined, 'kumanda_page.sleep'.tr(), s.sleep!),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      itemCount: ogeler.length,
      itemBuilder: (c, i) {
        final o = ogeler[i];
        return BasilabilirKart(
          etiket: o.etiket,
          ikon: o.ikon,
          onPressed: () => provider.yay(o.komut),
        );
      },
    );
  }

  Widget _bos(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: AppColors.warning, size: 56),
            const SizedBox(height: 12),
            Text('kumanda_page.komut_yok'.tr(),
                style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}

class _FanOge {
  final IconData ikon;
  final String etiket;
  final IrKomut komut;
  const _FanOge(this.ikon, this.etiket, this.komut);
}

/// Dikdortgen, neumorphic, basilinca ice cokme animasyonu olan buton.
/// NeuButton dairesel oldugu icin cok kelimeli etiketlere uygun degil; bu
/// widget metin/ikon kombinasyonu icin kullanilir.
class BasilabilirKart extends StatefulWidget {
  final String etiket;
  final IconData? ikon;
  final VoidCallback onPressed;

  const BasilabilirKart({
    super.key,
    required this.etiket,
    this.ikon,
    required this.onPressed,
  });

  @override
  State<BasilabilirKart> createState() => _BasilabilirKartState();
}

class _BasilabilirKartState extends State<BasilabilirKart> {
  bool _basili = false;

  void _down(_) {
    HapticFeedback.lightImpact();
    setState(() => _basili = true);
  }

  void _up(_) {
    setState(() => _basili = false);
    widget.onPressed();
  }

  void _cancel() => setState(() => _basili = false);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _down,
      onTapUp: _up,
      onTapCancel: _cancel,
      child: AnimatedScale(
        scale: _basili ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: Neumorphic(
          style: NeumorphicStyle(
            shape: NeumorphicShape.flat,
            boxShape: NeumorphicBoxShape.roundRect(
                BorderRadius.circular(AppRadius.md)),
            depth: _basili ? -2 : 4,
            intensity: 0.55,
            lightSource: LightSource.topLeft,
            color: AppColors.background,
            shadowDarkColor: AppColors.shadowDark,
            shadowLightColor: AppColors.shadowLight,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.ikon != null) ...[
                    Icon(widget.ikon, color: AppColors.accent, size: 22),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    widget.etiket,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
