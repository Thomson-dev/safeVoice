import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ResourcesHubScreen extends StatefulWidget {
  const ResourcesHubScreen({Key? key}) : super(key: key);

  @override
  State<ResourcesHubScreen> createState() => _ResourcesHubScreenState();
}

class _ResourcesHubScreenState extends State<ResourcesHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
          // Background gradient header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 220,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green.shade700,
                    Colors.green.shade500,
                    Colors.teal.shade400,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 100,
                    left: -30,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Custom header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () => Get.back(),
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () => _showSearchDialog(),
                              icon: const Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.library_books,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Resources & Help',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Information to support and guide you',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Tab bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade600,
                          Colors.teal.shade500,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey.shade600,
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    tabs: const [
                      Tab(text: 'Resources'),
                      Tab(text: 'Support'),
                      Tab(text: 'Emergency'),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildResourcesTab(),
                      _buildSupportTab(),
                      _buildEmergencyTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEnhancedSection(
            icon: Icons.info_outline,
            title: 'How to Preserve Evidence',
            description: 'Essential steps to document incidents properly',
            color: Colors.blue,
            gradient: [Colors.blue.shade600, Colors.blue.shade400],
            items: [
              {
                'icon': Icons.screenshot,
                'text': 'Take screenshots including date and time stamps'
              },
              {
                'icon': Icons.message,
                'text': 'Save original messages and conversations'
              },
              {
                'icon': Icons.event,
                'text': 'Document the incident date and time precisely'
              },
              {'icon': Icons.people, 'text': 'Note any witnesses present'},
              {
                'icon': Icons.save,
                'text': 'Keep all communications as evidence'
              },
              {
                'icon': Icons.lock,
                'text': 'Store copies in a secure location'
              },
            ],
          ),
          const SizedBox(height: 16),
          _buildEnhancedSection(
            icon: Icons.gavel,
            title: 'Your Rights',
            description: 'Know your legal protections and entitlements',
            color: Colors.purple,
            gradient: [Colors.purple.shade600, Colors.purple.shade400],
            items: [
              {
                'icon': Icons.privacy_tip,
                'text': 'Right to confidentiality and anonymity'
              },
              {
                'icon': Icons.search,
                'text': 'Right to fair and prompt investigation'
              },
              {
                'icon': Icons.support,
                'text': 'Right to support throughout the process'
              },
              {'icon': Icons.balance, 'text': 'Right to appeal decisions'},
              {
                'icon': Icons.shield,
                'text': 'Protection from retaliation'
              },
              {
                'icon': Icons.medical_services,
                'text': 'Access to counseling and support services'
              },
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSupportTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEnhancedSection(
            icon: Icons.local_hospital,
            title: 'Counseling & Support',
            description: 'Professional help available to you',
            color: Colors.teal,
            gradient: [Colors.teal.shade600, Colors.teal.shade400],
            items: [
              {
                'icon': Icons.location_on,
                'text': 'Campus Counseling Center - Building A, Room 101',
                'action': 'Map'
              },
              {
                'icon': Icons.health_and_safety,
                'text': 'Student Wellness Office',
                'action': 'Visit'
              },
              {
                'icon': Icons.groups,
                'text': 'Peer Support Groups (Weekly Meetings)',
                'action': 'Join'
              },
              {
                'icon': Icons.psychology,
                'text': 'Professional Therapists Available',
                'action': 'Book'
              },
              {
                'icon': Icons.volunteer_activism,
                'text': 'Free and Confidential Services',
                'action': 'Info'
              },
            ],
          ),
          const SizedBox(height: 16),
          _buildEnhancedSection(
            icon: Icons.place,
            title: 'Safe Spaces',
            description: 'Locations where you can find immediate help',
            color: Colors.orange,
            gradient: [Colors.orange.shade600, Colors.orange.shade400],
            items: [
              {
                'icon': Icons.medical_services,
                'text': 'Campus Health Center (24/7)',
                'action': 'Navigate'
              },
              {
                'icon': Icons.school,
                'text': 'Dean of Students Office',
                'action': 'Navigate'
              },
              {
                'icon': Icons.psychology_alt,
                'text': 'Counseling Center',
                'action': 'Navigate'
              },
              {
                'icon': Icons.home_work,
                'text': 'Residential Life Offices',
                'action': 'Navigate'
              },
              {
                'icon': Icons.security,
                'text': 'Security Office (Open 24/7)',
                'action': 'Navigate'
              },
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildEmergencyTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emergency alert card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade600, Colors.red.shade400],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.emergency,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  'In Immediate Danger?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'If you\'re in immediate danger, call emergency services or use our SOS feature',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _callEmergency('112'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.phone),
                        label: const Text(
                          'Call 112',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Navigate to Emergency Alert screen
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.sos),
                        label: const Text(
                          'Send SOS',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildHotlineCard(
            icon: Icons.phone_in_talk,
            title: 'National Gender-Based Violence Hotline',
            number: '1800-XXX-XXXX',
            description: '24/7 support and counseling',
            color: Colors.red,
          ),
          const SizedBox(height: 12),
          _buildHotlineCard(
            icon: Icons.security,
            title: 'Campus Security',
            number: '123',
            description: 'Call or SMS "SECURITY"',
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildHotlineCard(
            icon: Icons.local_police,
            title: 'Police Emergency',
            number: '999',
            description: 'For immediate police assistance',
            color: Colors.indigo,
          ),
          const SizedBox(height: 12),
          _buildHotlineCard(
            icon: Icons.psychology,
            title: 'Mental Health Support',
            number: '1800-XXX-XXXX',
            description: 'Professional counseling available',
            color: Colors.teal,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildEnhancedSection({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required List<Color> gradient,
    required List<Map<String, dynamic>> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gradient
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final item = entry.value;
                final isLast = entry.key == items.length - 1;

                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          size: 20,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['text'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF2C3E50),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (item.containsKey('action'))
                        TextButton(
                          onPressed: () => _handleAction(item['action']),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            backgroundColor: color.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            item['action'] as String,
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotlineCard({
    required IconData icon,
    required String title,
    required String number,
    required String description,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: () => _callEmergency(number),
                  style: IconButton.styleFrom(
                    backgroundColor: color,
                    padding: const EdgeInsets.all(12),
                  ),
                  icon: const Icon(
                    Icons.phone,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  number,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Search Resources',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search for help, resources...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAction(String action) {
    Get.snackbar(
      action,
      'This feature will be available soon',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: const Color(0xFF2C3E50),
      icon: const Icon(Icons.info_outline, color: Colors.blue),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void _callEmergency(String number) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.phone,
                  color: Colors.red.shade600,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Call Emergency Number?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This will dial $number',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        // Launch phone dialer
                        Clipboard.setData(ClipboardData(text: number));
                        Get.snackbar(
                          'Number Copied',
                          '$number copied to clipboard',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.white,
                          colorText: const Color(0xFF2C3E50),
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Call Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}