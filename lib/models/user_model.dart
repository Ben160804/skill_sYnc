class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String? bio;
  final String? address;
  final String? phone;
  final List<Map<String, String>> skills;
  final List<Map<String, String>> links;
  final List<String> matchedUsers;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.bio,
    this.address,
    this.phone,
    this.skills = const [],
    this.links = const [],
    this.matchedUsers = const [],
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? '',
      bio: json['bio'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      skills: (json['skills'] as List<dynamic>? ?? []).map((e) => Map<String, String>.from(e as Map)).toList(),
      links: (json['links'] as List<dynamic>? ?? []).map((e) => Map<String, String>.from(e as Map)).toList(),
      matchedUsers: List<String>.from(json['matchedUsers'] as List<dynamic>? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'bio': bio,
      'address': address,
      'phone': phone,
      'skills': skills,
      'links': links,
      'matchedUsers': matchedUsers,
    };
  }
}