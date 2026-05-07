import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

import '../db/oda_deposu.dart';
import '../models/oda_ikonlari.dart';
import '../theme/app_theme.dart';
import '../theme/modern_presets.dart';
import '../theme/theme_provider.dart';

class RoomCard extends StatefulWidget {
  final Oda oda;
  final int cihazSayisi;
  final VoidCallback onTap;
  final int animationIndex;
  final ThemeProvider themeProvider;

  const RoomCard({
    super.key,
    required this.oda,
    required this.cihazSayisi,
    required this.onTap,
    this.animationIndex = 0,
    required this.themeProvider,
  });

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _entry;
  late Animation<double> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _slide = Tween<double>(begin: 30, end: 0)
        .animate(CurvedAnimation(parent: _entry, curve: Curves.easeOutCubic));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _entry, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: 80 * widget.animationIndex), () {
      if (mounted) _entry.forward();
    });
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isClassic = widget.themeProvider.isClassic;

    return AnimatedBuilder(
      animation: _entry,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _slide.value),
        child: Opacity(opacity: _fade.value, child: child),
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 155,
          margin: const EdgeInsets.only(right: 14),
          child: isClassic ? _classic(context) : _modern(context),
        ),
      ),
    );
  }

  Widget _classic(BuildContext c) => Neumorphic(
        style: NeuPresets.card(depth: 5),
        child: _content(c, isClassic: true),
      );

  Widget _modern(BuildContext c) => Container(
        decoration: ModernPresets.card(),
        child: _content(c, isClassic: false),
      );

  Widget _content(BuildContext context, {required bool isClassic}) {
    final ikon = OdaIkonlari.ikon(widget.oda.ikonAnahtari);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isClassic)
            Neumorphic(
              style: NeuPresets.pressed(radius: AppRadius.md),
              child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(ikon, color: AppColors.accent, size: 22)),
            )
          else
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    width: 0.5),
              ),
              child: Icon(ikon, color: AppColors.accent, size: 22),
            ),
          const Spacer(),
          Text(widget.oda.ad,
              style: Theme.of(context).textTheme.titleLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text('${widget.cihazSayisi} ${'oda.cihaz'.tr()}',
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
