import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrGenerator extends StatefulWidget {
  const QrGenerator({super.key});
  static const routeName = '/qr-generate';

  @override
  State<QrGenerator> createState() => _QrGeneratorState();
}

class _QrGeneratorState extends State<QrGenerator> {
  final TextEditingController _controller = TextEditingController(
    text: "https://example.com",
  );
  String _data = "https://example.com";

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generate() {
    setState(() {
      _data = _controller.text.trim().isEmpty
          ? "Hello World"
          : _controller.text.trim();
    });
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _data));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR data copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldFill = isDark ? Colors.white10 : Colors.white;

    // Gradient yang sama dengan Home/Profile
    const homeGradient = LinearGradient(
      colors: [Color(0xFFDFF6F6), Color(0xFFB7E1E6)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return Scaffold(
      // Biar gradient naik sampai di balik AppBar
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: const Text("Generate QR Code"),
        backgroundColor: Colors.transparent, // sama seperti Home/Profile
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
      ),

      body: Container(
        decoration: const BoxDecoration(gradient: homeGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Input field
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: "Enter text or URL",
                    filled: true,
                    fillColor: fieldFill,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.link_outlined),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _controller.clear(),
                    ),
                  ),
                  onSubmitted: (_) => _generate(),
                ),
                const SizedBox(height: 16),

                // Generate button
                FilledButton.icon(
                  onPressed: _generate,
                  icon: const Icon(Icons.qr_code),
                  label: const Text("Generate", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xff9edb4b),
                  ),
                ),

                const SizedBox(height: 24),

                // QR Code preview (card putih biar kontras di atas gradient)
                Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: _data,
                        size: 240,
                        version: QrVersions.auto,
                        gapless: true,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _copyToClipboard,
                      icon: const Icon(Icons.copy),
                      label: const Text("Copy Data"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
