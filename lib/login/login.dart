import 'package:flutter/material.dart';
import 'package:tsel_ui/signup/signup.dart';
import 'package:tsel_ui/services/auth_service.dart';

class Login extends StatelessWidget {
  Login({super.key});

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Instance service SQLite
  final AuthServiceSqlite _auth = AuthServiceSqlite();

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

                // Username (email) input
                _buildTextField(
                  controller: _usernameController,
                  hint: "USERNAME / EMAIL",
                  icon: Icons.person_outline,
                  obscure: false,
                ),
                const SizedBox(height: 20),

                // Password input
                _buildTextField(
                  controller: _passwordController,
                  hint: "PASSWORD",
                  icon: Icons.lock_outline,
                  obscure: true,
                ),
                const SizedBox(height: 30),

                // Tombol login
                _loginButton(context),
                const SizedBox(height: 12),

                // Forgot password (nonaktif di auth lokal)
                TextButton(
                  onPressed: () {
                    // Untuk auth lokal (SQLite) tidak ada reset via email.
                    // Kamu bisa arahkan ke halaman set password lokal jika diperlukan.
                  },
                  child: const Text(
                    "Forgot Password ?",
                    style: TextStyle(color: Colors.black54),
                  ),
                ),

                const SizedBox(height: 80),

                // Sign Up text
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

  Widget _loginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff9edb4b),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        onPressed: () async {
          // Panggil SIGN IN versi SQLite
          await _auth.signin(
            email: _usernameController.text,    // di auth lokal tetap pakai email sebagai key
            password: _passwordController.text,
            context: context,
          );
        },
        child: const Text(
          "LOGIN",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
