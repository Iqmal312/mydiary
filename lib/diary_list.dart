import 'dart:io';
import 'package:flutter/material.dart';
import 'add_entry_screen.dart';
import 'diary_entry.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

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
        title: const Text('My Diary'),
        actions: [
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
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToEditEntry(context, entry),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entry.imagePath != null && entry.imagePath!.isNotEmpty && File(entry.imagePath!).existsSync())
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(entry.imagePath!),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _formatDate(entry.date),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                entry.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    _getMoodIcon(entry.mood),
                    size: 16,
                    color: _getMoodColor(entry.mood),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    entry.mood,
                    style: TextStyle(fontSize: 12, color: _getMoodColor(entry.mood)),
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
        return Icons.sentiment_dissatisfied;
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
