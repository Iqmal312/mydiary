import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'diary_entry.dart';
import 'database_helper.dart';

class AddEntryScreen extends StatefulWidget {
  final DatabaseHelper repository;
  final DiaryEntry? entryToEdit;
  final VoidCallback onEntryAdded;

  const AddEntryScreen({
    Key? key,
    required this.repository,
    required this.onEntryAdded,
    this.entryToEdit,
  }) : super(key: key);

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedMood = 'Neutral';
  bool _isListening = false;
  late stt.SpeechToText _speech;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    if (widget.entryToEdit != null) {
      _titleController.text = widget.entryToEdit!.title;
      _contentController.text = widget.entryToEdit!.content;
      _selectedMood = widget.entryToEdit!.mood;
    }
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => setState(() => _isListening = status == 'listening'),
      onError: (error) => print('Speech error: $error'),
    );

    if (available) {
      _speech.listen(
        onResult: (result) {
          setState(() {
            _contentController.text += result.recognizedWords + ' ';
          });
        },
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      final newEntry = DiaryEntry(
        id: widget.entryToEdit?.id ?? DiaryEntry.generateId(),
        title: _titleController.text,
        content: _contentController.text,
        date: DateTime.now(),
        mood: _selectedMood,
      );

      if (widget.entryToEdit == null) {
        await widget.repository.insertEntry(newEntry);
      } else {
        await widget.repository.updateEntry(newEntry);
      }

      widget.onEntryAdded();
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entryToEdit == null ? 'New Entry' : 'Edit Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(labelText: 'Content'),
                      maxLines: 5,
                      validator: (value) => value == null || value.isEmpty ? 'Please enter content' : null,
                    ),
                  ),
                  IconButton(
                    icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                    onPressed: _isListening ? _stopListening : _startListening,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedMood,
                decoration: const InputDecoration(labelText: 'Mood'),
                items: ['Happy', 'Sad', 'Excited', 'Angry', 'Neutral'].map((mood) {
                  return DropdownMenuItem(value: mood, child: Text(mood));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedMood = value);
                },
              ),
              const SizedBox(height: 20),
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
