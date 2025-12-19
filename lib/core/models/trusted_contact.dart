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
      'isEnabled': isEnabled,
    };
  }

  factory TrustedContact.fromJson(Map<String, dynamic> json) {
    return TrustedContact(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      isEnabled: json['isEnabled'] ?? true,
    );
  }

  TrustedContact copyWith({bool? isEnabled}) {
    return TrustedContact(
      id: id,
      name: name,
      phoneNumber: phoneNumber,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
