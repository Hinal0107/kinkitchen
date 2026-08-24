import 'package:flutter/material.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;

  const ResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          return child;
        }

        // Desktop/Web layout: Show beautiful device simulator in dot-grid canvas
        return Scaffold(
          backgroundColor: const Color(0xFF111115),
          body: Stack(
            children: [
              // 1. Dot Grid Background
              Positioned.fill(
                child: CustomPaint(
                  painter: DotGridPainter(),
                ),
              ),
              
              // 2. Centered Device Frame
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: AspectRatio(
                    aspectRatio: 9 / 19.5, // Standard modern smartphone aspect ratio
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E24),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: const Color(0xFF2D2D37),
                          width: 12, // Bezel width
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Column(
                          children: [
                            // 3. Status Bar Simulation
                            const SimulatorStatusBar(),
                            // 4. Actual Child App Content
                            Expanded(
                              child: child,
                            ),
                            // 5. Home Indicator Bar Simulation
                            const SimulatorHomeIndicator(),
                          ],
                        ),
                      ),
                    ),
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

class DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2C2C35)
      ..strokeWidth = 1.0;

    const double spacing = 24.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SimulatorStatusBar extends StatelessWidget {
  const SimulatorStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '09:41',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          Row(
            children: [
              const Icon(
                Icons.signal_cellular_4_bar,
                size: 13,
                color: Colors.black,
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.wifi,
                size: 13,
                color: Colors.black,
              ),
              const SizedBox(width: 4),
              // Battery Icon
              Container(
                width: 20,
                height: 10,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1.0),
                  borderRadius: BorderRadius.circular(3),
                ),
                padding: const EdgeInsets.all(1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SimulatorHomeIndicator extends StatelessWidget {
  const SimulatorHomeIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      color: Colors.white,
      alignment: Alignment.center,
      child: Container(
        width: 120,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(2.5),
        ),
      ),
    );
  }
}
