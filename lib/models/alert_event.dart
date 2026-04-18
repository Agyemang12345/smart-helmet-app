enum AlertSeverity { low, medium, high }

class AlertEvent {
  final String type;
  final String title;
  final String message;
  final DateTime timestamp;
  final AlertSeverity severity;
  bool isActive;
  bool sentToSupervisor;

  AlertEvent({
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.severity,
    this.isActive = true,
    this.sentToSupervisor = false,
  });

  String get severityLabel {
    switch (severity) {
      case AlertSeverity.low:
        return 'LOW';
      case AlertSeverity.medium:
        return 'MED';
      case AlertSeverity.high:
        return 'HIGH';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'severity': severityLabel,
      'isActive': isActive,
      'sentToSupervisor': sentToSupervisor,
    };
  }
}
