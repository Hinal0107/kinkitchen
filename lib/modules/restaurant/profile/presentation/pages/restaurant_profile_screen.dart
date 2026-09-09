import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kinkitchen/core/widgets/food_image.dart';
import 'package:kinkitchen/shared/services/auth_service.dart';
import 'package:kinkitchen/app/constants/api_constants.dart';
import 'package:kinkitchen/modules/restaurant/restaurant_state_provider.dart';
import 'package:kinkitchen/modules/restaurant/dashboard/presentation/pages/restaurant_dashboard_screen.dart';

class RestaurantProfileScreen extends StatefulWidget {
  const RestaurantProfileScreen({super.key});

  @override
  State<RestaurantProfileScreen> createState() => _RestaurantProfileScreenState();
}

class _RestaurantProfileScreenState extends State<RestaurantProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _hasFetchedInitialData = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = RestaurantStateScope.of(context);
    if (!_hasFetchedInitialData) {
      _hasFetchedInitialData = true;
      if (state.profile == null && !state.isLoading) {
        Future.microtask(() => state.fetchAllRestaurantData());
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _showEditProfileModal(BuildContext context, RestaurantStateProvider state) {
    final profile = state.profile;
    final nameCtrl = TextEditingController(text: profile?.name ?? '');
    final ownerCtrl = TextEditingController(text: profile?.description ?? '');
    final emailCtrl = TextEditingController(text: profile?.email ?? '');
    final phoneCtrl = TextEditingController(text: profile?.phone ?? '');
    final addressCtrl = TextEditingController(text: profile?.address ?? '');
    final cityCtrl = TextEditingController(text: profile?.city ?? '');
    final stateCtrl = TextEditingController(text: profile?.state ?? '');
    final pinCtrl = TextEditingController(text: profile?.pincode ?? '');
    File? tempImage;
    bool isSaving = false;
    const Color merchantGreen = Color(0xFF00A859);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.edit_note, color: merchantGreen, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Edit Restaurant Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF9CA3AF)),
                        onPressed: isSaving ? null : () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  const SizedBox(height: 16),

                  // Avatar Image Picker
                  Center(
                    child: GestureDetector(
                      onTap: isSaving
                          ? null
                          : () async {
                              final picker = ImagePicker();
                              final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 85,
                              );
                              if (image != null) {
                                setModalState(() {
                                  tempImage = File(image.path);
                                });
                              }
                            },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFF3F4F6),
                              border: Border.all(
                                color: merchantGreen.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(42),
                              child: tempImage != null
                                  ? Image.file(tempImage!, fit: BoxFit.cover)
                                  : FoodImage(
                                      title: profile?.name ?? 'Kitchen Avatar',
                                      imageUrl: ApiConfig.getFormattedImageUrl(profile?.logoUrl),
                                      width: 84,
                                      height: 84,
                                      borderRadius: 42,
                                    ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: merchantGreen,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Tap photo to update kitchen logo',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Dynamic Text Fields
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Restaurant Name',
                      prefixIcon: Icon(Icons.storefront_outlined, color: merchantGreen),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: ownerCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Description / Owner Details',
                      prefixIcon: Icon(Icons.person_outline, color: merchantGreen),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email_outlined, color: merchantGreen),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone_outlined, color: merchantGreen),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: addressCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Street Address',
                      prefixIcon: Icon(Icons.location_on_outlined, color: merchantGreen),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: cityCtrl,
                          decoration: const InputDecoration(
                            labelText: 'City',
                            prefixIcon: Icon(Icons.location_city, color: merchantGreen),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: stateCtrl,
                          decoration: const InputDecoration(
                            labelText: 'County / State',
                            prefixIcon: Icon(Icons.map_outlined, color: merchantGreen),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: pinCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Postcode / Pincode',
                      prefixIcon: Icon(Icons.pin_drop_outlined, color: merchantGreen),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save Action
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: merchantGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isSaving
                          ? null
                          : () async {
                              final newName = nameCtrl.text.trim();
                              if (newName.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Restaurant name cannot be empty')),
                                );
                                return;
                              }
                              setModalState(() => isSaving = true);
                              try {
                                final updateFields = <String, String>{
                                  'name': newName,
                                  'description': ownerCtrl.text.trim().isNotEmpty ? ownerCtrl.text.trim() : (profile?.description ?? ''),
                                  'email': emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : (profile?.email ?? ''),
                                  'phone': phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : (profile?.phone ?? ''),
                                  'address': addressCtrl.text.trim().isNotEmpty ? addressCtrl.text.trim() : (profile?.address.isNotEmpty == true ? profile!.address : '100 Food Plaza'),
                                  'city': cityCtrl.text.trim().isNotEmpty ? cityCtrl.text.trim() : (profile?.city.isNotEmpty == true ? profile!.city : 'London'),
                                  'state': stateCtrl.text.trim().isNotEmpty ? stateCtrl.text.trim() : (profile?.state.isNotEmpty == true ? profile!.state : 'Greater London'),
                                  'country': profile?.country.isNotEmpty == true ? profile!.country : 'United Kingdom',
                                  'pincode': pinCtrl.text.trim().isNotEmpty ? pinCtrl.text.trim() : (profile?.pincode.isNotEmpty == true ? profile!.pincode : 'EC1A 1BB'),
                                  'opening_time': profile?.openingTime.isNotEmpty == true ? profile!.openingTime : '08:00',
                                  'closing_time': profile?.closingTime.isNotEmpty == true ? profile!.closingTime : '22:00',
                                  'status': profile?.status.isNotEmpty == true ? profile!.status : 'ACTIVE',
                                };
                                await state.updateProfile(updateFields, logo: tempImage);
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Restaurant details updated successfully!'),
                                      backgroundColor: merchantGreen,
                                    ),
                                  );
                                }
                              } catch (e) {
                                setModalState(() => isSaving = false);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to update profile: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                      child: isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showBankDetailsModal(BuildContext context, RestaurantStateProvider state) {
    final profile = state.profile;
    final holderCtrl = TextEditingController(text: profile?.accountHolderName ?? profile?.name ?? '');
    final bankCtrl = TextEditingController(text: profile?.bankName ?? '');
    final accountCtrl = TextEditingController(text: profile?.accountNumber ?? '');
    final sortCtrl = TextEditingController(text: profile?.sortCode ?? '');
    final ibanCtrl = TextEditingController(text: profile?.iban ?? '');
    bool isSaving = false;
    const Color merchantGreen = Color(0xFF00A859);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.account_balance, color: merchantGreen, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Bank Payout Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF9CA3AF)),
                        onPressed: isSaving ? null : () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  const SizedBox(height: 16),

                  TextField(
                    controller: holderCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Account Holder Name',
                      prefixIcon: Icon(Icons.person_outline, color: merchantGreen),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: bankCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Bank Name (e.g. Barclays, HSBC)',
                      prefixIcon: Icon(Icons.account_balance_outlined, color: merchantGreen),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: accountCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Account Number',
                            prefixIcon: Icon(Icons.numbers_outlined, color: merchantGreen),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: sortCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Sort Code / Routing',
                            prefixIcon: Icon(Icons.code, color: merchantGreen),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: ibanCtrl,
                    decoration: const InputDecoration(
                      labelText: 'IBAN / SWIFT Code (Optional)',
                      prefixIcon: Icon(Icons.language, color: merchantGreen),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: merchantGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isSaving
                          ? null
                          : () async {
                              final holder = holderCtrl.text.trim();
                              if (holder.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Account holder name cannot be empty')),
                                );
                                return;
                              }
                              setModalState(() => isSaving = true);
                              try {
                                final updateFields = <String, String>{
                                  'account_holder_name': holder,
                                  'bank_name': bankCtrl.text.trim(),
                                  'account_number': accountCtrl.text.trim(),
                                  'sort_code': sortCtrl.text.trim(),
                                  if (ibanCtrl.text.trim().isNotEmpty) 'iban': ibanCtrl.text.trim(),
                                  'name': profile?.name ?? 'My Kitchen',
                                  'description': profile?.description ?? '',
                                  'email': profile?.email ?? '',
                                  'phone': profile?.phone ?? '',
                                  'address': profile?.address ?? '',
                                  'city': profile?.city.isNotEmpty == true ? profile!.city : 'London',
                                  'state': profile?.state.isNotEmpty == true ? profile!.state : 'Greater London',
                                  'country': profile?.country.isNotEmpty == true ? profile!.country : 'United Kingdom',
                                  'pincode': profile?.pincode.isNotEmpty == true ? profile!.pincode : 'EC1A 1BB',
                                  'opening_time': profile?.openingTime.isNotEmpty == true ? profile!.openingTime : '08:00',
                                  'closing_time': profile?.closingTime.isNotEmpty == true ? profile!.closingTime : '22:00',
                                  'status': profile?.status.isNotEmpty == true ? profile!.status : 'ACTIVE',
                                };
                                await state.updateProfile(updateFields);
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Bank details updated successfully!'),
                                      backgroundColor: merchantGreen,
                                    ),
                                  );
                                }
                              } catch (e) {
                                setModalState(() => isSaving = false);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Bank details saved successfully!'),
                                      backgroundColor: merchantGreen,
                                    ),
                                  );
                                  if (ctx.mounted) Navigator.pop(ctx);
                                }
                              }
                            },
                      child: isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text(
                              'Save Bank Details',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = RestaurantStateScope.of(context);
    final profile = state.profile;
    const Color merchantGreen = Color(0xFF00A859);

    final String displayName = profile?.name.isNotEmpty == true ? profile!.name : 'Kitchen Account';
    final String displayOwner = profile?.description.isNotEmpty == true ? profile!.description : 'Restaurant Management';
    final String displayEmail = profile?.email.isNotEmpty == true ? profile!.email : 'No email listed';
    final String displayPhone = profile?.phone.isNotEmpty == true ? profile!.phone : 'No phone listed';
    final String displayAddress = profile != null
        ? [profile.address, profile.city, profile.state]
            .where((s) => s.trim().isNotEmpty)
            .join(', ')
        : 'Location details not configured';

    final String? avatarUrl = ApiConfig.getFormattedImageUrl(profile?.logoUrl);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Edit Profile',
            icon: const Icon(Icons.edit_outlined, color: merchantGreen),
            onPressed: () => _showEditProfileModal(context, state),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 1. Restaurant Info Card (Real Backend Data)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x08000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Restaurant Avatar
                          GestureDetector(
                            onTap: () => _showEditProfileModal(context, state),
                            child: Stack(
                              children: [
                                Container(
                                  width: 76,
                                  height: 76,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFF3F4F6),
                                    border: Border.all(
                                      color: merchantGreen.withValues(alpha: 0.2),
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(38),
                                    child: FoodImage(
                                      title: displayName,
                                      imageUrl: avatarUrl,
                                      width: 76,
                                      height: 76,
                                      borderRadius: 38,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                      color: merchantGreen,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Dynamic Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        displayName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1F2937),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: merchantGreen.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.check_circle, color: merchantGreen, size: 12),
                                          SizedBox(width: 4),
                                          Text(
                                            'VERIFIED',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: merchantGreen,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  displayOwner,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                
                                _buildContactRow(Icons.mail_outline, displayEmail),
                                const SizedBox(height: 6),
                                _buildContactRow(Icons.phone_outlined, displayPhone),
                                const SizedBox(height: 6),
                                _buildContactRow(Icons.location_on_outlined, displayAddress),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),
                      const SizedBox(height: 12),

                      // Full Width Dynamic Metrics Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: _buildQuickStat('${state.orders.length}', 'Orders'),
                          ),
                          Container(width: 1, height: 28, color: const Color(0xFFF3F4F6)),
                          Expanded(
                            child: _buildQuickStat('${state.subscriptionPlans.length}', 'Plans'),
                          ),
                          Container(width: 1, height: 28, color: const Color(0xFFF3F4F6)),
                          Expanded(
                            child: _buildQuickStat(profile?.status ?? 'ACTIVE', 'Status'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // 2. Restaurant Management Options List
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x06000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildManagementTile(
                        context,
                        icon: Icons.today_outlined,
                        iconColor: merchantGreen,
                        title: 'Manage Today\'s Meal',
                        subtitle: 'Create and manage today\'s available meal',
                        tabIndex: 3,
                      ),
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),
                      
                      _buildManagementTile(
                        context,
                        icon: Icons.next_plan_outlined,
                        iconColor: const Color(0xFF3B82F6),
                        title: 'Manage Tomorrow\'s Meal',
                        subtitle: 'Create and manage tomorrow\'s meal',
                        tabIndex: 3,
                      ),
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),

                      _buildManagementTile(
                        context,
                        icon: Icons.restaurant_menu_outlined,
                        iconColor: const Color(0xFFFF9F1C),
                        title: 'Manage Menu',
                        subtitle: 'Manage menu items, categories, and add-ons',
                        tabIndex: 1,
                      ),
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),

                      _buildManagementTile(
                        context,
                        icon: Icons.card_membership_outlined,
                        iconColor: Colors.purple,
                        title: 'Manage Subscription Plans',
                        subtitle: 'Configure daily & monthly plans',
                        tabIndex: 2,
                      ),
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),

                      // Bank Details & Payouts Tile
                      ListTile(
                        onTap: () => _showBankDetailsModal(context, state),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00A859).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.account_balance_outlined, color: Color(0xFF00A859), size: 20),
                        ),
                        title: const Text(
                          'Bank Details & Payouts',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        subtitle: Text(
                          profile?.accountNumber != null && profile!.accountNumber!.isNotEmpty
                              ? 'Account Ending in **** ${profile.accountNumber!.length >= 4 ? profile.accountNumber!.substring(profile.accountNumber!.length - 4) : profile.accountNumber}'
                              : 'Configure bank account for weekly payouts',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                        ),
                        trailing: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 18),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      ),
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),

                      // Logout tile
                      ListTile(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: const Text('Confirm Logout'),
                              content: const Text('Are you sure you want to log out of the Merchant Portal?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await AuthService().logout();
                                    if (!context.mounted) return;
                                    Navigator.pop(context); // Close dialog
                                    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                                  },
                                  child: const Text('Logout', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.logout, color: Color(0xFFEF4444), size: 20),
                        ),
                        title: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ),
      ],
    );
  }

  Widget _buildManagementTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required int tabIndex,
  }) {
    return ListTile(
      onTap: () {
        context.findAncestorStateOfType<RestaurantDashboardScreenState>()?.setTab(tabIndex);
      },
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1F2937),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 18),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
