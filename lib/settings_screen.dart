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

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout Confirmation'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/auth');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B4775),
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/settings.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.black.withOpacity(0.3),
          appBar: AppBar(
            title: const Text('Settings'),
            backgroundColor: const Color(0xFF1B4775),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildCard(
                child: SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: _darkMode,
                  onChanged: (value) {
                    setState(() {
                      _darkMode = value;
                      _saveSettings();
                    });
                  },
                ),
              ),
              _buildCard(
                child: ListTile(
                  title: const Text('Font Size'),
                  subtitle: Text(_fontSize),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showFontSizeDialog,
                ),
              ),
              _buildCard(
                child: ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notifications'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ),
              _buildCard(
                child: ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Privacy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ),
              _buildCard(
                child: ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('About App'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ),
              const SizedBox(height: 100), // Space for floating button
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FloatingActionButton.extended(
                backgroundColor: Colors.redAccent,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                onPressed: _confirmLogout,
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select Font Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Small', 'Medium', 'Large'].map((size) {
            return RadioListTile(
              title: Text(size),
              value: size,
              groupValue: _fontSize,
              onChanged: (value) {
                setState(() {
                  _fontSize = value.toString();
                  _saveSettings();
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
