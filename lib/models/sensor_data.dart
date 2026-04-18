class SensorData {
  final double gas;
  final double alcohol;
  final double mpuX;
  final double mpuY;
  final double mpuZ;
  final double temperature;
  final double humidity;
  final double userTemperature;
  final DateTime timestamp;

  SensorData({
    required this.gas,
    required this.alcohol,
    required this.mpuX,
    required this.mpuY,
    required this.mpuZ,
    required this.temperature,
    required this.humidity,
    required this.userTemperature,
    required this.timestamp,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      gas: double.tryParse(json['V0'].toString()) ?? 0.0,
      alcohol: double.tryParse(json['V1'].toString()) ?? 0.0,
      mpuX: double.tryParse(json['V6'].toString()) ?? 0.0,
      mpuY: double.tryParse(json['V7'].toString()) ?? 0.0,
      mpuZ: double.tryParse(json['V8'].toString()) ?? 0.0,
      temperature: double.tryParse(json['V9'].toString()) ?? 0.0,
      humidity: double.tryParse(json['V10']?.toString() ?? '') ?? 0.0,
      userTemperature: double.tryParse(json['V11']?.toString() ?? '') ?? 0.0,
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gas': gas,
      'alcohol': alcohol,
      'mpuX': mpuX,
      'mpuY': mpuY,
      'mpuZ': mpuZ,
      'temperature': temperature,
      'humidity': humidity,
      'userTemperature': userTemperature,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
