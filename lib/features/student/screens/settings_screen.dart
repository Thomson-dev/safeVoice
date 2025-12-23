import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_voice/app/controllers/auth_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.isRegistered<AuthController>() 
        ? Get.find<AuthController>() 
        : Get.put(AuthController());

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
          // Background gradient header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4A5AAF), Color(0xFF5B6BC5), Color(0xFF6B7BD5)],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                      const Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Account Section
                          _buildSectionCard(
                            title: 'Account',
                            children: [
                              Obx(() => _buildSettingsTile(
                                icon: Icons.person_outline,
                                title: 'Profile',
                                subtitle: authController.currentUser.value?.displayName ?? 'Anonymous User',
                                onTap: () => _showProfileDialog(context, authController),
                              )),
                              _buildSettingsTile(
                                icon: Icons.shield_outlined,
                                title: 'Privacy & Security',
                                subtitle: 'Manage your privacy settings',
                                onTap: () => _showPrivacySettings(context),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Notifications Section
                          _buildSectionCard(
                            title: 'Notifications',
                            children: [
                              _buildSettingsTile(
                                icon: Icons.notifications_outlined,
                                title: 'Push Notifications',
                                subtitle: 'Receive alerts and updates',
                                trailing: Switch(
                                  value: true,
                                  onChanged: (value) {},
                                  activeColor: const Color(0xFF4A5AAF),
                                ),
                              ),
                              _buildSettingsTile(
                                icon: Icons.email_outlined,
                                title: 'Email Notifications',
                                subtitle: 'Get updates via email',
                                trailing: Switch(
                                  value: false,
                                  onChanged: (value) {},
                                  activeColor: const Color(0xFF4A5AAF),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Emergency Section
                          _buildSectionCard(
                            title: 'Emergency',
                            children: [
                              _buildSettingsTile(
                                icon: Icons.emergency_outlined,
                                title: 'Emergency Contacts',
                                subtitle: 'Manage your trusted contacts',
                                onTap: () => Get.toNamed('/trusted-contacts'),
                              ),
                              _buildSettingsTile(
                                icon: Icons.location_on_outlined,
                                title: 'Location Services',
                                subtitle: 'Share location in emergencies',
                                trailing: Switch(
                                  value: true,
                                  onChanged: (value) {},
                                  activeColor: const Color(0xFF4A5AAF),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // App Settings Section
                          _buildSectionCard(
                            title: 'App Settings',
                            children: [
                              _buildSettingsTile(
                                icon: Icons.language_outlined,
                                title: 'Language',
                                subtitle: 'English',
                                onTap: () => _showLanguageDialog(context),
                              ),
                              _buildSettingsTile(
                                icon: Icons.palette_outlined,
                                title: 'Theme',
                                subtitle: 'Light Mode',
                                onTap: () => _showThemeDialog(context),
                              ),
                              _buildSettingsTile(
                                icon: Icons.storage_outlined,
                                title: 'Clear Cache',
                                subtitle: 'Free up storage space',
                                onTap: () => _showClearCacheDialog(context),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Support Section
                          _buildSectionCard(
                            title: 'Support',
                            children: [
                              _buildSettingsTile(
                                icon: Icons.help_outline,
                                title: 'Help & Support',
                                subtitle: 'Get help with the app',
                                onTap: () => _showHelpDialog(context),
                              ),
                              _buildSettingsTile(
                                icon: Icons.policy_outlined,
                                title: 'Privacy Policy',
                                subtitle: 'View our privacy policy',
                                onTap: () {},
                              ),
                              _buildSettingsTile(
                                icon: Icons.description_outlined,
                                title: 'Terms of Service',
                                subtitle: 'Read our terms',
                                onTap: () {},
                              ),
                              _buildSettingsTile(
                                icon: Icons.info_outline,
                                title: 'About SafeVoice',
                                subtitle: 'Version 1.0.0',
                                onTap: () {},
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Logout Button
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ElevatedButton(
                              onPressed: () => _showLogoutDialog(context, authController),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade50,
                                foregroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.logout, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Logout',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A5AAF),
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF4A5AAF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF4A5AAF),
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
          ],
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context, AuthController authController) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person, size: 64, color: Color(0xFF4A5AAF)),
              const SizedBox(height: 16),
              const Text(
                'Profile Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Profile editing coming soon!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A5AAF),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield, size: 64, color: Color(0xFF4A5AAF)),
              const SizedBox(height: 16),
              const Text(
                'Privacy & Security',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Your reports are completely anonymous. We never share your identity with counselors.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A5AAF),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Got it'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Language',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 20),
              _buildLanguageOption('English', true),
              _buildLanguageOption('Français', false),
              _buildLanguageOption('Español', false),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A5AAF),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language, bool isSelected) {
    return ListTile(
      title: Text(language),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Color(0xFF4A5AAF))
          : const Icon(Icons.circle_outlined, color: Colors.grey),
      onTap: () {},
    );
  }

  void _showThemeDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Theme',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 20),
              _buildThemeOption('Light Mode', true),
              _buildThemeOption('Dark Mode', false),
              _buildThemeOption('System Default', false),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A5AAF),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(String theme, bool isSelected) {
    return ListTile(
      title: Text(theme),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Color(0xFF4A5AAF))
          : const Icon(Icons.circle_outlined, color: Colors.grey),
      onTap: () {},
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear the app cache? This will free up storage space.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Success',
                'Cache cleared successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A5AAF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.help, size: 32, color: Color(0xFF4A5AAF)),
                  SizedBox(width: 12),
                  Text(
                    'Help & Support',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Need help? Contact us:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              const Text('📧 Email: support@safevoice.org'),
              const SizedBox(height: 8),
              const Text('📞 Hotline: 1-800-SAFEVOICE'),
              const SizedBox(height: 8),
              const Text('💬 Live Chat: Available 24/7'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A5AAF),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authController.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
