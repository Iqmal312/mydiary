import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'diary_entry.dart';
import 'add_entry_screen.dart'; // Make sure this import is correct

class CalendarView extends StatefulWidget {
  const CalendarView({Key? key}) : super(key: key);

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DatabaseHelper _repository;
  List<DiaryEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _repository = DatabaseHelper();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = await _repository.getAllEntries();
    setState(() {
      _entries = entries;
    });
  }

  void _showAddEntryDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEntryScreen(
          repository: _repository,
          entryToEdit: null,
          onEntryAdded: _loadEntries,
        ),
      ),
    ).then((_) => _loadEntries());
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
    ).then((_) => _loadEntries());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Diary"),
      ),
      body: ListView.builder(
        itemCount: _entries.length,
        itemBuilder: (context, index) {
          final entry = _entries[index];
          return ListTile(
            title: Text(entry.title),
            subtitle: Text(entry.date.toString()),
            onTap: () => _showEditEntryDialog(context, entry),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEntryDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
