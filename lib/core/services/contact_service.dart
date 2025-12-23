import 'package:dio/dio.dart';
import '../models/trusted_contact.dart';

/// Service for managing trusted contacts via API
class ContactService {
  final Dio _dio;
  static const String baseUrl = 'https://safe-voice-backend.vercel.app/api';

  ContactService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        ),
      );

  /// Add authorization header to request options
  Options _getOptions(String? token) {
    return Options(
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  /// Get all trusted contacts for the current user
  Future<List<TrustedContact>> getTrustedContacts(String token) async {
    try {
      print('ContactService: Fetching trusted contacts');

      final response = await _dio.get(
        '/student/contacts',
        options: _getOptions(token),
      );

      print('ContactService: Response status: ${response.statusCode}');
      print('ContactService: Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        // Handle different response formats
        List<dynamic> contactsJson;
        if (data is Map && data.containsKey('contacts')) {
          contactsJson = data['contacts'] as List<dynamic>;
        } else if (data is List) {
          contactsJson = data;
        } else {
          throw Exception('Unexpected response format');
        }

        return contactsJson
            .map(
              (json) => TrustedContact.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception('Failed to fetch contacts');
      }
    } on DioException catch (e) {
      print('ContactService: DioException - ${e.message}');
      if (e.response != null) {
        print('ContactService: Error response: ${e.response?.data}');
        final errorData = e.response?.data;
        String errorMsg = 'Failed to fetch contacts';
        if (errorData is Map) {
          errorMsg = errorData['error'] ?? errorData['message'] ?? errorMsg;
        }
        throw Exception(errorMsg);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('ContactService: Unexpected error - $e');
      throw Exception('Failed to fetch contacts: $e');
    }
  }

  /// Add a new trusted contact
  Future<TrustedContact> addTrustedContact({
    required String token,
    required String name,
    required String phone,
  }) async {
    try {
      print('ContactService: Adding trusted contact - $name');

      final response = await _dio.post(
        '/student/contacts',
        data: {'name': name, 'phone': phone},
        options: _getOptions(token),
      );

      print('ContactService: Response status: ${response.statusCode}');
      print('ContactService: Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        // Handle different response formats
        Map<String, dynamic> contactJson;
        if (data is Map && data.containsKey('contact')) {
          contactJson = Map<String, dynamic>.from(data['contact'] as Map);
        } else if (data is Map) {
          contactJson = Map<String, dynamic>.from(data);
        } else {
          throw Exception('Unexpected response format');
        }

        return TrustedContact.fromJson(contactJson);
      } else {
        throw Exception('Failed to add contact');
      }
    } on DioException catch (e) {
      print('ContactService: DioException - ${e.message}');
      if (e.response != null) {
        print('ContactService: Error response: ${e.response?.data}');
        final errorData = e.response?.data;
        String errorMsg = 'Failed to add contact';
        if (errorData is Map) {
          errorMsg = errorData['error'] ?? errorData['message'] ?? errorMsg;
        }
        throw Exception(errorMsg);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('ContactService: Unexpected error - $e');
      throw Exception('Failed to add contact: $e');
    }
  }

  /// Update a trusted contact
  Future<TrustedContact> updateTrustedContact({
    required String token,
    required String contactId,
    String? name,
    String? phone,
    bool? isEnabled,
  }) async {
    try {
      print('ContactService: Updating contact - $contactId');

      final response = await _dio.patch(
        '/student/contacts/$contactId',
        data: {
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
          if (isEnabled != null) 'isEnabled': isEnabled,
        },
        options: _getOptions(token),
      );

      print('ContactService: Response status: ${response.statusCode}');
      print('ContactService: Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        // Handle different response formats
        Map<String, dynamic> contactJson;
        if (data is Map && data.containsKey('contact')) {
          contactJson = Map<String, dynamic>.from(data['contact'] as Map);
        } else if (data is Map) {
          contactJson = Map<String, dynamic>.from(data);
        } else {
          throw Exception('Unexpected response format');
        }

        return TrustedContact.fromJson(contactJson);
      } else {
        throw Exception('Failed to update contact');
      }
    } on DioException catch (e) {
      print('ContactService: DioException - ${e.message}');
      if (e.response != null) {
        print('ContactService: Error response: ${e.response?.data}');
        final errorData = e.response?.data;
        String errorMsg = 'Failed to update contact';
        if (errorData is Map) {
          errorMsg = errorData['error'] ?? errorData['message'] ?? errorMsg;
        }
        throw Exception(errorMsg);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('ContactService: Unexpected error - $e');
      throw Exception('Failed to update contact: $e');
    }
  }

  /// Delete a trusted contact
  Future<void> deleteTrustedContact({
    required String token,
    required String contactId,
  }) async {
    try {
      print('ContactService: Deleting contact - $contactId');

      final response = await _dio.delete(
        '/student/contacts/$contactId',
        options: _getOptions(token),
      );

      print('ContactService: Response status: ${response.statusCode}');
      print('ContactService: Response data: ${response.data}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete contact');
      }
    } on DioException catch (e) {
      print('ContactService: DioException - ${e.message}');
      if (e.response != null) {
        print('ContactService: Error response: ${e.response?.data}');
        final errorData = e.response?.data;
        String errorMsg = 'Failed to delete contact';
        if (errorData is Map) {
          errorMsg = errorData['error'] ?? errorData['message'] ?? errorMsg;
        }
        throw Exception(errorMsg);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('ContactService: Unexpected error - $e');
      throw Exception('Failed to delete contact: $e');
    }
  }
}
