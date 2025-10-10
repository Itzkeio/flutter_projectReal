// lib/login/login.dart
import 'package:flutter/material.dart';
import 'package:tsel_ui/signup/signup.dart';
import 'package:tsel_ui/services/auth_service.dart';

class Login extends StatefulWidget {
  Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscure = true;
  bool _loadingEmail = false;
  bool _loadingMs = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _doEmailLogin() async {
    setState(() => _loadingEmail = true);
    try {
      await AuthService().signin(
        email: _usernameController.text.trim(),
        password: _passwordController.text,
        context: context,
      );
    } finally {
      if (mounted) setState(() => _loadingEmail = false);
    }
  }

  Future<void> _doMicrosoftLogin() async {
    setState(() => _loadingMs = true);
    try {
      await AuthService().signinWithMicrosoft(context: context);
    } finally {
      if (mounted) setState(() => _loadingMs = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffd9e9ef), Color(0xff8ebcd0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Logo
                Column(
                  children: [
                    Image.asset(
                      'assets/images/logoHJ.png',
                      height: 80,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
                const SizedBox(height: 60),

                // Username
                _buildTextField(
                  controller: _usernameController,
                  hint: "USERNAME",
                  icon: Icons.person_outline,
                  obscure: false,
                ),
                const SizedBox(height: 20),

                // Password
                _buildPasswordField(),

                const SizedBox(height: 24),

                // Tombol login email/password
                _loginButton(context),

                const SizedBox(height: 16),

                // Separator OR
                Row(
                  children: const [
                    Expanded(child: Divider(thickness: 1, color: Colors.white70)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('OR', style: TextStyle(color: Colors.white70)),
                    ),
                    Expanded(child: Divider(thickness: 1, color: Colors.white70)),
                  ],
                ),

                const SizedBox(height: 16),

                // Tombol login Microsoft
                _msLoginButton(context),

                const SizedBox(height: 12),

                // Forgot password (opsional)
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Forgot Password ?",
                    style: TextStyle(color: Colors.black54),
                  ),
                ),

                const SizedBox(height: 60),

                // Sign Up
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Signup()),
                    );
                  },
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool obscure,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff00a79d),
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black),
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff00a79d),
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock_outline, color: Colors.black),
          hintText: "PASSWORD",
          hintStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          suffixIcon: IconButton(
            tooltip: _obscure ? 'Show password' : 'Hide password',
            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off,
                color: Colors.white),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
      ),
    );
  }

  Widget _loginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff9edb4b),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        onPressed: _loadingEmail ? null : _doEmailLogin,
        child: _loadingEmail
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Text(
                "LOGIN",
                style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
              ),
      ),
    );
  }

  Widget _msLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Colors.black12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        icon: _loadingMs
            ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.account_circle, color: Colors.black87),
        label: Text(
          _loadingMs ? 'Signing in...' : 'Sign in with Microsoft',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: _loadingMs ? null : _doMicrosoftLogin,
      ),
    );
  }
}
