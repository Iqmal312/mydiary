import 'package:flutter/material.dart';
import 'database_helper.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dbHelper = DatabaseHelper();

  String _email = '';
  String _newPassword = '';
  bool _success = false;

  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final updated = await _dbHelper.updatePassword(_email, _newPassword);
      setState(() => _success = updated);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(updated
              ? '✅ Password updated! Please log in.'
              : '❌ Email not found.'),
          backgroundColor: updated ? Colors.green : Colors.red,
        ),
      );

      if (updated) {
        Navigator.pop(context); // Go back to login
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Reset Your Password',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onSaved: (value) => _email = value!.trim(),
                validator: (value) =>
                    value != null && value.contains('@') ? null : 'Enter valid email',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'New Password'),
                obscureText: true,
                onSaved: (value) => _newPassword = value!.trim(),
                validator: (value) =>
                    value != null && value.length >= 6 ? null : 'Minimum 6 characters',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reset Password'),
                
                
              ),
            ],
          ),
        ),
      ),
    );
  }
}
