import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

import '../db/kumanda_deposu.dart';
import '../models/kategori_ikonu.dart';
import '../theme/app_theme.dart';
import '../theme/modern_presets.dart';
import '../theme/theme_provider.dart';

/// Tema-duyarli kumanda karti.
class DeviceTile extends StatefulWidget {
  final Kumanda kumanda;
  final VoidCallback onTap;
  final ValueChanged<bool>? onFavoriteToggle;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;
  final int animationIndex;
  final ThemeProvider themeProvider;

  const DeviceTile({
    super.key,
    required this.kumanda,
    required this.onTap,
    this.onFavoriteToggle,
    this.onRename,
    this.onDelete,
    this.animationIndex = 0,
    required this.themeProvider,
  });

  @override
  State<DeviceTile> createState() => _DeviceTileState();
}

class _DeviceTileState extends State<DeviceTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _entry;
  late Animation<double> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(
        duration: const Duration(milliseconds: 450), vsync: this);
    _slide = Tween<double>(begin: 20, end: 0)
        .animate(CurvedAnimation(parent: _entry, curve: Curves.easeOutCubic));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _entry, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: 60 * widget.animationIndex), () {
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
        child: isClassic ? _classic(context) : _modern(context),
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
    final ikon = KategoriIkonu.ikon(widget.kumanda.kategoriAnahtari);
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        if (isClassic)
          Neumorphic(
            style: NeuPresets.pressed(radius: AppRadius.md),
            child: SizedBox(
                width: 46,
                height: 46,
                child: Icon(ikon, color: AppColors.accent, size: 22)),
          )
        else
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  width: 0.5),
            ),
            child: Icon(ikon, color: AppColors.accent, size: 22),
          ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.kumanda.ad,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 3),
              Text('${widget.kumanda.marka} · ${widget.kumanda.cihazTipi}',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        if (widget.onFavoriteToggle != null)
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onFavoriteToggle!(!widget.kumanda.favori);
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: AnimatedSwitcher(
                duration: AppDurations.normal,
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  widget.kumanda.favori
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  key: ValueKey(widget.kumanda.favori),
                  color: widget.kumanda.favori
                      ? AppColors.warning
                      : AppColors.textSecondary,
                  size: 22,
                ),
              ),
            ),
          ),
        if (widget.onRename != null || widget.onDelete != null)
          PopupMenuButton<String>(
            tooltip: '',
            color: AppColors.surface,
            icon: const Icon(Icons.more_vert_rounded,
                color: AppColors.textSecondary, size: 22),
            padding: EdgeInsets.zero,
            onSelected: (v) {
              if (v == 'rename' && widget.onRename != null) {
                widget.onRename!();
              } else if (v == 'delete' && widget.onDelete != null) {
                widget.onDelete!();
              }
            },
            itemBuilder: (c) => [
              if (widget.onRename != null)
                PopupMenuItem(
                  value: 'rename',
                  child: Row(children: [
                    const Icon(Icons.edit_outlined,
                        color: AppColors.textPrimary, size: 18),
                    const SizedBox(width: 10),
                    Text('genel.yeniden_adlandir'.tr(),
                        style:
                            const TextStyle(color: AppColors.textPrimary)),
                  ]),
                ),
              if (widget.onDelete != null)
                PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    const Icon(Icons.delete_outline_rounded,
                        color: AppColors.error, size: 18),
                    const SizedBox(width: 10),
                    Text('genel.sil'.tr(),
                        style: const TextStyle(color: AppColors.error)),
                  ]),
                ),
            ],
          )
        else
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textSecondary, size: 24),
      ]),
    );
  }
}
