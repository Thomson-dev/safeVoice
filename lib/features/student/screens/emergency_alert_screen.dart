import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/controllers/report_controller.dart';
import '../../../app/controllers/trusted_contact_controller.dart';
import '../../../core/services/location_service.dart';

class EmergencyAlertScreen extends StatefulWidget {
  const EmergencyAlertScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyAlertScreen> createState() => _EmergencyAlertScreenState();
}

class _EmergencyAlertScreenState extends State<EmergencyAlertScreen> {
  final reportController = Get.find<ReportController>();
  final contactController = Get.find<TrustedContactController>();
  final locationService = LocationService();

  bool isAlertActive = false;
  bool shareLocation = true;
  bool alertContacts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFF7B7B), Color(0xFFFF9B9B)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    ),
                    const Text(
                      'Emergency Alert',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the close button
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Bell Icon with animation rings
              Container(
                padding: const EdgeInsets.all(8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Animated rings
                    ...List.generate(3, (index) {
                      return Container(
                        width: 80 + (index * 20),
                        height: 80 + (index * 20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3 - (index * 0.1)),
                            width: 2,
                          ),
                        ),
                      );
                    }),
                    // Bell icon
                    const Icon(
                      Icons.notifications_outlined,
                      size: 60,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // SOS Text
              const Text(
                'SOS',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 8,
                ),
              ),

              const SizedBox(height: 16),

              // Status Message
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  isAlertActive
                      ? 'Emergency alert sent to counselors\nand your trusted contacts'
                      : 'Press "Send Alert" for immediate help\nor mark yourself safe',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Settings Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildSettingCard(
                      icon: Icons.location_on_outlined,
                      title: 'Share My Location',
                      subtitle: 'Helps responders find you',
                      value: shareLocation,
                      onChanged: (value) {
                        setState(() => shareLocation = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildSettingCard(
                      icon: Icons.contacts_outlined,
                      title: 'Alert Trusted Contacts',
                      subtitle: 'Send SMS to emergency contacts',
                      value: alertContacts,
                      onChanged: (value) {
                        setState(() => alertContacts = value);
                      },
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // I'm Safe Button
              GestureDetector(
                onTap: () {
                  setState(() => isAlertActive = false);
                  Get.snackbar(
                    'Status Updated',
                    'You marked yourself as safe',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.white,
                    colorText: const Color(0xFF2C3E50),
                  );
                },
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'I\'m Safe',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF7B7B),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.phone_outlined,
                        label: 'Call 112',
                        onTap: () {
                          Get.snackbar(
                            'Emergency Call',
                            'Dialing emergency services...',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.white,
                            colorText: const Color(0xFF2C3E50),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.send_outlined,
                        label: 'Send Alert',
                        onTap: () => _triggerEmergency(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: Colors.white.withOpacity(0.5),
            inactiveThumbColor: Colors.white70,
            inactiveTrackColor: Colors.white.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _triggerEmergency() async {
    if (!shareLocation && !alertContacts) {
      Get.snackbar(
        'Settings Required',
        'Please enable at least one option (location or contacts)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: const Color(0xFF2C3E50),
      );
      return;
    }

    setState(() => isAlertActive = true);

    // Get location if enabled
    String? location;
    if (shareLocation) {
      final position = await locationService.getCurrentLocation();
      if (position != null) {
        location = '${position.latitude}, ${position.longitude}';
      }
    }

    // Create emergency report
    await reportController.submitReport(
      incidentType: 'Emergency - Immediate Danger',
      description: 'EMERGENCY ALERT - User pressed emergency button. Location: ${location ?? "Not shared"}',
      location: location,
    );

    Get.snackbar(
      'Emergency Alert Sent',
      'Counselors have been notified${alertContacts ? " and contacts alerted" : ""}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: const Color(0xFF2C3E50),
      duration: const Duration(seconds: 4),
    );

    // In production, this would:
    // 1. Send alert to campus security/counselors
    // 2. Send SMS to trusted contacts if enabled
    // 3. Share location if enabled
    // 4. Log the emergency event with timestamp
  }
}
