import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tsel_ui/profile/profile_page.dart';
import 'package:tsel_ui/login/login.dart';
import 'package:tsel_ui/qrGenerator/qr_generator.dart';
import 'package:tsel_ui/qrscan/qr_scanner.dart';
import 'package:tsel_ui/services/auth_service.dart';
import 'package:tsel_ui/data/user_dao.dart';

void main() {
  runApp(const HomePage());
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HJ App Mockup',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const HomeScreen(),
      routes: {
        '/login': (_) => Login(),
        '/qr-scan': (_) => const QrScanner(),
        '/qr-generate': (_) => const QrGenerator(),
        '/profile': (_) => const ProfilePage(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// 0: Beranda, 1: Riwayat, 2: Notifikasi
  int _selectedIndex = 0;

  /// token untuk memaksa GreetingChip rebuild setelah kembali dari Profile
  int _reload = 0;

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  // Gunakan getter agar halaman baru dibuat ulang saat setState dipanggil.
  List<Widget> get _pages => [
        _HomeContent(reload: _reload),
        const _PlaceholderPage('Halaman Riwayat'),
        const _PlaceholderPage('Halaman Notifikasi'),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ===== AppBar (Logout dipertahankan) =====
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 100,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset("assets/images/logoHJ.png", height: 40),
                const Spacer(),
                IconButton(
                  tooltip: 'Search',
                  icon: const Icon(Icons.search, color: Colors.black54),
                  onPressed: () {},
                ),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Logout',
                  icon: const Icon(Icons.logout, color: Colors.black87),
                  onPressed: () async {
                    try {
                      await AuthServiceSqlite().signout(context: context);
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Logout failed: $e')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),

      // ===== Body dengan IndexedStack (menjaga state setiap tab) =====
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFDFF6F6), Color(0xFFB7E1E6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: IndexedStack(index: _selectedIndex, children: _pages),
        ),
      ),

      // ===== FAB tengah → pindah page (contoh ke /qr-scan) =====
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.qr_code_scanner),
        onPressed: () => Navigator.pushNamed(context, '/qr-scan'),
      ),

      // ===== Bottom Navigation (Profile → push ke route /profile) =====
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: SizedBox(
          height: 62,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Kiri: Beranda & Riwayat
              Row(
                children: [
                  MaterialButton(
                    minWidth: 60,
                    onPressed: () => _onItemTapped(0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.home,
                            color: _selectedIndex == 0
                                ? Colors.teal
                                : Colors.black54),
                        const SizedBox(height: 4),
                        Text(
                          'Beranda',
                          style: TextStyle(
                            fontSize: 12,
                            color: _selectedIndex == 0
                                ? Colors.teal
                                : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  MaterialButton(
                    minWidth: 60,
                    onPressed: () => _onItemTapped(1),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history,
                            color: _selectedIndex == 1
                                ? Colors.teal
                                : Colors.black54),
                        const SizedBox(height: 4),
                        Text(
                          'Riwayat',
                          style: TextStyle(
                            fontSize: 12,
                            color: _selectedIndex == 1
                                ? Colors.teal
                                : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Kanan: Notifikasi & Profile (Profile → push route)
              Row(
                children: [
                  MaterialButton(
                    minWidth: 60,
                    onPressed: () => _onItemTapped(2),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.notifications_none,
                            color: _selectedIndex == 2
                                ? Colors.teal
                                : Colors.black54),
                        const SizedBox(height: 4),
                        Text(
                          'Notifikasi',
                          style: TextStyle(
                            fontSize: 12,
                            color: _selectedIndex == 2
                                ? Colors.teal
                                : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  MaterialButton(
                    minWidth: 60,
                    // PROFIL: tunggu result lalu refresh greeting
                    onPressed: () async {
                      final changed =
                          await Navigator.pushNamed(context, '/profile');
                      if (!mounted) return;
                      if (changed == true) {
                        setState(() => _reload++); // paksa Greeting reset
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.person, color: Colors.black54),
                        SizedBox(height: 4),
                        Text('Profile',
                            style:
                                TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ===================== HOME CONTENT ===================== */

class _HomeContent extends StatelessWidget {
  final int reload;
  const _HomeContent({super.key, this.reload = 0});

  Widget _buildMenuItem({required Widget child}) {
    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ===== Greeting dari SQLite (sinkron setelah kembali dari Profile) =====
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: GreetingChipSqlite(key: ValueKey(reload)),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Divider(thickness: 1),
        ),

        // ===== Grid Menu (pindah page via Navigator) =====
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              children: [
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 16,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 0.9,
                  children: [
                    _buildMenuItem(
                      child: _MenuTile(
                        icon: Icons.photo_camera_outlined,
                        label: 'Camera',
                        onTap: () => Navigator.pushNamed(context, '/qr-scan'),
                      ),
                    ),
                    _buildMenuItem(
                      child: _MenuTile(
                        icon: Icons.qr_code_2,
                        label: 'QR Code',
                        onTap: () =>
                            Navigator.pushNamed(context, '/qr-generate'),
                      ),
                    ),
                    _buildMenuItem(
                      child: _MenuTile(
                        icon: Icons.credit_card,
                        label: 'RFID Card',
                        onTap: () => _toast(context, 'RFID Card tapped'),
                      ),
                    ),
                    _buildMenuItem(
                      child: _MenuTile(
                        icon: Icons.print_outlined,
                        label: 'Thermal\nPrinter',
                        onTap: () => _toast(context, 'Thermal Printer tapped'),
                      ),
                    ),
                    _buildMenuItem(child: const SizedBox.shrink()),
                    _buildMenuItem(child: const SizedBox.shrink()),
                  ],
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuTile(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36),
          const SizedBox(height: 6),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

/* ===================== GREETING CHIP: SQLite ===================== */

class GreetingChipSqlite extends StatelessWidget {
  /// Opsional: jika punya email user aktif, kirim di sini untuk query spesifik.
  final String? email;
  const GreetingChipSqlite({super.key, this.email});

  @override
  Widget build(BuildContext context) {
    final dao = UserDao();

    final Future<UserEntity?> future =
        (email != null && email!.trim().isNotEmpty)
            ? dao.findByEmail(email!.trim().toLowerCase())
            : dao.getLastLoggedInUser(); // method ini sudah kamu tambahkan

    return FutureBuilder<UserEntity?>(
      future: future,
      builder: (context, snap) {
        final loading = snap.connectionState == ConnectionState.waiting;
        final u = snap.data;

        final role =
            (u?.role?.trim().isNotEmpty ?? false) ? u!.role!.trim() : '—';
        final name = (u?.displayName?.trim().isNotEmpty ?? false)
            ? u!.displayName!.trim()
            : (u?.email.isNotEmpty ?? false)
                ? u!.email.split('@').first
                : 'User';

        final photoPath = u?.photoPath;
        final hasPhoto = photoPath != null &&
            photoPath.isNotEmpty &&
            File(photoPath).existsSync();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFADB3BA).withOpacity(0.65),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.teal,
                backgroundImage: hasPhoto ? FileImage(File(photoPath!)) : null,
                child: hasPhoto
                    ? null
                    : const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loading ? 'Loading…' : role,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(loading ? 'Hi, …' : 'Hi, $name !',
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              // Tombol opsional di chip (hapus jika tidak perlu)
              // ElevatedButton(
              //   onPressed: () {},
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.teal[300],
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(8),
              //     ),
              //     elevation: 0,
              //   ),
              //   child: const Text('Pilih Menu'),
              // ),
            ],
          ),
        );
      },
    );
  }
}

/* ===================== Placeholder Pages ===================== */

class _PlaceholderPage extends StatelessWidget {
  final String text;
  const _PlaceholderPage(this.text);
  @override
  Widget build(BuildContext context) => Center(child: Text(text));
}
