import 'package:flutter/material.dart';
import 'diary_entry.dart';

class NewEntryScreen extends StatefulWidget {
  final Function(DiaryEntry) addEntry;

  const NewEntryScreen({super.key, required this.addEntry});

  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedMood = 'happy';
  final _formKey = GlobalKey<FormState>();

  void _submitEntry() {
  if (_formKey.currentState!.validate()) {
    final newEntry = DiaryEntry(
      id: DateTime.now().toString(),
      title: _titleController.text,
      content: _contentController.text,
      date: DateTime.now(),
      mood: _selectedMood,
      imagePath: '',
      userId: 1, // TEMP userId until integrated with actual auth
    );

    widget.addEntry(newEntry);
    Navigator.of(context).pop();
  }
}


  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Diary Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedMood,
                items: const [
                  DropdownMenuItem(value: 'happy', child: Text('Happy 😊')),
                  DropdownMenuItem(value: 'sad', child: Text('Sad 😢')),
                  DropdownMenuItem(
                      value: 'thoughtful', child: Text('Thoughtful 🤔')),
                  DropdownMenuItem(
                      value: 'excited', child: Text('Excited 😃')),
                  DropdownMenuItem(value: 'angry', child: Text('Angry 😠')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedMood = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Mood'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please write something';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitEntry,
                child: const Text('Save Entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}