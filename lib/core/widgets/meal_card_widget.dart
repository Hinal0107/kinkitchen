import 'package:flutter/material.dart';
import 'food_image.dart';

class MealCardWidget extends StatelessWidget {
  final String title;
  final String? subtitleTag;
  final String? imageUrl;
  final double price;
  final double? discountPrice;
  final double taxPercentage;
  final String description;
  final List<String>? items;
  final bool isVeg;
  final bool isActive;
  final String currencySymbol;
  final VoidCallback? onUpdate;
  final VoidCallback? onDelete;
  final ValueChanged<bool>? onToggleActive;
  final int? availableQty;
  final int? totalQty;

  const MealCardWidget({
    super.key,
    required this.title,
    this.subtitleTag,
    this.imageUrl,
    required this.price,
    this.discountPrice,
    this.taxPercentage = 5.0,
    this.description = '',
    this.items,
    this.isVeg = true,
    this.isActive = true,
    this.currencySymbol = '£',
    this.onUpdate,
    this.onDelete,
    this.onToggleActive,
    this.availableQty,
    this.totalQty,
  });

  List<String> get _itemChips {
    if (items != null && items!.isNotEmpty) {
      return items!;
    }
    if (description.trim().isNotEmpty) {
      // Split description by commas, newlines, or bullets
      final rawList = description.split(RegExp(r'[,;\n•+]'));
      final cleaned = rawList
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (cleaned.isNotEmpty) {
        return cleaned;
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final bool hasDiscount = discountPrice != null &&
        discountPrice! > 0 &&
        discountPrice! < price;
    final double discountAmount = hasDiscount ? (price - discountPrice!) : 0.0;
    final double discountPercent =
        hasDiscount ? ((discountAmount / price) * 100) : 0.0;

    final double effectivePrice = hasDiscount ? discountPrice! : price;
    final double taxAmount = effectivePrice * (taxPercentage / 100);
    final double finalPrice = effectivePrice + taxAmount;

    final String displayBadgePrice =
        '$currencySymbol${effectivePrice.toStringAsFixed(effectivePrice.truncateToDouble() == effectivePrice ? 0 : 2)}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isActive ? const Color(0xFFE5E7EB) : const Color(0xFFF3F4F6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── 1. TOP IMAGE WITH PRICE BADGE & VEG INDICATOR ─────────────────
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: FoodImage(
                  title: title,
                  imageUrl: imageUrl,
                  height: 190,
                  width: double.infinity,
                  borderRadius: 0,
                ),
              ),
              // Top-Left Price Badge
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayBadgePrice,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF374151),
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text(
                          '$currencySymbol${price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                            decoration: TextDecoration.lineThrough,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Top-Right Veg / Status Badge
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildVegIndicator(isVeg),
                      const SizedBox(width: 6),
                      Text(
                        isVeg ? 'VEG' : 'NON-VEG',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isVeg
                              ? const Color(0xFF00A859)
                              : const Color(0xFF8B0000),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ─── 2. CARD CONTENT (TAG, TITLE, ITEM CHIPS) ─────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subtitle / Category Tag (e.g., MEAL 1)
                if (subtitleTag != null && subtitleTag!.isNotEmpty) ...[
                  Text(
                    subtitleTag!.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF8B4513), // Rust/Brown accent
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],

                // Main Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                    height: 1.25,
                  ),
                ),

                // Item Chips / Tags (Roti, Shak, Dal Fry, Jira Rice, etc.)
                if (_itemChips.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _itemChips.map((item) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F5F4),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFEADBCE).withOpacity(0.6),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4A3E3D),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                const SizedBox(height: 12),

                // ─── 3. DISCOUNT AMOUNT & TAXES DISPLAY SECTION ───────────────
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFF3F4F6)),
                  ),
                  child: Column(
                    children: [
                      // Base Price Row
                      _buildPriceRow(
                        label: 'Base Price',
                        value: '$currencySymbol${price.toStringAsFixed(2)}',
                      ),

                      // Discount Amount Row (if available)
                      if (hasDiscount) ...[
                        const SizedBox(height: 4),
                        _buildPriceRow(
                          label: 'Discount (${discountPercent.toStringAsFixed(0)}% OFF)',
                          value: '- $currencySymbol${discountAmount.toStringAsFixed(2)}',
                          valueColor: const Color(0xFF00A859),
                          isBold: true,
                        ),
                      ],

                      // Taxes / GST Row
                      const SizedBox(height: 4),
                      _buildPriceRow(
                        label: 'Taxes & GST (${taxPercentage.toStringAsFixed(0)}%)',
                        value: '+ $currencySymbol${taxAmount.toStringAsFixed(2)}',
                        valueColor: const Color(0xFF4B5563),
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                      ),

                      // Final Total Row
                      _buildPriceRow(
                        label: 'Total Payable Price',
                        value: '$currencySymbol${finalPrice.toStringAsFixed(2)}',
                        labelColor: const Color(0xFF1F2937),
                        valueColor: const Color(0xFF1F2937),
                        isBold: true,
                        fontSize: 13.5,
                      ),
                    ],
                  ),
                ),

                // Availability Quantity info if provided
                if (availableQty != null && totalQty != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Availability: $availableQty / $totalQty meals left',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: availableQty! > 0
                              ? const Color(0xFF00A859)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                      if (onToggleActive != null)
                        Row(
                          children: [
                            Text(
                              isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isActive
                                    ? const Color(0xFF00A859)
                                    : const Color(0xFF9CA3AF),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                activeColor: const Color(0xFF00A859),
                                value: isActive,
                                onChanged: onToggleActive,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],

                const SizedBox(height: 14),

                // ─── 4. ACTION BUTTONS (UPDATE & DELETE) ──────────────────────
                Row(
                  children: [
                    // Update / Exchange Edit Button
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(
                              color: Color(0xFFD1D5DB),
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          onPressed: onUpdate,
                          child: const Text(
                            'Update',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (onDelete != null) ...[
                      const SizedBox(width: 12),

                      // Delete / Trash Icon Button
                      SizedBox(
                        height: 46,
                        width: 72,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFF5F5),
                            side: const BorderSide(
                              color: Color(0xFFFECACA),
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: EdgeInsets.zero,
                            elevation: 0,
                          ),
                          onPressed: onDelete,
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Color(0xFFDC2626),
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVegIndicator(bool isVeg) {
    final Color color =
        isVeg ? const Color(0xFF00A859) : const Color(0xFF8B0000);
    return Container(
      width: 13,
      height: 13,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.2),
        borderRadius: BorderRadius.circular(3),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 5,
        height: 5,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  Widget _buildPriceRow({
    required String label,
    required String value,
    Color labelColor = const Color(0xFF6B7280),
    Color valueColor = const Color(0xFF374151),
    bool isBold = false,
    double fontSize = 12.0,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            color: labelColor,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            color: valueColor,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
