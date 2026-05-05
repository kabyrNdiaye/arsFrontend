import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PetalSuccessAnimation extends StatefulWidget {
  final VoidCallback onComplete;

  const PetalSuccessAnimation({Key? key, required this.onComplete}) : super(key: key);

  @override
  _PetalSuccessAnimationState createState() => _PetalSuccessAnimationState();
}

class _PetalSuccessAnimationState extends State<PetalSuccessAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _petalAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    _petalAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) widget.onComplete();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Les pétales qui explosent
              CustomPaint(
                size: Size(300.w, 300.w),
                painter: PetalPainter(
                  progress: _petalAnimation.value,
                  color: const Color(0xFF7C39D3),
                ),
              ),
              // Le cercle de succès central
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: const Color(0xFF7C39D3),
                    size: 50.sp,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PetalPainter extends CustomPainter {
  final double progress;
  final Color color;

  PetalPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color.withOpacity((1 - progress).clamp(0, 1))
      ..style = PaintingStyle.fill;

    const petalCount = 12;
    final maxRadius = size.width / 2;
    final currentRadius = maxRadius * progress;

    for (int i = 0; i < petalCount; i++) {
      final angle = (i * 2 * math.pi) / petalCount;
      final petalCenter = Offset(
        center.dx + math.cos(angle) * currentRadius,
        center.dy + math.sin(angle) * currentRadius,
      );

      // Dessiner un pétale (forme d'ellipse pointue)
      canvas.save();
      canvas.translate(petalCenter.dx, petalCenter.dy);
      canvas.rotate(angle + math.pi / 2);
      
      final path = Path();
      final petalWidth = 10.w * (1 - progress);
      final petalHeight = 25.w * (1 - progress);
      
      path.moveTo(0, -petalHeight / 2);
      path.quadraticBezierTo(petalWidth, 0, 0, petalHeight / 2);
      path.quadraticBezierTo(-petalWidth, 0, 0, -petalHeight / 2);
      
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant PetalPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
