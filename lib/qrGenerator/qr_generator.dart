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
  final TextEditingController _controller = TextEditingController(text: "https://example.com");
  String _data = "https://example.com";

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generate() {
    setState(() {
      _data = _controller.text.trim().isEmpty ? "Hello World" : _controller.text.trim();
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Generate QR Code"),
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            //Input field
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "Enter text or URL",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _controller.clear(),
                ),
              ),
              onSubmitted: (_) => _generate(),
            ),
            const SizedBox(height: 20),

            // Generate button
            FilledButton.icon(
              onPressed: _generate,
              icon: const Icon(Icons.qr_code),
              label: const Text("Generate"),
            ),

            const SizedBox(height: 30),

            // QR Code preview
            Expanded(
              child: Center(
                child: QrImageView(
                  data: _data,
                  size: 240,
                  version: QrVersions.auto,
                  gapless: true,
                  backgroundColor: Colors.white,
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
            )
          ],
        ),
      ),
    );
  }
}
