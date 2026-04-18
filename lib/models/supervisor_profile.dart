class SupervisorProfile {
  final String uid;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? department;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime? lastLogin;

  SupervisorProfile({
    required this.uid,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.department,
    this.profileImageUrl,
    required this.createdAt,
    this.lastLogin,
  });

  factory SupervisorProfile.fromJson(Map<String, dynamic> json) {
    return SupervisorProfile(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      department: json['department'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'department': department,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }
}
