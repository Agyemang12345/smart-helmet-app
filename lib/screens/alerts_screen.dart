import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alert_event.dart';
import '../providers/sensor_provider.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SensorProvider>();
    final activeAlerts = provider.activeAlerts;
    final resolvedAlerts = provider.resolvedAlerts;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _PageHeader(),
              const SizedBox(height: 18),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _SectionTitle(title: 'Active Alerts'),
                    const SizedBox(height: 12),
                    if (activeAlerts.isEmpty)
                      const _EmptyState(
                          message: 'No active alerts at the moment.')
                    else
                      ...activeAlerts.map((alert) => _AlertCard(alert: alert)),
                    const SizedBox(height: 22),
                    _SectionTitle(title: 'Past Alerts'),
                    const SizedBox(height: 12),
                    if (resolvedAlerts.isEmpty)
                      const _EmptyState(message: 'No past alerts yet.')
                    else
                      ...resolvedAlerts.map(
                          (alert) => _AlertCard(alert: alert, compact: true)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF112139),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notification_important,
              color: Colors.redAccent, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Alerts',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: 6),
                Text('Supervisor notifications and alert history',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          GestureDetector(
            onTap: Navigator.of(context).pop,
            child: const Icon(Icons.close, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700));
  }
}

class _AlertCard extends StatelessWidget {
  final dynamic alert;
  final bool compact;

  const _AlertCard({required this.alert, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final date = alert.timestamp;
    final timeLabel =
        '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    final color = alert.severity == AlertSeverity.high
        ? Colors.redAccent
        : alert.severity == AlertSeverity.medium
            ? Colors.orangeAccent
            : Colors.greenAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF112139),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(Icons.warning, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alert.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(timeLabel,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(alert.severityLabel,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
              ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: 16),
            Text(alert.message,
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 14),
            Row(
              children: [
                Text('Supervisor notified',
                    style: TextStyle(
                        color: alert.sentToSupervisor
                            ? Colors.greenAccent
                            : Colors.grey,
                        fontSize: 12)),
                const SizedBox(width: 12),
                Text(alert.isActive ? 'Active' : 'Resolved',
                    style: TextStyle(
                        color: alert.isActive ? Colors.redAccent : Colors.grey,
                        fontSize: 12)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF112139),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
              child: Text(message, style: const TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }
}
