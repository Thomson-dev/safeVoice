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
  final DateTime submittedAt;
  final DateTime? resolvedAt;
  final bool isAnonymous;

  Report({
    required this.id,
    required this.trackingCode,
    this.userId,
    this.anonymousId,
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
    return Report(
      id: json['id'],
      trackingCode: json['trackingCode'],
      userId: json['userId'],
      anonymousId: json['anonymousId'],
      incidentType: json['incidentType'],
      description: json['description'],
      location: json['location'],
      evidencePaths: json['evidencePaths'] != null 
          ? List<String>.from(json['evidencePaths']) 
          : null,
      urgencyLevel: json['urgencyLevel'],
      status: json['status'],
      assignedCounselorId: json['assignedCounselorId'],
      submittedAt: DateTime.parse(json['submittedAt']),
      resolvedAt: json['resolvedAt'] != null 
          ? DateTime.parse(json['resolvedAt']) 
          : null,
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
