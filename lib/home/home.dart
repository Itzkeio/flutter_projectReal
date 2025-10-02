import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HJ App Mockup',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
    return Scaffold(
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
                // ✅ Logo dari asset
                Image.asset("assets/image/logoHJ.png", height: 40),
                const Spacer(),
                Row(
                  children: const [
                    Icon(Icons.search, color: Colors.black54),
                    SizedBox(width: 12),
                    Icon(Icons.notifications_none, color: Colors.black54),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFDFF6F6), Color(0xFFB7E1E6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Profile card
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 6,
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.teal,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Tom Holland',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Produksi',
                              style: TextStyle(color: Colors.black54),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'NIK Anda    001111',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Pilih Menu'),
                      ),
                    ],
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Divider(thickness: 1),
              ),

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
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.nfc, size: 36),
                                SizedBox(height: 6),
                                Text(
                                  'RFID Card',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          _buildMenuItem(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.qr_code, size: 36),
                                SizedBox(height: 6),
                                Text('QR Code', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                          _buildMenuItem(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.print, size: 36),
                                SizedBox(height: 6),
                                Text(
                                  'Thermal\nPrinter',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          _buildMenuItem(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.camera_alt, size: 36),
                                SizedBox(height: 6),
                                Text('Camera', style: TextStyle(fontSize: 12)),
                              ],
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
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.teal,
        child: const Icon(Icons.qr_code_scanner),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: SizedBox(
          height: 62,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  MaterialButton(
                    minWidth: 60,
                    onPressed: () => _onItemTapped(0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.home,
                          color: _selectedIndex == 0
                              ? Colors.teal
                              : Colors.black54,
                        ),
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
                        Icon(
                          Icons.history,
                          color: _selectedIndex == 1
                              ? Colors.teal
                              : Colors.black54,
                        ),
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
              Row(
                children: [
                  MaterialButton(
                    minWidth: 60,
                    onPressed: () => _onItemTapped(2),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          color: _selectedIndex == 2
                              ? Colors.teal
                              : Colors.black54,
                        ),
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
                    onPressed: () => _onItemTapped(3),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person,
                          color: _selectedIndex == 3
                              ? Colors.teal
                              : Colors.black54,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 12,
                            color: _selectedIndex == 3
                                ? Colors.teal
                                : Colors.black54,
                          ),
                        ),
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

