import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../utils/app_colors.dart';

class DokumentasiWebViewScreen extends StatefulWidget {
  final String url;
  const DokumentasiWebViewScreen({Key? key, required this.url})
    : super(key: key);

  @override
  State<DokumentasiWebViewScreen> createState() =>
      _DokumentasiWebViewScreenState();
}

class _DokumentasiWebViewScreenState extends State<DokumentasiWebViewScreen> {
  InAppWebViewController? _webViewController;
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Dokumentasi Acara'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onProgressChanged: (controller, progress) {
              setState(() {
                _progress = progress / 100;
              });
            },
          ),
          if (_progress < 1) LinearProgressIndicator(value: _progress),
          // WebView back button (in-app navigation)
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton(
              heroTag: 'webview-back',
              backgroundColor: AppColors.primary,
              onPressed: () async {
                if (_webViewController != null) {
                  if (await _webViewController!.canGoBack()) {
                    await _webViewController!.goBack();
                  } else {
                    // Optionally show a snackbar or disable button
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tidak ada halaman sebelumnya.'),
                      ),
                    );
                  }
                }
              },
              child: const Icon(Icons.arrow_back, color: Colors.white),
              tooltip: 'Kembali ke halaman sebelumnya',
            ),
          ),
        ],
      ),
    );
  }
}
