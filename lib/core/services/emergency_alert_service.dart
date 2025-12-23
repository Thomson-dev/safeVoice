import 'package:dio/dio.dart';

/// Service for emergency SOS alerts
class EmergencyAlertService {
  final Dio _dio;
  static const String baseUrl = 'https://safe-voice-backend.vercel.app/api';

  EmergencyAlertService()
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

  /// Trigger SOS emergency alert
  /// Sends alert to trusted contacts and counselors via SMS
  Future<Map<String, dynamic>> triggerSOS({
    required String token,
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    try {
      print('EmergencyAlertService: Triggering SOS alert');
      print('Location: $latitude, $longitude');
      print('Address: $address');

      final response = await _dio.post(
        '/emergency/sos',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'address': address,
        },
        options: _getOptions(token),
      );

      print('EmergencyAlertService: Response status: ${response.statusCode}');
      print('EmergencyAlertService: Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Emergency alert sent',
          'alertId': data['alert']?['id'],
          'status': data['alert']?['status'] ?? 'triggered',
          'notifiedContacts': data['notifiedContacts'] ?? 0,
          'notifiedCounselors': data['notifiedCounselors'] ?? 0,
          'createdAt': data['alert']?['createdAt'],
        };
      } else {
        throw Exception('Failed to trigger SOS alert');
      }
    } on DioException catch (e) {
      print('EmergencyAlertService: DioException - ${e.message}');
      if (e.response != null) {
        print('EmergencyAlertService: Error response: ${e.response?.data}');
        final errorData = e.response?.data;
        String errorMsg = 'Failed to trigger SOS alert';

        if (errorData is Map) {
          errorMsg = errorData['error'] ?? errorData['message'] ?? errorMsg;
        }

        throw Exception(errorMsg);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('EmergencyAlertService: Unexpected error - $e');
      throw Exception('Failed to trigger SOS alert: $e');
    }
  }

  /// Get emergency alert history
  Future<List<Map<String, dynamic>>> getAlertHistory({
    required String token,
  }) async {
    try {
      print('EmergencyAlertService: Fetching alert history');

      final response = await _dio.get(
        '/emergency/history',
        options: _getOptions(token),
      );

      print('EmergencyAlertService: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map && data.containsKey('alerts')) {
          return List<Map<String, dynamic>>.from(data['alerts']);
        } else if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }

        return [];
      } else {
        throw Exception('Failed to fetch alert history');
      }
    } on DioException catch (e) {
      print('EmergencyAlertService: DioException - ${e.message}');
      if (e.response != null) {
        print('EmergencyAlertService: Error response: ${e.response?.data}');
        throw Exception('Failed to fetch alert history');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('EmergencyAlertService: Unexpected error - $e');
      throw Exception('Failed to fetch alert history: $e');
    }
  }
}
