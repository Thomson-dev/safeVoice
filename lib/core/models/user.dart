class User {
  final String id; // Backend userId (UUID)
  final String role; // 'student' or 'counselor'
  final String? email; // Optional for students, required for counselors
  
  // Student-specific fields
  final String? anonymousId; // ANON-12345 (public-facing ID for students)
  final String? displayName; // Optional nickname for students
  
  // Counselor-specific fields
  final String? fullName; // Required for counselors
  final String? licenseNumber; // Professional license
  final bool? isVerified; // Counselor verification status
  
  final String? avatar;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.role,
    this.email,
    this.anonymousId,
    this.displayName,
    this.fullName,
    this.licenseNumber,
    this.isVerified,
    this.avatar,
    this.createdAt,
    this.lastLogin,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'email': email,
      'anonymousId': anonymousId,
      'displayName': displayName,
      'fullName': fullName,
      'licenseNumber': licenseNumber,
      'isVerified': isVerified,
      'avatar': avatar,
      'createdAt': createdAt?.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      role: json['role'],
      email: json['email'],
      anonymousId: json['anonymousId'],
      displayName: json['displayName'],
      fullName: json['fullName'],
      licenseNumber: json['licenseNumber'],
      isVerified: json['isVerified'],
      avatar: json['avatar'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      lastLogin: json['lastLogin'] != null 
          ? DateTime.parse(json['lastLogin']) 
          : null,
    );
  }

  bool get isStudent => role == 'student';
  bool get isCounselor => role == 'counselor';
  
  // Get display name for UI
  String get publicDisplayName {
    if (isStudent) {
      return displayName ?? anonymousId ?? 'Anonymous User';
    }
    return fullName ?? 'Counselor';
  }
}
