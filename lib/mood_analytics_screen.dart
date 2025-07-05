import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'database_helper.dart';

class MoodAnalyticsScreen extends StatefulWidget {
  final int userId;
  const MoodAnalyticsScreen({super.key, required this.userId});

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

  final Map<String, Color> moodColors = {
    'happy': Colors.green,
    'sad': Colors.blue,
    'angry': Colors.red,
    'excited': Colors.orange,
    'tired': Colors.purple,
    'neutral': Colors.grey,
  };

  @override
  void initState() {
    super.initState();
    _loadMoodData();
  }

  Future<void> _loadMoodData() async {
    final entries = await _dbHelper.getAllEntries(userId: widget.userId);
    final Map<String, int> counts = {
      for (var mood in moodEmojis.keys) mood: 0
    };

    for (var entry in entries) {
      final mood = entry.mood.toLowerCase(); // Normalize mood
      if (counts.containsKey(mood)) {
        counts[mood] = (counts[mood] ?? 0) + 1;
      }
    }

    setState(() {
      moodCounts = counts;
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = moodCounts.values.fold(0, (sum, count) => sum + count);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Analytics'),
        backgroundColor: const Color.fromARGB(255, 27, 71, 117),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/home.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.black.withOpacity(0.3),
          child: moodCounts.isEmpty
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : Column(
                  children: [
                    const SizedBox(height: 20),
                    AspectRatio(
                      aspectRatio: 1.2,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 50,
                          sections: moodCounts.entries
                              .where((entry) => entry.value > 0)
                              .map((entry) {
                            final mood = entry.key.toLowerCase(); // Normalize
                            final count = entry.value;
                            final percentage = total == 0
                                ? '0.0'
                                : (count / total * 100).toStringAsFixed(1);

                            return PieChartSectionData(
                              color: moodColors[mood] ?? Colors.grey,
                              value: count.toDouble(),
                              title: '${moodEmojis[mood] ?? '❓'} $percentage%',
                              radius: 90,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Mood Distribution',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView(
                        children: moodCounts.entries
                            .where((entry) => entry.value > 0)
                            .map((entry) {
                          final mood = entry.key.toLowerCase(); // Normalize
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: moodColors[mood] ?? Colors.grey,
                              child: Text(
                                moodEmojis[mood] ?? '❓',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                            title: Text(
                              mood[0].toUpperCase() + mood.substring(1),
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: Text(
                              '${entry.value} entries',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
