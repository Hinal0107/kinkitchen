import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kinkitchen/core/widgets/food_image.dart';
import 'package:kinkitchen/shared/services/auth_service.dart';
import 'package:kinkitchen/modules/customer/tiffin_state_provider.dart';
import 'package:kinkitchen/modules/customer/home/presentation/pages/dashboard_screen.dart';
import 'package:kinkitchen/modules/customer/orders/presentation/pages/customer_orders_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _hasFetchedProfile = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = TiffinStateScope.of(context);
    if (!_hasFetchedProfile) {
      _hasFetchedProfile = true;
      if (state.currentUser == null && !state.isLoading) {
        state.fetchCurrentUserProfile();
      }
    }
  }

  void _showEditProfileModal(BuildContext context, TiffinStateProvider state) {
    final user = state.currentUser;
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final phoneCtrl = TextEditingController(text: user?.phone ?? '');
    final emailCtrl = TextEditingController(text: user?.email ?? '');
    File? pickedImageFile;
    bool isSaving = false;
    const Color brandOrange = Color(0xFFFF5E00);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Edit Profile',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: isSaving ? null : () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Avatar Picker
                  GestureDetector(
                    onTap: isSaving
                        ? null
                        : () async {
                            final picker = ImagePicker();
                            final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                            if (image != null) {
                              setModalState(() {
                                pickedImageFile = File(image.path);
                              });
                            }
                          },
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(44),
                          child: Container(
                            width: 88,
                            height: 88,
                            color: const Color(0xFFF3F4F6),
                            child: pickedImageFile != null
                                ? Image.file(pickedImageFile!, fit: BoxFit.cover)
                                : FoodImage(
                                    title: user?.name ?? 'User Avatar',
                                    imageUrl: user?.avatarUrl,
                                    width: 88,
                                    height: 88,
                                    borderRadius: 44,
                                  ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: brandOrange,
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
                  const SizedBox(height: 8),
                  Text(
                    'Tap photo to change profile picture',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: emailCtrl,
                    readOnly: true,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: const Icon(Icons.email_outlined),
                      suffixIcon: const Icon(Icons.lock_outline, size: 18),
                      fillColor: Colors.grey.shade100,
                      filled: true,
                      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandOrange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: isSaving
                          ? null
                          : () async {
                              final name = nameCtrl.text.trim();
                              final phone = phoneCtrl.text.trim();
                              if (name.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Name cannot be empty')),
                                );
                                return;
                              }
                              setModalState(() => isSaving = true);
                              try {
                                await state.updateUserProfile(name: name, phone: phone, image: pickedImageFile);
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Profile updated successfully!')),
                                  );
                                }
                              } catch (e) {
                                setModalState(() => isSaving = false);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to update profile: $e'), backgroundColor: Colors.red),
                                  );
                                }
                              }
                            },
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
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

  void _showDeleteAccountConfirmation(BuildContext context, TiffinStateProvider state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'Are you sure you want to permanently delete your account and profile data? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await state.deleteUserAccount();
                await AuthService().logout();
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Your account has been deleted.')),
                  );
                }
              } catch (e) {
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete account: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Delete Account', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showPaymentMethodsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Payment Methods',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.credit_card, color: Color(0xFFFF5E00), size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Worldpay Simulated Gateway', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        SizedBox(height: 2),
                        Text('Credit / Debit Cards & Direct Bank Pay', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                      ],
                    ),
                  ),
                  Icon(Icons.check_circle, color: Color(0xFF00A859), size: 20),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Securely processed via Worldpay Gateway integration.',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showHelpSupportModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Help & Support',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.email_outlined, color: Color(0xFFFF5E00)),
              title: const Text('Email Customer Care'),
              subtitle: const Text('support@kinkitchen.com'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.phone_outlined, color: Color(0xFF00A859)),
              title: const Text('Call Support Hotline'),
              subtitle: const Text('+44 800 123 4567 (Mon-Sat 8AM-8PM)'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.question_answer_outlined, color: Color(0xFF6366F1)),
              title: const Text('Frequently Asked Questions'),
              subtitle: const Text('Learn about subscriptions & delivery'),
              onTap: () => Navigator.pop(ctx),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = TiffinStateScope.of(context);
    const Color brandOrange = Color(0xFFFF5E00);
    const Color brandGreen = Color(0xFF00A859);
    final user = state.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF374151)),
            onPressed: () => _showEditProfileModal(context, state),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Logged-in User Profile Header matching design image
            Column(
              children: [
                GestureDetector(
                  onTap: () => _showEditProfileModal(context, state),
                  child: Stack(
                    children: [
                      FoodImage(
                        title: user?.name ?? 'User Avatar',
                        imageUrl: user?.avatarUrl,
                        width: 88,
                        height: 88,
                        borderRadius: 44,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: brandOrange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  (user?.name != null && user!.name.isNotEmpty) ? user.name : 'John Doe',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (user?.phone != null && user!.phone.isNotEmpty) ? user.phone : '+1 555 000 0000',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),

                // Member Status Badge matching design image
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Premium Member',
                    style: TextStyle(
                      color: brandOrange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Options List matching exact design image
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
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
                  _buildOptionTile(
                    icon: Icons.calendar_month_outlined,
                    iconColor: brandGreen,
                    title: 'My Subscriptions',
                    subtitle: state.activeSubscription == 'None'
                        ? 'Active: Weekly Standard'
                        : 'Active: ${state.activeSubscription}',
                    onTap: () {
                      context.findAncestorStateOfType<DashboardScreenState>()?.setTab(2);
                    },
                  ),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),

                  _buildOptionTile(
                    icon: Icons.history,
                    iconColor: brandOrange,
                    title: 'Order History',
                    subtitle: 'View active & past meal orders',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CustomerOrdersScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),

                  _buildOptionTile(
                    icon: Icons.location_on_outlined,
                    iconColor: brandOrange,
                    title: 'Delivery Addresses',
                    subtitle: state.selectedAddress != null
                        ? '${state.selectedAddress!.label}: ${state.selectedAddress!.line1}'
                        : 'Manage saved delivery addresses',
                    onTap: () => _showAddressManagerModal(context, state),
                  ),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),

                  _buildOptionTile(
                    icon: Icons.credit_card_outlined,
                    iconColor: brandOrange,
                    title: 'Payment Methods',
                    subtitle: 'Cards & saved payment options',
                    onTap: () => _showPaymentMethodsModal(context),
                  ),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),

                  _buildOptionTile(
                    icon: Icons.help_outline,
                    iconColor: brandOrange,
                    title: 'Help & Support',
                    subtitle: 'FAQs & customer support hotline',
                    onTap: () => _showHelpSupportModal(context),
                  ),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),

                  _buildOptionTile(
                    icon: Icons.gavel_outlined,
                    iconColor: brandOrange,
                    title: 'Terms & Conditions',
                    subtitle: 'Service rules & user agreement',
                    onTap: () {
                      Navigator.pushNamed(context, '/terms-and-conditions');
                    },
                  ),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),

                  // Logout option matching design image
                  _buildOptionTile(
                    icon: Icons.logout,
                    iconColor: const Color(0xFFEF4444),
                    title: 'Logout',
                    titleColor: const Color(0xFFEF4444),
                    showChevron: false,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm Logout'),
                          content: const Text('Are you sure you want to log out?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                state.clearCart();
                                await AuthService().logout();
                                if (!context.mounted) return;
                                Navigator.pop(context);
                                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                              },
                              child: const Text('Logout', style: TextStyle(color: Color(0xFFEF4444))),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),

                  // Delete Account option
                  _buildOptionTile(
                    icon: Icons.delete_forever_outlined,
                    iconColor: const Color(0xFFEF4444),
                    title: 'Delete Account',
                    titleColor: const Color(0xFFEF4444),
                    subtitle: 'Permanently remove profile & data',
                    showChevron: false,
                    onTap: () => _showDeleteAccountConfirmation(context, state),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Color titleColor = const Color(0xFF1F2937),
    bool showChevron = true,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.bold,
          color: titleColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            )
          : null,
      trailing: showChevron
          ? const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 18)
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showAddressManagerModal(BuildContext context, TiffinStateProvider state) {
    final labelCtrl = TextEditingController(text: 'Home');
    final line1Ctrl = TextEditingController();
    final cityCtrl = TextEditingController(text: 'London');
    final stateCtrl = TextEditingController(text: 'England');
    final pinCtrl = TextEditingController(text: 'W1U 7EU');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Manage Delivery Addresses',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(),
                if (state.addresses.isNotEmpty) ...[
                  const Text('Saved Addresses:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 140),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.addresses.length,
                      itemBuilder: (c, i) {
                        final addr = state.addresses[i];
                        final isSel = state.selectedAddress?.id == addr.id;
                        return ListTile(
                          dense: true,
                          title: Text('${addr.label}: ${addr.line1}'),
                          subtitle: Text('${addr.city}, ${addr.state} - ${addr.pincode}'),
                          trailing: isSel
                              ? const Icon(Icons.check_circle, color: Color(0xFFFF5E00), size: 20)
                              : null,
                          onTap: () {
                            state.selectedAddress = addr;
                            setModalState(() {});
                          },
                        );
                      },
                    ),
                  ),
                  const Divider(),
                ],
                const Text('Add New Address:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: labelCtrl,
                        decoration: const InputDecoration(labelText: 'Label (Home/Office)', isDense: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: pinCtrl,
                        decoration: const InputDecoration(labelText: 'Postcode', isDense: true),
                      ),
                    ),
                  ],
                ),
                TextField(
                  controller: line1Ctrl,
                  decoration: const InputDecoration(labelText: 'Address Line 1', isDense: true),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: cityCtrl,
                        decoration: const InputDecoration(labelText: 'City', isDense: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: stateCtrl,
                        decoration: const InputDecoration(labelText: 'County/State', isDense: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5E00)),
                    onPressed: () async {
                      if (line1Ctrl.text.trim().isEmpty) return;
                      await state.createAddress(
                        label: labelCtrl.text.trim(),
                        line1: line1Ctrl.text.trim(),
                        city: cityCtrl.text.trim(),
                        state: stateCtrl.text.trim(),
                        pincode: pinCtrl.text.trim(),
                        isDefault: true,
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Save Address', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
