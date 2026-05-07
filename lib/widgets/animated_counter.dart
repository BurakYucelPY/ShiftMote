import 'package:flutter/material.dart';

/// Sayı değişimlerinde smooth animasyon gösteren sayaç widget'ı.
/// Kanal, ses, sıcaklık gibi değerlerde kullanılır.
class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;
  final String? suffix;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 300),
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        return Text(
          '${animatedValue.toInt()}${suffix ?? ''}',
          style: style ?? Theme.of(context).textTheme.titleLarge,
        );
      },
    );
  }
}

/// Double değerler için animasyonlu sayaç (sıcaklık gibi).
class AnimatedDoubleCounter extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final Duration duration;
  final String? suffix;
  final int decimals;

  const AnimatedDoubleCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 400),
    this.suffix,
    this.decimals = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        return Text(
          '${animatedValue.toStringAsFixed(decimals)}${suffix ?? ''}',
          style: style ?? Theme.of(context).textTheme.titleLarge,
        );
      },
    );
  }
}
