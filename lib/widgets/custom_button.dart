import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RemoteButton extends StatefulWidget {
  final IconData? icon;
  final String? label;
  final VoidCallback onPressed;
  final double size;
  final bool isAccent;
  final bool isPower;
  final Color? color;

  const RemoteButton({
    super.key,
    this.icon,
    this.label,
    required this.onPressed,
    this.size = 56,
    this.isAccent = false,
    this.isPower = false,
    this.color,
  });

  @override
  State<RemoteButton> createState() => _RemoteButtonState();
}

class _RemoteButtonState extends State<RemoteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.color ??
        (widget.isPower
            ? AppColors.error
            : widget.isAccent
                ? AppColors.accent
                : AppColors.surfaceLight);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: _handleTap,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(widget.size > 60 ? 20 : 14),
            border: Border.all(
              color: widget.isPower
                  ? AppColors.error.withValues(alpha: 0.3)
                  : widget.isAccent
                      ? AppColors.accent.withValues(alpha: 0.3)
                      : AppColors.cardBorder,
              width: 1,
            ),
            boxShadow: widget.isPower || widget.isAccent
                ? [
                    BoxShadow(
                      color: (widget.isPower ? AppColors.error : AppColors.accent)
                          .withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: widget.icon != null
                ? Icon(
                    widget.icon,
                    color: widget.isPower || widget.isAccent
                        ? Colors.white
                        : AppColors.textPrimary,
                    size: widget.size * 0.4,
                  )
                : Text(
                    widget.label ?? '',
                    style: TextStyle(
                      color: widget.isPower || widget.isAccent
                          ? Colors.white
                          : AppColors.textPrimary,
                      fontSize: widget.size * 0.3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
