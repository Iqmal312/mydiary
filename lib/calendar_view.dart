import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'diary_entry.dart';
import 'diary_repository.dart';
import 'database_helper.dart';
import 'add_entry_screen.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late final DiaryRepository _repository;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<DiaryEntry>> _entriesMap = {};

  @override
  void initState() {
    super.initState();
    _repository = DiaryRepository(DatabaseHelper());
    _selectedDay = _focusedDay;
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = await _repository.getAllEntries();
    final Map<DateTime, List<DiaryEntry>> newMap = {};

    for (var entry in entries) {
      final date = DateTime(entry.date.year, entry.date.month, entry.date.day);
      if (newMap[date] == null) {
        newMap[date] = [];
      }
      newMap[date]!.add(entry);
    }

    setState(() {
      _entriesMap = newMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diary Calendar')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            eventLoader: (day) => _entriesMap[day] ?? [],
            calendarStyle: CalendarStyle(
              markerDecoration: const BoxDecoration(
                color: Colors.purple,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.purple,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildEntriesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEntryDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEntriesList() {
    if (_selectedDay == null) return Container();

    final entries = _entriesMap[_selectedDay] ?? [];

    if (entries.isEmpty) {
      return const Center(
        child: Text('No entries for this date'),
      );
    }

    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(entry.title),
            subtitle: Text(entry.content),
            onTap: () => _showEditEntryDialog(context, entry),
          ),
        );
      },
    );
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
}