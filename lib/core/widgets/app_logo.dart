import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isLightOnDark;

  const AppLogo({
    super.key,
    this.size = 100,
    this.showText = false,
    this.isLightOnDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final primaryColor = isLightOnDark ? const Color(0xFF78A9FF) : colorScheme.primary;
    final onSurfaceColor = isLightOnDark ? Colors.white : colorScheme.onBackground;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor,
                primaryColor.withOpacity(0.85),
                const Color(0xFF002D9C), // Deep Indigo
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.35),
                blurRadius: size * 0.15,
                spreadRadius: 1,
                offset: Offset(0, size * 0.08),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ripple ring
              Container(
                width: size * 0.82,
                height: size * 0.82,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 1.5,
                  ),
                ),
              ),
              // Inner ripple ring
              Container(
                width: size * 0.65,
                height: size * 0.65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                    width: 1.0,
                  ),
                ),
              ),
              // Main Icon symbol (Weather Storm)
              Icon(
                Icons.storm_rounded,
                size: size * 0.48,
                color: Colors.white,
              ),
              // Subtly overlaid pulse wave lines in the base of the icon
              Positioned(
                bottom: size * 0.28,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: size * 0.08,
                      height: 2.5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Container(
                      width: size * 0.22,
                      height: 3.5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Container(
                      width: size * 0.08,
                      height: 2.5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 16),
          Text(
            'SkyPulse',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: onSurfaceColor,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'WEATHER & NEWS HUB',
            style: TextStyle(
              fontSize: 10,
              color: primaryColor,
              letterSpacing: 3.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}
