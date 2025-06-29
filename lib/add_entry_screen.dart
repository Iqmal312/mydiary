import 'package:flutter/material.dart';
import 'diary_entry.dart';
import 'diary_repository.dart';

class AddEntryScreen extends StatefulWidget {
  final DiaryRepository repository;
  final DiaryEntry? entryToEdit;
  final VoidCallback? onEntryAdded;

  const AddEntryScreen({
    super.key,
    required this.repository,
    this.entryToEdit,
    this.onEntryAdded,
  });

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
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      final entry = DiaryEntry(
        id: widget.entryToEdit?.id ?? DiaryEntry.generateId(),
        title: _titleController.text,
        content: _contentController.text,
        date: _selectedDate,
        mood: _selectedMood,
      );

      if (widget.entryToEdit != null) {
        await widget.repository.updateEntry(entry);
      } else {
        await widget.repository.addEntry(entry);
      }

      if (widget.onEntryAdded != null) {
        widget.onEntryAdded!();
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entryToEdit != null ? 'Edit Entry' : 'New Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveEntry,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date'),
                subtitle: Text('${_selectedDate.toLocal()}'.split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedMood,
                decoration: const InputDecoration(
                  labelText: 'Mood',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'happy', child: Text('Happy 😊')),
                  DropdownMenuItem(value: 'sad', child: Text('Sad 😢')),
                  DropdownMenuItem(value: 'angry', child: Text('Angry 😠')),
                  DropdownMenuItem(value: 'excited', child: Text('Excited 😃')),
                  DropdownMenuItem(value: 'thoughtful', child: Text('Thoughtful 🤔')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedMood = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveEntry,
                child: const Text('Save Entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}