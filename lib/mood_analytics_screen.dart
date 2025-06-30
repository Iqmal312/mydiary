import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'database_helper.dart';
import 'diary_entry.dart';

class MoodAnalyticsScreen extends StatefulWidget {
  const MoodAnalyticsScreen({super.key});

  @override
  State<MoodAnalyticsScreen> createState() => _MoodAnalyticsScreenState();
}

class _MoodAnalyticsScreenState extends State<MoodAnalyticsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, int> moodCounts = {};

  @override
  void initState() {
    super.initState();
    _loadMoodData();
  }

  Future<void> _loadMoodData() async {
    final entries = await _dbHelper.getAllEntries();
    final Map<String, int> counts = {};
    for (var entry in entries) {
      counts[entry.mood] = (counts[entry.mood] ?? 0) + 1;
    }
    setState(() {
      moodCounts = counts;
    });
  }

  @override
  Widget build(BuildContext context) {
    final moods = moodCounts.keys.toList();
    final values = moodCounts.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Mood Analytics')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: moodCounts.isEmpty
            ? const Center(child: Text('No mood data available.'))
            : BarChart(
                BarChartData(
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final index = value.toInt();
                          return index < moods.length
                              ? Text(moods[index], style: const TextStyle(fontSize: 10))
                              : const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),
                  barGroups: List.generate(
                    moods.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: values[index].toDouble(),
                          color: Colors.blue,
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
