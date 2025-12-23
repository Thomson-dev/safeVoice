import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../app/controllers/report_controller.dart';
import '../../../core/utils/urgency_classifier.dart';
import '../../../core/models/report.dart';

class ReportDetailScreen extends StatefulWidget {
  const ReportDetailScreen({Key? key}) : super(key: key);

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen>
    with SingleTickerProviderStateMixin {
  final reportController = Get.find<ReportController>();
  final messageController = TextEditingController();
  late dynamic report;
  Map<String, dynamic>? _caseData;
  bool _isLoadingDetails = false;
  String? _caseId;
  late TabController _tabController;
  bool _isUpdating = false;
  List<Map<String, dynamic>> _messages = [];
  bool _isLoadingMessages = false;

  @override
  void initState() {
    super.initState();
    report = Get.arguments;
    String? caseId;
    if (report is String) {
      caseId = report as String;
    } else if (report is Map<String, dynamic>) {
      caseId =
          report['caseId'] ??
          report['case']?['caseId'] ??
          report['id'] ??
          report['case']?['id'];
    } else if (report is Report) {
      caseId = (report as Report).caseCode;
    }

    print('ReportDetailScreen: Extracted caseId: $caseId');

    if (caseId != null && caseId.isNotEmpty) {
      _caseId = caseId;
      // Delay fetching until after the first frame to avoid snackbar errors during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchDetailsForCase(caseId!);
      });
    }

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 2 && !_tabController.indexIsChanging) {
        _fetchMessages();
      }
    });

    // Also fetch messages initially if we have the ID to ensure readiness
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_caseId != null) {
        _fetchMessages();
      }
    });
  }

  Future<void> _fetchMessages() async {
    // We need the MongoDB _id for fetching messages
    String? caseMongoId;
    if (_caseData != null && _caseData!['id'] != null) {
      caseMongoId = _caseData!['id'].toString();
    } else if (report is Report && (report as Report).caseMongoId != null) {
      caseMongoId = (report as Report).caseMongoId.toString();
    }

    if (caseMongoId == null) {
      // Try to extract from report object if it's a map
      if (report is Map<String, dynamic>) {
        caseMongoId = report['caseMongoId'] ?? report['id'];
      }
    }

    if (caseMongoId == null) return;

    setState(() => _isLoadingMessages = true);
    try {
      final result = await reportController.reportService.getCaseMessages(
        caseMongoId,
      );
      if (result != null && result['messages'] != null) {
        setState(() {
          _messages = List<Map<String, dynamic>>.from(result['messages']);
        });
      }
    } catch (e) {
      print('ReportDetailScreen: Error fetching messages: $e');
    } finally {
      setState(() => _isLoadingMessages = false);
    }
  }

  Future<void> _fetchDetailsForCase(String caseId) async {
    _caseId = caseId;
    setState(() => _isLoadingDetails = true);
    try {
      final details = await reportController.fetchCaseDetails(caseId);
      print('ReportDetailScreen: Fetched case details: $details');
      if (details != null) {
        // Extract case-level data and report-level data
        _caseData = details['case'] ?? details['caseDetails'] ?? details;

        dynamic reportJson =
            details['report'] ??
            details['reportDetails'] ??
            details['case']?['report'] ??
            details;
        if (reportJson is Map<String, dynamic>) {
          try {
            final parsed = Report.fromJson(reportJson);
            report = parsed; // replace local report with strongly-typed Report
          } catch (e) {
            print('ReportDetailScreen: Failed to parse report JSON - $e');
            // leave report as-is
          }
        }
      }
    } catch (e) {
      print('ReportDetailScreen: Error fetching case details - $e');
    } finally {
      setState(() => _isLoadingDetails = false);
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
          // Background gradient header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.indigo.shade800,
                    Colors.indigo.shade600,
                    Colors.indigo.shade400,
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Custom header
                _buildHeader(),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildStatusCard(),
                        const SizedBox(height: 16),
                        _buildTabSection(),
                        const SizedBox(height: 30),
                      ],
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Case Details',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.tag, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          report.trackingCode ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'copy':
                        _copyTrackingCode();
                        break;
                      case 'share':
                        _shareCase();
                        break;
                      case 'export':
                        _exportCase();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'copy',
                      child: Row(
                        children: [
                          Icon(Icons.copy, size: 20),
                          SizedBox(width: 12),
                          Text('Copy Tracking Code'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share, size: 20),
                          SizedBox(width: 12),
                          Text('Share Case'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'export',
                      child: Row(
                        children: [
                          Icon(Icons.download, size: 20),
                          SizedBox(width: 12),
                          Text('Export Report'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildStatusItem(
                    icon: Icons.circle,
                    label: 'Status',
                    value: (report.status ?? 'unknown')
                        .replaceAll('_', ' ')
                        .toUpperCase(),
                    color: _getStatusColor(report.status ?? 'unknown'),
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade200),
                Expanded(
                  child: _buildStatusItem(
                    icon: Icons.warning_amber,
                    label: 'Priority',
                    value: UrgencyClassifier.getLabel(
                      report.urgencyLevel ?? 'medium',
                    ),
                    color: _getUrgencyColor(report.urgencyLevel ?? 'medium'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Submitted ${_formatDateTime(report.submittedAt ?? DateTime.now())}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTabSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade600, Colors.indigo.shade400],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              tabs: const [
                Tab(text: 'Details'),
                Tab(text: 'Actions'),
                Tab(text: 'Messages'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 700,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDetailsTab(),
                _buildActionsTab(),
                _buildMessagesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    // Show loading or helpful message when no details
    if (_isLoadingDetails) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Loading case details...'),
            ],
          ),
        ),
      );
    }

    if (_caseData == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'No case details available',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'No details were returned from the server for this case.',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: (_caseId == null)
                      ? null
                      : () => _fetchDetailsForCase(_caseId!),
                  child: const Text('Retry'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () async {
                    // Show the raw selectedCaseDetails for debugging
                    final raw = reportController.selectedCaseDetails.value;
                    Get.dialog(
                      Dialog(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SingleChildScrollView(
                            child: Text(
                              raw?.toString() ?? 'No controller data',
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Show Raw Debug'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Compose all details from _caseData, report, and lastMessage
    final caseData = _caseData ?? {};
    final lastMessage = caseData['lastMessage'] ?? {};
    final messageCount = caseData['messageCount']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailSection(
              icon: Icons.info_outline,
              title: 'Case Info',
              items: [
                {
                  'label': 'Case ID',
                  'value':
                      caseData['caseId']?.toString() ??
                      caseData['id']?.toString() ??
                      '',
                },
                {
                  'label': 'Status',
                  'value': caseData['status']?.toString() ?? '',
                },
                {
                  'label': 'Risk Level',
                  'value': caseData['riskLevel']?.toString() ?? '',
                },
                {
                  'label': 'Notes',
                  'value': caseData['notes']?.toString() ?? '',
                },
                {
                  'label': 'Assigned At',
                  'value': caseData['assignedAt']?.toString() ?? '',
                },
                {
                  'label': 'Created At',
                  'value': caseData['createdAt']?.toString() ?? '',
                },
                {
                  'label': 'Updated At',
                  'value': caseData['updatedAt']?.toString() ?? '',
                },
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailSection(
              icon: Icons.report_problem_outlined,
              title: 'Report Info',
              items: [
                {'label': 'Report ID', 'value': report.id?.toString() ?? ''},
                {
                  'label': 'Tracking Code',
                  'value': report.trackingCode?.toString() ?? '',
                },
                {
                  'label': 'Anonymous ID',
                  'value': report.anonymousId?.toString() ?? '',
                },
                {
                  'label': 'Incident Type',
                  'value': report.incidentType?.toString() ?? '',
                },
                {'label': 'Status', 'value': report.status?.toString() ?? ''},
                {
                  'label': 'Submitted At',
                  'value': report.submittedAt?.toString() ?? '',
                },
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailSection(
              icon: Icons.message_outlined,
              title: 'Messages',
              items: [
                {'label': 'Message Count', 'value': messageCount},
                {
                  'label': 'Last Message',
                  'value': lastMessage['content']?.toString() ?? '',
                },
                {
                  'label': 'Last Message At',
                  'value': lastMessage['createdAt']?.toString() ?? '',
                },
                {
                  'label': 'From Counselor',
                  'value': lastMessage['fromCounselor']?.toString() ?? '',
                },
              ],
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 20,
                  color: Colors.indigo,
                ),
                SizedBox(width: 8),
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                report.description?.toString() ?? 'No description available',
                style: const TextStyle(fontSize: 14),
              ),
            ),
            if (report.evidencePaths != null &&
                report.evidencePaths!.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Row(
                children: [
                  Icon(Icons.image_outlined, size: 20, color: Colors.indigo),
                  SizedBox(width: 8),
                  Text(
                    'Evidence',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: report.evidencePaths!.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final path = report.evidencePaths![index];
                    return GestureDetector(
                      onTap: () {
                        // Open full screen image
                        Get.dialog(
                          Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: EdgeInsets.zero,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                InteractiveViewer(
                                  child: Image.network(
                                    path,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: Colors.white,
                                      child: const Center(
                                        child: Text('Failed to load image'),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 40,
                                  right: 20,
                                  child: GestureDetector(
                                    onTap: () => Get.back(),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          barrierDismissible: true,
                        );
                      },
                      child: Container(
                        width: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                          image: DecorationImage(
                            image: NetworkImage(path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required String title,
    required List<Map<String, String>> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.indigo),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _buildDetailRow(item['label']!, item['value']!)),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          Flexible(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.assignment_outlined, size: 20, color: Colors.indigo),
                SizedBox(width: 8),
                Text(
                  'Case Actions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Update the case status based on your progress',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            _buildActionButton(
              icon: Icons.play_circle_outline,
              label: 'Activate / Under Review',
              subtitle: 'Mark case as active and under investigation',
              color: Colors.orange,
              onTap: () => _confirmStatusUpdate('active'),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.arrow_upward,
              label: 'Escalate Case',
              subtitle: 'Requires senior attention or intervention',
              color: Colors.red,
              onTap: () => _confirmStatusUpdate('escalated'),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.check_circle_outline,
              label: 'Close Case',
              subtitle: 'Mark case as resolved and closed',
              color: Colors
                  .green, // Changed to green to represent resolution/closure
              onTap: () => _confirmStatusUpdate('closed'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _isUpdating ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.message_outlined,
                size: 20,
                color: Colors.indigo,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Communication',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Anonymous & Confidential',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock, size: 12, color: Colors.green.shade700),
                    const SizedBox(width: 4),
                    Text(
                      'Secure',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: _isLoadingMessages
                  ? const Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No messages yet',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Start a conversation with the student',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      reverse:
                          true, // Show latest at bottom if list is reversed order, or scroll to bottom
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        // Assuming messages are returned oldest first, we might want to reverse them or use reverse: true logic properly
                        // Let's check the order. Usually chat APIs return chronological.
                        // If we want newest at bottom (standard chat), we display as is and auto-scroll, OR use reverse ListView and reverse the list.
                        // For simplicity, let's just render them.
                        // Actually better UX: reverse the list + reverse ListView so it stays at bottom.
                        final msg = _messages[_messages.length - 1 - index];
                        final isMe = msg['fromCounselor'] == true;

                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? Colors.indigo.shade600
                                  : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(12),
                                topRight: const Radius.circular(12),
                                bottomLeft: Radius.circular(isMe ? 12 : 0),
                                bottomRight: Radius.circular(isMe ? 0 : 12),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg['content'] ?? '',
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black87,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDateTime(
                                    DateTime.parse(
                                      msg['createdAt'] ??
                                          DateTime.now().toIso8601String(),
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: isMe
                                        ? Colors.white70
                                        : Colors.grey.shade500,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: messageController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Type your message here...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
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
                borderSide: BorderSide(color: Colors.indigo.shade600, width: 2),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sendMessage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade600,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.send, size: 18),
              label: const Text(
                'Send Message',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmStatusUpdate(String newStatus) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getStatusColor(newStatus).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStatusIcon(newStatus),
                  color: _getStatusColor(newStatus),
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Update Case Status?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Change status to "${newStatus.replaceAll('_', ' ').toUpperCase()}"',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _updateStatus(newStatus);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getStatusColor(newStatus),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);

    try {
      // Prefer human case code (CASE-...) when available, fall back to mongo id or report id
      // Prefer Mongo ID for API updates as backend usually expects the document _id
      final caseId =
          (report.caseMongoId != null &&
              report.caseMongoId.toString().isNotEmpty)
          ? report.caseMongoId.toString()
          : ((_caseData != null && _caseData!['id'] != null)
                ? _caseData!['id'].toString()
                : ((report.caseCode != null && report.caseCode!.isNotEmpty)
                      ? report.caseCode!
                      : report.id.toString()));

      await reportController.updateCaseStatus(caseId, newStatus);
      report = report.copyWith(status: newStatus);
      setState(() => _isUpdating = false);

      Get.snackbar(
        'Success',
        'Status updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: const Color.fromRGBO(27, 94, 32, 1),
        icon: const Icon(Icons.check_circle, color: Colors.green),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      setState(() => _isUpdating = false);
      Get.snackbar(
        'Error',
        'Failed to update status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        icon: const Icon(Icons.error, color: Colors.red),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  void _sendMessage() async {
    final content = messageController.text.trim();
    if (content.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a message',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
        icon: const Icon(Icons.warning, color: Colors.orange),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    // Get the MongoDB _id for the case
    String? caseMongoId;
    if (report is Report && (report as Report).caseMongoId != null) {
      caseMongoId = (report as Report).caseMongoId.toString();
    } else if (_caseData != null && _caseData!['id'] != null) {
      caseMongoId = _caseData!['id'].toString();
    } else {
      final sel = reportController.selectedCaseDetails.value;
      caseMongoId = sel?['case']?['id']?.toString() ?? sel?['id']?.toString();
    }

    if (caseMongoId == null || caseMongoId.isEmpty) {
      Get.snackbar(
        'Error',
        'No valid case ID found (MongoDB _id required)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        icon: const Icon(Icons.error, color: Colors.red),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    try {
      await reportController.sendCounselorMessage(caseMongoId, content);
      messageController.clear();

      // Refresh messages to show the new one
      _fetchMessages();

      Get.snackbar(
        'Success',
        'Message sent to student',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        icon: const Icon(Icons.check_circle, color: Colors.green),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send message: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        icon: const Icon(Icons.error, color: Colors.red),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  void _copyTrackingCode() {
    Clipboard.setData(ClipboardData(text: report.trackingCode ?? ''));
    Get.snackbar(
      'Copied',
      'Tracking code copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade100,
      colorText: Colors.blue.shade900,
      icon: const Icon(Icons.copy, color: Colors.blue),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }

  void _shareCase() {
    Get.snackbar(
      'Share',
      'Share functionality coming soon',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade100,
      colorText: Colors.blue.shade900,
      icon: const Icon(Icons.share, color: Colors.blue),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void _exportCase() {
    Get.snackbar(
      'Export',
      'Export functionality coming soon',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade100,
      colorText: Colors.blue.shade900,
      icon: const Icon(Icons.download, color: Colors.blue),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'under_review':
        return Icons.play_circle_outline;
      case 'resolved':
      case 'closed':
        return Icons.check_circle_outline;
      case 'escalated':
        return Icons.arrow_upward;
      default:
        return Icons.info_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return Colors.blue;
      case 'under_review':
      case 'active':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'escalated':
        return Colors.red;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color _getUrgencyColor(String urgencyLevel) {
    switch (urgencyLevel.toLowerCase()) {
      case 'urgent':
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes} minutes ago';
      }
      return '${diff.inHours} hours ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday at ${_formatTime(date)}';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
