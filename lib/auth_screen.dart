import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'main_navigation.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  String _email = '';
  String _password = '';
  final DatabaseHelper _dbHelper = DatabaseHelper();

  void _submit() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

    if (_isLogin) {
      final user = await _dbHelper.getUser(_email, _password);
debugPrint('Fetched user: $user'); 
      if (user != null) {
        // Save user ID in AuthService for global access (optional)
        AuthService.instance.currentUserId = user['id'] as int;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainNavigation(userId: user['id'] as int),
          ),
        );
      } else {
        _showError('Invalid email or password');
      }
    } else {
      final success = await _dbHelper.registerUser(_email, _password);
      if (success) {
        _showSuccess('Account created! You can now log in.');
        setState(() => _isLogin = true);
      } else {
        _showError('User already exists');
      }
    }
  }
}


  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Login' : 'Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value != null && value.contains('@') ? null : 'Enter a valid email',
                onSaved: (value) => _email = value!.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) =>
                    value != null && value.length >= 6 ? null : 'Minimum 6 characters',
                onSaved: (value) => _password = value!.trim(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: Text(_isLogin ? 'Login' : 'Sign Up'),
              ),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(_isLogin
                    ? "Don't have an account? Sign Up"
                    : "Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthService {
  static final AuthService instance = AuthService._internal();

  int? currentUserId; // will be set after login/signup

  AuthService._internal();
}

