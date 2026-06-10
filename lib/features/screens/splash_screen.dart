import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../navigation/main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainNavigation(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 1000),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Background Tech Grid / Dots
          Positioned.fill(
            child: CustomPaint(
              painter: _TechGridPainter(color: primaryColor.withValues(alpha: 0.05)),
            ),
          ),
          
          // Background ambient glows
          _buildAmbientGlow(top: -100, left: -100, color: primaryColor),
          _buildAmbientGlow(bottom: -150, right: -100, color: const Color(0xFF22D3EE)),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Refined High-Tech Logo
                _buildTechLogo(primaryColor)
                    .animate()
                    .scale(duration: 800.ms, curve: Curves.easeOutBack)
                    .shimmer(delay: 1000.ms, duration: 2000.ms, color: Colors.white24),
                
                const SizedBox(height: 60),
                
                // Brand Name with spacing
                Column(
                  children: [
                    Text(
                      'WaKeMe',
                      style: GoogleFonts.outfit(
                        fontSize: 56,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      'INTELLIGENT MORNINGS',
                      style: GoogleFonts.jetBrainsMono(
                        color: primaryColor,
                        letterSpacing: 4,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.5, end: 0),
                  ],
                ),
              ],
            ),
          ),
          
          // Technical Loading Bar at bottom
          Positioned(
            bottom: 80,
            left: 60,
            right: 80,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                    minHeight: 2,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white24),
                  ),
                ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1500.ms, color: primaryColor),
                const SizedBox(height: 12),
                Text(
                  'SYSTEM INITIALIZING...',
                  style: GoogleFonts.jetBrainsMono(
                    color: Colors.white24,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 1200.ms),
        ],
      ),
    );
  }

  Widget _buildAmbientGlow({double? top, double? bottom, double? left, double? right, required Color color}) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: 400,
        height: 400,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }

  Widget _buildTechLogo(Color primaryColor) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer rotating ring
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: primaryColor.withValues(alpha: 0.2), width: 1),
          ),
        ).animate(onPlay: (c) => c.repeat()).rotate(duration: 10.seconds),
        
        // Inner hexagon frames
        Transform.rotate(
          angle: 0.5,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: primaryColor, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
         .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 2.seconds, curve: Curves.easeInOut),
        
        // Central Core
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor.withValues(alpha: 0.6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: primaryColor.withValues(alpha: 0.5), blurRadius: 30, spreadRadius: -5),
            ],
          ),
          child: Center(
            child: Text(
              'W',
              style: GoogleFonts.outfit(
                fontSize: 44,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TechGridPainter extends CustomPainter {
  final Color color;
  _TechGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const spacing = 30.0;
    for (double i = 0; i < size.width; i += spacing) {
      for (double j = 0; j < size.height; j += spacing) {
        canvas.drawCircle(Offset(i, j), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
