import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

import '../theme/app_theme.dart';
import '../theme/modern_presets.dart';
import '../theme/theme_provider.dart';

/// Tema-duyarlı bottom navigation bar.
/// Klasik = Neumorphic kart · Modern = Sade shadow kart
class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final ThemeProvider themeProvider;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.themeProvider,
  });

  static const _items = [
    _NavItem(icon: Icons.home_rounded, activeIcon: Icons.home_rounded, labelKey: 'nav.anasayfa'),
    _NavItem(icon: Icons.meeting_room_outlined, activeIcon: Icons.meeting_room_rounded, labelKey: 'nav.odalar'),
    _NavItem(icon: Icons.star_outline_rounded, activeIcon: Icons.star_rounded, labelKey: 'nav.favoriler'),
  ];

  @override
  Widget build(BuildContext context) {
    final isClassic = themeProvider.isClassic;

    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: isClassic
              ? Neumorphic(
                  style: NeuPresets.card(depth: 5),
                  child: _buildContent(context),
                )
              : Container(
                  decoration: ModernPresets.navBar(),
                  child: _buildContent(context),
                ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          final isActive = currentIndex == index;
          return _buildNavItem(context, item: item, isActive: isActive, onTap: () {
            HapticFeedback.selectionClick();
            onTap(index);
          });
        }),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {required _NavItem item, required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppDurations.normal,
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: isActive ? 20 : 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          AnimatedSwitcher(
            duration: AppDurations.fast,
            child: Icon(isActive ? item.activeIcon : item.icon, key: ValueKey(isActive), color: isActive ? AppColors.accent : AppColors.textSecondary, size: 22),
          ),
          AnimatedSize(
            duration: AppDurations.normal,
            curve: Curves.easeOutCubic,
            child: isActive
                ? Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(item.labelKey.tr(), style: const TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w600)),
                  )
                : const SizedBox.shrink(),
          ),
        ]),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String labelKey;
  const _NavItem({required this.icon, required this.activeIcon, required this.labelKey});
}
