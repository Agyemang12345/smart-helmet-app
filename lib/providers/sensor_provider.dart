import 'dart:async';
import 'package:flutter/material.dart';
import '../models/alert_event.dart';
import '../models/sensor_data.dart';
import '../services/blynk_service.dart';
import '../services/firebase_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SensorProvider with ChangeNotifier {
  SensorData? _sensorData;
  bool _isConnected = true;
  Timer? _timer;
  final List<SensorData> _history = [];
  final List<AlertEvent> _alerts = [];
  bool _gasAlertActive = false;
  bool _alcoholAlertActive = false;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseService _firebaseService = FirebaseService.instance;

  SensorData? get sensorData => _sensorData;
  bool get isConnected => _isConnected;
  List<SensorData> get history => List.unmodifiable(_history.reversed);
  List<AlertEvent> get alerts => List.unmodifiable(_alerts.reversed);
  List<AlertEvent> get activeAlerts =>
      _alerts.where((alert) => alert.isActive).toList();
  List<AlertEvent> get resolvedAlerts =>
      _alerts.where((alert) => !alert.isActive).toList();

  SensorProvider() {
    _initializeNotifications();
    startFetchingData();
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);
    _notificationsPlugin.initialize(settings);
  }

  void startFetchingData() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      await _fetchData();
    });
  }

  Future<void> _fetchData() async {
    final data = await BlynkService().fetchSensorData();
    if (data != null) {
      _sensorData = data;
      _history.add(data);
      if (_history.length > 100) {
        _history.removeAt(0);
      }
      _isConnected = true;
      await _checkAlerts();
      try {
        await _firebaseService.saveSensorRecord(data);
      } catch (e) {
        debugPrint('Firebase sensor save failed: $e');
      }
      notifyListeners();
    } else {
      _isConnected = false;
      notifyListeners();
    }
  }

  Future<void> _checkAlerts() async {
    if (_sensorData == null) return;

    if (_sensorData!.gas > 100 && !_gasAlertActive) {
      _gasAlertActive = true;
      await _createAlert(
        type: 'gas',
        title: 'Gas Alert',
        message: 'Gas level is high. Supervisor notified.',
        severity: AlertSeverity.high,
      );
    } else if (_sensorData!.gas <= 100 && _gasAlertActive) {
      _gasAlertActive = false;
      _resolveAlert('gas');
    }

    if (_sensorData!.alcohol > 0 && !_alcoholAlertActive) {
      _alcoholAlertActive = true;
      await _createAlert(
        type: 'alcohol',
        title: 'Alcohol Alert',
        message: 'Alcohol detected. Supervisor notified.',
        severity: AlertSeverity.high,
      );
    } else if (_sensorData!.alcohol <= 0 && _alcoholAlertActive) {
      _alcoholAlertActive = false;
      _resolveAlert('alcohol');
    }
  }

  Future<void> _createAlert({
    required String type,
    required String title,
    required String message,
    required AlertSeverity severity,
  }) async {
    final alert = AlertEvent(
      type: type,
      title: title,
      message: message,
      timestamp: DateTime.now(),
      severity: severity,
      isActive: true,
      sentToSupervisor: true,
    );
    _alerts.add(alert);
    try {
      await _firebaseService.saveAlertEvent(alert);
    } catch (e) {
      debugPrint('Firebase alert save failed: $e');
    }
    _sendSupervisorMessage(title, message);
    _showNotification(title, message);
  }

  void _resolveAlert(String type) {
    for (final alert in _alerts.reversed) {
      if (alert.type == type && alert.isActive) {
        alert.isActive = false;
        notifyListeners();
        break;
      }
    }
  }

  Future<void> _sendSupervisorMessage(String title, String body) async {
    debugPrint('Supervisor message sent: $title - $body');
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'sensor_alerts',
      'Sensor Alerts',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails details =
        NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(0, title, body, details);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
