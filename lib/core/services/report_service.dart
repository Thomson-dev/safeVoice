import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import '../models/report.dart';
import 'auth_service.dart';

class ReportService {
  final AuthService _authService = AuthService();

  static const String baseUrl = 'https://safe-voice-backend.vercel.app/api';
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  ReportService() {
    // Add interceptor to automatically attach auth token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _authService.getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // Handle 401 Unauthorized - token expired
          if (error.response?.statusCode == 401) {
            _handleTokenExpiration();
          }
          return handler.next(error);
        },
      ),
    );
  }

  void _handleTokenExpiration() {
    _authService.logout();
    try {
      getx.Get.offAllNamed('/role-selection');
      getx.Get.snackbar(
        'Session Expired',
        'Your session has expired. Please log in again.',
        snackPosition: getx.SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('ReportService: Error handling token expiration - $e');
    }
  }

  /// Submit a new report
  Future<Map<String, dynamic>> submitReport({
    required String incidentType,
    required String description,
    String? evidenceUrl,
    String? schoolName,
  }) async {
    try {
      print('ReportService: Submitting report');

      final response = await _dio.post(
        '/reports',
        data: {
          'incidentType': incidentType,
          'description': description,
          if (evidenceUrl != null && evidenceUrl.isNotEmpty)
            'evidenceUrl': evidenceUrl,
          if (schoolName != null && schoolName.isNotEmpty)
            'schoolName': schoolName,
        },
      );

      print('ReportService: Response status: ${response.statusCode}');
      print('ReportService: Response data: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;

        // API returns: {
        //   "success": true,
        //   "message": "Report submitted successfully",
        //   "trackingCode": "TRACK-C2BD47F9",
        //   "reportId": "694661bf1fc8781b06552050",
        //   "caseId": "CASE-5798D9DC",
        //   "report": {
        //     "id": "694661bf1fc8781b06552050",
        //     "trackingCode": "TRACK-C2BD47F9",
        //     "anonymousId": "ANON-00001",
        //     "status": "pending",
        //     "createdAt": "2025-12-20T08:43:43.117Z"
        //   }
        // }

        return {
          'success': true,
          'message': data['message'] ?? 'Report submitted successfully',
          'trackingCode': data['trackingCode'],
          'reportId': data['reportId'],
          'caseId': data['caseId'],
          'report': data['report'],
        };
      } else {
        throw Exception('Failed to submit report');
      }
    } on DioException catch (e) {
      print('ReportService: DioException - ${e.message}');
      if (e.response != null) {
        print('ReportService: Error response: ${e.response?.data}');
        final errorData = e.response?.data;
        String errorMsg = 'Failed to submit report';
        if (errorData is Map) {
          errorMsg = errorData['error'] ?? errorData['message'] ?? errorMsg;
        }
        throw Exception(errorMsg);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('ReportService: Unexpected error - $e');
      throw Exception('Failed to submit report: $e');
    }
  }

  /// Get all reports for the current user
  Future<List<Report>> getMyReports() async {
    try {
      print('ReportService: Fetching user reports');

      final response = await _dio.get('/reports/my-reports');

      print('ReportService: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> reportsData = data['reports'] ?? [];

        return reportsData.map((json) => Report.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch reports');
      }
    } on DioException catch (e) {
      print('ReportService: DioException - ${e.message}');

      // If 404, it might mean no reports found (depending on API design)
      if (e.response?.statusCode == 404) {
        print('ReportService: No reports found (404), returning empty list');
        return [];
      }

      if (e.response != null) {
        final errorData = e.response?.data;
        String errorMsg = 'Failed to fetch reports';
        if (errorData is Map) {
          errorMsg = errorData['error'] ?? errorData['message'] ?? errorMsg;
        }
        throw Exception(errorMsg);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('ReportService: Unexpected error - $e');
      throw Exception('Failed to fetch reports: $e');
    }
  }

  /// Get all cases for counselor (assigned reports)
  Future<List<Report>> getMyCases() async {
    try {
      print('ReportService: Fetching counselor cases');

      final response = await _dio.get('/cases/my-cases');

      print('ReportService: Response status: ${response.statusCode}');
      print('ReportService: Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> casesData = data['cases'] ?? data['reports'] ?? [];

        // The API may return case objects that wrap a `report` object or return report objects directly.
        // Normalize each item so Report.fromJson receives a report-like map.
        List<Report> parsed = [];
        for (var item in casesData) {
          if (item is Map<String, dynamic>) {
            Map<String, dynamic> candidate = Map<String, dynamic>.from(item);

            // If the case contains a nested 'report', prefer its fields but merge case-level metadata.
            if (item.containsKey('report') &&
                item['report'] is Map<String, dynamic>) {
              final reportMap = Map<String, dynamic>.from(item['report']);
              // Merge case-level fields without overwriting report fields
              final caseMap = Map<String, dynamic>.from(item);
              caseMap.remove('report');
              reportMap.addAll(caseMap);
              candidate = reportMap;
            } else if (item.containsKey('case') &&
                item['case'] is Map<String, dynamic>) {
              final caseMap = Map<String, dynamic>.from(item['case']);
              // Some responses include both 'case' and 'report'
              if (item.containsKey('report') &&
                  item['report'] is Map<String, dynamic>) {
                final reportMap = Map<String, dynamic>.from(item['report']);
                caseMap.addAll(reportMap);
              }
              candidate = caseMap;
            }

            try {
              parsed.add(Report.fromJson(candidate));
            } catch (e) {
              print('ReportService: Failed to parse case/report item: $e');
            }
          }
        }

        return parsed;
      } else {
        throw Exception('Failed to fetch cases');
      }
    } on DioException catch (e) {
      print('ReportService: DioException - ${e.message}');

      // If 404, it might mean no cases found
      if (e.response?.statusCode == 404) {
        print('ReportService: No cases found (404), returning empty list');
        return [];
      }

      if (e.response != null) {
        final errorData = e.response?.data;
        String errorMsg = 'Failed to fetch cases';
        if (errorData is Map) {
          errorMsg = errorData['error'] ?? errorData['message'] ?? errorMsg;
        }
        throw Exception(errorMsg);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('ReportService: Unexpected error - $e');
      throw Exception('Failed to fetch cases: $e');
    }
  }

  /// Get available cases for counselors to claim
  Future<List<Map<String, dynamic>>> getAvailableCases() async {
    try {
      print('ReportService: Fetching available cases');
      final response = await _dio.get('/cases/available');

      print('ReportService: Response status: ${response.statusCode}');
      print('ReportService: Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> casesData = data['cases'] ?? [];
        return List<Map<String, dynamic>>.from(casesData);
      } else {
        throw Exception('Failed to fetch available cases');
      }
    } on DioException catch (e) {
      print('ReportService: DioException - ${e.message}');
      if (e.response != null) {
        final errorData = e.response?.data;
        String errorMsg = 'Failed to fetch available cases';
        if (errorData is Map) {
          errorMsg = errorData['error'] ?? errorData['message'] ?? errorMsg;
        }
        throw Exception(errorMsg);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('ReportService: Unexpected error - $e');
      throw Exception('Failed to fetch available cases: $e');
    }
  }

  /// Claim a case by caseId (counselor action)
  Future<Map<String, dynamic>> claimCase(String caseId) async {
    try {
      print('ReportService: Claiming case: $caseId');
      final response = await _dio.post('/cases/$caseId/claim');

      print('ReportService: Claim response status: ${response.statusCode}');
      print('ReportService: Claim response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Map<String, dynamic>.from(response.data ?? {});
      } else {
        throw Exception('Failed to claim case');
      }
    } on DioException catch (e) {
      print('ReportService: DioException - ${e.message}');
      if (e.response != null) {
        final errorData = e.response?.data;
        String errorMsg = 'Failed to claim case';
        if (errorData is Map) {
          errorMsg = errorData['error'] ?? errorData['message'] ?? errorMsg;
        }
        throw Exception(errorMsg);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('ReportService: Unexpected error - $e');
      throw Exception('Failed to claim case: $e');
    }
  }

  /// Get a case and its report details by caseId (e.g. CASE-3D3C1DB8 or mongo id)
  Future<Map<String, dynamic>?> getCaseByCaseId(String caseId) async {
    try {
      print('ReportService: Fetching case details for: $caseId');
      final response = await _dio.get('/cases/$caseId');

      print('ReportService: getCaseByCaseId status: ${response.statusCode}');
      print('ReportService: getCaseByCaseId data: ${response.data}');

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data ?? {});
      } else {
        return null;
      }
    } on DioException catch (e) {
      print('ReportService: DioException in getCaseByCaseId - ${e.message}');
      if (e.response != null) {
        print('ReportService: Error response: ${e.response?.data}');
        return Map<String, dynamic>.from(e.response?.data ?? {});
      }
      rethrow;
    } catch (e) {
      print('ReportService: Unexpected error in getCaseByCaseId - $e');
      rethrow;
    }
  }

  /// Update case fields (e.g., status) via PATCH /cases/{caseId}
  Future<Map<String, dynamic>> updateCaseStatus(
    String caseId,
    String status,
  ) async {
    try {
      print('ReportService: Updating case $caseId status -> $status');
      final response = await _dio.patch(
        '/cases/$caseId/status',
        data: {'status': status},
      );

      print('ReportService: updateCaseStatus status: ${response.statusCode}');
      print('ReportService: updateCaseStatus data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Map<String, dynamic>.from(response.data ?? {});
      } else {
        throw Exception('Failed to update case status');
      }
    } on DioException catch (e) {
      print('ReportService: DioException in updateCaseStatus - ${e.message}');
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to update case status',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('ReportService: Unexpected error in updateCaseStatus - $e');
      throw Exception('Failed to update case status: $e');
    }
  }

  /// Update case risk level via PATCH /cases/{caseId}/risk-level
  Future<Map<String, dynamic>> updateCaseRiskLevel(
    String caseId,
    String riskLevel,
  ) async {
    try {
      print('ReportService: Updating case $caseId riskLevel -> $riskLevel');
      final response = await _dio.patch(
        '/cases/$caseId/risk-level',
        data: {'riskLevel': riskLevel},
      );

      print(
        'ReportService: updateCaseRiskLevel status: ${response.statusCode}',
      );
      print('ReportService: updateCaseRiskLevel data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Map<String, dynamic>.from(response.data ?? {});
      } else {
        throw Exception('Failed to update case risk level');
      }
    } on DioException catch (e) {
      print(
        'ReportService: DioException in updateCaseRiskLevel - ${e.message}',
      );
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to update case risk level',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('ReportService: Unexpected error in updateCaseRiskLevel - $e');
      throw Exception('Failed to update case risk level: $e');
    }
  }

  /// Get report by tracking code
  Future<Map<String, dynamic>?> getReportByTrackingCode(
    String trackingCode,
  ) async {
    try {
      print('ReportService: Fetching report by tracking code: $trackingCode');

      final response = await _dio.get('/reports/$trackingCode');

      print('ReportService: Response status: ${response.statusCode}');
      print('ReportService: Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        // API returns: {"success": true, "report": {...}}
        return {'success': data['success'] ?? true, 'report': data['report']};
      } else {
        return null;
      }
    } on DioException catch (e) {
      print('ReportService: DioException - ${e.message}');

      // Handle 404 - Report not found
      if (e.response?.statusCode == 404) {
        print('ReportService: Report not found (404)');
        return {
          'success': false,
          'error': 'not_found',
          'message': 'No report found with this tracking code',
        };
      }

      // Handle other errors
      if (e.response != null) {
        print('ReportService: Error response: ${e.response?.data}');
        return {
          'success': false,
          'error': 'api_error',
          'message': e.response?.data['message'] ?? 'Failed to fetch report',
        };
      }

      return {
        'success': false,
        'error': 'network_error',
        'message': 'Network error. Please check your connection.',
      };
    } catch (e) {
      print('ReportService: Unexpected error - $e');
      return {
        'success': false,
        'error': 'unknown_error',
        'message': 'An unexpected error occurred',
      };
    }
  }

  /// Get messages for a report (student-counselor chat)
  Future<Map<String, dynamic>?> getReportMessages(String reportId) async {
    try {
      // Endpoint confirmed by user: /student/reports/:reportId/messages
      final response = await _dio.get('/student/reports/$reportId/messages');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to fetch messages');
      }
    } catch (e) {
      print('ReportService: Error fetching messages: $e');
      rethrow;
    }
  }

  /// Send a message as student
  Future<void> sendStudentMessage(String reportId, String content) async {
    try {
      // Endpoint confirmed by screenshot: POST /student/messages
      final response = await _dio.post(
        '/student/messages',
        data: {'reportId': reportId, 'content': content},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      print('ReportService: Error sending message: $e');
      rethrow;
    }
  }

  /// Get all messages for a specific case (Counselor view)
  /// Endpoint: GET /api/cases/{caseId}/messages
  Future<Map<String, dynamic>?> getCaseMessages(String caseId) async {
    try {
      print('ReportService: Fetching messages for case: $caseId');
      final response = await _dio.get('/cases/$caseId/messages');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to fetch case messages');
      }
    } catch (e) {
      print('ReportService: Error fetching case messages: $e');
      rethrow;
    }
  }

  /// Send a message as counselor to a case using the case's MongoDB _id
  Future<void> sendCounselorMessage(String caseMongoId, String content) async {
    try {
      print('ReportService: Sending counselor message to case: $caseMongoId');
      final response = await _dio.post(
        '/cases/$caseMongoId/messages',
        data: {'caseId': caseMongoId, 'content': content},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to send counselor message');
      }
    } catch (e) {
      print('ReportService: Error sending counselor message: $e');
      rethrow;
    }
  }
}
