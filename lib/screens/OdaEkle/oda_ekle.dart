import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../db/oda_deposu.dart';
import '../../models/oda_ikonlari.dart';
import '../../theme/app_theme.dart';
import '../../theme/modern_presets.dart';
import '../../theme/theme_provider.dart';

class OdaEkle extends StatefulWidget {
  const OdaEkle({super.key});

  @override
  State<OdaEkle> createState() => _OdaEkleState();
}

class _OdaEkleState extends State<OdaEkle> {
  final _adController = TextEditingController();
  String _seciliIkon = OdaIkonlari.tumu.first.anahtar;
  // Son otomatik doldurulan ad — kullanici bunu degistirdigi anda
  // ikon secimleri ad'i artik ezmez.
  String _otoAd = '';
  bool _baslatildi = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_baslatildi) {
      _baslatildi = true;
      final ilk = OdaIkonlari.tumu.first;
      final ad = context.locale.languageCode == 'tr' ? ilk.etiketTr : ilk.etiketEn;
      _adController.text = ad;
      _otoAd = ad;
    }
  }

  void _ikonSec(OdaIkonu item) {
    final dilTr = context.locale.languageCode == 'tr';
    final yeniAd = dilTr ? item.etiketTr : item.etiketEn;
    setState(() {
      _seciliIkon = item.anahtar;
      // Kullanici metni degistirmemis (eski oto-ad ile birebir ayni) ya da bos ise
      // yeni ikon ismini textbar'a yaz.
      final mevcut = _adController.text.trim();
      if (mevcut.isEmpty || mevcut == _otoAd) {
        _adController.text = yeniAd;
      }
      _otoAd = yeniAd;
    });
    HapticFeedback.selectionClick();
  }

  @override
  void dispose() {
    _adController.dispose();
    super.dispose();
  }

  Future<void> _kaydet() async {
    final ad = _adController.text.trim();
    if (ad.isEmpty) return;
    HapticFeedback.mediumImpact();
    await OdaDeposu.ekle(ad: ad, ikonAnahtari: _seciliIkon);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    final isClassic = tp.isClassic;
    final dilTr = context.locale.languageCode == 'tr';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('oda_ekle.baslik'.tr()),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('oda_ekle.ad_etiket'.tr(),
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              isClassic
                  ? Neumorphic(
                      style: NeuPresets.pressed(radius: AppRadius.md),
                      child: _adInput(),
                    )
                  : Container(
                      decoration: ModernPresets.inset(radius: AppRadius.md),
                      child: _adInput(),
                    ),
              const SizedBox(height: 24),
              Text('oda_ekle.ikon_secin'.tr(),
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: OdaIkonlari.tumu.length,
                  itemBuilder: (c, i) {
                    final item = OdaIkonlari.tumu[i];
                    final secili = item.anahtar == _seciliIkon;
                    return GestureDetector(
                      onTap: () => _ikonSec(item),
                      child: isClassic
                          ? Neumorphic(
                              style: secili
                                  ? NeuPresets.pressed(radius: AppRadius.md)
                                  : NeuPresets.button(
                                      depth: 4, radius: AppRadius.md),
                              child: _ikonIc(item.ikon,
                                  dilTr ? item.etiketTr : item.etiketEn,
                                  secili: secili),
                            )
                          : Container(
                              decoration: secili
                                  ? ModernPresets.selectedChip(
                                      radius: AppRadius.md)
                                  : ModernPresets.unselectedChip(
                                      radius: AppRadius.md),
                              child: _ikonIc(item.ikon,
                                  dilTr ? item.etiketTr : item.etiketEn,
                                  secili: secili),
                            ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: _kaydet,
                  child: isClassic
                      ? Neumorphic(
                          style: NeuPresets.button(depth: 5),
                          child: _kaydetIc(),
                        )
                      : Container(
                          decoration: ModernPresets.button(),
                          child: _kaydetIc(),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _adInput() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: TextField(
          controller: _adController,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'oda_ekle.ad_hint'.tr(),
            hintStyle: const TextStyle(color: AppColors.textSecondary),
          ),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
        ),
      );

  Widget _ikonIc(IconData ikon, String etiket, {required bool secili}) {
    final renk = secili ? AppColors.accent : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(ikon, color: renk, size: 28),
          const SizedBox(height: 6),
          Text(etiket,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: renk, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
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
