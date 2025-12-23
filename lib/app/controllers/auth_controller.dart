import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_voice/core/models/user.dart';
import 'package:safe_voice/core/services/auth_service.dart';
import 'package:safe_voice/core/services/notification_service.dart';
import 'package:safe_voice/app/routes/app_pages.dart';

class AuthController extends GetxController {
  final authService = AuthService();

  final currentUser = Rxn<User>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // DO NOT auto-check auth status here - it causes snackbar initialization errors
    // Auth check will be triggered manually from RoleSelectionScreen after first frame
  }

  /// Check if user is already logged in and navigate accordingly
  void checkAuthStatus() {
    try {
      final user = authService.getCurrentUser();
      final token = authService.getAuthToken();

      if (user != null && token != null) {
        currentUser.value = user;

        // Register push token
        _registerPushToken();

        // Navigate to appropriate home screen based on role
        print('AuthController: User found in storage - ${user.role}');
        Future.delayed(const Duration(milliseconds: 100), () {
          if (user.isStudent) {
            Get.offAllNamed(AppRoutes.STUDENT_HOME);
          } else if (user.isCounselor) {
            Get.offAllNamed(AppRoutes.COUNSELOR_HOME);
          }
        });
      } else {
        print('AuthController: No user found in storage');
      }
    } catch (e) {
      print('AuthController: Error validating session - $e');
      // authService.logout();
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

      // Register push token
      _registerPushToken();

      // Navigate to student home
      Get.offAllNamed(AppRoutes.STUDENT_HOME);

      // Show success message after navigation completes
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.snackbar(
          'Success',
          'Welcome! Your anonymous ID is: ${user.anonymousId}',
          snackPosition: SnackPosition.BOTTOM,
        );
      });
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Registration Failed',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
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
    required String phone,
    String? schoolName,
    String? department,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await authService.registerCounselor(
        email: email,
        password: password,
        fullName: fullName,
        licenseNumber: licenseNumber,
        phone: phone,
        schoolName: schoolName,
        department: department,
      );

      final user = result['user'] as User;
      final token = result['token'] as String;

      authService.saveUserSession(user, token);
      currentUser.value = user;

      // Register push token
      _registerPushToken();

      // Navigate to counselor home
      Get.offAllNamed(AppRoutes.COUNSELOR_HOME);

      // Show success message after navigation completes
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.snackbar(
          'Account Created',
          'Your counselor account is pending admin verification',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      });
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Registration Failed',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Login (works for both students and counselors)
  Future<void> login({required String email, required String password}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await authService.login(email: email, password: password);

      final user = result['user'] as User;
      final token = result['token'] as String;

      authService.saveUserSession(user, token);
      currentUser.value = user;

      // Register push token
      _registerPushToken();

      // Navigate based on role
      if (user.isStudent) {
        Get.offAllNamed(AppRoutes.STUDENT_HOME);
      } else {
        Get.offAllNamed(AppRoutes.COUNSELOR_HOME);
      }

      // Show welcome message after navigation completes
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.snackbar(
          'Welcome Back',
          user.isStudent
              ? 'Logged in as ${user.anonymousId}'
              : 'Logged in as ${user.fullName}',
          snackPosition: SnackPosition.BOTTOM,
        );
      });
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Login Failed',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
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

  /// Helper to register push token
  Future<void> _registerPushToken() async {
    try {
      // Find NotificationService - might fail if not initialized yet, but in AuthController it should be ready
      if (Get.isRegistered<NotificationService>()) {
        final notificationService = Get.find<NotificationService>();
        final token = await notificationService.getDeviceToken();
        if (token != null) {
          await authService.registerDeviceToken(token: token);
        }
      }
    } catch (e) {
      print('AuthController: Failed to register push token - $e');
    }
  }
}
