import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../Route/identify_routes.dart';
import '../../../db/kumanda_deposu.dart';
import '../../../db/oda_deposu.dart';
import '../../../models/oda_ikonlari.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/theme_provider.dart';
import '../../../widgets/cihaz_aksiyonlari.dart';
import '../../../widgets/device_tile.dart';

class OdaDetay extends StatefulWidget {
  final String odaId;
  const OdaDetay({super.key, required this.odaId});

  @override
  State<OdaDetay> createState() => _OdaDetayState();
}

class _OdaDetayState extends State<OdaDetay> {
  Oda? _oda;
  List<Kumanda> _cihazlar = [];

  @override
  void initState() {
    super.initState();
    _yenile();
    OdaDeposu.degisim.addListener(_yenile);
    KumandaDeposu.degisim.addListener(_yenile);
  }

  @override
  void dispose() {
    OdaDeposu.degisim.removeListener(_yenile);
    KumandaDeposu.degisim.removeListener(_yenile);
    super.dispose();
  }

  void _yenile() {
    if (!mounted) return;
    setState(() {
      _oda = OdaDeposu.bul(widget.odaId);
      _cihazlar = KumandaDeposu.odadakiler(widget.odaId);
    });
  }

  Future<void> _odaDuzenle(Oda oda) async {
    HapticFeedback.lightImpact();
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (c) => _OdaDuzenleSheet(oda: oda),
    );
  }

  Future<void> _odaSil() async {
    HapticFeedback.mediumImpact();
    final onay = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('oda_detay.sil_baslik'.tr()),
        content: Text('oda_detay.sil_aciklama'.tr()),
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
      // Once cihazlardaki odaId'yi temizle
      for (final k in _cihazlar) {
        await KumandaDeposu.odayaTasi(k.id, null);
      }
      await OdaDeposu.sil(widget.odaId);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    final isClassic = tp.isClassic;
    final oda = _oda;

    if (oda == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(),
        body: Center(child: Text('oda_detay.yok'.tr())),
      );
    }

    final ikon = OdaIkonlari.ikon(oda.ikonAnahtari);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(oda.ad),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _odaDuzenle(oda),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: _odaSil,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          physics: const BouncingScrollPhysics(),
          children: [
            // Oda baslik karti
            isClassic
                ? Neumorphic(
                    style: NeuPresets.card(),
                    child: _odaBaslik(context, ikon),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppRadius.lg),
                    ),
                    child: _odaBaslik(context, ikon),
                  ),
            const SizedBox(height: 24),
            Text('oda_detay.cihazlar'.tr(),
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            if (_cihazlar.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(children: [
                    const Icon(Icons.devices_other_rounded,
                        color: AppColors.textSecondary, size: 48),
                    const SizedBox(height: 12),
                    Text('oda_detay.cihaz_yok'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium),
                  ]),
                ),
              )
            else
              ..._cihazlar.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DeviceTile(
                        kumanda: e.value,
                        onTap: () => context.push(
                            '${Rotalar.anasayfaPath}/kumanda/${e.value.id}'),
                        onFavoriteToggle: (v) async {
                          await KumandaDeposu.favoriDegistir(e.value.id, v);
                        },
                        onRename: () =>
                            cihazYenidenAdlandir(context, e.value),
                        onDelete: () => cihazSil(context, e.value),
                        animationIndex: e.key,
                        themeProvider: tp,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _odaBaslik(BuildContext context, IconData ikon) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(children: [
        Icon(ikon, color: AppColors.accent, size: 36),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_oda!.ad,
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text('${_cihazlar.length} ${'oda.cihaz'.tr()}',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ]),
    );
  }
}

class _OdaDuzenleSheet extends StatefulWidget {
  final Oda oda;
  const _OdaDuzenleSheet({required this.oda});

  @override
  State<_OdaDuzenleSheet> createState() => _OdaDuzenleSheetState();
}

class _OdaDuzenleSheetState extends State<_OdaDuzenleSheet> {
  late TextEditingController _adController;
  late String _seciliIkon;
  late Set<int> _odadaki;
  late List<Kumanda> _tumKumandalar;

  @override
  void initState() {
    super.initState();
    _adController = TextEditingController(text: widget.oda.ad);
    _seciliIkon = widget.oda.ikonAnahtari;
    _tumKumandalar = KumandaDeposu.tumunu();
    _odadaki = _tumKumandalar
        .where((k) => k.odaId == widget.oda.id)
        .map((k) => k.id)
        .toSet();
  }

  @override
  void dispose() {
    _adController.dispose();
    super.dispose();
  }

  Future<void> _kaydet() async {
    final yeniAd = _adController.text.trim();
    if (yeniAd.isEmpty) return;
    HapticFeedback.mediumImpact();

    await OdaDeposu.guncelle(widget.oda.id,
        ad: yeniAd, ikonAnahtari: _seciliIkon);

    // Cihaz - oda baglantilarini guncelle
    for (final k in _tumKumandalar) {
      final secili = _odadaki.contains(k.id);
      final mevcuttu = k.odaId == widget.oda.id;
      if (secili && !mevcuttu) {
        await KumandaDeposu.odayaTasi(k.id, widget.oda.id);
      } else if (!secili && mevcuttu) {
        await KumandaDeposu.odayaTasi(k.id, null);
      }
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('genel.duzenle'.tr(),
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            // Ad
            Text('oda_ekle.ad_etiket'.tr(),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Neumorphic(
              style: NeuPresets.pressed(radius: AppRadius.md),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: TextField(
                  controller: _adController,
                  decoration: InputDecoration(
                    hintText: 'oda_ekle.ad_hint'.tr(),
                    hintStyle:
                        const TextStyle(color: AppColors.textSecondary),
                  ),
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Ikon secimi
            Text('oda_ekle.ikon_secin'.tr(),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: OdaIkonlari.tumu.length,
              itemBuilder: (c, i) {
                final item = OdaIkonlari.tumu[i];
                final secili = item.anahtar == _seciliIkon;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _seciliIkon = item.anahtar);
                  },
                  child: Neumorphic(
                    style: secili
                        ? NeuPresets.pressed(radius: AppRadius.md)
                        : NeuPresets.button(
                            depth: 3, radius: AppRadius.md),
                    child: Center(
                      child: Icon(item.ikon,
                          color: secili
                              ? AppColors.accent
                              : AppColors.textSecondary,
                          size: 24),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            // Cihaz secimi
            Text('oda_detay.cihazlar'.tr(),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_tumKumandalar.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text('anasayfa.bos_cihazlar'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium),
              )
            else
              ..._tumKumandalar.map((k) {
                final secili = _odadaki.contains(k.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        if (secili) {
                          _odadaki.remove(k.id);
                        } else {
                          _odadaki.add(k.id);
                        }
                      });
                    },
                    child: Neumorphic(
                      style: secili
                          ? NeuPresets.pressed(radius: AppRadius.md)
                          : NeuPresets.button(
                              depth: 2, radius: AppRadius.md),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        child: Row(children: [
                          Icon(
                              secili
                                  ? Icons.check_box_rounded
                                  : Icons.check_box_outline_blank_rounded,
                              color: secili
                                  ? AppColors.accent
                                  : AppColors.textSecondary,
                              size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(k.ad,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                const SizedBox(height: 2),
                                Text('${k.marka} · ${k.cihazTipi}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall),
                              ],
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Neumorphic(
                    style: NeuPresets.button(depth: 3),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Center(
                        child: Text('genel.iptal'.tr(),
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: _kaydet,
                  child: Neumorphic(
                    style: NeuPresets.button(depth: 5),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Center(
                        child: Text('genel.kaydet'.tr(),
                            style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
