import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart' as glass;
import '../theme/anti_gravity_theme.dart';

class AntiGravityGlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final double blur;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const AntiGravityGlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 20,
    this.blur = 20,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: glass.GlassmorphicContainer(
        width: width ?? double.infinity,
        height: height ?? 0,
        borderRadius: borderRadius,
        blur: blur,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AntiGravityTheme.pureWhite.withOpacity(0.1),
            AntiGravityTheme.pureWhite.withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AntiGravityTheme.pureWhite.withOpacity(0.3),
            AntiGravityTheme.pureWhite.withOpacity(0.1),
          ],
        ),
        child: padding != null
            ? Padding(
                padding: padding!,
                child: child,
              )
            : child,
      ),
    );
  }
}
