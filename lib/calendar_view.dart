import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'database_helper.dart';
import 'diary_entry.dart';
import 'add_entry_screen.dart';

class CalendarView extends StatefulWidget {
  final int userId;

  const CalendarView({Key? key, required this.userId}) : super(key: key);

  @override
  _CalendarViewState createState() => _CalendarViewState();
}


class _CalendarViewState extends State<CalendarView> {
  late DatabaseHelper _repository;
  Map<DateTime, List<DiaryEntry>> _entriesByDate = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _repository = DatabaseHelper();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
  final entries = await _repository.getEntriesByUserId(widget.userId);
  final Map<DateTime, List<DiaryEntry>> mapped = {};

  for (var entry in entries) {
    final date = DateTime(entry.date.year, entry.date.month, entry.date.day);
    if (!mapped.containsKey(date)) {
      mapped[date] = [];
    }
    mapped[date]!.add(entry);
  }

  setState(() {
    _entriesByDate = mapped;
  });
}

  List<DiaryEntry> _getEntriesForDay(DateTime day) {
    return _entriesByDate[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _showAddEntryDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEntryScreen(
          repository: _repository,
          entryToEdit: null,
          onEntryAdded: _loadEntries,
          userId: widget.userId,
        ),
      ),
    );
  }

  void _showEditEntryDialog(DiaryEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEntryScreen(
          repository: _repository,
          entryToEdit: entry,
          onEntryAdded: _loadEntries,
          userId: widget.userId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calendar")),
      body: Column(
        children: [
          TableCalendar<DiaryEntry>(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getEntriesForDay,
            calendarStyle: const CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Colors.purple,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: _getEntriesForDay(_selectedDay ?? _focusedDay)
                  .map((entry) => ListTile(
                        title: Text(entry.title),
                        subtitle: Text(entry.date.toLocal().toString().split(' ')[0]),
                        onTap: () => _showEditEntryDialog(entry),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEntryDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
