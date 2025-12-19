import 'package:get/get.dart';
import 'package:safe_voice/core/models/user.dart';
import 'package:safe_voice/core/services/auth_service.dart';
import 'package:safe_voice/app/routes/app_pages.dart';

class AuthController extends GetxController {
  final authService = AuthService();

  final currentUser = Rxn<User>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  /// Check if user is already logged in
  void checkAuthStatus() {
    final user = authService.getCurrentUser();
    if (user != null) {
      currentUser.value = user;
    }
  }

  /// Register as student (anonymous but controlled)
  Future<void> registerStudent({
    required String password,
    String? email,
    String? displayName,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await authService.registerStudent(
        password: password,
        email: email,
        displayName: displayName,
      );

      final user = result['user'] as User;
      final token = result['token'] as String;

      authService.saveUserSession(user, token);
      currentUser.value = user;

      Get.snackbar(
        'Success',
        'Welcome! Your anonymous ID is: ${user.anonymousId}',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Navigate to student home
      Get.offAllNamed(AppRoutes.STUDENT_HOME);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Registration Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Register as counselor (requires verification)
  Future<void> registerCounselor({
    required String email,
    required String password,
    required String fullName,
    required String licenseNumber,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await authService.registerCounselor(
        email: email,
        password: password,
        fullName: fullName,
        licenseNumber: licenseNumber,
      );

      final user = result['user'] as User;
      final token = result['token'] as String;

      authService.saveUserSession(user, token);
      currentUser.value = user;

      Get.snackbar(
        'Account Created',
        'Your counselor account is pending admin verification',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );

      // Navigate to counselor home
      Get.offAllNamed(AppRoutes.COUNSELOR_HOME);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Registration Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Login (works for both students and counselors)
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await authService.login(
        email: email,
        password: password,
      );

      final user = result['user'] as User;
      final token = result['token'] as String;

      authService.saveUserSession(user, token);
      currentUser.value = user;

      Get.snackbar(
        'Welcome Back',
        user.isStudent 
            ? 'Logged in as ${user.anonymousId}' 
            : 'Logged in as ${user.fullName}',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Navigate based on role
      if (user.isStudent) {
        Get.offAllNamed(AppRoutes.STUDENT_HOME);
      } else {
        Get.offAllNamed(AppRoutes.COUNSELOR_HOME);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Login Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout
  void logout() {
    authService.logout();
    currentUser.value = null;
    Get.offAllNamed(AppRoutes.ROLE_SELECTION);
  }

  /// Update user profile
  Future<void> updateProfile(User updatedUser) async {
    try {
      isLoading.value = true;
      final user = await authService.updateProfile(updatedUser);
      currentUser.value = user;
      
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Update Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Check if current user is verified counselor
  bool get isVerifiedCounselor {
    return authService.isCounselorVerified();
  }

  /// Get display name for UI
  String get displayName {
    return currentUser.value?.publicDisplayName ?? 'User';
  }

  bool get isLoggedIn => currentUser.value != null;
  bool get isStudent => currentUser.value?.isStudent ?? false;
  bool get isCounselor => currentUser.value?.isCounselor ?? false;
}
