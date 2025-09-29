import 'package:flutter/material.dart';
import 'package:tsel_ui/theme/theme-controller.dart';
import 'package:tsel_ui/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF0F1220), Color(0xFF1C2030)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        : const LinearGradient(
            colors: [Color(0xFFEAF4FF), Color(0xff8ebcd0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 0) {
            Navigator.pushReplacementNamed(context, '/');
            // }else if(i == 1){
            //   Navigator.pushReplacement(context,'/notifications');
            // }
          } else {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.notifications_none),
          //   label: 'Notification',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: isDark ? 'Switch to light' : 'Switch to dark',
                      onPressed: toggleTheme,
                      icon: Icon(
                        isDark
                            ? Icons.wb_sunny_outlined
                            : Icons.dark_mode_outlined,
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search',
                            isDense: true,
                            prefixIcon: const Icon(Icons.search, size: 18),
                            filled: true,
                            fillColor: isDark ? Colors.white12 : Colors.white,
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Logout',
                      icon: const Icon(Icons.logout),
                      onPressed: () async {
                        try {
                          await AuthService().signout(
                            context: context,
                          ); // <-- pass context + use instance
                          // No extra Navigator push here — signout() already navigates to /login
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Logout failed: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  10,
                  16,
                  14,
                ), // left, top, right, bottom
                child: const _GreetingChip(),
              ),
              const SizedBox(height: 40),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  runSpacing: 28,
                  spacing: 44,
                  children: [
                    _ActionIcon(
                      icon: Icons.photo_camera_outlined,
                      label: 'Camera',
                      onTap: (ctx) => Navigator.pushNamed(ctx, '/qr-scan'),
                    ),
                    _ActionIcon(
                      icon: Icons.qr_code_2,
                      label: 'QR Code',
                      onTap: (ctx) => Navigator.pushNamed(ctx, '/qr-generate'),
                    ),
                    _ActionIcon(
                      icon: Icons.credit_card,
                      label: 'RFID Card',
                      onTap: (ctx) => _toast(ctx, 'RFID Card tapped'),
                    ),
                    _ActionIcon(
                      icon: Icons.print_outlined,
                      label: 'Thermal Printer',
                      onTap: (ctx) => _toast(ctx, 'Thermal Printer tapped'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24), // small bottom space,
            ],
          ),
        ),
      ),
    );
  }

  static void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _GreetingChip extends StatelessWidget {
  const _GreetingChip({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email?.trim().toLowerCase();

    // No signed-in user
    if (email == null || email.isEmpty) {
      return _bubble(context, role: '—', name: 'User', loading: false);
    }

    // Query by email (store emails lowercased in Firestore)
    final Stream<QuerySnapshot<Map<String, dynamic>>> stream = FirebaseFirestore
        .instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return _bubble(
            context,
            role: 'Loading…',
            name: 'User',
            loading: true,
          );
        }
        if (snap.hasError) {
          return _bubble(context, role: 'Error', name: 'User', loading: false);
        }

        Map<String, dynamic>? data;
        if (snap.hasData && snap.data!.docs.isNotEmpty) {
          data = snap.data!.docs.first.data();
        }

        // Prefer Firestore name → Auth displayName → (no fallback if you want strict)
        final firestoreName =
            (data?['name'] ?? data?['fullName'] ?? data?['displayName'])
                as String?;
        // If you NEVER want "User", use empty string fallback instead:
        final String name = (firestoreName?.trim().isNotEmpty ?? false)
            ? firestoreName!.trim()
            : ((user?.displayName?.trim().isNotEmpty ?? false)
                  ? user!.displayName!.trim()
                  : ''); // ← empty when missing

        final String role =
            ((data?['role'] as String?)?.trim().isNotEmpty ?? false)
            ? (data!['role'] as String).trim()
            : '—';

        return _bubble(
          context,
          role: role,
          // If you want to strictly avoid "Hi, User", show placeholder dots instead
          name: name.isEmpty ? '…' : name,
          loading: false,
        );
      },
    );
  }

  Widget _bubble(
    BuildContext context, {
    required String role,
    required String name,
    required bool loading,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg = isDark
        ? const Color(0xFF9399A1).withOpacity(0.35)
        : const Color(0xFFADB3BA).withOpacity(0.65);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(role, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            loading ? 'Hi, …' : 'Hi, $name !',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final void Function(BuildContext) onTap;

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surface.withOpacity(.95);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => onTap(context),
      child: SizedBox(
        width: 110,
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 36),
            ),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
