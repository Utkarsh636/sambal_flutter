import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/storage/local_storage.dart';
import '../../core/theme/app_theme.dart';
import '../shell/shell_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _navigate();
  }

  Future<void> _navigate() async {
    await Future<void>.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    final destination = LocalStorage.hasCompletedOnboarding
        ? const ShellScreen()
        : const OnboardingScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => destination,
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final subtitleColor = isDark
        ? AppTheme.mutedSlate
        : AppTheme.warmInk.withValues(alpha: 0.72);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return SizedBox(
                    width: 260,
                    height: 300,
                    child: CustomPaint(
                      painter: _FamilyTreePainter(
                        progress: _controller.value,
                        isDark: isDark,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Sambal',
                style: textTheme.displaySmall?.copyWith(
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'हर कदम पर साथ',
                style: textTheme.titleMedium?.copyWith(
                  color: isDark ? AppTheme.ceruleanBlue : AppTheme.warmInk,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'A gentle guide through every next step.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: subtitleColor),
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final wave = (math.sin(
                                (_controller.value * math.pi * 2) -
                                    (index * 0.8),
                              ) +
                              1) /
                          2;

                      final color1 = isDark ? AppTheme.darkRaised : AppTheme.mochaCream;
                      final color2 = isDark ? AppTheme.ceruleanBlue : AppTheme.deepBurgundy;

                      return Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: Color.lerp(color1, color2, wave),
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                'आपके लिए सही रास्ता तैयार कर रहे हैं…',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: subtitleColor),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _FamilyTreePainter extends CustomPainter {
  const _FamilyTreePainter({required this.progress, required this.isDark});

  final double progress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    final trunkColor = isDark
        ? AppTheme.ceruleanBlue.withValues(alpha: 0.5)
        : AppTheme.deepBurgundy.withValues(alpha: 0.3);
    final branchColor = isDark
        ? AppTheme.ceruleanBlue.withValues(alpha: 0.35)
        : AppTheme.deepBurgundy.withValues(alpha: 0.22);
    final personColor = isDark ? AppTheme.ceruleanBlue : AppTheme.deepBurgundy;
    final personFill = isDark
        ? AppTheme.ceruleanBlue.withValues(alpha: 0.25)
        : AppTheme.mochaCream.withValues(alpha: 0.7);
    final leafColor = isDark ? AppTheme.neonRose : AppTheme.mochaCream;
    final leafVeinColor = isDark
        ? AppTheme.neonRose.withValues(alpha: 0.6)
        : AppTheme.deepBurgundy.withValues(alpha: 0.6);
    final groundColor = isDark
        ? AppTheme.ceruleanBlue.withValues(alpha: 0.2)
        : AppTheme.deepBurgundy.withValues(alpha: 0.14);

    final trunkPaint = Paint()
      ..color = trunkColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final trunk = Path()
      ..moveTo(cx, size.height - 30)
      ..quadraticBezierTo(cx - 5, size.height * 0.5, cx, size.height * 0.32);

    canvas.drawPath(trunk, trunkPaint);

    final branchPaint = Paint()
      ..color = branchColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final leftBranch = Path()
      ..moveTo(cx, size.height * 0.42)
      ..quadraticBezierTo(cx - 50, size.height * 0.32, cx - 75, size.height * 0.22);
    canvas.drawPath(leftBranch, branchPaint);

    final rightBranch = Path()
      ..moveTo(cx, size.height * 0.38)
      ..quadraticBezierTo(cx + 50, size.height * 0.28, cx + 78, size.height * 0.18);
    canvas.drawPath(rightBranch, branchPaint);

    final upperLeft = Path()
      ..moveTo(cx - 30, size.height * 0.35)
      ..quadraticBezierTo(cx - 55, size.height * 0.22, cx - 40, size.height * 0.12);
    canvas.drawPath(upperLeft, branchPaint);

    final upperRight = Path()
      ..moveTo(cx + 25, size.height * 0.33)
      ..quadraticBezierTo(cx + 48, size.height * 0.18, cx + 30, size.height * 0.08);
    canvas.drawPath(upperRight, branchPaint);

    _drawPerson(canvas, cx - 75, size.height * 0.18, 12, personColor, personFill);
    _drawPerson(canvas, cx + 78, size.height * 0.14, 12, personColor, personFill);
    _drawPerson(canvas, cx - 40, size.height * 0.08, 12, personColor, personFill);
    _drawPerson(canvas, cx + 30, size.height * 0.04, 12, personColor, personFill);

    final fall = Curves.easeInOut.transform(progress);
    final startX = cx;
    final startY = size.height * 0.32;
    final endY = size.height - 50;

    final leafX = startX + math.sin(progress * math.pi * 2.5) * 30;
    final leafY = startY + (fall * (endY - startY));

    final departAlpha = (1.0 - fall).clamp(0.0, 1.0);
    if (departAlpha > 0.05) {
      _drawPerson(
        canvas,
        cx,
        startY - 4,
        12,
        personColor.withValues(alpha: departAlpha * 0.6),
        personFill.withValues(alpha: departAlpha * 0.4),
      );
    }

    canvas.save();
    canvas.translate(leafX, leafY);
    canvas.rotate(-0.5 + (progress * 2.8));

    final leaf = Path()
      ..moveTo(0, -18)
      ..cubicTo(20, -15, 20, 5, 0, 24)
      ..cubicTo(-20, 5, -20, -15, 0, -18)
      ..close();

    canvas.drawPath(
      leaf,
      Paint()
        ..color = leafColor.withValues(alpha: 0.85)
        ..style = PaintingStyle.fill,
    );

    final veinPaint = Paint()
      ..color = leafVeinColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(0, -12), const Offset(0, 18), veinPaint);
    canvas.drawLine(const Offset(0, 0), const Offset(9, -7), veinPaint);
    canvas.drawLine(const Offset(0, 6), const Offset(-9, 0), veinPaint);

    canvas.restore();

    final groundPaint = Paint()
      ..color = groundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final ground = Path()
      ..moveTo(cx - 70, size.height - 28)
      ..quadraticBezierTo(cx, size.height - 16, cx + 70, size.height - 28);

    canvas.drawPath(ground, groundPaint);
  }

  void _drawPerson(
    Canvas canvas,
    double x,
    double y,
    double radius,
    Color stroke,
    Color fill,
  ) {
    canvas.drawCircle(
      Offset(x, y - radius * 0.4),
      radius * 0.42,
      Paint()
        ..color = fill
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(x, y - radius * 0.4),
      radius * 0.42,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    final bodyPaint = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(x, y + radius * 0.1),
      Offset(x, y + radius * 0.85),
      bodyPaint,
    );

    canvas.drawLine(
      Offset(x - radius * 0.4, y + radius * 0.35),
      Offset(x + radius * 0.4, y + radius * 0.35),
      bodyPaint,
    );

    canvas.drawLine(
      Offset(x, y + radius * 0.85),
      Offset(x - radius * 0.3, y + radius * 1.3),
      bodyPaint,
    );
    canvas.drawLine(
      Offset(x, y + radius * 0.85),
      Offset(x + radius * 0.3, y + radius * 1.3),
      bodyPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FamilyTreePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}
