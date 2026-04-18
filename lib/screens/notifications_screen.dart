import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _gasAlerts = true;
  bool _alcoholAlerts = true;
  bool _temperatureAlerts = true;
  bool _motionAlerts = true;
  bool _criticalOnly = false;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF142D4C),
        title: const Text('Notification Settings'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alert Types Section
            const Text(
              'Alert Types',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildNotificationToggle(
              title: 'Gas Level Alerts',
              subtitle: 'Notify when gas levels are high',
              value: _gasAlerts,
              onChanged: (value) => setState(() => _gasAlerts = value),
              icon: Icons.cloud,
            ),
            _buildNotificationToggle(
              title: 'Alcohol Detection Alerts',
              subtitle: 'Notify when alcohol is detected',
              value: _alcoholAlerts,
              onChanged: (value) => setState(() => _alcoholAlerts = value),
              icon: Icons.local_drink,
            ),
            _buildNotificationToggle(
              title: 'Temperature Alerts',
              subtitle: 'Notify for abnormal temperature',
              value: _temperatureAlerts,
              onChanged: (value) => setState(() => _temperatureAlerts = value),
              icon: Icons.thermostat,
            ),
            _buildNotificationToggle(
              title: 'Motion/Impact Alerts',
              subtitle: 'Notify on sudden movements',
              value: _motionAlerts,
              onChanged: (value) => setState(() => _motionAlerts = value),
              icon: Icons.directions_walk,
            ),
            const SizedBox(height: 24),

            // Alert Severity Section
            const Text(
              'Alert Severity',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildNotificationToggle(
              title: 'Critical Alerts Only',
              subtitle: 'Receive only critical severity alerts',
              value: _criticalOnly,
              onChanged: (value) => setState(() => _criticalOnly = value),
              icon: Icons.warning,
            ),
            const SizedBox(height: 24),

            // Notification Methods Section
            const Text(
              'Notification Methods',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildNotificationToggle(
              title: 'Push Notifications',
              subtitle: 'Receive push notifications on this device',
              value: _pushNotifications,
              onChanged: (value) => setState(() => _pushNotifications = value),
              icon: Icons.notifications,
            ),
            _buildNotificationToggle(
              title: 'Email Notifications',
              subtitle: 'Receive alerts via email',
              value: _emailNotifications,
              onChanged: (value) => setState(() => _emailNotifications = value),
              icon: Icons.email,
            ),
            const SizedBox(height: 24),

            // Notification Preferences Section
            const Text(
              'Preferences',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildNotificationToggle(
              title: 'Sound',
              subtitle: 'Play sound for alerts',
              value: _soundEnabled,
              onChanged: (value) => setState(() => _soundEnabled = value),
              icon: Icons.volume_up,
            ),
            _buildNotificationToggle(
              title: 'Vibration',
              subtitle: 'Vibrate on alert',
              value: _vibrationEnabled,
              onChanged: (value) => setState(() => _vibrationEnabled = value),
              icon: Icons.vibration,
            ),
            const SizedBox(height: 24),

            // Quiet Hours Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quiet Hours',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Critical alerts will still come through during quiet hours',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'From',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: const Text(
                                '22:00',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'To',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: const Text(
                                '06:00',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notification settings saved'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E6DE4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Save Settings'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1E6DE4)),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF1E6DE4),
        ),
      ),
    );
  }
}
