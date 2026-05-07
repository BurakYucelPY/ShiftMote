import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../theme/modern_presets.dart';

/// Tema-duyarlı buton — kumanda butonları için.
/// Klasik = Neumorphic circle · Modern = Material circle + shadow
class NeuButton extends StatefulWidget {
  final IconData? icon;
  final String? label;
  final VoidCallback onPressed;
  final double size;
  final bool isPower;
  final bool isAccent;
  final Color? glowColor;
  final Color? iconColor;
  final double iconSize;
  final double depth;
  final ThemeProvider? themeProvider;

  const NeuButton({
    super.key,
    this.icon,
    this.label,
    required this.onPressed,
    this.size = 56,
    this.isPower = false,
    this.isAccent = false,
    this.glowColor,
    this.iconColor,
    this.iconSize = 0,
    this.depth = 4,
    this.themeProvider,
  });

  @override
  State<NeuButton> createState() => _NeuButtonState();
}

class _NeuButtonState extends State<NeuButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));
    if (widget.isPower || widget.isAccent) _glowController.repeat(reverse: true);
  }

  @override
  void dispose() { _glowController.dispose(); super.dispose(); }

  Color get _effectiveGlowColor {
    if (widget.glowColor != null) return widget.glowColor!;
    if (widget.isPower) return AppColors.error;
    if (widget.isAccent) return AppColors.accent;
    return Colors.transparent;
  }

  Color get _effectiveIconColor {
    if (widget.iconColor != null) return widget.iconColor!;
    if (widget.isPower) return AppColors.error;
    if (widget.isAccent) return AppColors.accent;
    return AppColors.textPrimary;
  }

  // Basma anini takip eder; cok hizli (tek dokunus) basislarda
  // 'pressed' gorseli en az _minBasiliMs kadar gorunur olsun diye
  // tapUp'tan once gecen sureyi olcup eksik kismi bekleriz.
  DateTime? _basildiAn;
  static const int _minBasiliMs = 110;

  void _handleTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
    _basildiAn = DateTime.now();
    HapticFeedback.lightImpact();
  }

  Future<void> _handleTapUp(TapUpDetails _) async {
    widget.onPressed();
    final basildi = _basildiAn;
    if (basildi != null) {
      final gecen = DateTime.now().difference(basildi).inMilliseconds;
      final kalan = _minBasiliMs - gecen;
      if (kalan > 0) {
        await Future.delayed(Duration(milliseconds: kalan));
      }
    }
    if (mounted) setState(() => _isPressed = false);
  }

  Future<void> _handleTapCancel() async {
    final basildi = _basildiAn;
    if (basildi != null) {
      final gecen = DateTime.now().difference(basildi).inMilliseconds;
      final kalan = _minBasiliMs - gecen;
      if (kalan > 0) {
        await Future.delayed(Duration(milliseconds: kalan));
      }
    }
    if (mounted) setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final isClassic = widget.themeProvider?.isClassic ?? true;
    final hasGlow = widget.isPower || widget.isAccent || widget.glowColor != null;
    final effectiveIconSize = widget.iconSize > 0 ? widget.iconSize : widget.size * 0.4;

    final child = SizedBox(
      width: widget.size,
      height: widget.size,
      child: Center(
        child: widget.icon != null
            ? Icon(widget.icon, color: _effectiveIconColor, size: effectiveIconSize)
            : Text(widget.label ?? '', style: TextStyle(color: _effectiveIconColor, fontSize: widget.size * 0.3, fontWeight: FontWeight.w700)),
      ),
    );

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, _) {
          return Container(
            width: widget.size,
            height: widget.size,
            decoration: hasGlow && !_isPressed
                ? BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: _effectiveGlowColor.withValues(alpha: _glowAnimation.value * 0.25), blurRadius: 14, spreadRadius: 1)])
                : null,
            child: isClassic
                ? Neumorphic(
                    style: NeumorphicStyle(
                      shape: NeumorphicShape.flat, boxShape: const NeumorphicBoxShape.circle(),
                      depth: _isPressed ? -3 : widget.depth, intensity: 0.5, lightSource: LightSource.topLeft,
                      color: AppColors.background, shadowDarkColor: AppColors.shadowDark, shadowLightColor: AppColors.shadowLight,
                    ),
                    child: child,
                  )
                : AnimatedContainer(
                    duration: AppDurations.fast,
                    decoration: ModernPresets.circleButton(isPressed: _isPressed),
                    child: child,
                  ),
          );
        },
      ),
    );
  }
}
