import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // ⬅️ ADD THIS
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

// import '../utils/notification_helper.dart'; // ⬅️ REMOVE THIS

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  static const routeName = '/profile';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController(); // read-only

  String? _role;
  String? _photoBase64; // stored in Firestore
  bool _saving = false;

  final _roles = const ['Produksi', 'MSTD', 'QC', 'Engineering', 'Logistic'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _emailCtrl.text = user.email ?? '';

    final snap = await _db.collection('users').doc(user.uid).get();
    final data = snap.data() ?? {};

    _nameCtrl.text = (data['displayName'] ?? '') as String;
    _role = data['role'] as String?;
    _photoBase64 = data['photoBase64'] as String?;

    if (mounted) setState(() {});
  }

  // ... (All your helper methods like _avatarBytesFromBase64, etc. remain unchanged) ...
  Uint8List? _avatarBytesFromBase64(String? raw) {
    if (raw == null) return null;
    try {
      var s = raw.trim();
      final i = s.indexOf(',');
      if (s.startsWith('data:image') && i != -1) {
        s = s.substring(i + 1);
      }
      s = s.replaceAll(RegExp(r'\s'), '');
      final mod = s.length % 4;
      if (mod != 0) s = s.padRight(s.length + (4 - mod), '=');
      final bytes = base64Decode(s);
      if (bytes.isEmpty) return null;
      return bytes;
    } catch (e) {
      debugPrint('❌ Base64 decode failed: $e');
      return null;
    }
  }

  void _debugLogPhotoInfo() {
    final len = _photoBase64?.length ?? 0;
    final bytes = _avatarBytesFromBase64(_photoBase64);
    debugPrint('📷 photoBase64 length: $len');
    debugPrint('📦 decoded bytes: ${bytes?.lengthInBytes ?? 0}');
  }

  Future<String?> _pickCompressedBase64(ImageSource source) async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(source: source);
    if (xfile == null) return null;
    final bytes = await FlutterImageCompress.compressWithFile(
      File(xfile.path).absolute.path,
      minWidth: 512,
      minHeight: 512,
      quality: 75,
      format: CompressFormat.jpeg,
    );
    if (bytes == null) return null;
    return base64Encode(bytes);
  }

  Future<void> _changePhotoFromCamera() async {
    final b64 = await _pickCompressedBase64(ImageSource.camera);
    if (b64 == null) return;
    if (b64.length > 800000) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image too large. Try again.')),
      );
      return;
    }
    setState(() => _photoBase64 = b64);
    _debugLogPhotoInfo();
  }

  Future<void> _changePhotoFromGallery() async {
    final b64 = await _pickCompressedBase64(ImageSource.gallery);
    if (b64 == null) return;
    if (b64.length > 800000) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image too large. Pick a smaller one.')),
      );
      return;
    }
    setState(() => _photoBase64 = b64);
    _debugLogPhotoInfo();
  }
  // -----------------------------------------------------------

  // ⭐️ EDITED THIS FUNCTION TO TRIGGER THE PUSH NOTIFICATION ⭐️
   Future<void> _save() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _saving = true);
    try {
      // ⭐️ Get the latest FCM token
      final token = await FirebaseMessaging.instance.getToken();

      // ⭐️ Save the profile data AND the fcmToken to the 'users' document.
      // This action will now trigger your updated Cloud Function every time.
      await _db.collection('users').doc(user.uid).set({
        'displayName':
            _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
        'role': _role,
        'photoBase64': _photoBase64,
        'fcmToken': token, // ⬅️ ADD THIS LINE
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // ⭐️ REMOVE the old event creation logic
      // await _db.collection('profileSaveEvents').add({...});

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profile saved successfully')));
          
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... Your build method is unchanged ...
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldFill = isDark ? Colors.white10 : Colors.white;
    final avatarBg = isDark ? Colors.white12 : Colors.white;
    final Uint8List? avatarBytes = _avatarBytesFromBase64(_photoBase64);
    const homeGradient = LinearGradient(
      colors: [Color(0xFFDFF6F6), Color(0xFFB7E1E6)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: scheme.onSurface),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: scheme.onSurface,
            ),
        leading: BackButton(
          color: scheme.onSurface,
          onPressed: () {
            final nav = Navigator.of(context);
            if (nav.canPop()) {
              nav.pop();
            } else {
              nav.pushReplacementNamed('/');
            }
          },
        ),
        title: const Text('Profile'),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: scheme.onSurface),
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save_outlined),
            label: const Text('Save'),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: homeGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: avatarBg,
                      backgroundImage:
                          (avatarBytes != null) ? MemoryImage(avatarBytes) : null,
                      child: (avatarBytes == null)
                          ? const Icon(Icons.person, size: 48)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: PopupMenuButton<String>(
                        tooltip: 'Change photo',
                        itemBuilder: (ctx) => const [
                          PopupMenuItem(
                            value: 'camera',
                            child: ListTile(
                              leading: Icon(Icons.photo_camera_outlined),
                              title: Text('Take a photo'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          PopupMenuItem(
                            value: 'gallery',
                            child: ListTile(
                              leading: Icon(Icons.photo_library_outlined),
                              title: Text('Select from gallery'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                        onSelected: (v) async {
                          if (v == 'camera') {
                            await _changePhotoFromCamera();
                          } else if (v == 'gallery') {
                            await _changePhotoFromGallery();
                          }
                        },
                        child: const CircleAvatar(
                          radius: 18,
                          child: Icon(Icons.edit, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Email', style: TextStyle(color: scheme.onSurfaceVariant)),
              const SizedBox(height: 6),
              TextField(
                controller: _emailCtrl,
                readOnly: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: fieldFill,
                  prefixIcon: const Icon(Icons.alternate_email),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text('Name', style: TextStyle(color: scheme.onSurfaceVariant)),
              const SizedBox(height: 6),
              TextField(
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Your name',
                  filled: true,
                  fillColor: fieldFill,
                  prefixIcon: const Icon(Icons.person_outline),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text('Role', style: TextStyle(color: scheme.onSurfaceVariant)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _role,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: fieldFill,
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: const OutlineInputBorder(),
                ),
                hint: const Text('Select role'),
                items: _roles
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: _saving ? null : (v) => setState(() => _role = v),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.save),
                label: const Text(
                  'Save Changes',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xff9edb4b),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}