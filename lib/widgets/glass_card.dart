import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Modern elevated card widget
class GlassCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final List<Color>? gradientColors;

  const GlassCard({
    super.key,
    required this.child,
    this.color,
    this.padding,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    if (gradientColors != null) {
      return Container(
        padding: padding,
        decoration: AppTheme.gradientCard(colors: gradientColors!),
        child: child,
      );
    }

    return Container(
      padding: padding,
      decoration: AppTheme.elevatedCard(context, color: color),
      child: child,
    );
  }
}

