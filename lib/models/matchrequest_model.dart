class MatchRequest {
  final String id; // Document ID
  final String requestId; // Reference to the original Request
  final String requesterId; // ID of the user who sent the request
  final String targetUserId; // ID of the user receiving the request
  final String requesterName; // Name of the requester
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime timestamp; // When the match request was created

  MatchRequest({
    required this.id,
    required this.requestId,
    required this.requesterId,
    required this.targetUserId,
    required this.requesterName,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'requesterId': requesterId,
      'targetUserId': targetUserId,
      'requesterName': requesterName,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory MatchRequest.fromJson(Map<String, dynamic> json, String id) {
    return MatchRequest(
      id: id,
      requestId: json['requestId'] as String,
      requesterId: json['requesterId'] as String,
      targetUserId: json['targetUserId'] as String,
      requesterName: json['requesterName'] as String,
      status: json['status'] as String? ?? 'pending',
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}