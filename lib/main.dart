import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  if (Platform.isAndroid) {
    WebView.platform = SurfaceAndroidWebView();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
        ),
      ),
      home: const WebViewPage(),
    );
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({Key? key}) : super(key: key);

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final String url = 'https://direinttechexpo.com/';
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  bool _showRefreshIndicator = false;
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
    _refresh();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == 0) {
        setState(() {
          _showRefreshIndicator = true;
        });
      }
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    _refreshKey.currentState?.show();
  }

  Future<void> _handleRefreshIndicator() async {
    setState(() {
      _showRefreshIndicator = false;
    });

    await _refresh();
  }

  Future<void> _reloadPage() async {
   
    final controller = await _controller.future;
    await controller.clearCache(); 
    controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 20),
        child: Stack(
          children: [
            WebView(
              initialUrl: url,
              javascriptMode: JavascriptMode.unrestricted,
              // Disable caching
              

              onPageFinished: (String url) {
                setState(() {
                  _isLoading = false;
                });
              },
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
              },
              navigationDelegate: (NavigationRequest request) {
                // Optional: Add custom logic for handling URL navigation
                return NavigationDecision.navigate;
              },
              gestureNavigationEnabled:
                  true, // Enable swipe gestures for navigation
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            if (_showRefreshIndicator)
              RefreshIndicator(
                key: _refreshKey,
                onRefresh: _handleRefreshIndicator,
                child: Container(),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _reloadPage,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
