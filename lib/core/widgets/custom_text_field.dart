import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  const CustomTextField({
    super.key,
    this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscureText : false,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          focusNode: widget.focusNode,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onFieldSubmitted,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 15,
            color: const Color(0xFF1F2937),
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon != null 
                ? Icon(widget.prefixIcon, size: 20, color: const Color(0xFF9CA3AF)) 
                : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                      color: const Color(0xFF9CA3AF),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
