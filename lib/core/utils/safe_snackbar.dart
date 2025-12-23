import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Safe wrapper for Get.snackbar that ensures the overlay is ready
/// This prevents LateInitializationError during app startup
class SafeSnackbar {
  /// Show a snackbar only if the overlay is ready
  /// If not ready, it will be delayed until the next frame
  static void show({
    required String title,
    required String message,
    SnackPosition snackPosition = SnackPosition.BOTTOM,
    Color? backgroundColor,
    Color? colorText,
    Duration? duration,
    int maxRetries = 3,
  }) {
    _tryShowSnackbar(
      title: title,
      message: message,
      snackPosition: snackPosition,
      backgroundColor: backgroundColor,
      colorText: colorText,
      duration: duration,
      retryCount: 0,
      maxRetries: maxRetries,
    );
  }

  static void _tryShowSnackbar({
    required String title,
    required String message,
    required SnackPosition snackPosition,
    Color? backgroundColor,
    Color? colorText,
    Duration? duration,
    required int retryCount,
    required int maxRetries,
  }) {
    try {
      // Check if Get context is available
      if (Get.context == null) {
        if (retryCount < maxRetries) {
          // Retry after a delay
          Future.delayed(Duration(milliseconds: 100 * (retryCount + 1)), () {
            _tryShowSnackbar(
              title: title,
              message: message,
              snackPosition: snackPosition,
              backgroundColor: backgroundColor,
              colorText: colorText,
              duration: duration,
              retryCount: retryCount + 1,
              maxRetries: maxRetries,
            );
          });
        } else {
          print(
            'SafeSnackbar: Failed to show snackbar after $maxRetries retries - $title: $message',
          );
        }
        return;
      }

      // Show the snackbar
      Get.snackbar(
        title,
        message,
        snackPosition: snackPosition,
        backgroundColor: backgroundColor,
        colorText: colorText,
        duration: duration,
      );
    } catch (e) {
      if (retryCount < maxRetries) {
        // Retry after a delay
        Future.delayed(Duration(milliseconds: 100 * (retryCount + 1)), () {
          _tryShowSnackbar(
            title: title,
            message: message,
            snackPosition: snackPosition,
            backgroundColor: backgroundColor,
            colorText: colorText,
            duration: duration,
            retryCount: retryCount + 1,
            maxRetries: maxRetries,
          );
        });
      } else {
        print('SafeSnackbar: Error showing snackbar - $e');
        print('SafeSnackbar: $title: $message');
      }
    }
  }

  /// Show a success snackbar
  static void success(String message, {String title = 'Success'}) {
    show(
      title: title,
      message: message,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
    );
  }

  /// Show an error snackbar
  static void error(String message, {String title = 'Error'}) {
    show(
      title: title,
      message: message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  /// Show an info snackbar
  static void info(String message, {String title = 'Info'}) {
    show(
      title: title,
      message: message,
      backgroundColor: const Color(0xFF2196F3),
      colorText: Colors.white,
    );
  }

  /// Show a warning snackbar
  static void warning(String message, {String title = 'Warning'}) {
    show(
      title: title,
      message: message,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }
}
