import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? suffixIcon;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.suffixIcon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.04,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1.0 - _controller.value;
    final primaryColor = widget.backgroundColor ?? Theme.of(context).primaryColor;
    final txtColor = widget.textColor ?? Colors.white;

    return GestureDetector(
      onTapDown: (_) {
        if (!widget.isLoading) _controller.forward();
      },
      onTapUp: (_) {
        if (!widget.isLoading) {
          _controller.reverse();
          widget.onPressed();
        }
      },
      onTapCancel: () {
        if (!widget.isLoading) _controller.reverse();
      },
      child: Transform.scale(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: widget.isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(txtColor),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.text,
                      style: TextStyle(
                        color: txtColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    if (widget.suffixIcon != null) ...[
                      const SizedBox(width: 8),
                      Icon(
                        widget.suffixIcon,
                        color: txtColor,
                        size: 18,
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
