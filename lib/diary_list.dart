import 'package:flutter/material.dart';
import 'diary_entry.dart';
import 'database_helper.dart';
import 'diary_repository.dart';
import 'add_entry_screen.dart';

class DiaryListScreen extends StatefulWidget {
  const DiaryListScreen({super.key});

  @override
  State<DiaryListScreen> createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends State<DiaryListScreen> {
  late final DiaryRepository _repository;
  late Future<List<DiaryEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _repository = DiaryRepository(DatabaseHelper());
    _loadEntries();
  }

  void _loadEntries() {
    setState(() {
      _entriesFuture = _repository.getAllEntries();
    });
  }

  Future<void> _addNewEntry(DiaryEntry newEntry) async {
    await _repository.addEntry(newEntry);
    _loadEntries();
  }

  Future<void> _deleteEntry(String id) async {
    await _repository.deleteEntry(id);
    _loadEntries();
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
            return const Center(child: Text('No entries yet. Start writing!'));
          }
          
          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Dismissible(
                key: Key(entry.id),
                background: Container(color: Colors.red),
                onDismissed: (direction) => _deleteEntry(entry.id),
                child: Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(entry.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.date.toString().substring(0, 16)),
                        Text(
                          entry.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    onTap: () => _showEditEntryDialog(context, entry),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEntryDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEntryDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEntryScreen(
          repository: _repository,
          onEntryAdded: _loadEntries,
        ),
      ),
    );
  }

  void _showEditEntryDialog(BuildContext context, DiaryEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEntryScreen(
          repository: _repository,
          entryToEdit: entry,
          onEntryAdded: _loadEntries,
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController searchController = TextEditingController();
        
        return AlertDialog(
          title: const Text('Search Entries'),
          content: TextField(
            controller: searchController,
            decoration: const InputDecoration(hintText: 'Search...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final results = await _repository.searchEntries(searchController.text);
                Navigator.pop(context);
                _showSearchResults(context, results);
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _showSearchResults(BuildContext context, List<DiaryEntry> results) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Results'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: results.length,
              itemBuilder: (context, index) {
                final entry = results[index];
                return ListTile(
                  title: Text(entry.title),
                  subtitle: Text(entry.date.toString().substring(0, 16)),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditEntryDialog(context, entry);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}