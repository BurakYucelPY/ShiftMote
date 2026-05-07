import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

import '../../ir/uzaktan_komut.dart';
import '../../theme/app_theme.dart';
import '../../theme/modern_presets.dart';
import '../../theme/theme_provider.dart';
import '../../widgets/ir_gosterge.dart';
import '../../widgets/neu_button.dart';
import 'kumanda.dart';

class ProjektorRemote extends StatefulWidget {
  final KumandaProvider provider;
  final ThemeProvider themeProvider;
  const ProjektorRemote(
      {super.key, required this.provider, required this.themeProvider});

  @override
  State<ProjektorRemote> createState() => _ProjektorRemoteState();
}

class _ProjektorRemoteState extends State<ProjektorRemote> {
  ProjektorKomut _kaynak = ProjektorKomut.sourceHdmi;
  bool _sessiz = false;

  bool get isClassic => widget.themeProvider.isClassic;

  @override
  Widget build(BuildContext context) {
    final tp = widget.themeProvider;
    final k = widget.provider.kumanda!;
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        physics: const BouncingScrollPhysics(),
        child: Column(children: [
          Center(
            child: NeuButton(
                icon: Icons.power_settings_new_rounded,
                onPressed: () =>
                    widget.provider.yayProjektor(ProjektorKomut.power),
                isPower: true,
                size: 64,
                themeProvider: tp),
          ),
          const SizedBox(height: 28),
          Text('projektor.kaynak'.tr(),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(children: [
            _kaynakBtn('HDMI', ProjektorKomut.sourceHdmi),
            const SizedBox(width: 10),
            _kaynakBtn('VGA', ProjektorKomut.sourceVga),
            const SizedBox(width: 10),
            _kaynakBtn('USB', ProjektorKomut.sourceUsb),
          ]),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(children: [
                Text('tv.ses'.tr(),
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                NeuButton(
                    icon: Icons.volume_up_rounded,
                    onPressed: () =>
                        widget.provider.yayProjektor(ProjektorKomut.volumeUp),
                    size: 48,
                    themeProvider: tp),
                const SizedBox(height: 8),
                NeuButton(
                    icon: Icons.volume_off_rounded,
                    onPressed: () {
                      setState(() => _sessiz = !_sessiz);
                      widget.provider.yayProjektor(ProjektorKomut.mute);
                    },
                    size: 40,
                    iconColor: _sessiz ? AppColors.error : null,
                    themeProvider: tp),
                const SizedBox(height: 8),
                NeuButton(
                    icon: Icons.volume_down_rounded,
                    onPressed: () => widget.provider
                        .yayProjektor(ProjektorKomut.volumeDown),
                    size: 48,
                    themeProvider: tp),
              ]),
              _dPad(),
              Column(children: [
                Text('projektor.zoom'.tr(),
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                NeuButton(
                    icon: Icons.zoom_in_rounded,
                    onPressed: () =>
                        widget.provider.yayProjektor(ProjektorKomut.zoomIn),
                    size: 48,
                    themeProvider: tp),
                const SizedBox(height: 56),
                NeuButton(
                    icon: Icons.zoom_out_rounded,
                    onPressed: () =>
                        widget.provider.yayProjektor(ProjektorKomut.zoomOut),
                    size: 48,
                    themeProvider: tp),
              ]),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              NeuButton(
                  icon: Icons.menu_rounded,
                  onPressed: () =>
                      widget.provider.yayProjektor(ProjektorKomut.menu),
                  size: 46,
                  themeProvider: tp),
              NeuButton(
                  icon: Icons.arrow_back_rounded,
                  onPressed: () =>
                      widget.provider.yayProjektor(ProjektorKomut.back),
                  size: 46,
                  themeProvider: tp),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _kaynakBtn(String etiket, ProjektorKomut k) {
    final secili = _kaynak == k;
    final ic = Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Center(
        child: Text(etiket,
            style: TextStyle(
                color: secili ? AppColors.accent : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
      ),
    );
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _kaynak = k);
          widget.provider.yayProjektor(k);
        },
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

  Widget _dPad() {
    final tp = widget.themeProvider;
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(alignment: Alignment.center, children: [
        if (isClassic)
          Neumorphic(
              style: NeuPresets.circlePressed(depth: -3),
              child: const SizedBox(width: 150, height: 150))
        else
          Container(
              width: 150, height: 150, decoration: ModernPresets.circleInset()),
        Positioned(
            top: 6,
            child: NeuButton(
                icon: Icons.keyboard_arrow_up_rounded,
                onPressed: () =>
                    widget.provider.yayProjektor(ProjektorKomut.up),
                size: 40,
                themeProvider: tp)),
        Positioned(
            bottom: 6,
            child: NeuButton(
                icon: Icons.keyboard_arrow_down_rounded,
                onPressed: () =>
                    widget.provider.yayProjektor(ProjektorKomut.down),
                size: 40,
                themeProvider: tp)),
        Positioned(
            left: 6,
            child: NeuButton(
                icon: Icons.keyboard_arrow_left_rounded,
                onPressed: () =>
                    widget.provider.yayProjektor(ProjektorKomut.left),
                size: 40,
                themeProvider: tp)),
        Positioned(
            right: 6,
            child: NeuButton(
                icon: Icons.keyboard_arrow_right_rounded,
                onPressed: () =>
                    widget.provider.yayProjektor(ProjektorKomut.right),
                size: 40,
                themeProvider: tp)),
        NeuButton(
            label: 'OK',
            onPressed: () => widget.provider.yayProjektor(ProjektorKomut.ok),
            size: 50,
            isAccent: true,
            themeProvider: tp),
      ]),
    );
  }
}
