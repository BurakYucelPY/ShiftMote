import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

import '../../ir/uzaktan_komut.dart';
import '../../theme/app_theme.dart';
import '../../theme/modern_presets.dart';
import '../../theme/theme_provider.dart';
import '../../widgets/ir_gosterge.dart';
import '../../widgets/neu_button.dart';
import 'kumanda.dart';

class AcRemote extends StatefulWidget {
  final KumandaProvider provider;
  final ThemeProvider themeProvider;
  const AcRemote({super.key, required this.provider, required this.themeProvider});

  @override
  State<AcRemote> createState() => _AcRemoteState();
}

enum _Mod { cool, heat, fan, auto }
enum _FanSpeed { low, medium, high, auto }

class _AcRemoteState extends State<AcRemote> {
  static const int _sicaklikMin = 16;
  static const int _sicaklikMax = 30;

  int _sicaklik = 24;
  _Mod _mod = _Mod.cool;
  _FanSpeed _fan = _FanSpeed.medium;

  // Drag basladiginda kaydederiz, drag bitince fark kadar IR yayariz.
  int? _dragBaslangic;

  bool get isClassic => widget.themeProvider.isClassic;

  Color _modRengi() {
    switch (_mod) {
      case _Mod.cool: return AppColors.modeCool;
      case _Mod.heat: return AppColors.modeHeat;
      case _Mod.fan: return AppColors.modeFan;
      case _Mod.auto: return AppColors.modeAuto;
    }
  }

  void _modSec(_Mod m) {
    setState(() => _mod = m);
    switch (m) {
      case _Mod.cool: widget.provider.yayKlima(KlimaKomut.modeCool); break;
      case _Mod.heat: widget.provider.yayKlima(KlimaKomut.modeHeat); break;
      case _Mod.fan: widget.provider.yayKlima(KlimaKomut.modeFan); break;
      case _Mod.auto: widget.provider.yayKlima(KlimaKomut.modeAuto); break;
    }
  }

  void _fanSec(_FanSpeed f) {
    setState(() => _fan = f);
    switch (f) {
      case _FanSpeed.low: widget.provider.yayKlima(KlimaKomut.fanLow); break;
      case _FanSpeed.medium: widget.provider.yayKlima(KlimaKomut.fanMedium); break;
      case _FanSpeed.high: widget.provider.yayKlima(KlimaKomut.fanHigh); break;
      case _FanSpeed.auto: widget.provider.yayKlima(KlimaKomut.fanAuto); break;
    }
  }

  void _sicaklikGuncelle(int yeni) {
    final clamped = yeni.clamp(_sicaklikMin, _sicaklikMax);
    if (clamped != _sicaklik) {
      setState(() => _sicaklik = clamped);
      HapticFeedback.selectionClick();
    }
  }

  void _dragdanSicaklik(Offset localPos, Size size) {
    final center = Offset(size.width / 2, size.height - 8);
    final dx = localPos.dx - center.dx;
    final dy = localPos.dy - center.dy;
    // Yarim ay merkezin USTUNDE (dy <= 0). Az asagiya da izin ver.
    if (dy > 6) return;
    // Ekran koordinatinda atan2: ust yarim = [-π, 0].
    double aci = math.atan2(dy, dx);
    if (aci > 0) {
      // Sol yarim alt (~π) sol uca, sag yarim alt (~0+) sag uca yapis.
      aci = aci > math.pi / 2 ? -math.pi : 0;
    }
    if (aci < -math.pi) aci = -math.pi;
    final oran = 1 + aci / math.pi; // [-π,0] → [0,1]
    final yeni =
        (_sicaklikMin + oran * (_sicaklikMax - _sicaklikMin)).round();
    _sicaklikGuncelle(yeni);
  }

  Future<void> _dragBittikten(int? baslangic) async {
    if (baslangic == null) return;
    final fark = _sicaklik - baslangic;
    if (fark == 0) return;
    final komut = fark > 0 ? KlimaKomut.tempUp : KlimaKomut.tempDown;
    for (int i = 0; i < fark.abs(); i++) {
      widget.provider.yayKlima(komut);
      await Future.delayed(const Duration(milliseconds: 70));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tp = widget.themeProvider;
    final k = widget.provider.kumanda!;
    final modRenk = _modRengi();
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(children: [
            // Yarim daire sicaklik gostergesi
            _SicaklikGosterge(
              sicaklik: _sicaklik,
              min: _sicaklikMin,
              max: _sicaklikMax,
              renk: modRenk,
              onDragStart: () => _dragBaslangic = _sicaklik,
              onDragEnd: () {
                final b = _dragBaslangic;
                _dragBaslangic = null;
                _dragBittikten(b);
              },
              dragdanSicaklik: _dragdanSicaklik,
            ),
            const SizedBox(height: 12),
            // Power - Eksi - Arti - Timer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                NeuButton(
                    icon: Icons.power_settings_new_rounded,
                    onPressed: () => widget.provider.yayKlima(KlimaKomut.power),
                    isPower: true,
                    size: 54,
                    themeProvider: tp),
                NeuButton(
                    icon: Icons.remove_rounded,
                    onPressed: () {
                      _sicaklikGuncelle(_sicaklik - 1);
                      widget.provider.yayKlima(KlimaKomut.tempDown);
                    },
                    size: 60,
                    iconSize: 28,
                    themeProvider: tp),
                NeuButton(
                    icon: Icons.add_rounded,
                    onPressed: () {
                      _sicaklikGuncelle(_sicaklik + 1);
                      widget.provider.yayKlima(KlimaKomut.tempUp);
                    },
                    size: 60,
                    iconSize: 28,
                    themeProvider: tp),
                NeuButton(
                    icon: Icons.access_time_rounded,
                    onPressed: () =>
                        widget.provider.yayKlima(KlimaKomut.timerSet),
                    size: 54,
                    themeProvider: tp),
              ],
            ),
            const SizedBox(height: 18),
            Align(
                alignment: Alignment.centerLeft,
                child: Text('klima.mod'.tr(),
                    style: Theme.of(context).textTheme.titleMedium)),
            const SizedBox(height: 8),
            Row(children: [
              _modBtn('klima.cool'.tr(), Icons.ac_unit_rounded, _Mod.cool,
                  AppColors.modeCool),
              const SizedBox(width: 8),
              _modBtn('klima.heat'.tr(), Icons.local_fire_department_rounded,
                  _Mod.heat, AppColors.modeHeat),
              const SizedBox(width: 8),
              _modBtn('klima.fan'.tr(), Icons.toys_rounded, _Mod.fan,
                  AppColors.modeFan),
              const SizedBox(width: 8),
              _modBtn('klima.auto'.tr(), Icons.autorenew_rounded, _Mod.auto,
                  AppColors.modeAuto),
            ]),
            const SizedBox(height: 16),
            Align(
                alignment: Alignment.centerLeft,
                child: Text('klima.fan_hizi'.tr(),
                    style: Theme.of(context).textTheme.titleMedium)),
            const SizedBox(height: 8),
            Row(children: [
              _fanBtn('klima.dusuk'.tr(), _FanSpeed.low),
              const SizedBox(width: 8),
              _fanBtn('klima.orta'.tr(), _FanSpeed.medium),
              const SizedBox(width: 8),
              _fanBtn('klima.yuksek'.tr(), _FanSpeed.high),
              const SizedBox(width: 8),
              _fanBtn('klima.auto'.tr(), _FanSpeed.auto),
            ]),
            const SizedBox(height: 18),
            Center(
              child: NeuButton(
                  icon: Icons.swap_vert_rounded,
                  onPressed: () =>
                      widget.provider.yayKlima(KlimaKomut.swingToggle),
                  size: 54,
                  themeProvider: tp),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _modBtn(String etiket, IconData ikon, _Mod m, Color renk) {
    final secili = _mod == m;
    final ic = Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(children: [
        Icon(ikon,
            color: secili ? renk : AppColors.textSecondary, size: 22),
        const SizedBox(height: 4),
        Text(etiket,
            style: TextStyle(
                color: secili ? renk : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      ]),
    );
    return Expanded(
      child: GestureDetector(
        onTap: () => _modSec(m),
        child: isClassic
            ? Neumorphic(
                style: secili
                    ? NeuPresets.pressed(radius: AppRadius.md)
                    : NeuPresets.button(depth: 4, radius: AppRadius.md),
                child: ic,
              )
            : Container(
                decoration: secili
                    ? ModernPresets.selectedChip(
                        radius: AppRadius.md, color: renk)
                    : ModernPresets.unselectedChip(radius: AppRadius.md),
                child: ic,
              ),
      ),
    );
  }

  Widget _fanBtn(String etiket, _FanSpeed f) {
    final secili = _fan == f;
    final ic = Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Center(
        child: Text(etiket,
            style: TextStyle(
                color: secili ? AppColors.accent : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ),
    );
    return Expanded(
      child: GestureDetector(
        onTap: () => _fanSec(f),
        child: isClassic
            ? Neumorphic(
                style: secili
                    ? NeuPresets.pressed(radius: AppRadius.md)
                    : NeuPresets.button(depth: 4, radius: AppRadius.md),
                child: ic,
              )
            : Container(
                decoration: secili
                    ? ModernPresets.selectedChip(radius: AppRadius.md)
                    : ModernPresets.unselectedChip(radius: AppRadius.md),
                child: ic,
              ),
      ),
    );
  }
}

/// Yarim daire sicaklik gostergesi.
/// - Drag ile veya yarim daire uzerine dokunarak sicaklik secilir.
/// - Aktif yay 'renk' ile, arka yay surfaceLight ile cizilir.
/// - Ortada buyuk fontla "$sicaklik°C" yazisi durur.
class _SicaklikGosterge extends StatelessWidget {
  final int sicaklik;
  final int min;
  final int max;
  final Color renk;
  final VoidCallback onDragStart;
  final VoidCallback onDragEnd;
  final void Function(Offset localPos, Size size) dragdanSicaklik;

  const _SicaklikGosterge({
    required this.sicaklik,
    required this.min,
    required this.max,
    required this.renk,
    required this.onDragStart,
    required this.onDragEnd,
    required this.dragdanSicaklik,
  });

  @override
  Widget build(BuildContext context) {
    final oran = (sicaklik - min) / (max - min);
    return SizedBox(
      width: 300,
      height: 200,
      child: LayoutBuilder(builder: (c, cons) {
        final size = Size(cons.maxWidth, cons.maxHeight);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => dragdanSicaklik(d.localPosition, size),
          onPanStart: (d) {
            onDragStart();
            dragdanSicaklik(d.localPosition, size);
          },
          onPanUpdate: (d) => dragdanSicaklik(d.localPosition, size),
          onPanEnd: (_) => onDragEnd(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _YariCemberCizici(
                    oran: oran.clamp(0.0, 1.0),
                    renk: renk,
                    arkaRenk: AppColors.surfaceLight,
                    kalinlik: 18,
                  ),
                ),
              ),
              // Yari ayin ic kismina sicaklik yazisi (yay'in altinda kalmali)
              Positioned(
                left: 0,
                right: 0,
                top: 100,
                bottom: 16,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$sicaklik',
                          style: TextStyle(
                              color: renk,
                              fontSize: 56,
                              fontWeight: FontWeight.w700,
                              height: 1.0)),
                      const SizedBox(height: 4),
                      Text('°C',
                          style: TextStyle(
                              color: renk.withValues(alpha: 0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _YariCemberCizici extends CustomPainter {
  final double oran;
  final Color renk;
  final Color arkaRenk;
  final double kalinlik;

  _YariCemberCizici({
    required this.oran,
    required this.renk,
    required this.arkaRenk,
    required this.kalinlik,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 8);
    final radius = (size.width / 2) - kalinlik;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // UST yarim daire: -π (sol) → 0 (sag), pozitif sweep π. Yol -π/2
    // (yukari) noktasindan gecer cunku ekran Y-down konvansiyonunda
    // sin(-π/2) = -1, yani center.y'nin USTUNE.
    final arka = Paint()
      ..color = arkaRenk
      ..style = PaintingStyle.stroke
      ..strokeWidth = kalinlik
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi, math.pi, false, arka);

    final on = Paint()
      ..color = renk
      ..style = PaintingStyle.stroke
      ..strokeWidth = kalinlik
      ..strokeCap = StrokeCap.round;
    final orn = oran.clamp(0.0, 1.0);
    if (orn > 0.001) {
      canvas.drawArc(rect, -math.pi, math.pi * orn, false, on);
    }

    // Surukleme topu — aci = -π (sol) → 0 (sag) interpolasyonu
    final aci = -math.pi + math.pi * orn;
    final topMerkez = Offset(
      center.dx + math.cos(aci) * radius,
      center.dy + math.sin(aci) * radius,
    );
    canvas.drawCircle(
      topMerkez,
      kalinlik * 0.95,
      Paint()..color = renk,
    );
    canvas.drawCircle(
      topMerkez,
      kalinlik * 0.95,
      Paint()
        ..color = AppColors.background
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(_YariCemberCizici old) =>
      old.oran != oran || old.renk != renk;
}
