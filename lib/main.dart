import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daliluk - دليلك',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WebViewPage(),
    );
  }
}

class WebViewPage extends StatefulWidget {
  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  String? _preferredLanguage;
  bool _isLoading = true; // Tracks loading state
  String websiteUrl = 'https://dalil.uk?key=kit1';

  @override
  void initState() {
    super.initState();

    // Initialize the WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // You can show progress here if needed
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true; // Show loading screen
            });
            print('Page started loading: $url');

            // Parse the URL and check for the 'lang' parameter
            Uri uri = Uri.parse(url);
            String? lang = uri.queryParameters['lang'];

            if (lang != null && _preferredLanguage != lang) {
              _preferredLanguage = lang;
              _savePreferredLanguage(lang);
            }
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false; // Hide loading screen
            });
            print('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            // Handle web resource errors
          },
        ),
      )
      ..loadRequest(Uri.parse(websiteUrl));

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ));

    _getPreferredLanguage().then((lang) {
      _preferredLanguage = lang;

      if (_preferredLanguage != null) {
        _updateUrlWithLanguage(_preferredLanguage!);
      }
    });
  }

  Future<void> _updateUrlWithLanguage(String lang) async {
    await _controller.loadRequest(Uri.parse(websiteUrl + '&lang=$lang'));
  }

  Future<void> _savePreferredLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferred_language', lang);
    print('Preferred language saved: $lang');
  }

  Future<String?> _getPreferredLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('preferred_language') ?? 'ar';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(), // Loading indicator
              ),
          ],
        ),
      ),
    );
  }
}
