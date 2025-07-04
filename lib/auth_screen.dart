import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'main_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'forgot_password_screen.dart';


class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _showPassword = false;
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
      body: Stack(
        children: [
          // 🎨 Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/login.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🌫️ Overlay
          Container(color: Colors.black.withOpacity(0.6)),

          // ✨ Stylish App Title at top center
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'DiaryKu',
                style: GoogleFonts.pacifico(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  foreground: Paint()
                      ..shader = LinearGradient(
                        colors: [Color.fromARGB(255, 158, 6, 163), const Color.fromARGB(255, 91, 0, 248)],
                      ).createShader(
                        Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                      ),
                ),
              ),
            ),
          ),


          // 📝 Login / Sign Up Form
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 8,
                color: Colors.black.withOpacity(0.7),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isLogin ? 'Login' : 'Sign Up',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        

                        const SizedBox(height: 16),
                        TextFormField(
                           style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) =>
                              value != null && value.contains('@') ? null : 'Enter a valid email',
                          onSaved: (value) => _email = value!.trim(),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          obscureText: !_showPassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _showPassword = !_showPassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) =>
                              value != null && value.length >= 6 ? null : 'Minimum 6 characters',
                          onSaved: (value) => _password = value!.trim(),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(_isLogin ? 'Login' : 'Sign Up',
                          style: const TextStyle(color: Colors.white),),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _isLogin = !_isLogin),
                          child: Text(
                            _isLogin
                                ? "Don't have an account? Sign Up"
                                : "Already have an account? Login",
                            style: TextStyle(color: Colors.deepPurple),
                          ),
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                              );
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(color: Colors.deepPurple),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthService {
  static final AuthService instance = AuthService._internal();

  int? currentUserId;

  AuthService._internal();
}
