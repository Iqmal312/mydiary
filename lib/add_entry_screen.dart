import 'dart:io';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'diary_entry.dart';
import 'database_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:lottie/lottie.dart';

class AddEntryScreen extends StatefulWidget {
  final DatabaseHelper repository;
  final DiaryEntry? entryToEdit;
  final VoidCallback onEntryAdded;
  final int userId;

  const AddEntryScreen({
    super.key,
    required this.repository,
    required this.onEntryAdded,
    required this.userId,
    this.entryToEdit,
  });

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;
  bool _isListening = false;
  bool _showSuccessAnimation = false;

  String _selectedMood = 'Neutral';
  late stt.SpeechToText _speech;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    if (widget.entryToEdit != null) {
      _titleController.text = widget.entryToEdit!.title;
      _contentController.text = widget.entryToEdit!.content;
      _selectedMood = widget.entryToEdit!.mood;
      if (widget.entryToEdit!.imagePath?.isNotEmpty ?? false) {
        _selectedImage = File(widget.entryToEdit!.imagePath!);
      }
    }
  }

  Future<void> _startListening() async {
    final available = await _speech.initialize(
      onStatus: (status) => setState(() => _isListening = status == 'listening'),
      onError: (error) => print('Speech error: $error'),
    );

    if (available) {
      _speech.listen(
        onResult: (result) => setState(() {
          _contentController.text += '${result.recognizedWords} ';
        }),
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = path.basename(picked.path);
      final saved = await File(picked.path).copy('${directory.path}/$fileName');
      setState(() => _selectedImage = saved);
    }
  }

  Future<void> _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final entry = DiaryEntry(
        id: widget.entryToEdit?.id ?? DiaryEntry.generateId(),
        title: _titleController.text,
        content: _contentController.text,
        date: DateTime.now(),
        mood: _selectedMood,
        imagePath: _selectedImage?.path ?? '',
        userId: widget.userId,
      );

      if (widget.entryToEdit == null) {
        await widget.repository.insertEntry(entry);
      } else {
        await widget.repository.updateEntry(entry);
      }

      widget.onEntryAdded();
      setState(() {
        _isLoading = false;
        _showSuccessAnimation = true;
      });

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pop(context);
      }
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
          backgroundColor: Colors.black.withOpacity(0.6),
          appBar: AppBar(
            title: Text(widget.entryToEdit == null ? 'New Entry' : 'Edit Entry'),
            backgroundColor: const Color.fromARGB(255, 27, 71, 117),
          ),
          body: Stack(
            children: [
              if (_showSuccessAnimation)
                Center(
                  child: Lottie.asset('assets/animations/success.json', repeat: false),
                ),
              if (!_showSuccessAnimation)
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildCard(
                          child: TextFormField(
                            controller: _titleController,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration('Title'),
                            validator: (v) => v == null || v.isEmpty ? 'Enter title' : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildCard(
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _contentController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _inputDecoration('Content'),
                                  maxLines: 3,
                                  validator: (v) =>
                                      v == null || v.isEmpty ? 'Enter content' : null,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  _isListening ? Icons.mic : Icons.mic_none,
                                  color: Colors.white,
                                ),
                                onPressed: _isListening ? _stopListening : _startListening,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildCard(
                          child: DropdownButtonFormField<String>(
                            value: _selectedMood,
                            dropdownColor: const Color.fromARGB(255, 27, 71, 117),
                            decoration: _inputDecoration('Mood'),
                            style: const TextStyle(color: Colors.white),
                            iconEnabledColor: Colors.white,
                            items: ['Happy', 'Sad', 'Excited', 'Angry', 'Neutral']
                                .map((m) => DropdownMenuItem(
                                      value: m,
                                      child: Text(m),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _selectedMood = v);
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image, color: Colors.white),
                          label: const Text('Pick Image', style: TextStyle(color: Colors.white)),
                        ),
                        if (_selectedImage != null)
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: FileImage(_selectedImage!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        const SizedBox(height: 10),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton.icon(
                                icon: const Icon(Icons.save),
                                label: const Text(
                                  'Save Entry',
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: _saveEntry,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 60, 69, 78),
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                                  textStyle: const TextStyle(fontSize: 16),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white24),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: child,
    );
  }
}
