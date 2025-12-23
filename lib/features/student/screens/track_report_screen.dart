import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/controllers/report_controller.dart';
import '../../../core/utils/urgency_classifier.dart';
import 'chat_with_counselor_screen.dart';

class TrackReportScreen extends StatefulWidget {
  const TrackReportScreen({Key? key}) : super(key: key);

  @override
  State<TrackReportScreen> createState() => _TrackReportScreenState();
}

class _TrackReportScreenState extends State<TrackReportScreen>
    with SingleTickerProviderStateMixin {
  final reportController = Get.find<ReportController>();
  final trackingCodeController = TextEditingController();
  var foundReport = Rxn<Map<String, dynamic>>();
  var isSearching = false.obs;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Track Report',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF4A5AAF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [const Color(0xFF4A5AAF), Colors.grey.shade50],
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildSearchSection(),
                  const SizedBox(height: 30),
                  Obx(() => _buildResults()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.search,
                  color: Colors.blue.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Track Your Report',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Enter your tracking code to check status',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: trackingCodeController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'TRACK-ABC123DEF',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
              prefixIcon: Icon(
                Icons.tag,
                color: Colors.grey.shade600,
                size: 20,
              ),
              suffixIcon: trackingCodeController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                      onPressed: () {
                        trackingCodeController.clear();
                        setState(() => foundReport.value = null);
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
          const SizedBox(height: 16),
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isSearching.value ? null : _searchReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A5AAF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: isSearching.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Search Report',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (foundReport.value == null) {
      return const SizedBox();
    }

    final report = foundReport.value!;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Report Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatusCard(report),
          const SizedBox(height: 16),
          _buildDetailsCard(report),
          const SizedBox(height: 16),
          _buildTimelineCard(report),
          const SizedBox(height: 16),
          _buildMessagesCard(report),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildStatusCard(Map<String, dynamic> report) {
    final status = report['status'] as String;
    final statusInfo = _getStatusInfo(status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: statusInfo['gradient'] as List<Color>,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (statusInfo['color'] as Color).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(statusInfo['icon'] as IconData, color: Colors.white, size: 48),
          const SizedBox(height: 12),
          Text(
            statusInfo['label'] as String,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            statusInfo['message'] as String,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(Map<String, dynamic> report) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'Report Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            icon: Icons.tag,
            label: 'Tracking Code',
            value: report['trackingCode'],
            valueColor: Colors.blue.shade700,
          ),
          const Divider(height: 24),
          _buildDetailRow(
            icon: Icons.report_problem_outlined,
            label: 'Incident Type',
            value: report['incidentType'],
          ),
          const Divider(height: 24),
          _buildDetailRow(
            icon: Icons.priority_high,
            label: 'Urgency Level',
            value: UrgencyClassifier.getLabel(report['urgencyLevel']),
            valueWidget: _buildUrgencyBadge(report['urgencyLevel']),
          ),
          const Divider(height: 24),
          _buildDetailRow(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: report['location'] ?? 'Not specified',
          ),
          const Divider(height: 24),
          _buildDetailRow(
            icon: Icons.access_time,
            label: 'Submitted',
            value: _formatDateTime(report['submittedAt']),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(Map<String, dynamic> report) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.timeline, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'Progress Timeline',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTimelineItem(
            'Report Submitted',
            _formatDateTime(report['submittedAt']),
            isCompleted: true,
            isFirst: true,
          ),
          _buildTimelineItem(
            'Under Review',
            'In progress',
            isCompleted:
                report['status'] == 'under_review' ||
                report['status'] == 'resolved' ||
                report['status'] == 'escalated',
          ),
          _buildTimelineItem(
            'Resolution',
            'Pending',
            isCompleted: report['status'] == 'resolved',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String subtitle, {
    bool isCompleted = false,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      children: [
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2,
                height: 20,
                color: isCompleted
                    ? Colors.blue.shade700
                    : Colors.grey.shade300,
              ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.blue.shade700
                    : Colors.grey.shade300,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: isCompleted
                        ? Colors.blue.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 20,
                color: isCompleted
                    ? Colors.blue.shade700
                    : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? Colors.black87 : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessagesCard(Map<String, dynamic> report) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.message_outlined, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'Messages & Updates',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Chat with your assigned counselor for updates and support.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openChat(report),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A5AAF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.chat, size: 18),
                    label: const Text(
                      'Open Chat',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    Widget? valueWidget,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              valueWidget ??
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: valueColor ?? Colors.black87,
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUrgencyBadge(String urgency) {
    Color color;
    IconData icon;

    switch (urgency.toLowerCase()) {
      case 'high':
      case 'critical':
        color = Colors.red;
        icon = Icons.warning;
        break;
      case 'medium':
        color = Colors.orange;
        icon = Icons.report_problem;
        break;
      default:
        color = Colors.green;
        icon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            UrgencyClassifier.getLabel(urgency),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'submitted':
        return {
          'label': 'Submitted',
          'message': 'Your report has been received',
          'color': Colors.blue,
          'gradient': [Colors.blue.shade600, Colors.blue.shade400],
          'icon': Icons.check_circle,
        };
      case 'under_review':
        return {
          'label': 'Under Review',
          'message': 'Our team is reviewing your report',
          'color': Colors.orange,
          'gradient': [Colors.orange.shade600, Colors.orange.shade400],
          'icon': Icons.rate_review,
        };
      case 'resolved':
        return {
          'label': 'Resolved',
          'message': 'Your report has been resolved',
          'color': Colors.green,
          'gradient': [Colors.green.shade600, Colors.green.shade400],
          'icon': Icons.task_alt,
        };
      case 'escalated':
        return {
          'label': 'Escalated',
          'message': 'This case requires urgent attention',
          'color': Colors.red,
          'gradient': [Colors.red.shade600, Colors.red.shade400],
          'icon': Icons.priority_high,
        };
      default:
        return {
          'label': 'Pending',
          'message': 'Awaiting processing',
          'color': Colors.grey,
          'gradient': [Colors.grey.shade600, Colors.grey.shade400],
          'icon': Icons.hourglass_empty,
        };
    }
  }

  void _searchReport() async {
    final code = trackingCodeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a tracking code',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        icon: const Icon(Icons.error_outline, color: Colors.red),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    // Validate tracking code format (TRACK-XXXXXXXX)
    if (!code.startsWith('TRACK-') || code.length < 12) {
      Get.snackbar(
        'Invalid Format',
        'Tracking code should be in format: TRACK-XXXXXXXX',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
        icon: const Icon(Icons.info_outline, color: Colors.orange),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    try {
      isSearching.value = true;
      foundReport.value = null;

      // Fetch report from API
      final result = await reportController.reportService
          .getReportByTrackingCode(code);

      if (result != null &&
          result['success'] == true &&
          result['report'] != null) {
        final reportData = result['report'] as Map<String, dynamic>;

        // Convert API response to display format

        final extractedId = reportData['id'] ?? reportData['_id'];
        print('DEBUG: Extracted ID for chat: $extractedId');

        foundReport.value = {
          '_id': extractedId, // MongoDB ID for chat
          'reportId': extractedId, // Backup key
          'trackingCode': reportData['trackingCode'] ?? code,
          'incidentType': reportData['incidentType'] ?? 'Unknown',
          'description':
              reportData['description'] ?? 'No description available',
          'location': reportData['schoolName'] ?? 'Not specified',
          'urgencyLevel': _mapStatusToUrgency(reportData['status']),
          'status': reportData['status'] ?? 'pending',
          'submittedAt': reportData['createdAt'] != null
              ? DateTime.parse(reportData['createdAt'])
              : DateTime.now(),
          'anonymousId': reportData['anonymousId'],
        };

        _animationController.forward(from: 0);

        Get.snackbar(
          'Success',
          'Report found successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          icon: const Icon(Icons.check_circle, color: Colors.green),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 2),
        );
      } else if (result != null && result['error'] == 'not_found') {
        // Report not found (404)
        Get.snackbar(
          'Not Found',
          result['message'] ?? 'No report found with tracking code: $code',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade900,
          icon: const Icon(Icons.search_off, color: Colors.orange),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
        );
      } else if (result != null && result['error'] == 'network_error') {
        // Network error
        Get.snackbar(
          'Connection Error',
          result['message'] ?? 'Please check your internet connection',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          icon: const Icon(Icons.wifi_off, color: Colors.red),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
        );
      } else {
        // Generic error
        Get.snackbar(
          'Error',
          result?['message'] ?? 'Failed to search report. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          icon: const Icon(Icons.error_outline, color: Colors.red),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      print('Error searching report: $e');
      foundReport.value = null;
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        icon: const Icon(Icons.error_outline, color: Colors.red),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isSearching.value = false;
    }
  }

  // Map API status to urgency level for UI display
  String _mapStatusToUrgency(String? status) {
    // You can customize this mapping based on your needs
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'medium';
      case 'in_progress':
      case 'under_review':
        return 'high';
      case 'resolved':
        return 'low';
      case 'rejected':
        return 'low';
      default:
        return 'medium';
    }
  }

  String _formatDateTime(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _openChat(Map<String, dynamic> report) {
    print('DEBUG: Opening chat with report data keys: ${report.keys.toList()}');
    print(
      'DEBUG: Report ID values - id: ${report['id']}, _id: ${report['_id']}, reportId: ${report['reportId']}',
    );

    // Extract the report ID from the report data
    final reportId = report['id'] ?? report['_id'] ?? report['reportId'];

    if (reportId == null || reportId.toString().isEmpty) {
      Get.snackbar(
        'Error',
        'Unable to open chat. Report ID not found.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        icon: const Icon(Icons.error_outline, color: Colors.red),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    // Navigate to chat screen
    Get.to(
      () => ChatWithCounselorScreen(reportId: reportId.toString()),
      transition: Transition.rightToLeft,
    );
  }

  @override
  void dispose() {
    trackingCodeController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
