import 'dart:io';
import 'package:flutter/material.dart';
import 'add_entry_screen.dart';
import 'diary_entry.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';
import 'mood_analytics_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class DiaryListScreen extends StatefulWidget {
  final int userId;

  const DiaryListScreen({super.key, required this.userId});

  @override
  State<DiaryListScreen> createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends State<DiaryListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<List<DiaryEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  void _loadEntries() {
    setState(() {
      _entriesFuture = _dbHelper.getAllEntries().then(
        (entries) => entries.where((e) => e.userId == widget.userId).toList(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DiaryKu',
        style: GoogleFonts.lato(),
        ),
        actions: [
          IconButton(
      icon: const Icon(Icons.bar_chart),
      tooltip: 'Mood Analytics',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MoodAnalyticsScreen(userId: widget.userId),
          ),
        );
      },
    ),
          IconButton(  
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: FutureBuilder<List<DiaryEntry>>(
        future: _entriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final entries = snapshot.data ?? [];

          if (entries.isEmpty) {
            return _buildEmptyState();
          }

          return _buildEntriesList(entries);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEntry(context),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No entries yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to write your first entry',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildEntriesList(List<DiaryEntry> entries) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _buildEntryCard(entry);
      },
    );
  }

  Widget _buildEntryCard(DiaryEntry entry) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 4,
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _navigateToEditEntry(context, entry),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📸 Optional image
            if (entry.imagePath != null &&
                entry.imagePath!.isNotEmpty &&
                File(entry.imagePath!).existsSync())
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(entry.imagePath!),
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 12),

            // 📅 Date as tag
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _formatDate(entry.date),
                  style: const TextStyle(fontSize: 12, color: Colors.deepPurple),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // 📝 Title
            Text(
              entry.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 6),

            // 📖 Content snippet
            Text(
              entry.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 12),

            // 😊 Mood
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _getMoodColor(entry.mood).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getMoodIcon(entry.mood),
                    size: 18,
                    color: _getMoodColor(entry.mood),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  entry.mood,
                  style: TextStyle(
                    fontSize: 14,
                    color: _getMoodColor(entry.mood),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

  String _formatDate(DateTime date) {
    final malaysiaTime = date.toUtc().add(const Duration(hours: 8));
    return DateFormat('EEEE, dd MMM yyyy – hh:mm a').format(malaysiaTime);
  }

  IconData _getMoodIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'sad':
        return Icons.sentiment_very_dissatisfied;
      case 'angry':
        return Icons.sentiment_very_dissatisfied;
      case 'excited':
        return Icons.sentiment_satisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Colors.green;
      case 'sad':
        return Colors.blue;
      case 'angry':
        return Colors.red;
      case 'excited':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _navigateToAddEntry(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEntryScreen(
          repository: _dbHelper,
          onEntryAdded: _loadEntries,
          userId: widget.userId,
        ),
      ),
    );
    _loadEntries();
  }

  void _navigateToEditEntry(BuildContext context, DiaryEntry entry) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEntryScreen(
          repository: _dbHelper,
          onEntryAdded: _loadEntries,
          entryToEdit: entry,
          userId: widget.userId,
        ),
      ),
    );
    _loadEntries();
  }

  void _showSearchDialog(BuildContext context) {
    // You can implement search later if needed
  }
}
