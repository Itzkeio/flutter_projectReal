import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tsel_ui/data/user_dao.dart';

class AuthServiceSqlite {
  final UserDao _dao = UserDao();

  // ---------------- SIGN UP ----------------
  Future<void> signup({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();

      // Cek duplikasi email
      final existed = await _dao.findByEmail(normalizedEmail);
      if (existed != null) {
        _toast('An account already exists with that email.');
        return;
      }

      // Hash password pakai bcrypt
      final salt = BCrypt.gensalt();
      final hash = BCrypt.hashpw(password, salt);
      final now = DateTime.now().millisecondsSinceEpoch;

      final entity = UserEntity(
        id: null,
        uid: null,
        email: normalizedEmail,
        passwordHash: hash,
        displayName: null,
        role: null,
        photoPath: null,
        createdAt: now,
        updatedAt: now,
        lastLoginAt: now,
      );

      await _dao.insert(entity);

      // Simpan sesi
      final sp = await SharedPreferences.getInstance();
      await sp.setString('current_email', normalizedEmail);

      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
    } catch (e) {
      debugPrint('❌ Signup sqlite error: $e');
      _toast('Sign up failed. Please try again.');
    }
  }

  // ---------------- SIGN IN ----------------
  Future<void> signin({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final user = await _dao.findByEmail(normalizedEmail);
      if (user == null) {
        _toast('No user found for that email.');
        return;
      }

      final ok = BCrypt.checkpw(password, user.passwordHash);
      if (!ok) {
        _toast('Wrong password provided for that user.');
        return;
      }

      await _dao.touchLogin(user.id!);

      // Simpan sesi
      final sp = await SharedPreferences.getInstance();
      await sp.setString('current_email', normalizedEmail);

      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
    } catch (e) {
      debugPrint('❌ Signin sqlite error: $e');
      _toast('Sign in failed. Please try again.');
    }
  }

  // ---------------- SIGN OUT ----------------
  Future<void> signout({required BuildContext context}) async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.remove('current_email');

      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
    } catch (_) {
      _toast('Logout failed. Please try again.');
    }
  }

  // ---------------- Helpers ----------------
  void _toast(String msg) {
    if (msg.isEmpty) return;
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.SNACKBAR,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }
}
