import 'package:get/get.dart';
import 'package:safe_voice/core/models/trusted_contact.dart' as model;
import 'package:safe_voice/core/services/local_storage_service.dart';
import 'package:uuid/uuid.dart';


class TrustedContactController extends GetxController {
  final localStorageService = LocalStorageService();

  final trustedContacts = <model.TrustedContact>[].obs;
  final isLoading = false.obs;
  final shakeAlertEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTrustedContacts();
  }

  void loadTrustedContacts() {
    trustedContacts.value = localStorageService.getTrustedContacts();
  }

  Future<void> addTrustedContact({
    required String name,
    required String phoneNumber,
  }) async {
    try {
      isLoading.value = true;
      final contact = model.TrustedContact(
        id: const Uuid().v4(),
        name: name,
        phoneNumber: phoneNumber,
        isEnabled: true,
      );
      await localStorageService.saveTrustedContact(contact);
      loadTrustedContacts();
    } catch (e) {
      print('Error adding contact: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleContact(String contactId, bool newValue) async {
    try {
      final contact = trustedContacts.firstWhere((c) => c.id == contactId);
      final updatedContact = contact.copyWith(isEnabled: newValue);
      await localStorageService.updateTrustedContact(updatedContact);
      loadTrustedContacts();
    } catch (e) {
      print('Error toggling contact: $e');
      rethrow;
    }
  }

  Future<void> deleteContact(String contactId) async {
    try {
      await localStorageService.deleteTrustedContact(contactId);
      loadTrustedContacts();
    } catch (e) {
      print('Error deleting contact: $e');
      rethrow;
    }
  }

  List<model.TrustedContact> getEnabledContacts() {
    return trustedContacts.where((c) => c.isEnabled).toList();
  }
}
