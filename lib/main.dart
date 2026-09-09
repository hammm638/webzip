import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Diisi otomatis oleh GitHub Actions lewat --dart-define
// MODE = "web"  -> load dari WEB_URL
// MODE = "zip"  -> load dari file index.html hasil ekstrak ZIP (assets/web/)
const String appMode = String.fromEnvironment('MODE', defaultValue: 'web');
const String webUrl =
    String.fromEnvironment('WEB_URL', defaultValue: 'https://flutter.dev');
const String zipIndexPath =
    String.fromEnvironment('ZIP_INDEX', defaultValue: 'assets/web/index.html');

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Web/Zip to APK',
      home: const WebViewPage(),
    );
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
        ),
      );

    if (appMode == 'zip') {
      _controller.loadFlutterAsset(zipIndexPath);
    } else {
      _controller.loadRequest(Uri.parse(webUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_loading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
