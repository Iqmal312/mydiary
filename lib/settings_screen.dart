import 'package:flutter/material.dart';
import 'auth_screen.dart';

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
    // You can load settings from SharedPreferences if needed
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // cancel
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog first
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red,
            foregroundColor: Colors.white,),
          ),
        ],
      ),
    );
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
              });
              // You can add SharedPreferences saving logic here
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Font Size'),
            subtitle: Text(_fontSize),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Select Font Size'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: ['Small', 'Medium', 'Large'].map((size) {
                      return RadioListTile(
                        title: Text(size),
                        value: size,
                        groupValue: _fontSize,
                        onChanged: (value) {
                          setState(() => _fontSize = value.toString());
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),

      // 🟣 Floating Logout Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _confirmLogout,
        label: const Text("Logout"),
        icon: const Icon(Icons.logout),
        backgroundColor: Colors.red,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
