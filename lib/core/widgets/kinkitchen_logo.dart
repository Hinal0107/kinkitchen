import 'package:flutter/material.dart';

class KinKitchenLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final String? subtitle;

  const KinKitchenLogo({
    super.key,
    this.size = 80.0,
    this.showText = true,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Brand Logo Image Asset
        Image.asset(
          'assets/images/logo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: LogoPainter(),
              ),
            );
          },
        ),
        if (showText && subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ],
    );
  }
}

class LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    
    // Draw Orange Box
    final boxPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF7A00), Color(0xFFFF4D00)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(w * 0.1, h * 0.3, w * 0.8, h * 0.6))
      ..style = PaintingStyle.fill;
      
    final boxRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.15, h * 0.35, w * 0.7, h * 0.55),
      Radius.circular(w * 0.15),
    );
    canvas.drawRRect(boxRect, boxPaint);
    
    // Draw Box flap/ribbon
    final tapePaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;
      
    canvas.drawRect(
      Rect.fromLTWH(w * 0.44, h * 0.35, w * 0.12, h * 0.55),
      tapePaint,
    );

    // Draw Chef symbols (White Fork and Knife)
    final symbolPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round;
      
    // Fork Handle
    canvas.drawLine(
      Offset(w * 0.38, h * 0.56),
      Offset(w * 0.38, h * 0.72),
      symbolPaint,
    );
    // Fork base curve and prongs
    canvas.drawLine(Offset(w * 0.34, h * 0.54), Offset(w * 0.34, h * 0.62), symbolPaint);
    canvas.drawLine(Offset(w * 0.42, h * 0.54), Offset(w * 0.42, h * 0.62), symbolPaint);
    canvas.drawLine(Offset(w * 0.34, h * 0.62), Offset(w * 0.42, h * 0.62), symbolPaint);
    
    // Knife Handle
    canvas.drawLine(
      Offset(w * 0.62, h * 0.56),
      Offset(w * 0.62, h * 0.72),
      symbolPaint,
    );
    // Knife Blade fill
    final knifePath = Path()
      ..moveTo(w * 0.58, h * 0.54)
      ..quadraticBezierTo(w * 0.58, h * 0.62, w * 0.62, h * 0.62)
      ..lineTo(w * 0.62, h * 0.54)
      ..close();
    canvas.drawPath(
      knifePath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    // Draw Sprout / Leaf on Top (Green)
    final leafPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00C853), Color(0xFF009624)],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(Rect.fromLTWH(w * 0.25, h * 0.05, w * 0.5, h * 0.3))
      ..style = PaintingStyle.fill;
      
    final leafPath = Path();
    leafPath.moveTo(w * 0.5, h * 0.35);
    // Left leaf arc
    leafPath.cubicTo(
      w * 0.25, h * 0.25,
      w * 0.35, h * 0.05,
      w * 0.5, h * 0.12,
    );
    // Right leaf arc
    leafPath.cubicTo(
      w * 0.65, h * 0.05,
      w * 0.75, h * 0.25,
      w * 0.5, h * 0.35,
    );
    leafPath.close();
    canvas.drawPath(leafPath, leafPaint);
    
    // Inner leaf vein
    final veinPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.015
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(w * 0.5, h * 0.32),
      Offset(w * 0.5, h * 0.18),
      veinPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
