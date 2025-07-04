import 'dart:io';
import 'package:flutter/material.dart';
import 'add_entry_screen.dart';
import 'diary_entry.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';
import 'mood_analytics_screen.dart';

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
      _entriesFuture = _dbHelper.getAllEntries(userId: widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/home.jpg'), 
              fit: BoxFit.cover,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text(
              'DiaryKu',
              style: TextStyle(color: Colors.white),
            ),
            
            backgroundColor: Color.fromARGB(255, 27, 71, 117), 
            actions: [
              IconButton(
                icon: const Icon(Icons.bar_chart, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MoodAnalyticsScreen(userId: widget.userId)),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () => _showSearchDialog(context),
              ),
            ],
          ),
          body: FutureBuilder<List<DiaryEntry>>(
            future: _entriesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
              }

              final entries = snapshot.data ?? [];

              if (entries.isEmpty) {
                return _buildEmptyState();
              }

              return _buildEntriesList(entries);
            },
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor:  Color.fromARGB(255, 27, 71, 117),
            onPressed: () => _navigateToAddEntry(context),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book, size: 60, color: Colors.white70),
          const SizedBox(height: 16),
          const Text(
            'No entries yet',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the + button to write your first entry',
            style: TextStyle(fontSize: 14, color: Colors.white70),
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
        return Dismissible(
          key: Key(entry.id.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) async {
            await _dbHelper.deleteEntry(entry.id);
            setState(() {
              entries.removeAt(index);
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Entry deleted'),
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () async {
                    await _dbHelper.insertEntry(entry);
                    setState(() {
                      entries.insert(index, entry);
                    });
                  },
                ),
              ),
            );
          },
          child: _buildEntryCard(entry),
        );
      },
    );
  }


  Widget _buildEntryCard(DiaryEntry entry) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToEditEntry(context, entry),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entry.imagePath != null &&
                  entry.imagePath!.isNotEmpty &&
                  File(entry.imagePath!).existsSync())
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
    // Optionally implement search
  }
}
