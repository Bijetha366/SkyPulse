import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import '../../../core/widgets/app_logo.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Accessing the controller to ensure it starts the timer
    Get.find<SplashController>();

    return const Scaffold(
      backgroundColor: Color(0xFF0F172A), // Deep elegant slate dark
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background atmospheric glows
          Positioned(
            top: -100,
            left: -100,
            child: _GlowBubble(size: 300, color: Color(0xFF0F62FE)),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: _GlowBubble(size: 250, color: Color(0xFF002D9C)),
          ),
          // Centered Brand Logo
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppLogo(
                  size: 130,
                  showText: true,
                  isLightOnDark: true,
                ),
                SizedBox(height: 48),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF78A9FF)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A subtle blur glow bubble for atmospheric styling
class _GlowBubble extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowBubble({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.08),
      ),
    );
  }
}
