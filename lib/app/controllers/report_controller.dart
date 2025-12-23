import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_voice/core/models/report.dart';
import 'package:safe_voice/core/services/local_storage_service.dart';
import 'package:safe_voice/core/services/auth_service.dart';
import 'package:safe_voice/core/services/report_service.dart';
import 'package:safe_voice/core/services/cloudinary_service.dart';
import 'package:safe_voice/core/utils/tracking_code_generator.dart';
import 'package:safe_voice/core/utils/urgency_classifier.dart';
import 'dart:io';

class ReportController extends GetxController {
  final localStorageService = LocalStorageService();
  final authService = AuthService();
  final reportService = ReportService();
  final cloudinaryService = CloudinaryService();

  final currentReport = Rxn<Report>();
  final reports = <Report>[].obs;
  final availableCases = <Map<String, dynamic>>[].obs;
  final selectedCaseDetails = Rxn<Map<String, dynamic>>();
  final isLoading = false.obs;
  final uploadProgress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadReports();
  }

  void loadReports() {
    // Load from local storage for offline access
    reports.value = localStorageService.getReports();

    // Also try to fetch from API
    fetchReportsFromAPI();
  }

  /// Fetch reports from API
  Future<void> fetchReportsFromAPI() async {
    try {
      final apiReports = await reportService.getMyReports();

      // Merge with local reports
      for (var apiReport in apiReports) {
        final existingIndex = reports.indexWhere((r) => r.id == apiReport.id);
        if (existingIndex >= 0) {
          reports[existingIndex] = apiReport;
        } else {
          reports.add(apiReport);
        }
      }

      // Save merged reports to local storage
      for (var report in apiReports) {
        await localStorageService.saveReport(report);
      }
    } catch (e) {
      print('Error fetching reports from API: $e');
      // Silent fail - local reports still available
    }
  }

  /// Fetch counselor cases from API
  Future<void> fetchCounselorCases() async {
    try {
      isLoading.value = true;
      final cases = await reportService.getMyCases();

      // Replace reports with counselor cases
      reports.value = cases;

      // Save to local storage
      for (var report in cases) {
        await localStorageService.saveReport(report);
      }

      print('ReportController: Fetched ${cases.length} counselor cases');
      // Debug: show ids / tracking codes so developer can see what arrived
      try {
        final ids = cases.map((r) => r.id).toList();
        final caseCodes = cases.map((r) => r.trackingCode ?? r.id).toList();
        print('ReportController DEBUG: case ids: $ids');
        print('ReportController DEBUG: case codes: $caseCodes');
      } catch (e) {
        print('ReportController DEBUG: failed to print case list: $e');
      }
    } catch (e) {
      print('Error fetching counselor cases from API: $e');
      Get.snackbar(
        'Error',
        'Failed to load cases: ${e.toString().replaceAll('Exception: ', '')}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch available cases for counselors
  Future<void> fetchAvailableCases() async {
    try {
      isLoading.value = true;
      final cases = await reportService.getAvailableCases();
      availableCases.assignAll(cases);
      print('ReportController: fetched ${cases.length} available cases');
    } catch (e) {
      print('ReportController: Error fetching available cases - $e');
      Get.snackbar(
        'Error',
        'Failed to load available cases: ${e.toString().replaceAll('Exception: ', '')}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch case details (case + report) by caseId and return the parsed map
  Future<Map<String, dynamic>?> fetchCaseDetails(String caseId) async {
    try {
      isLoading.value = true;
      final result = await reportService.getCaseByCaseId(caseId);
      if (result != null) {
        selectedCaseDetails.value = result;
        print('ReportController: fetchCaseDetails result: $result');
        return result;
      }
      return null;
    } catch (e) {
      print('ReportController: Error fetching case details - $e');
      // Delay error snackbar to avoid showing during build
      Future.delayed(const Duration(milliseconds: 100), () {
        Get.snackbar(
          'Error',
          'Failed to fetch case details: ${e.toString().replaceAll('Exception: ', '')}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
      });
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update a case's status (new, active, escalated, closed)
  Future<void> updateCaseStatus(String caseId, String status) async {
    try {
      isLoading.value = true;
      final result = await reportService.updateCaseStatus(caseId, status);

      final success = result['success'] == true || result.containsKey('case');
      final message =
          result['message'] ??
          (success ? 'Case updated' : 'Failed to update case');

      if (success) {
        Get.snackbar('Success', message, snackPosition: SnackPosition.BOTTOM);

        // If availableCases contains this item, update its status
        final idx = availableCases.indexWhere(
          (c) => (c['id'] ?? '') == caseId || (c['caseId'] ?? '') == caseId,
        );
        if (idx >= 0) {
          final updatedCase = result['case'] ?? result;
          if (updatedCase is Map<String, dynamic>) {
            availableCases[idx] = updatedCase;
          }
        }

        // Update reports list (assigned cases) by re-fetching
        await fetchCounselorCases();

        // Update selectedCaseDetails if it matches
        if (selectedCaseDetails.value != null) {
          final selId =
              (selectedCaseDetails.value?['case']?['id'] ??
                      selectedCaseDetails.value?['id'])
                  ?.toString();
          if (selId == caseId) {
            selectedCaseDetails.value = result['case'] ?? result;
          }
        }
      } else {
        Get.snackbar(
          'Error',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
      }
    } catch (e) {
      print('ReportController: Error updating case status - $e');
      Get.snackbar(
        'Error',
        'Failed to update case status: ${e.toString().replaceAll('Exception: ', '')}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Update a case's risk level (low, medium, high, critical)
  Future<void> updateCaseRiskLevel(String caseId, String riskLevel) async {
    try {
      isLoading.value = true;
      final result = await reportService.updateCaseRiskLevel(caseId, riskLevel);

      final success = result['success'] == true || result.containsKey('case');
      final message =
          result['message'] ??
          (success ? 'Case risk level updated' : 'Failed to update risk level');

      if (success) {
        Get.snackbar('Success', message, snackPosition: SnackPosition.BOTTOM);

        // Update availableCases if present
        final idx = availableCases.indexWhere(
          (c) => (c['id'] ?? '') == caseId || (c['caseId'] ?? '') == caseId,
        );
        if (idx >= 0) {
          final updatedCase = result['case'] ?? result;
          if (updatedCase is Map<String, dynamic>) {
            availableCases[idx] = updatedCase;
          }
        }

        // Refresh assigned cases list
        await fetchCounselorCases();

        // Update selectedCaseDetails if it matches
        if (selectedCaseDetails.value != null) {
          final selId =
              (selectedCaseDetails.value?['case']?['id'] ??
                      selectedCaseDetails.value?['id'])
                  ?.toString();
          if (selId == caseId) {
            selectedCaseDetails.value = result['case'] ?? result;
          }
        }
      } else {
        Get.snackbar(
          'Error',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
      }
    } catch (e) {
      print('ReportController: Error updating case risk level - $e');
      Get.snackbar(
        'Error',
        'Failed to update risk level: ${e.toString().replaceAll('Exception: ', '')}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Send a message as counselor to a case (by mongo id)
  Future<void> sendCounselorMessage(String caseMongoId, String content) async {
    try {
      isLoading.value = true;
      await reportService.sendCounselorMessage(caseMongoId, content);
      Get.snackbar(
        'Success',
        'Message sent',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('ReportController: Error sending counselor message - $e');
      Get.snackbar(
        'Error',
        'Failed to send message: ${e.toString().replaceAll('Exception: ', '')}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Claim a case and refresh assigned cases
  Future<void> claimCase(String caseId) async {
    try {
      isLoading.value = true;
      final result = await reportService.claimCase(caseId);
      final success = result['success'] == true;
      final message =
          result['message'] ??
          (success ? 'Claimed successfully' : 'Failed to claim');

      if (success) {
        Get.snackbar('Success', message, snackPosition: SnackPosition.BOTTOM);

        // Remove claimed case from availableCases using MongoDB _id (field 'id')
        availableCases.removeWhere((c) => (c['id'] ?? '') == caseId);

        // Refresh assigned cases so counselor sees newly claimed case
        await fetchCounselorCases();
      } else {
        Get.snackbar(
          'Error',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
      }
    } catch (e) {
      print('ReportController: Error claiming case - $e');
      Get.snackbar(
        'Error',
        'Failed to claim case: ${e.toString().replaceAll('Exception: ', '')}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> submitReport({
    required String incidentType,
    required String description,
    String? location,
    List<String>? evidencePaths,
  }) async {
    try {
      isLoading.value = true;
      uploadProgress.value = 0.0;

      String? evidenceUrl;

      // Upload images to Cloudinary if evidence paths are provided
      if (evidencePaths != null && evidencePaths.isNotEmpty) {
        try {
          print(
            'ReportController: 📤 Starting upload of ${evidencePaths.length} image(s) to Cloudinary',
          );
          uploadProgress.value = 0.05;

          // Convert paths to File objects
          final imageFiles = evidencePaths.map((path) => File(path)).toList();

          print('ReportController: Files prepared, starting upload...');

          // Upload to Cloudinary with progress callback
          final uploadedUrls = await cloudinaryService.uploadMultipleImages(
            imageFiles,
            onProgress: (progress) {
              // Map 0-1 progress to 0.05-0.5 range (45% of total progress for upload)
              uploadProgress.value = 0.05 + (progress * 0.45);
              print(
                'ReportController: Upload progress: ${(uploadProgress.value * 100).toInt()}%',
              );
            },
          );

          if (uploadedUrls.isNotEmpty) {
            // Use the first uploaded URL as primary evidence
            evidenceUrl = uploadedUrls.first;
            print('ReportController: ✅ Images uploaded successfully!');
            print('ReportController: URLs: $uploadedUrls');
            uploadProgress.value = 0.5;

            // Show success notification
            Get.snackbar(
              '✓ Image Uploaded',
              'Evidence uploaded successfully',
              snackPosition: SnackPosition.TOP,
              duration: const Duration(seconds: 2),
              backgroundColor: const Color(0xFF4CAF50),
              colorText: Colors.white,
            );
          } else {
            print('ReportController: ⚠️ No images were uploaded');
            throw Exception('No images were uploaded');
          }
        } catch (e) {
          print('ReportController: ❌ Failed to upload images: $e');
          // Continue without images - don't fail the entire report
          Get.snackbar(
            '⚠️ Upload Warning',
            'Failed to upload images: ${e.toString().replaceAll('Exception: ', '')}',
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          uploadProgress.value = 0.5;
        }
      }

      uploadProgress.value = 0.6;
      print('ReportController: 📝 Submitting report to API...');

      // Submit to API with the Cloudinary URL
      final result = await reportService.submitReport(
        incidentType: incidentType,
        description: description,
        evidenceUrl: evidenceUrl,
        schoolName: location,
      );

      uploadProgress.value = 0.8;

      final trackingCode = result['trackingCode'] as String;
      final reportData = result['report'] as Map<String, dynamic>;

      // Get current user info
      final currentUser = authService.getCurrentUser();

      // Create local report object with API response data
      final report = Report(
        id:
            reportData['id'] ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        trackingCode: trackingCode,
        userId: currentUser?.id,
        anonymousId: reportData['anonymousId'] ?? currentUser?.anonymousId,
        incidentType: incidentType,
        description: description,
        location: location,
        evidencePaths: evidenceUrl != null
            ? [evidenceUrl]
            : null, // Store Cloudinary URL
        urgencyLevel: UrgencyClassifier.classify(incidentType, description),
        status: reportData['status'] ?? 'pending',
        submittedAt: reportData['createdAt'] != null
            ? DateTime.parse(reportData['createdAt'])
            : DateTime.now(),
        isAnonymous: true,
      );

      // Save to local storage for offline access
      await localStorageService.saveReport(report);
      loadReports();

      currentReport.value = report;
      uploadProgress.value = 1.0;

      return trackingCode;
    } catch (e) {
      print('Error submitting report: $e');

      // Fallback to local-only submission if API fails
      return await _submitReportLocally(
        incidentType: incidentType,
        description: description,
        location: location,
        evidencePaths: evidencePaths,
      );
    } finally {
      isLoading.value = false;
      uploadProgress.value = 0.0;
    }
  }

  /// Fallback method for offline report submission
  Future<String> _submitReportLocally({
    required String incidentType,
    required String description,
    String? location,
    List<String>? evidencePaths,
  }) async {
    // Get current user info
    final currentUser = authService.getCurrentUser();
    final userId = currentUser?.id;
    final anonymousId = currentUser?.anonymousId;

    // Generate tracking code
    final trackingCode = TrackingCodeGenerator.generate();

    // Classify urgency
    final urgencyLevel = UrgencyClassifier.classify(incidentType, description);

    // Create report with user linking
    final report = Report(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      trackingCode: trackingCode,
      userId: userId,
      anonymousId: anonymousId,
      incidentType: incidentType,
      description: description,
      location: location,
      evidencePaths: evidencePaths,
      urgencyLevel: urgencyLevel,
      status: 'submitted',
      submittedAt: DateTime.now(),
      isAnonymous: true,
    );

    // Save to local storage
    await localStorageService.saveReport(report);
    loadReports();

    currentReport.value = report;
    return trackingCode;
  }

  Report? getReportByTrackingCode(String trackingCode) {
    try {
      return reports.firstWhere((r) => r.trackingCode == trackingCode);
    } catch (e) {
      return null;
    }
  }

  /// Fetch report by tracking code from API
  Future<Report?> fetchReportByTrackingCode(String trackingCode) async {
    try {
      isLoading.value = true;
      final reportData = await reportService.getReportByTrackingCode(
        trackingCode,
      );

      if (reportData != null) {
        // Convert Map to Report object
        final report = Report.fromJson(reportData);

        // Save to local storage
        await localStorageService.saveReport(report);
        loadReports();

        return report;
      }

      return null;
    } catch (e) {
      print('Error fetching report by tracking code: $e');
      // Fallback to local search
      return getReportByTrackingCode(trackingCode);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateReportStatus(String reportId, String newStatus) async {
    final report = reports.firstWhere((r) => r.id == reportId);
    final updatedReport = report.copyWith(status: newStatus);
    await localStorageService.updateReport(updatedReport);
    loadReports();
  }

  List<Report> getUrgentReports() {
    return reports.where((r) => r.urgencyLevel == 'urgent').toList();
  }

  List<Report> getHighPriorityReports() {
    return reports.where((r) => r.urgencyLevel == 'high').toList();
  }

  List<Report> getMediumPriorityReports() {
    return reports.where((r) => r.urgencyLevel == 'medium').toList();
  }
}
