import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/sensor_data.dart';
import '../providers/sensor_provider.dart';

enum HistoryFilter { all, gas, alcohol, temperature }

class HistoryScreen extends StatefulWidget {
  final HistoryFilter initialFilter;

  const HistoryScreen({super.key, this.initialFilter = HistoryFilter.all});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late HistoryFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
  }

  Future<void> _exportData(List<SensorData> data) async {
    try {
      final csvData = _generateCSV(data);
      final fileName =
          'helmet_sensor_data_${DateTime.now().toIso8601String().split('T')[0]}.csv';

      if (Platform.isAndroid || Platform.isIOS) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsString(csvData);
        await Share.shareXFiles([XFile(file.path)],
            text: 'Helmet Sensor Data Export');
      } else {
        // For web/desktop, just show the data
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data exported: $fileName')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  String _generateCSV(List<SensorData> data) {
    final buffer = StringBuffer();
    buffer.writeln(
        'Timestamp,Gas (PPM),Alcohol (%),MPU X,MPU Y,MPU Z,Temperature (°C),Humidity (%),User Temperature (°C)');

    for (final item in data) {
      buffer.writeln('${item.timestamp.toIso8601String()},'
          '${item.gas},'
          '${item.alcohol},'
          '${item.mpuX},'
          '${item.mpuY},'
          '${item.mpuZ},'
          '${item.temperature},'
          '${item.humidity},'
          '${item.userTemperature}');
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SensorProvider>();
    final history = provider.history;
    final latest = history.isNotEmpty ? history.first : null;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _PageHeader(title: 'History', subtitle: 'Sensor record timeline'),
              const SizedBox(height: 18),
              _FilterChips(
                selected: _filter,
                onSelected: (filter) {
                  setState(() {
                    _filter = filter;
                  });
                },
              ),
              const SizedBox(height: 18),
              _SummaryRow(latest: latest, filter: _filter),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_getFilteredData(history, _filter).length} records',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () =>
                        _exportData(_getFilteredData(history, _filter)),
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Export CSV'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E6DE4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: history.isEmpty
                    ? const Center(
                        child: Text(
                          'No history available yet.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: history.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = history[index];
                          return _HistoryCard(item: item, filter: _filter);
                        },
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
  final String title;
  final String subtitle;

  const _PageHeader({required this.title, required this.subtitle});

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
          const Icon(Icons.history, color: Colors.lightBlueAccent, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
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

class _FilterChips extends StatelessWidget {
  final HistoryFilter selected;
  final ValueChanged<HistoryFilter> onSelected;

  const _FilterChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: HistoryFilter.values.map((filter) {
        final label = _filterLabel(filter);
        final active = filter == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelected(filter),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color:
                    active ? const Color(0xFF2E6DE3) : const Color(0xFF112139),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: active
                        ? Colors.transparent
                        : Colors.white.withOpacity(0.08)),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: active ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

List<SensorData> _getFilteredData(
    List<SensorData> history, HistoryFilter filter) {
  switch (filter) {
    case HistoryFilter.gas:
      return history.where((item) => item.gas > 50).toList();
    case HistoryFilter.alcohol:
      return history.where((item) => item.alcohol > 0.05).toList();
    case HistoryFilter.temperature:
      return history
          .where((item) => item.temperature > 30 || item.temperature < 15)
          .toList();
    default:
      return history;
  }
}

class _SummaryRow extends StatelessWidget {
  final SensorData? latest;
  final HistoryFilter filter;

  const _SummaryRow({required this.latest, required this.filter});

  @override
  Widget build(BuildContext context) {
    if (latest == null) {
      return Container(
        height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFF112139),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        alignment: Alignment.center,
        child: const Text('Waiting for sensor data...',
            style: TextStyle(color: Colors.grey)),
      );
    }

    final latestRecord = latest!;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF112139),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _SummaryTag(
              label: 'Latest',
              value:
                  '${latestRecord.timestamp.hour.toString().padLeft(2, '0')}:${latestRecord.timestamp.minute.toString().padLeft(2, '0')}'),
          const SizedBox(width: 12),
          _SummaryTag(
              label: 'Gas',
              value: '${latestRecord.gas.toStringAsFixed(0)} ppm'),
          const SizedBox(width: 12),
          _SummaryTag(
              label: 'Alcohol',
              value: '${latestRecord.alcohol.toStringAsFixed(2)} %BAC'),
        ],
      ),
    );
  }
}

class _SummaryTag extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryTag({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final SensorData item;
  final HistoryFilter filter;

  const _HistoryCard({required this.item, required this.filter});

  @override
  Widget build(BuildContext context) {
    final date = item.timestamp;
    final label =
        '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
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
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 12),
          Wrap(
            runSpacing: 10,
            spacing: 10,
            children: [
              _HistoryBadge(
                  label: 'Gas',
                  value: '${item.gas.toStringAsFixed(0)} ppm',
                  active: filter == HistoryFilter.all ||
                      filter == HistoryFilter.gas),
              _HistoryBadge(
                  label: 'Alcohol',
                  value: '${item.alcohol.toStringAsFixed(2)} %BAC',
                  active: filter == HistoryFilter.all ||
                      filter == HistoryFilter.alcohol),
              _HistoryBadge(
                  label: 'Temp',
                  value: '${item.temperature.toStringAsFixed(1)}°C',
                  active: filter == HistoryFilter.all ||
                      filter == HistoryFilter.temperature),
              _HistoryBadge(
                  label: 'Humidity',
                  value: '${item.humidity.toStringAsFixed(0)}%',
                  active: filter == HistoryFilter.all),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryBadge extends StatelessWidget {
  final String label;
  final String value;
  final bool active;

  const _HistoryBadge(
      {required this.label, required this.value, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF2E6DE3) : const Color(0xFF0B1827),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
