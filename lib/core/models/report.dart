class Report {
  final String id;
  final String trackingCode;
  
  // Anonymous but controlled - links to user account
  final String? userId; // Backend link to student account
  final String? anonymousId; // What counselor sees (ANON-12345)
  
  final String incidentType;
  final String description;
  final String? location;
  final List<String>? evidencePaths; // File paths for images/evidence
  final String urgencyLevel; // 'critical', 'high', 'medium', 'low'
  final String status; // 'submitted', 'under_review', 'resolved', 'escalated'
  
  final String? assignedCounselorId; // Counselor handling the case
  final String? caseMongoId; // MongoDB _id for the case when available
  final String? caseCode; // Human-friendly case code like CASE-3D3C1DB8
  final DateTime submittedAt;
  final DateTime? resolvedAt;
  final bool isAnonymous;

  Report({
    required this.id,
    required this.trackingCode,
    this.userId,
    this.anonymousId,
    this.caseMongoId,
    this.caseCode,
    required this.incidentType,
    required this.description,
    this.location,
    this.evidencePaths,
    required this.urgencyLevel,
    required this.status,
    this.assignedCounselorId,
    required this.submittedAt,
    this.resolvedAt,
    this.isAnonymous = true,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trackingCode': trackingCode,
      'caseMongoId': caseMongoId,
      'caseCode': caseCode,
      'userId': userId,
      'anonymousId': anonymousId,
      'incidentType': incidentType,
      'description': description,
      'location': location,
      'evidencePaths': evidencePaths,
      'urgencyLevel': urgencyLevel,
      'status': status,
      'assignedCounselorId': assignedCounselorId,
      'submittedAt': submittedAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'isAnonymous': isAnonymous,
    };
  }

  // Create from JSON
  factory Report.fromJson(Map<String, dynamic> json) {
    // Helper to pick the first non-null string from multiple possible keys
    String _pickString(Map<String, dynamic> src, List<String> keys, [String defaultValue = '']) {
      for (var k in keys) {
        final v = src[k];
        if (v != null) return v.toString();
      }
      return defaultValue;
    }

    DateTime _pickDate(Map<String, dynamic> src, List<String> keys, [DateTime? fallback]) {
      for (var k in keys) {
        final v = src[k];
        if (v != null) {
          try {
            return DateTime.parse(v.toString());
          } catch (_) {
            continue;
          }
        }
      }
      return fallback ?? DateTime.now();
    }

    final id = _pickString(json, ['id', '_id']);
    final trackingCode = _pickString(json, ['trackingCode', 'caseId', 'tracking', 'tracking_code']);
    final incidentType = _pickString(json, ['incidentType', 'incident_type', 'incident'], 'Unknown');
    final description = _pickString(json, ['description', 'details'], '');
    final location = json['location']?.toString();

    List<String>? evidencePaths;
    if (json['evidencePaths'] != null) {
      try {
        evidencePaths = List<String>.from(json['evidencePaths']);
      } catch (_) {
        evidencePaths = (json['evidencePaths'] as List<dynamic>?)?.map((e) => e.toString()).toList();
      }
    } else if (json['evidenceUrl'] != null) {
      evidencePaths = [json['evidenceUrl'].toString()];
    }

    final urgencyLevel = _pickString(json, ['urgencyLevel', 'riskLevel', 'priority'], 'low');
    final status = _pickString(json, ['status', 'caseStatus'], 'unknown');

    final assignedCounselorId = _pickString(json, ['assignedCounselorId', 'assignedTo'], '');

    // Try to extract case-specific IDs if present
    String? caseMongoId;
    String? caseCode;
    if (json['case'] is Map<String, dynamic>) {
      final caseMap = Map<String, dynamic>.from(json['case']);
      caseMongoId = _pickString(caseMap, ['id', '_id']);
      caseCode = _pickString(caseMap, ['caseId', 'case_id']);
    } else {
      // Top-level fallbacks
      caseCode = _pickString(json, ['caseId', 'case_id']);
      // If top-level contains a different id that looks like an ObjectId and caseCode exists, treat id as caseMongoId
      if ((json.containsKey('caseId') || caseCode.isNotEmpty) && (json.containsKey('_id') || json.containsKey('id'))) {
        final cand = json['_id'] ?? json['id'];
        if (cand != null) caseMongoId = cand.toString();
      }
    }

    final submittedAt = _pickDate(json, ['submittedAt', 'createdAt', 'created_at', 'created'], DateTime.now());

    DateTime? resolvedAt;
    try {
      if (json['resolvedAt'] != null || json['resolved_at'] != null) {
        resolvedAt = DateTime.parse((json['resolvedAt'] ?? json['resolved_at']).toString());
      }
    } catch (_) {
      resolvedAt = null;
    }

    return Report(
      id: id.isNotEmpty ? id : DateTime.now().millisecondsSinceEpoch.toString(),
      trackingCode: trackingCode.isNotEmpty ? trackingCode : DateTime.now().millisecondsSinceEpoch.toString(),
      userId: json['userId']?.toString(),
      anonymousId: json['anonymousId']?.toString(),
      caseMongoId: caseMongoId,
      caseCode: caseCode,
      incidentType: incidentType,
      description: description,
      location: location,
      evidencePaths: evidencePaths,
      urgencyLevel: urgencyLevel,
      status: status,
      assignedCounselorId: assignedCounselorId,
      submittedAt: submittedAt,
      resolvedAt: resolvedAt,
      isAnonymous: json['isAnonymous'] ?? true,
    );
  }

  // Copy with method
  Report copyWith({
    String? status,
    String? urgencyLevel,
    String? location,
    String? assignedCounselorId,
    DateTime? resolvedAt,
  }) {
    return Report(
      id: id,
      trackingCode: trackingCode,
      userId: userId,
      anonymousId: anonymousId,
      incidentType: incidentType,
      description: description,
      location: location ?? this.location,
      evidencePaths: evidencePaths,
      urgencyLevel: urgencyLevel ?? this.urgencyLevel,
      status: status ?? this.status,
      assignedCounselorId: assignedCounselorId ?? this.assignedCounselorId,
      submittedAt: submittedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      isAnonymous: isAnonymous,
    );
  }
}
