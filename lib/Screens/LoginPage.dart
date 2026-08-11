import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/SignupPage.dart';
import 'package:flutter_application_1/State/AppState.dart';
import 'package:flutter_application_1/Theme/AppColors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final ok = await AppState.instance.login(_username.text, _password.text);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (!ok) {
        _error = 'Invalid username or password';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CircleAvatar(
                  radius: 45,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.chat_bubble, size: 48, color: Colors.black),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Trillion Chats',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Connect with anyone who has an account',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.grey),
                ),
                const SizedBox(height: 32),
                TextField(
                  key: const Key('login_username'),
                  controller: _username,
                  textCapitalization: TextCapitalization.none,
                  decoration: _decoration(
                    icon: Icons.person,
                    hint: 'Username',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('login_password'),
                  controller: _password,
                  obscureText: _obscure,
                  onSubmitted: (_) => _login(),
                  decoration: _decoration(
                    icon: Icons.lock,
                    hint: 'Password',
                    suffix: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.grey,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.accent, fontSize: 14),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  key: const Key('login_button'),
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?",
                        style: TextStyle(color: AppColors.grey)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Create an account',
                        style: TextStyle(
                          color: AppColors.chatGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Demo account: alice  /  alice123',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration({
    required IconData icon,
    required String hint,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.chatGreen),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    );
  }
}
