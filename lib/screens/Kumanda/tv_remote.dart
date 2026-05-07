import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

import '../../ir/uzaktan_komut.dart';
import '../../theme/app_theme.dart';
import '../../theme/modern_presets.dart';
import '../../theme/theme_provider.dart';
import '../../widgets/ir_gosterge.dart';
import '../../widgets/neu_button.dart';
import 'kumanda.dart';

class TvRemote extends StatefulWidget {
  final KumandaProvider provider;
  final ThemeProvider themeProvider;
  const TvRemote({super.key, required this.provider, required this.themeProvider});

  @override
  State<TvRemote> createState() => _TvRemoteState();
}

class _TvRemoteState extends State<TvRemote> {
  bool get isClassic => widget.themeProvider.isClassic;

  void _yay(TvKomut k) {
    widget.provider.yayTv(k);
  }

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Power - Mute - Source ust sira
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  NeuButton(
                      icon: Icons.power_settings_new_rounded,
                      onPressed: () => _yay(TvKomut.power),
                      isPower: true,
                      size: 58,
                      themeProvider: tp),
                  NeuButton(
                      icon: Icons.volume_off_rounded,
                      onPressed: () => _yay(TvKomut.mute),
                      size: 58,
                      themeProvider: tp),
                  NeuButton(
                      icon: Icons.input_rounded,
                      onPressed: () => _yay(TvKomut.source),
                      size: 58,
                      themeProvider: tp),
                ],
              ),

              // Kanal kolonu | D-pad | Ses kolonu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _kontrolKolonu(
                    etiket: 'tv.kanal'.tr(),
                    upIcon: Icons.keyboard_arrow_up_rounded,
                    downIcon: Icons.keyboard_arrow_down_rounded,
                    onUp: () => _yay(TvKomut.channelUp),
                    onDown: () => _yay(TvKomut.channelDown),
                  ),
                  _dPad(),
                  _kontrolKolonu(
                    etiket: 'tv.ses'.tr(),
                    upIcon: Icons.keyboard_arrow_up_rounded,
                    downIcon: Icons.keyboard_arrow_down_rounded,
                    onUp: () => _yay(TvKomut.volumeUp),
                    onDown: () => _yay(TvKomut.volumeDown),
                  ),
                ],
              ),

              // Menu / Back / Home
              isClassic
                  ? Neumorphic(
                      style: NeuPresets.card(depth: 2),
                      child: _altKontroller(tp))
                  : Container(
                      decoration: ModernPresets.card(),
                      child: _altKontroller(tp)),

              // Numpad — kendi dogal boyutunda
              _numpad(tp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _altKontroller(ThemeProvider tp) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          NeuButton(
              icon: Icons.menu_rounded,
              onPressed: () => _yay(TvKomut.menu),
              size: 50,
              themeProvider: tp),
          NeuButton(
              icon: Icons.arrow_back_rounded,
              onPressed: () => _yay(TvKomut.back),
              size: 50,
              themeProvider: tp),
          NeuButton(
              icon: Icons.home_rounded,
              onPressed: () => _yay(TvKomut.menu),
              size: 50,
              themeProvider: tp),
        ],
      ),
    );
  }

  Widget _kontrolKolonu({
    required String etiket,
    required IconData upIcon,
    required IconData downIcon,
    required VoidCallback onUp,
    required VoidCallback onDown,
  }) {
    final tp = widget.themeProvider;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(etiket,
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3)),
        const SizedBox(height: 12),
        NeuButton(icon: upIcon, onPressed: onUp, size: 50, themeProvider: tp),
        const SizedBox(height: 14),
        NeuButton(
            icon: downIcon, onPressed: onDown, size: 50, themeProvider: tp),
      ],
    );
  }

  Widget _dPad() {
    final tp = widget.themeProvider;
    return SizedBox(
      width: 170,
      height: 170,
      child: Stack(alignment: Alignment.center, children: [
        if (isClassic)
          Neumorphic(
              style: NeuPresets.circlePressed(depth: -3),
              child: const SizedBox(width: 170, height: 170))
        else
          Container(
              width: 170,
              height: 170,
              decoration: ModernPresets.circleInset()),
        Positioned(
            top: 6,
            child: NeuButton(
                icon: Icons.keyboard_arrow_up_rounded,
                onPressed: () => _yay(TvKomut.up),
                size: 46,
                themeProvider: tp)),
        Positioned(
            bottom: 6,
            child: NeuButton(
                icon: Icons.keyboard_arrow_down_rounded,
                onPressed: () => _yay(TvKomut.down),
                size: 46,
                themeProvider: tp)),
        Positioned(
            left: 6,
            child: NeuButton(
                icon: Icons.keyboard_arrow_left_rounded,
                onPressed: () => _yay(TvKomut.left),
                size: 46,
                themeProvider: tp)),
        Positioned(
            right: 6,
            child: NeuButton(
                icon: Icons.keyboard_arrow_right_rounded,
                onPressed: () => _yay(TvKomut.right),
                size: 46,
                themeProvider: tp)),
        NeuButton(
            label: 'OK',
            onPressed: () => _yay(TvKomut.ok),
            size: 54,
            isAccent: true,
            themeProvider: tp),
      ]),
    );
  }

  Widget _numpad(ThemeProvider tp) {
    Widget hucre(TvKomut? komut, String etiket) {
      if (komut == null) return const Expanded(child: SizedBox());
      return Expanded(
        child: Center(
          child: NeuButton(
              label: etiket,
              onPressed: () => _yay(komut),
              size: 56,
              themeProvider: tp),
        ),
      );
    }

    Widget sira(List<Widget> children) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(children: children),
        );

    final grid = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          sira([
            hucre(TvKomut.num1, '1'),
            hucre(TvKomut.num2, '2'),
            hucre(TvKomut.num3, '3'),
          ]),
          sira([
            hucre(TvKomut.num4, '4'),
            hucre(TvKomut.num5, '5'),
            hucre(TvKomut.num6, '6'),
          ]),
          sira([
            hucre(TvKomut.num7, '7'),
            hucre(TvKomut.num8, '8'),
            hucre(TvKomut.num9, '9'),
          ]),
          sira([
            hucre(null, ''),
            hucre(TvKomut.num0, '0'),
            hucre(null, ''),
          ]),
        ],
      ),
    );

    return isClassic
        ? Neumorphic(style: NeuPresets.card(depth: 2), child: grid)
        : Container(decoration: ModernPresets.card(), child: grid);
  }
}
