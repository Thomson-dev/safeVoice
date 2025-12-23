import 'package:get/get.dart';
import 'package:safe_voice/core/models/trusted_contact.dart' as model;
import 'package:safe_voice/core/services/local_storage_service.dart';
import 'package:safe_voice/core/services/contact_service.dart';
import 'package:safe_voice/core/services/auth_service.dart';
import 'package:uuid/uuid.dart';

class TrustedContactController extends GetxController {
  final localStorageService = LocalStorageService();
  final contactService = ContactService();
  final authService = AuthService();

  final trustedContacts = <model.TrustedContact>[].obs;
  final isLoading = false.obs;
  final shakeAlertEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTrustedContacts();
  }

  /// Load contacts from API, fallback to local storage
  Future<void> loadTrustedContacts() async {
    try {
      isLoading.value = true;

      // Try to load from API first
      final token = authService.getAuthToken();
      if (token != null) {
        try {
          final apiContacts = await contactService.getTrustedContacts(token);
          trustedContacts.value = apiContacts;

          // Sync to local storage
          for (var contact in apiContacts) {
            await localStorageService.saveTrustedContact(contact);
          }

          print(
            'TrustedContactController: Loaded ${apiContacts.length} contacts from API',
          );
          return;
        } catch (e) {
          print(
            'TrustedContactController: API load failed, falling back to local: $e',
          );
        }
      }

      // Fallback to local storage
      trustedContacts.value = localStorageService.getTrustedContacts();
      print(
        'TrustedContactController: Loaded ${trustedContacts.length} contacts from local storage',
      );
    } catch (e) {
      print('TrustedContactController: Error loading contacts: $e');
      trustedContacts.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  /// Add a new trusted contact
  Future<void> addTrustedContact({
    required String name,
    required String phoneNumber,
  }) async {
    try {
      isLoading.value = true;

      // Try API first
      final token = authService.getAuthToken();
      if (token != null) {
        try {
          final contact = await contactService.addTrustedContact(
            token: token,
            name: name,
            phone: phoneNumber,
          );

          // Save to local storage as backup
          await localStorageService.saveTrustedContact(contact);

          // Reload from API to ensure sync
          await loadTrustedContacts();

          print('TrustedContactController: Contact added via API');
          return;
        } catch (e) {
          print('TrustedContactController: API add failed, using local: $e');
        }
      }

      // Fallback to local storage
      final contact = model.TrustedContact(
        id: const Uuid().v4(),
        name: name,
        phoneNumber: phoneNumber,
        isEnabled: true,
      );
      await localStorageService.saveTrustedContact(contact);
      loadTrustedContacts();

      print('TrustedContactController: Contact added to local storage');
    } catch (e) {
      print('TrustedContactController: Error adding contact: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle contact enabled/disabled status
  Future<void> toggleContact(String contactId, bool newValue) async {
    try {
      isLoading.value = true;

      // Try API first
      final token = authService.getAuthToken();
      if (token != null) {
        try {
          final updatedContact = await contactService.updateTrustedContact(
            token: token,
            contactId: contactId,
            isEnabled: newValue,
          );

          // Update local storage
          await localStorageService.updateTrustedContact(updatedContact);

          // Reload
          await loadTrustedContacts();

          print('TrustedContactController: Contact toggled via API');
          return;
        } catch (e) {
          print('TrustedContactController: API toggle failed, using local: $e');
        }
      }

      // Fallback to local storage
      final contact = trustedContacts.firstWhere((c) => c.id == contactId);
      final updatedContact = contact.copyWith(isEnabled: newValue);
      await localStorageService.updateTrustedContact(updatedContact);
      loadTrustedContacts();

      print('TrustedContactController: Contact toggled in local storage');
    } catch (e) {
      print('TrustedContactController: Error toggling contact: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete a trusted contact
  Future<void> deleteContact(String contactId) async {
    try {
      isLoading.value = true;

      // Try API first
      final token = authService.getAuthToken();
      if (token != null) {
        try {
          await contactService.deleteTrustedContact(
            token: token,
            contactId: contactId,
          );

          // Delete from local storage
          await localStorageService.deleteTrustedContact(contactId);

          // Reload
          await loadTrustedContacts();

          print('TrustedContactController: Contact deleted via API');
          return;
        } catch (e) {
          print('TrustedContactController: API delete failed, using local: $e');
        }
      }

      // Fallback to local storage
      await localStorageService.deleteTrustedContact(contactId);
      loadTrustedContacts();

      print('TrustedContactController: Contact deleted from local storage');
    } catch (e) {
      print('TrustedContactController: Error deleting contact: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get only enabled contacts
  List<model.TrustedContact> getEnabledContacts() {
    return trustedContacts.where((c) => c.isEnabled).toList();
  }
}
