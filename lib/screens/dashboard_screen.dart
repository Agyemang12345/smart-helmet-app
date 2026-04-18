import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sensor_provider.dart';
import 'alerts_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Consumer<SensorProvider>(
          builder: (context, provider, child) {
            final data = provider.sensorData;
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF102A43), Color(0xFF1B3A5A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  _HeaderSection(isConnected: provider.isConnected),
                  const SizedBox(height: 18),
                  Expanded(
                    child: data == null
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF56CCF2)),
                            ),
                          )
                        : _DashboardContent(data: data),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final bool isConnected;

  const _HeaderSection({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF142D4C),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF1B4A78),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.safety_divider,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Smart Helmet Monitoring',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Live safety & sensor dashboard',
                  style: TextStyle(
                    color: Color(0xFF93A8C3),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isConnected ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  isConnected ? Icons.wifi : Icons.wifi_off,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  isConnected ? 'Connected' : 'Offline',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final dynamic data;

  const _DashboardContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          SizedBox(
            height: 320,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _TiltCard(
                    x: data.mpuX.toStringAsFixed(0),
                    y: data.mpuY.toStringAsFixed(0),
                    z: data.mpuZ.toStringAsFixed(0),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _GaugeCard(
                    title: 'Gas Level',
                    description: 'High gas level',
                    value: data.gas.toStringAsFixed(0),
                    unit: 'PPM',
                    valueColor:
                        data.gas > 100 ? Colors.redAccent : Colors.greenAccent,
                    sectors: const [
                      _GaugeSector(0.35, Colors.green),
                      _GaugeSector(0.25, Colors.yellow),
                      _GaugeSector(0.4, Colors.red),
                    ],
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HistoryScreen(
                              initialFilter: HistoryFilter.gas),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 320,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _GaugeCard(
                    title: 'Alcohol Detected',
                    description: '0.04 %BAC',
                    value: data.alcohol.toStringAsFixed(2),
                    unit: '%BAC',
                    valueColor: data.alcohol > 0.05
                        ? Colors.redAccent
                        : Colors.greenAccent,
                    sectors: const [
                      _GaugeSector(0.5, Colors.green),
                      _GaugeSector(0.25, Colors.yellow),
                      _GaugeSector(0.25, Colors.red),
                    ],
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HistoryScreen(
                              initialFilter: HistoryFilter.alcohol),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          title: 'Environment',
                          icon: Icons.thermostat,
                          values: [
                            _InfoValue(
                              label: 'Temp',
                              value: '${data.temperature.toStringAsFixed(1)}°C',
                            ),
                            _InfoValue(
                              label: 'Humidity',
                              value: '${data.humidity.toStringAsFixed(0)}%',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: _InfoCard(
                          title: 'User Temperature',
                          icon: Icons.person,
                          values: [
                            _InfoValue(
                              label: '',
                              value:
                                  '${data.userTemperature.toStringAsFixed(1)}°C',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _BottomNavBar(),
        ],
      ),
    );
  }
}

class _TiltCard extends StatelessWidget {
  final String x;
  final String y;
  final String z;

  const _TiltCard({required this.x, required this.y, required this.z});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF112139),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tilt Angle',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'MPU6050',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                _TiltDial(label: 'X', value: x),
                const SizedBox(width: 12),
                _TiltDial(label: 'Y', value: y),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1827),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _TiltValue(label: 'X', value: '$x°'),
                _TiltValue(label: 'Y', value: '$y°'),
                _TiltValue(label: 'Z', value: '$z°'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TiltDial extends StatelessWidget {
  final String label;
  final String value;

  const _TiltDial({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 132,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E3C6A), Color(0xFF12213D)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Text(
              '$value°',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TiltValue extends StatelessWidget {
  final String label;
  final String value;

  const _TiltValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _GaugeCard extends StatelessWidget {
  final String title;
  final String description;
  final String value;
  final String unit;
  final Color valueColor;
  final List<_GaugeSector> sectors;
  final VoidCallback? onTap;

  const _GaugeCard({
    required this.title,
    required this.description,
    required this.value,
    required this.unit,
    required this.valueColor,
    required this.sectors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(
                title.contains('Alcohol')
                    ? Icons.local_bar
                    : Icons.warning_amber,
                color: title.contains('Alcohol')
                    ? Colors.redAccent
                    : Colors.orangeAccent,
                size: 26,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 190,
                    width: 190,
                    child: CustomPaint(
                      painter: _GaugePainter(sectors: sectors),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          color: valueColor,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        unit,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _GaugeLabel(color: Colors.green, label: 'Low'),
              _GaugeLabel(color: Colors.yellow, label: 'Med'),
              _GaugeLabel(color: Colors.red, label: 'High'),
            ],
          ),
        ],
      ),
    );

    if (onTap == null) {
      return card;
    }

    return GestureDetector(
      onTap: onTap,
      child: card,
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_InfoValue> values;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Icon(icon, color: Colors.lightBlueAccent, size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...values.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.label,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  Text(
                    item.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoValue {
  final String label;
  final String value;

  const _InfoValue({required this.label, required this.value});
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF142D4C),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomActionButton(
            icon: Icons.history,
            label: 'History',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
          const _BottomActionButton(
              icon: Icons.home, label: 'Home', isActive: true),
          _BottomActionButton(
            icon: Icons.notifications,
            label: 'Alerts',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AlertsScreen()),
              );
            },
          ),
          _BottomActionButton(
            icon: Icons.settings,
            label: 'Settings',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BottomActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _BottomActionButton({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF2E6DE3)
                  : Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugeLabel extends StatelessWidget {
  final Color color;
  final String label;

  const _GaugeLabel({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}

class _GaugeSector {
  final double fraction;
  final Color color;

  const _GaugeSector(this.fraction, this.color);
}

class _GaugePainter extends CustomPainter {
  final List<_GaugeSector> sectors;

  _GaugePainter({required this.sectors});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 16.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    double startAngle = 3.14;

    for (final sector in sectors) {
      paint.color = sector.color;
      final sweepAngle = 3.14 * sector.fraction;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }

    canvas.drawCircle(
      center,
      radius - strokeWidth / 2,
      Paint()..color = const Color(0xFF0D1B2A),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
