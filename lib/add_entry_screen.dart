import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'diary_entry.dart';

class AddEntryScreen extends StatefulWidget {
  final DatabaseHelper repository;
  final DiaryEntry? entryToEdit;
  final VoidCallback onEntryAdded;

  const AddEntryScreen({
    Key? key,
    required this.repository,
    this.entryToEdit,
    required this.onEntryAdded,
  }) : super(key: key);
  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late DateTime _selectedDate;
  late String _selectedMood;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entryToEdit?.title ?? '');
    _contentController = TextEditingController(text: widget.entryToEdit?.content ?? '');
    _selectedDate = widget.entryToEdit?.date ?? DateTime.now();
    _selectedMood = widget.entryToEdit?.mood ?? 'happy';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entryToEdit == null ? 'New Entry' : 'Edit Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveEntry,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
                style: const TextStyle(fontSize: 16),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                style: const TextStyle(fontSize: 14),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildDatePicker(context),
              const SizedBox(height: 20),
              _buildMoodSelector(),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveEntry,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Entry',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          prefixIcon: const Icon(Icons.calendar_today),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: const TextStyle(fontSize: 16),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSelector() {
    const moods = {
      'happy': {'icon': Icons.sentiment_very_satisfied, 'color': Colors.green},
      'sad': {'icon': Icons.sentiment_very_dissatisfied, 'color': Colors.blue},
      'angry': {'icon': Icons.mood_bad, 'color': Colors.red},
      'excited': {'icon': Icons.celebration, 'color': Colors.orange},
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mood',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: moods.entries.map((mood) {
            return ChoiceChip(
              label: Text(mood.key),
              selected: _selectedMood == mood.key,
              onSelected: (selected) {
                setState(() {
                  _selectedMood = mood.key;
                });
              },
              avatar: Icon(
                mood.value['icon'] as IconData,
                color: Colors.white,
              ),
              backgroundColor: Colors.grey[200],
              selectedColor: mood.value['color'] as Color,
              labelStyle: TextStyle(
                color: _selectedMood == mood.key ? Colors.white : Colors.black,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

void _saveEntry() async {
  if (_formKey.currentState!.validate()) {
    final entry = DiaryEntry(
      id: widget.entryToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      content: _contentController.text,
      date: _selectedDate,
      mood: _selectedMood,
    );

    if (widget.entryToEdit == null) {
      // New entry
      await widget.repository.insertEntry(entry);
    } else {
      // Edit existing
      await widget.repository.updateEntry(entry);
    }

    widget.onEntryAdded(); // ✅ Reload entries in calendar_view.dart
    Navigator.pop(context); // ✅ Then return to previous screen
  }
}
}