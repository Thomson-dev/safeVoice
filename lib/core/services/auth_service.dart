import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/user.dart';

/// Authentication service for anonymous but controlled user management
/// Students: No real name required, gets anonymousId
/// Counselors: Full name required, must be verified
class AuthService {
  final box = GetStorage();
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'auth_token';

  // API Configuration
  static const String baseUrl = 'https://safe-voice-backend.vercel.app/api';
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  AuthService() {
    // Add interceptor to automatically attach auth token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = getAuthToken();
          if (token != null &&
              options.path != '/auth/student/register' &&
              options.path != '/auth/counselor/register' &&
              options.path != '/auth/student/login' &&
              options.path != '/auth/counselor/login') {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // Handle 401 Unauthorized - token expired or invalid
          if (error.response?.statusCode == 401) {
            print('AuthService: 401 Unauthorized - Token expired or invalid');
            // _handleTokenExpiration(); // DISABLED: Prevent auto-logout to debug backend 401s
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Handle token expiration - logout and redirect
  void _handleTokenExpiration() {
    print('AuthService: Handling token expiration - logging out');
    logout();

    // Navigate to role selection screen
    try {
      Get.offAllNamed('/role-selection');
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.snackbar(
          'Session Expired',
          'Your session has expired. Please log in again.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      });
    } catch (e) {
      print('AuthService: Could not navigate - GetX not initialized');
    }
  }

  // Get current logged-in user
  User? getCurrentUser() {
    final userData = box.read(_userKey);
    if (userData == null) return null;
    return User.fromJson(Map<String, dynamic>.from(userData));
  }

  // Save user session
  void saveUserSession(User user, String token) {
    box.write(_userKey, user.toJson());
    box.write(_tokenKey, token);
  }

  // Get auth token
  String? getAuthToken() {
    return box.read(_tokenKey);
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return getCurrentUser() != null && getAuthToken() != null;
  }

  // Logout
  void logout() {
    box.remove(_userKey);
    box.remove(_tokenKey);
  }

  // ===== API REGISTRATION =====

  /// Register student - Anonymous but controlled
  /// No real name required, gets ANON-12345 ID
  Future<Map<String, dynamic>> registerStudent({
    required String password,
    String? email, // Optional for password recovery
    String? displayName, // Optional nickname
  }) async {
    try {
      print('AuthService: Attempting student registration');

      final response = await _dio.post(
        '/auth/student/register',
        data: {
          'email':
              email ??
              'student${DateTime.now().millisecondsSinceEpoch}@safevoice.app',
          'password': password,
          'role': 'student',
          if (displayName != null) 'displayName': displayName,
        },
      );

      print(
        'AuthService: Registration response status: ${response.statusCode}',
      );
      print('AuthService: Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        // API returns: {"success": true, "userId": "...", "anonymousId": "...", "role": "student", "token": "..."}
        final user = User(
          id: data['userId'] ?? _generateId(),
          role: data['role'] ?? 'student',
          email:
              email ??
              'student${DateTime.now().millisecondsSinceEpoch}@safevoice.app',
          anonymousId: data['anonymousId'] ?? _generateAnonymousId(),
          displayName: displayName,
          createdAt: DateTime.now(),
        );

        final token = data['token'] ?? '';

        return {
          'user': user,
          'token': token,
          'message': 'Student account created successfully',
        };
      } else {
        throw Exception('Registration failed');
      }
    } on DioException catch (e) {
      print('AuthService: DioException - ${e.message}');
      if (e.response != null) {
        print('AuthService: Error response: ${e.response?.data}');
        final errorData = e.response?.data;
        String errorMsg = 'Registration failed';
        if (errorData is Map) {
          errorMsg = errorData['error'] ?? errorData['message'] ?? errorMsg;
        }
        throw Exception(errorMsg);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('AuthService: Unexpected error - $e');
      throw Exception('Registration failed: $e');
    }
  }

  /// Register counselor - Requires verification
  /// Full name and license required
  Future<Map<String, dynamic>> registerCounselor({
    required String email,
    required String password,
    required String fullName,
    required String licenseNumber,
    required String phone,
    String? schoolName,
    String? department,
  }) async {
    try {
      print('AuthService: Attempting counselor registration');

      final response = await _dio.post(
        '/auth/counselor/register',
        data: {
          'email': email,
          'password': password,
          'fullName': fullName,
          'license':
              licenseNumber, // Note: API uses 'license' not 'licenseNumber'
          'phone': phone,
          'schoolName': schoolName ?? 'Not Specified',
          'department': department ?? 'Not Specified',
          'role': 'counselor',
        },
      );

      print(
        'AuthService: Registration response status: ${response.statusCode}',
      );
      print('AuthService: Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        // API returns: {"success": true, "userId": "...", "fullName": "...", "role": "counselor", "isVerified": false, "token": "...", "message": "..."}
        final user = User(
          id: data['userId'] ?? _generateId(),
          role: data['role'] ?? 'counselor',
          email: email, // Use from request since API doesn't return it
          fullName: data['fullName'] ?? fullName,
          licenseNumber: licenseNumber,
          schoolName: schoolName,
          department: department,
          isVerified: data['isVerified'] ?? false,
          createdAt: DateTime.now(),
        );

        final token = data['token'] ?? '';
        final message =
            data['message'] ??
            'Counselor account created. Awaiting admin verification.';

        return {'user': user, 'token': token, 'message': message};
      } else {
        throw Exception('Registration failed');
      }
    } on DioException catch (e) {
      print('AuthService: DioException - ${e.message}');
      if (e.response != null) {
        print('AuthService: Error response: ${e.response?.data}');
        final errorData = e.response?.data;
        String errorMsg = 'Registration failed';
        if (errorData is Map) {
          errorMsg = errorData['error'] ?? errorData['message'] ?? errorMsg;
        }
        throw Exception(errorMsg);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('AuthService: Unexpected error - $e');
      throw Exception('Registration failed: $e');
    }
  }

  /// Login - Works for both students and counselors
  /// Tries student login first, then counselor login if student fails
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // Try student login first
    try {
      return await loginStudent(email: email, password: password);
    } catch (studentError) {
      // If student login fails, try counselor login
      try {
        return await loginCounselor(email: email, password: password);
      } catch (counselorError) {
        // If both fail, throw the error
        throw Exception('Invalid email or password');
      }
    }
  }

  /// Login as student
  Future<Map<String, dynamic>> loginStudent({
    required String email,
    required String password,
  }) async {
    try {
      print('AuthService: Attempting student login for $email');

      final response = await _dio.post(
        '/auth/student/login',
        data: {'email': email, 'password': password},
      );

      print(
        'AuthService: Student login response status: ${response.statusCode}',
      );
      print('AuthService: Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        // API returns: {"success": true, "userId": "...", "anonymousId": "...", "role": "student", "token": "..."}
        final user = User(
          id: data['userId'] ?? _generateId(),
          role: data['role'] ?? 'student',
          email: email, // Email not returned, use the one we sent
          anonymousId: data['anonymousId'],
          displayName: null,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        final token = data['token'] ?? '';

        return {'user': user, 'token': token, 'message': 'Login successful'};
      } else {
        throw Exception('Student login failed');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data;
        String errorMsg = 'Student login failed';
        if (errorData is Map) {
          errorMsg = errorData['error'] ?? errorData['message'] ?? errorMsg;
        }
        throw Exception(errorMsg);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Login as counselor
  Future<Map<String, dynamic>> loginCounselor({
    required String email,
    required String password,
  }) async {
    try {
      print('AuthService: Attempting counselor login for $email');

      final response = await _dio.post(
        '/auth/counselor/login',
        data: {'email': email, 'password': password},
      );

      print(
        'AuthService: Counselor login response status: ${response.statusCode}',
      );
      print('AuthService: Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        // API returns: {"success": true, "userId": "...", "fullName": "...", "role": "counselor", "isVerified": true, "token": "..."}
        final user = User(
          id: data['userId'] ?? _generateId(),
          role: data['role'] ?? 'counselor',
          email: email, // Email not returned, use the one we sent
          fullName: data['fullName'],
          licenseNumber: null, // Not returned in login response
          schoolName: null, // Not returned in login response
          department: null, // Not returned in login response
          isVerified: data['isVerified'] ?? false,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        final token = data['token'] ?? '';

        return {'user': user, 'token': token, 'message': 'Login successful'};
      } else {
        throw Exception('Counselor login failed');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data;
        String errorMsg = 'Counselor login failed';
        if (errorData is Map) {
          errorMsg = errorData['error'] ?? errorData['message'] ?? errorMsg;
        }
        throw Exception(errorMsg);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// OLD METHOD - Keep for backward compatibility but mark as deprecated
  @Deprecated('Use login() instead which automatically detects role')
  Future<Map<String, dynamic>> _oldLogin({
    required String email,
    required String password,
  }) async {
    try {
      print('AuthService: Attempting login for $email');

      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      print('AuthService: Response status code: ${response.statusCode}');
      print('AuthService: Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        final userData = data['user'];

        print('AuthService: User role from API: ${userData['role']}');

        final user = User(
          id: userData['id'] ?? userData['_id'] ?? _generateId(),
          role: userData['role'],
          email: userData['email'],
          anonymousId: userData['anonymousId'],
          displayName: userData['displayName'],
          fullName: userData['fullName'],
          licenseNumber: userData['license'] ?? userData['licenseNumber'],
          schoolName: userData['schoolName'],
          department: userData['department'],
          isVerified: userData['isVerified'],
          createdAt: DateTime.parse(
            userData['createdAt'] ?? DateTime.now().toIso8601String(),
          ),
          lastLogin: DateTime.now(),
        );

        final token = data['token'] ?? data['accessToken'] ?? '';

        print('AuthService: User object created successfully');

        return {
          'user': user,
          'token': token,
          'message': data['message'] ?? 'Login successful',
        };
      } else {
        throw Exception(
          'Login failed with status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('AuthService: DioException - ${e.message}');
      if (e.response != null) {
        print('AuthService: Error response data: ${e.response?.data}');
        throw Exception(e.response?.data['message'] ?? 'Login failed');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('AuthService: Unexpected error - $e');
      throw Exception('Login failed: $e');
    }
  }

  // ===== Helper Methods =====

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  String _generateAnonymousId() {
    final random = DateTime.now().millisecondsSinceEpoch % 99999;
    return 'ANON-${random.toString().padLeft(5, '0')}';
  }

  /// Get latest user profile from server
  Future<User> getUserProfile() async {
    try {
      final token = getAuthToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await _dio.get(
        '/auth/profile',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        final user = User.fromJson(userData);
        saveUserSession(user, token); // Update local cache
        return user;
      } else {
        throw Exception('Failed to fetch profile');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch profile',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  /// Update user profile
  Future<User> updateProfile(User user) async {
    try {
      final token = getAuthToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await _dio.patch(
        '/auth/profile',
        data: user.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final updatedUserData = response.data['user'];
        final updatedUser = User.fromJson(updatedUserData);
        saveUserSession(updatedUser, token);
        return updatedUser;
      } else {
        throw Exception('Profile update failed');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Profile update failed');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Profile update failed: $e');
    }
  }

  /// Register device token for push notifications
  /// Register device token for push notifications
  Future<void> registerDeviceToken({required String token}) async {
    try {
      final authToken = getAuthToken();
      if (authToken == null) {
        print('AuthService: Skipping device registration - Not authenticated');
        return;
      }

      print('AuthService: Registering device token');

      String deviceType = 'web';
      if (GetPlatform.isAndroid) deviceType = 'android';
      if (GetPlatform.isIOS) deviceType = 'ios';

      final payload = {
        'token': token,
        'deviceType': deviceType,
        'deviceName': GetPlatform.isWeb ? 'Web Browser' : 'Mobile Device',
        'appVersion': '1.0.0',
        'osVersion': '1.0',
      };

      print('AuthService: Sending payload: $payload');

      final response = await _dio.post('/devices/register', data: payload);

      print(
        'AuthService: Device registration response: ${response.statusCode}',
      );
    } catch (e) {
      print('AuthService: Failed to register device token - $e');
      // We process this silently so it doesn't block login navigation
    }
  }

  /// Check if counselor is verified
  bool isCounselorVerified() {
    final user = getCurrentUser();
    if (user == null || !user.isCounselor) return false;
    return user.isVerified ?? false;
  }
}
