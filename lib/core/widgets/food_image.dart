import 'dart:io';
import 'package:flutter/material.dart';
import '../config/api_config.dart';

class FoodImage extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final double width;
  final double height;
  final double borderRadius;

  const FoodImage({
    super.key,
    required this.title,
    this.imageUrl,
    this.width = double.infinity,
    this.height = 160,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final formattedUrl = ApiConfig.getFormattedImageUrl(imageUrl);
    final bool hasImage = formattedUrl != null && formattedUrl.trim().isNotEmpty;

    Widget imageWidget;

    if (!hasImage) {
      imageWidget = _buildCameraPlaceholder();
    } else if (formattedUrl.startsWith('file://') ||
        (!formattedUrl.startsWith('http://') &&
            !formattedUrl.startsWith('https://') &&
            File(formattedUrl).existsSync())) {
      final filePath = formattedUrl.startsWith('file://')
          ? formattedUrl.replaceFirst('file://', '')
          : formattedUrl;
      imageWidget = Image.file(
        File(filePath),
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildCameraPlaceholder(),
      );
    } else {
      imageWidget = Image.network(
        formattedUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('FoodImage load error for URL "$formattedUrl": $error');
          return _buildCameraPlaceholder();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFF15A22),
              ),
            ),
          );
        },
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: imageWidget,
      ),
    );
  }

  Widget _buildCameraPlaceholder() {
    final double iconSize = (height * 0.35).clamp(18.0, 36.0);
    return Center(
      child: Icon(
        Icons.camera_alt_outlined,
        color: const Color(0xFF9CA3AF),
        size: iconSize,
      ),
    );
  }
}
