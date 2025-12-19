import 'package:get_storage/get_storage.dart';
import '../models/user.dart';

/// Authentication service for anonymous but controlled user management
/// Students: No real name required, gets anonymousId
/// Counselors: Full name required, must be verified
class AuthService {
  final box = GetStorage();
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'auth_token';

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

  // ===== MOCK REGISTRATION (Replace with actual API calls) =====

  /// Register student - Anonymous but controlled
  /// No real name required, gets ANON-12345 ID
  Future<Map<String, dynamic>> registerStudent({
    required String password,
    String? email, // Optional for password recovery
    String? displayName, // Optional nickname
  }) async {
    // TODO: Replace with actual API call
    // POST /api/auth/register/student
    
    await Future.delayed(const Duration(seconds: 1)); // Simulate network

    final userId = _generateId();
    final anonymousId = _generateAnonymousId();

    final user = User(
      id: userId,
      role: 'student',
      email: email,
      anonymousId: anonymousId,
      displayName: displayName,
      createdAt: DateTime.now(),
    );

    const token = 'mock-jwt-token-student';

    return {
      'user': user,
      'token': token,
      'message': 'Student account created successfully',
    };
  }

  /// Register counselor - Requires verification
  /// Full name and license required
  Future<Map<String, dynamic>> registerCounselor({
    required String email,
    required String password,
    required String fullName,
    required String licenseNumber,
  }) async {
    // TODO: Replace with actual API call
    // POST /api/auth/register/counselor
    
    await Future.delayed(const Duration(seconds: 1)); // Simulate network

    final userId = _generateId();

    final user = User(
      id: userId,
      role: 'counselor',
      email: email,
      fullName: fullName,
      licenseNumber: licenseNumber,
      isVerified: false, // Admin must verify
      createdAt: DateTime.now(),
    );

    const token = 'mock-jwt-token-counselor';

    return {
      'user': user,
      'token': token,
      'message': 'Counselor account created. Awaiting admin verification.',
    };
  }

  /// Login - Works for both students and counselors
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // TODO: Replace with actual API call
    // POST /api/auth/login
    
    await Future.delayed(const Duration(seconds: 1)); // Simulate network

    // Mock response - student
    final user = User(
      id: _generateId(),
      role: 'student',
      email: email,
      anonymousId: 'ANON-19284',
      displayName: 'Anonymous User',
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );

    const token = 'mock-jwt-token-login';

    return {
      'user': user,
      'token': token,
      'message': 'Login successful',
    };
  }

  // ===== Helper Methods =====

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  String _generateAnonymousId() {
    final random = DateTime.now().millisecondsSinceEpoch % 99999;
    return 'ANON-${random.toString().padLeft(5, '0')}';
  }

  /// Update user profile
  Future<User> updateProfile(User user) async {
    // TODO: Replace with actual API call
    // PATCH /api/auth/profile
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    saveUserSession(user, getAuthToken()!);
    return user;
  }

  /// Check if counselor is verified
  bool isCounselorVerified() {
    final user = getCurrentUser();
    if (user == null || !user.isCounselor) return false;
    return user.isVerified ?? false;
  }
}
