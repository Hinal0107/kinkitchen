import 'package:flutter/material.dart';

class ShimmerLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final ShapeBorder? shapeBorder;

  const ShimmerLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.shapeBorder,
  });

  const ShimmerLoader.rectangular({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  }) : shapeBorder = null;

  const ShimmerLoader.circular({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = size / 2,
        shapeBorder = const CircleBorder();

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: widget.shapeBorder != null
              ? ShapeDecoration(
                  shape: widget.shapeBorder!,
                  gradient: LinearGradient(
                    begin: Alignment(_animation.value - 1, -0.3),
                    end: Alignment(_animation.value + 1, 0.3),
                    colors: const [
                      Color(0xFFEBEBF4),
                      Color(0xFFF4F4F8),
                      Color(0xFFEBEBF4),
                    ],
                    stops: const [0.1, 0.5, 0.9],
                  ),
                )
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  gradient: LinearGradient(
                    begin: Alignment(_animation.value - 1, -0.3),
                    end: Alignment(_animation.value + 1, 0.3),
                    colors: const [
                      Color(0xFFEBEBF4),
                      Color(0xFFF4F4F8),
                      Color(0xFFEBEBF4),
                    ],
                    stops: const [0.1, 0.5, 0.9],
                  ),
                ),
        );
      },
    );
  }
}
