import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------- Firestore helpers ----------------

  /// Create a minimal profile doc at signup.
  Future<void> _createUserDocOnSignup(User user) async {
    final ref = _db.collection('users').doc(user.uid);
    await ref.set({
      'email': user.email,
      'displayName': null,   // will be filled in Profile page
      'role': null,          // will be filled in Profile page
      'photoUrl': null,      // will be filled in Profile page
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); // creates doc if missing
  }

  /// Update timestamps on signin; create if missing.
  Future<void> _touchUserDocOnSignin(User user) async {
    final ref = _db.collection('users').doc(user.uid);
    await ref.update({
      'updatedAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    }).catchError((_) async {
      // If the doc didn't exist yet (e.g., migrated account), create it now.
      await ref.set({
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  // ---------------- SIGN UP ----------------
  Future<void> signup({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = cred.user!;
      try {
        await _createUserDocOnSignup(user);
      } on FirebaseException catch (e) {
        debugPrint('❌ Firestore create on signup failed: [${e.code}] ${e.message}');
        _toast('Profile setup failed (${e.code}). You can complete it later in Profile.');
      } catch (e) {
        debugPrint('❌ Firestore create on signup failed: $e');
        _toast('Profile setup failed. You can complete it later in Profile.');
      }

      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
    } on FirebaseAuthException catch (e) {
      _toast(_mapSignupError(e));
    } catch (e) {
      debugPrint('❌ Signup unexpected error: $e');
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
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = cred.user!;
      try {
        await _touchUserDocOnSignin(user);
      } on FirebaseException catch (e) {
        debugPrint('❌ Firestore touch on signin failed: [${e.code}] ${e.message}');
        // Non-blocking: continue to Home
      } catch (e) {
        debugPrint('❌ Firestore touch on signin failed: $e');
      }

      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
    } on FirebaseAuthException catch (e) {
      _toast(_mapSigninError(e));
    } catch (e) {
      debugPrint('❌ Signin unexpected error: $e');
      _toast('Sign in failed. Please try again.');
    }
  }

   // ---------------- SIGN IN WITH MICROSOFT ----------------
  Future<void> signinWithMicrosoft({required BuildContext context}) async {
    try {
      final provider = OAuthProvider('microsoft.com');

      // scope minimal (lihat doc Microsoft Graph; tambah sesuai kebutuhan)
      provider.addScope('User.Read');
      // supaya user bisa pilih akun setiap kali
      provider.setCustomParameters({'prompt': 'select_account'});

      UserCredential cred;
      if (kIsWeb) {
        // Web
        cred = await _auth.signInWithPopup(provider);
      } else {
        // Android / iOS
        cred = await _auth.signInWithProvider(provider);
      }

      final user = cred.user!;
      // Buat doc kalo user baru, atau sentuh timestamp saat login
      try {
        if (cred.additionalUserInfo?.isNewUser == true) {
          await _createUserDocOnSignup(user);
        } else {
          await _touchUserDocOnSignin(user);
        }
      } on FirebaseException catch (e) {
        debugPrint('❌ Firestore on microsoft signin failed: [${e.code}] ${e.message}');
      } catch (e) {
        debugPrint('❌ Firestore on microsoft signin failed: $e');
      }

      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
    } on FirebaseAuthException catch (e) {
      // beberapa kode error umum untuk OAuth
      final msg = switch (e.code) {
        'account-exists-with-different-credential' =>
          'Email sudah terpakai dengan metode login lain.',
        'invalid-credential' => 'Kredensial tidak valid.',
        'operation-not-allowed' => 'Login Microsoft belum diaktifkan.',
        'user-disabled' => 'Akun dinonaktifkan.',
        'popup-closed-by-user' => 'Login dibatalkan.',
        _ => e.message ?? 'Sign in with Microsoft error: ${e.code}',
      };
      _toast(msg);
    } catch (e) {
      debugPrint('❌ Microsoft signin unexpected error: $e');
      _toast('Sign in with Microsoft failed. Please try again.');
    }
  }

  // ---------------- SIGN OUT ----------------
  Future<void> signout({required BuildContext context}) async {
    try {
      await _auth.signOut();
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

  String _mapSignupError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password': return 'The password provided is too weak.';
      case 'email-already-in-use': return 'An account already exists with that email.';
      case 'invalid-email': return 'The email address is invalid.';
      default: return e.message ?? 'Sign up error: ${e.code}';
    }
  }

  String _mapSigninError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'invalid-email': return 'No user found for that email.';
      case 'wrong-password':
      case 'invalid-credential': return 'Wrong password provided for that user.';
      case 'user-disabled': return 'This user has been disabled.';
      default: return e.message ?? 'Sign in error: ${e.code}';
    }
  }
}
