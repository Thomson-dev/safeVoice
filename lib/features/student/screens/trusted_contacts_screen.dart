import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../../app/controllers/trusted_contact_controller.dart';

class TrustedContactsScreen extends StatefulWidget {
  const TrustedContactsScreen({Key? key}) : super(key: key);

  @override
  State<TrustedContactsScreen> createState() => _TrustedContactsScreenState();
}

class _TrustedContactsScreenState extends State<TrustedContactsScreen> {
  final contactController = Get.find<TrustedContactController>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Contact',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Add New Contact Button
            GestureDetector(
              onTap: () => _pickContact(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF7B7B).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Color(0xFFFF7B7B),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add new',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Max 5 contacts',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Contacts List
            Obx(
              () {
                if (contactController.trustedContacts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Column(
                        children: [
                          Icon(Icons.contact_phone_outlined, size: 80, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'No contacts added yet',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add emergency contacts to notify',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: contactController.trustedContacts.length,
                  itemBuilder: (context, index) {
                    final contact = contactController.trustedContacts[index];
                    return _buildContactCard(contact, index);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(contact, int index) {
    // Different colors for different contacts
    final colors = [
      const Color(0xFFFFC107), // Yellow
      const Color(0xFFFF7B7B), // Coral
      const Color(0xFF4CAF50), // Green
      const Color(0xFF2196F3), // Blue
      const Color(0xFF9C27B0), // Purple
    ];
    final color = colors[index % colors.length];
    
    // Status badge color
    final badgeColor = contact.isEnabled ? const Color(0xFF4CAF50) : const Color(0xFFFF7B7B);
    final badgeText = contact.isEnabled ? 'Active' : 'Inactive';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                contact.name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Contact Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        contact.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      contact.phoneNumber,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Menu Button
          PopupMenuButton(
            icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(
                      contact.isEnabled ? Icons.toggle_on : Icons.toggle_off,
                      color: const Color(0xFF4C6FFF),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(contact.isEnabled ? 'Disable' : 'Enable'),
                  ],
                ),
                onTap: () {
                  contactController.toggleContact(contact.id, !contact.isEnabled);
                },
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    SizedBox(width: 12),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
                onTap: () {
                  Future.delayed(Duration.zero, () {
                    _showDeleteConfirmation(contact.id, contact.name);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickContact() async {
    try {
      final hasPermission = await FlutterContacts.requestPermission();
      if (!hasPermission) {
        Get.snackbar(
          'Permission Denied',
          'Contacts permission is required to add emergency contacts',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: const Color(0xFF2C3E50),
        );
        return;
      }

      final Contact? contact = await FlutterContacts.openExternalPick();

      if (contact != null && contact.phones.isNotEmpty) {
        final name = contact.displayName;
        final phone = contact.phones.first.number;

        if (name.isNotEmpty && phone.isNotEmpty) {
          await contactController.addTrustedContact(
            name: name,
            phoneNumber: phone,
          );

          Get.snackbar(
            'Success',
            '$name added to trusted contacts',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.white,
            colorText: const Color(0xFF2C3E50),
          );
        }
      } else if (contact != null) {
        Get.snackbar(
          'No Phone Number',
          'This contact does not have a phone number',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: const Color(0xFF2C3E50),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not open contacts',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: const Color(0xFF2C3E50),
      );
      debugPrint('Contact picker error: $e');
    }
  }

  void _showAddContactDialog() {
    nameController.clear();
    phoneController.clear();
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add New Contact',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add emergency contact to notify in critical situations',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Contact Name',
                  hintText: 'e.g., Mom, Dad',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '207 662 3661',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _addContact();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF4C6FFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Add Contact',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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

  void _addContact() async {
    if (nameController.text.isEmpty || phoneController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      await contactController.addTrustedContact(
        name: nameController.text,
        phoneNumber: phoneController.text,
      );
      nameController.clear();
      phoneController.clear();
      Get.snackbar('Success', 'Contact added successfully', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to add contact: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _showDeleteConfirmation(String contactId, String contactName) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Contact?'),
        content: Text('Remove $contactName from your trusted contacts?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              contactController.deleteContact(contactId);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
