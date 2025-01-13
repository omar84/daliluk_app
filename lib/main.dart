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

class _WebViewPageState extends State<WebViewPage> with WidgetsBindingObserver {
  late final WebViewController _controller;
  String? _preferredLanguage;
  bool _appInForeground = false; 

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
            // Update loading bar
          },
          onPageStarted: (String url) {
            print('Page started loading: $url');

            // Parse the URL and check for the 'lang' parameter
            Uri uri = Uri.parse(url);
            String? lang = uri.queryParameters['lang'];

            if (lang != null && _preferredLanguage != lang) {
              // Update the preferred language and URL
              _preferredLanguage = lang;
              _savePreferredLanguage(lang);
            }
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            // Handle web resource errors
          },
        ),
      )
      ..loadRequest(Uri.parse('https://dalil.uk?key=kit1'));

    // Set the status bar color and icon brightness
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ));

    // Get the preferred language from SharedPreferences
    _getPreferredLanguage().then((lang) {
      _preferredLanguage = lang;

      // If preferred language is set, update the URL
      if (_preferredLanguage != null) {
        _updateUrlWithLanguage(_preferredLanguage!);
      }
    });

    WidgetsBinding.instance!.addObserver(this); 
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // App brought to foreground
      if (!_appInForeground) { 
        _appInForeground = true;
        _controller.reload(); 
        print('Reloading WebView after app resumed');
      }
    } else if (state == AppLifecycleState.paused) {
      // App moved to background
      _appInForeground = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
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
        child: WebViewWidget(
          controller: _controller,
        ),
      ),
    );
  }
}