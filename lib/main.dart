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

  @override
  void initState() {
    super.initState();

    // Initialize the WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    // Set the status bar color and icon brightness
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white, // Set the status bar color to white
      statusBarIconBrightness: Brightness.dark, // Set the icon brightness to dark
    ));

    // Get the preferred language from SharedPreferences
    _getPreferredLanguage().then((lang) {
      _preferredLanguage = lang;

      // Load the initial URL
      _controller.loadRequest(Uri.parse('https://dalil.uk?key=kit1'));

      // If preferred language is set, update the URL
      if (_preferredLanguage != null) {
        _updateUrlWithLanguage(_preferredLanguage!);
      }
    });

    // Listen for URL changes using navigationDelegate
    _controller.setNavigationDelegate(NavigationDelegate(
      onPageStarted: (url) {
        print('New URL: $url');

        // Parse the URL and check for the 'lang' parameter
        Uri uri = Uri.parse(url);
        String? lang = uri.queryParameters['lang'];

        if (lang != null && _preferredLanguage != lang) {
          // Update the preferred language and URL
          _preferredLanguage = lang;
          _savePreferredLanguage(lang);
        }
      },
    ));
  }

  // Update the WebView URL with the given language
  Future<void> _updateUrlWithLanguage(String lang) async {
    await _controller
        .loadRequest(Uri.parse('https://dalil.uk?key=kit1&lang=$lang'));
  }

  // Save the preferred language to SharedPreferences
  Future<void> _savePreferredLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferred_language', lang);
    print('Preferred language saved: $lang');
  }

  // Get the stored preferred language
  Future<String?> _getPreferredLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('preferred_language') ?? 'ar';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}