import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

enum ScanMode { qr, barcode }

class QrScanner extends StatefulWidget {
  const QrScanner({super.key});
  static const routeName = '/qr-scan';

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  late MobileScannerController _controller;

  ScanMode _mode = ScanMode.qr;
  bool _locked = false;
  String? _lastValue;

  DateTime? _lastTap;

  @override
  void initState() {
    super.initState();
    _controller = _makeController(_mode);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  MobileScannerController _makeController(ScanMode m) {
    return MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
      detectionSpeed: DetectionSpeed.noDuplicates, // controller param
      formats: _formatsFor(m),                     // controller param
    );
  }

  // Supported formats for each mode
  List<BarcodeFormat> _formatsFor(ScanMode m) {
    if (m == ScanMode.qr) {
      return const [BarcodeFormat.qrCode];
    }
    // Common 1D + a couple 2D formats (adjust to your needs)
    return const [
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.code93,
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.itf,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.pdf417,    // optional 2D
      BarcodeFormat.dataMatrix // optional 2D
    ];
  }

  /// Try to produce a valid http/https URL from a scanned string.
  /// - Accepts full http/https URLs.
  /// - If it looks like a domain but has no scheme, prepends https://
  Uri? _asHttpUrl(String value) {
    String v = value.trim();

    final direct = Uri.tryParse(v);
    if (direct != null && (direct.scheme == 'http' || direct.scheme == 'https')) {
      return direct;
    }

    final looksLikeDomain =
        RegExp(r'^[A-Za-z0-9.-]+\.[A-Za-z]{2,}([/:?#].*)?$').hasMatch(v);
    if ((direct == null || !direct.hasScheme) && looksLikeDomain) {
      final fixed = Uri.tryParse('https://$v');
      if (fixed != null && (fixed.scheme == 'http' || fixed.scheme == 'https')) {
        return fixed;
      }
    }
    return null;
  }

  // Open URL via external browser (most reliable)
  Future<void> _openUrl(Uri uri) async {
    // simple debounce (avoids channel spam on double-taps)
    final now = DateTime.now();
    if (_lastTap != null && now.difference(_lastTap!) < const Duration(milliseconds: 600)) {
      return;
    }
    _lastTap = now;

    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No app available to open this link')),
        );
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Open failed: ${e.message ?? e.code}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Open failed: $e')),
        );
      }
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_locked) return;
    if (capture.barcodes.isEmpty) return;
    final value = capture.barcodes.first.rawValue;
    if (value == null || value.isEmpty) return;

    setState(() {
      _locked = true;
      _lastValue = value;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Scanned: $value')));
  }

  void _switchMode(ScanMode m) {
    setState(() {
      _mode = m;
      _locked = false;
      _lastValue = null;
      // Recreate controller with new formats
      _controller.dispose();
      _controller = _makeController(m);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final url = (_lastValue == null) ? null : _asHttpUrl(_lastValue!);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        leading: const BackButton(),
        title: Text(_mode == ScanMode.qr ? 'Scan QR' : 'Scan Barcode'),
        actions: [
          IconButton(
            tooltip: 'Switch Camera',
            onPressed: () => _controller.switchCamera(),
            icon: const Icon(Icons.cameraswitch),
          ),
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _controller,
            builder: (context, state, _) {
              final torch = state.torchState;
              final isOn = torch == TorchState.on;
              final unavailable = torch == TorchState.unavailable;
              return IconButton(
                tooltip: unavailable
                    ? 'Torch unavailable'
                    : (isOn ? 'Turn off torch' : 'Turn on torch'),
                onPressed: unavailable ? null : () => _controller.toggleTorch(),
                icon: Icon(isOn ? Icons.flash_on : Icons.flash_off),
              );
            },
          ),
          PopupMenuButton<ScanMode>(
            tooltip: 'Scan mode',
            onSelected: _switchMode,
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: ScanMode.qr,
                child: Text('QR Code'),
              ),
              PopupMenuItem(
                value: ScanMode.barcode,
                child: Text('Barcodes'),
              ),
            ],
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: Stack(
        children: [
          // key is fine to keep; controller handles formats/speed
          MobileScanner(
            key: ValueKey(_mode),
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Scan window
          IgnorePointer(
            child: Center(
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.95),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          // Bottom action bar when locked (after a scan)
          if (_locked && _lastValue != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  color: scheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Mode chip + value
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                _mode == ScanMode.qr ? 'QR' : 'BARCODE',
                                style: TextStyle(
                                  color: scheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: InkWell(
                                onTap: url == null ? null : () => _openUrl(url),
                                child: Text(
                                  _lastValue!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: url != null ? scheme.primary : scheme.onSurface,
                                    decoration:
                                        url != null ? TextDecoration.underline : null,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            FilledButton.icon(
                              onPressed: () => setState(() => _locked = false),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Scan again'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: _lastValue!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Copied to clipboard')),
                                );
                              },
                              icon: const Icon(Icons.copy),
                              label: const Text('Copy'),
                            ),
                            const Spacer(),
                            if (url != null)
                              TextButton.icon(
                                onPressed: () => _openUrl(url),
                                icon: const Icon(Icons.open_in_new),
                                label: const Text('Open'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
