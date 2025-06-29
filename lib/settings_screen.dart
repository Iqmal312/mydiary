import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  String _fontSize = 'Medium';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      _fontSize = prefs.getString('fontSize') ?? 'Medium';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _darkMode);
    await prefs.setString('fontSize', _fontSize);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
                _saveSettings();
              });
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Font Size'),
            subtitle: Text(_fontSize),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Select Font Size'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile(
                          title: const Text('Small'),
                          value: 'Small',
                          groupValue: _fontSize,
                          onChanged: (value) {
                            setState(() {
                              _fontSize = value.toString();
                              _saveSettings();
                            });
                            Navigator.pop(context);
                          },
                        ),
                        RadioListTile(
                          title: const Text('Medium'),
                          value: 'Medium',
                          groupValue: _fontSize,
                          onChanged: (value) {
                            setState(() {
                              _fontSize = value.toString();
                              _saveSettings();
                            });
                            Navigator.pop(context);
                          },
                        ),
                        RadioListTile(
                          title: const Text('Large'),
                          value: 'Large',
                          groupValue: _fontSize,
                          onChanged: (value) {
                            setState(() {
                              _fontSize = value.toString();
                              _saveSettings();
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}