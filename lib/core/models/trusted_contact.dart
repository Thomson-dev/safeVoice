class TrustedContact {
  final String id;
  final String name;
  final String phoneNumber;
  final bool isEnabled;

  TrustedContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.isEnabled = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'phone': phoneNumber, // Support both formats
      'isEnabled': isEnabled,
    };
  }

  factory TrustedContact.fromJson(Map<String, dynamic> json) {
    return TrustedContact(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      // Support both 'phone' (API) and 'phoneNumber' (local storage)
      phoneNumber: json['phoneNumber'] ?? json['phone'] ?? '',
      isEnabled: json['isEnabled'] ?? true,
    );
  }

  TrustedContact copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    bool? isEnabled,
  }) {
    return TrustedContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
