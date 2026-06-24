class AnomalyReport {
  final String id;
  final String userId;
  final String type; // 'location', 'timing', 'pattern', 'frequency'
  final String description;
  final double severity; // 0.0 to 1.0
  final String status; // 'pending_review', 'reviewed', 'resolved', 'false_positive'
  final DateTime detectedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? notes;
  final Map<String, dynamic> metadata;

  AnomalyReport({
    required this.id,
    required this.userId,
    required this.type,
    required this.description,
    required this.severity,
    required this.status,
    required this.detectedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.notes,
    required this.metadata,
  });

  factory AnomalyReport.fromJson(Map<String, dynamic> json) {
    return AnomalyReport(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      severity: (json['severity'] as num).toDouble(),
      status: json['status'] as String,
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'] as String)
          : null,
      reviewedBy: json['reviewedBy'] as String?,
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'description': description,
      'severity': severity,
      'status': status,
      'detectedAt': detectedAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewedBy': reviewedBy,
      'notes': notes,
      'metadata': metadata,
    };
  }

  String getSeverityLabel() {
    if (severity >= 0.8) return 'Critical';
    if (severity >= 0.6) return 'High';
    if (severity >= 0.4) return 'Medium';
    return 'Low';
  }

  bool isPending() => status == 'pending_review';
  bool isReviewed() => status == 'reviewed';
  bool isResolved() => status == 'resolved';
}
