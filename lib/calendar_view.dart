import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'database_helper.dart';
import 'diary_entry.dart';
import 'add_entry_screen.dart';
import 'dart:io';

class CalendarView extends StatefulWidget {
  final int userId;

  const CalendarView({super.key, required this.userId});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<DiaryEntry>> _groupedEntries = {};

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = await _dbHelper.getAllEntries(userId: widget.userId);
    final Map<DateTime, List<DiaryEntry>> grouped = {};

    for (var entry in entries) {
      final date = DateTime(entry.date.year, entry.date.month, entry.date.day);
      if (grouped[date] == null) {
        grouped[date] = [];
      }
      grouped[date]!.add(entry);
    }

    setState(() {
      _groupedEntries = grouped;
    });
  }

  List<DiaryEntry> _getEntriesForDay(DateTime day) {
    return _groupedEntries[DateTime(day.year, day.month, day.day)] ?? [];
  }

  bool _hasEntries(DateTime day) {
    return _groupedEntries[DateTime(day.year, day.month, day.day)] != null;
  }

  int _entryCount(DateTime day) {
    return _groupedEntries[DateTime(day.year, day.month, day.day)]?.length ?? 0;
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
            title: const Text('Calendar View', style: TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF1B4775),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2000),
                lastDay: DateTime.utc(2100),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: (_selectedDay == null)
                        ? const Color(0xFF1B4775)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: const Color(0xFF1B4775),
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: const TextStyle(color: Colors.white),
                  weekendTextStyle: const TextStyle(color: Colors.redAccent),
                  markersMaxCount: 1,
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekendStyle: TextStyle(color: Colors.redAccent),
                  weekdayStyle: TextStyle(color: Colors.white),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleTextStyle: TextStyle(color: Colors.white),
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                ),
                calendarBuilders: CalendarBuilders(
  markerBuilder: (context, date, events) {
    final entryCount = _entryCount(date);
    if (entryCount > 0) {
      return Positioned(
        right: 1,
        bottom: 1,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Colors.deepPurple,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$entryCount',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  },
  defaultBuilder: (context, date, _) {
    final isToday = isSameDay(date, DateTime.now());
    final isSelected = isSameDay(date, _selectedDay);

    Color? bgColor;
    if (isSelected) {
      bgColor = const Color(0xFF1B4775); // Dark blue for selected
    } else if (isToday && _selectedDay == null) {
      bgColor = const Color(0xFF1B4775); // Highlight today only if not selected
    }

    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
      ),
      child: Center(
        child: Text(
          '${date.day}',
          style: TextStyle(
            color: isSelected || isToday ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  },
),

              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  child: _selectedDay == null || _getEntriesForDay(_selectedDay!).isEmpty
                      ? const Center(
                          child: Text(
                            'No diary entries for this day.',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _getEntriesForDay(_selectedDay!).length,
                          itemBuilder: (context, index) {
                            final entry = _getEntriesForDay(_selectedDay!)[index];
                            return _buildEntryCard(entry);
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEntryCard(DiaryEntry entry) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(entry.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          entry.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          _getMoodIcon(entry.mood),
          color: _getMoodColor(entry.mood),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEntryScreen(
                repository: _dbHelper,
                entryToEdit: entry,
                onEntryAdded: _loadEntries,
                userId: widget.userId,
              ),
            ),
          );
        },
      ),
    );
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
}
