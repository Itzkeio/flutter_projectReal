import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/notification_helper.dart';
import 'package:tsel_ui/data/user_dao.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  static const routeName = '/profile';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController(); // read-only

  String? _role;
  String? _photoPath; // path file lokal
  bool _saving = false;

  final _roles = const ['Produksi', 'MSTD', 'QC', 'Engineering', 'Logistic'];

  UserEntity? _user; // cache user dari SQLite
  final _dao = UserDao();

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
    final sp = await SharedPreferences.getInstance();
    final email = sp.getString('current_email')?.trim().toLowerCase();
    if (email == null || email.isEmpty) return;

    final user = await _dao.findByEmail(email);
    _user = user;

    _emailCtrl.text = email; // tampilkan email dari sesi
    _nameCtrl.text = (user?.displayName ?? '');
    _role = user?.role;
    _photoPath = user?.photoPath;

    if (mounted) setState(() {});
  }

  // ------- Pilih gambar, salin ke folder app, update _photoPath -------
  Future<void> _pickAndSavePhoto(ImageSource source) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: source, imageQuality: 85);
    if (x == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final fileName =
        'profile_${DateTime.now().millisecondsSinceEpoch}${p.extension(x.path)}';
    final destPath = p.join(appDir.path, fileName);

    // Optional: hapus file lama kalau ada
    if (_photoPath != null && _photoPath!.isNotEmpty) {
      final old = File(_photoPath!);
      if (await old.exists()) {
        try {
          await old.delete();
        } catch (_) {}
      }
    }

    await File(x.path).copy(destPath);

    setState(() {
      _photoPath = destPath; // simpan path baru
    });
  }

  Future<void> _changePhotoFromCamera() async {
    await _pickAndSavePhoto(ImageSource.camera);
  }

  Future<void> _changePhotoFromGallery() async {
    await _pickAndSavePhoto(ImageSource.gallery);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final email = _emailCtrl.text.trim().toLowerCase();
      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email tidak ditemukan. Coba login ulang.')),
        );
        return;
      }

      final now = DateTime.now().millisecondsSinceEpoch;

      if (_user == null) {
        // INSERT baru jika belum ada di SQLite (mis. user baru signup)
        final newUser = UserEntity(
          id: null,
          uid: null,
          email: email,
          passwordHash: _emptyOrKeep(), // tidak mengubah password di sini
          displayName:
              _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
          role: _role,
          photoPath: _photoPath,
          createdAt: now,
          updatedAt: now,
          lastLoginAt: null,
        );
        final insertedId = await _dao.insert(newUser);
        _user = newUser.copyWith(id: insertedId);
      } else {
        // UPDATE data yang boleh diubah dari Profile
        final updated = _user!.copyWith(
          displayName:
              _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
          role: _role,
          photoPath: _photoPath,
          updatedAt: now,
          // passwordHash tetap, email tetap
        );
        await _dao.update(updated);
        _user = updated;
      }

      if (!mounted) return;

      // snackbar
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profile saved')));

      // push notification
      await showSuccessNotification(
        "Profile Updated",
        "Your profile has been saved successfully!",
      );

      Navigator.maybePop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // helper agar insert tidak mengubah password: kalau _user ada, pakai hash lama; kalau tidak ada, kosongkan.
  String _emptyOrKeep() => _user?.passwordHash ?? '';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✨ same gradient as Home
    final gradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF0F1220), Color(0xFF1C2030)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        : const LinearGradient(
            colors: [Color(0xFFEAF4FF), Color(0xFFCFE8F9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );

    final fieldFill = isDark ? Colors.white10 : Colors.white;
    final avatarBg = isDark ? Colors.white12 : Colors.white;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
        decoration: BoxDecoration(gradient: gradient),
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
                      backgroundImage: (_photoPath != null && _photoPath!.isNotEmpty)
                          ? FileImage(File(_photoPath!))
                          : null,
                      child: (_photoPath == null || _photoPath!.isEmpty)
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
                style: TextStyle(color: scheme.onSurface), // biar selalu terlihat
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
                value: _roles.contains(_role) ? _role : null,
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
                label: const Text('Save Changes'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xff0D6EFD),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
