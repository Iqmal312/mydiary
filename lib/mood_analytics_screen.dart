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

  final Map<String, String> moodEmojis = {
    'happy': '😊',
    'sad': '😢',
    'angry': '😠',
    'excited': '😆',
    'tired': '😴',
    'neutral': '😐',
  };

  @override
  void initState() {
    super.initState();
    _loadMoodData();
  }

  Future<void> _loadMoodData() async {
    final entries = await _dbHelper.getAllEntries();
    final Map<String, int> counts = {
      for (var mood in moodEmojis.keys) mood: 0
    };
    for (var entry in entries) {
      counts[entry.mood] = (counts[entry.mood] ?? 0) + 1;
    }
    setState(() {
      moodCounts = counts;
    });
  }

  @override
  Widget build(BuildContext context) {
    final moods = moodEmojis.keys.toList();
    final values = moods.map((m) => moodCounts[m] ?? 0).toList();
    final maxY = (values.reduce((a, b) => a > b ? a : b) + 1).clamp(1, 10);

    return Scaffold(
      appBar: AppBar(title: const Text('Mood Analytics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1.5),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: AspectRatio(
                aspectRatio: 1.5, // Keeps chart from being too tall
                child: BarChart(
                  BarChartData(
                    maxY: maxY.toDouble(),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 48,
                          getTitlesWidget: (value, _) {
                            final index = value.toInt();
                            if (index < moods.length) {
                              final mood = moods[index];
                              final emoji = moodEmojis[mood] ?? '';
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(emoji, style: const TextStyle(fontSize: 18)),
                                  Text(mood, style: const TextStyle(fontSize: 10)),
                                ],
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          reservedSize: 28,
                          getTitlesWidget: (value, _) => Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: const Border(
                        top: BorderSide(color: Colors.black, width: 1),
                        bottom: BorderSide(color: Colors.black, width: 1),
                        left: BorderSide(color: Colors.black, width: 1),
                        right: BorderSide(color: Colors.black, width: 1),
                      ),
                    ),
                    barGroups: List.generate(
                      moods.length,
                      (index) => BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: values[index].toDouble(),
                            color: Colors.deepPurple,
                            width: 18,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Mood frequency by type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
