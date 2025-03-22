class Request {
  final String id; // Document ID
  final String userId; // ID of the user who created the request
  final List<String> skillRequired;
  final List<String> skillLevelRequired;
  final String requesterName;
  final DateTime timestamp;
  final String status; // 'pending', 'processed', etc.
  final List<String> returnedUsers;

  Request({
    required this.id,
    required this.userId,
    required this.skillRequired,
    required this.skillLevelRequired,
    required this.requesterName,
    required this.timestamp,
    required this.status,
    required this.returnedUsers,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'skillRequired': skillRequired,
      'skillLevelRequired': skillLevelRequired,
      'requesterName': requesterName,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'returnedUsers': returnedUsers,
    };
  }

  factory Request.fromJson(Map<String, dynamic> json, String id) {
    return Request(
      id: id,
      userId: json['userId'] as String? ?? '', // Default to empty string if null
      skillRequired: List<String>.from(json['skillRequired'] as List<dynamic>? ?? []),
      skillLevelRequired: List<String>.from(json['skillLevelRequired'] as List<dynamic>? ?? []),
      requesterName: json['requesterName'] as String? ?? 'Unknown',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      status: json['status'] as String? ?? 'pending',
      returnedUsers: List<String>.from(json['returnedUsers'] as List<dynamic>? ?? []),
    );
  }
}