import 'package:get/get.dart';
import 'package:safe_voice/core/models/report.dart';
import 'package:safe_voice/core/services/local_storage_service.dart';
import 'package:safe_voice/core/services/auth_service.dart';
import 'package:safe_voice/core/utils/tracking_code_generator.dart';
import 'package:safe_voice/core/utils/urgency_classifier.dart';


class ReportController extends GetxController {
  final localStorageService = LocalStorageService();
  final authService = AuthService();

  final currentReport = Rxn<Report>();
  final reports = <Report>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadReports();
  }

  void loadReports() {
    reports.value = localStorageService.getReports();
  }

  Future<String> submitReport({
    required String incidentType,
    required String description,
    String? location,
    List<String>? evidencePaths,
  }) async {
    try {
      isLoading.value = true;

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
        userId: userId, // Link to user account (backend use only)
        anonymousId: anonymousId, // What counselor sees
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
    } catch (e) {
      print('Error submitting report: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Report? getReportByTrackingCode(String trackingCode) {
    try {
      return reports.firstWhere((r) => r.trackingCode == trackingCode);
    } catch (e) {
      return null;
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
