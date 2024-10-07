import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(const MaterialApp(home: BineryTool()));
}

class BineryTool extends StatefulWidget {
  const BineryTool({super.key});

  @override
  State<BineryTool> createState() => _BineryToolState();
}

class _BineryToolState extends State<BineryTool> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    initializeWebView();
  }

  // Initializes WebViewController with JavaScript and local storage enabled
  void initializeWebView() {
    late final PlatformWebViewControllerCreationParams params;

    // Platform-specific WebView configuration for iOS/Android
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (int progress) {
          debugPrint('Loading progress: $progress%');
        },
        onPageFinished: (String url) {
          debugPrint('Finished loading: $url');
        },
        onWebResourceError: (WebResourceError error) {
          debugPrint('Error loading page: ${error.description}');
        },
      ))
      ..loadRequest(Uri.parse('https://app.binarytool.site'));

    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
  }

  // Handles file download
  Future<void> handleFileDownload() async {
    final directory = await getApplicationDocumentsDirectory();
    final String downloadPath = '${directory.path}/example_download.pdf';
    const url = 'https://example.com/file.pdf'; // Replace with your URL

    final request = await HttpClient().getUrl(Uri.parse(url));
    final response = await request.close();
    final bytes = await consolidateHttpClientResponseBytes(response);

    final file = File(downloadPath);
    await file.writeAsBytes(bytes);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('File downloaded to $downloadPath')),
    );
  }

  // Placeholder for file upload functionality
  Future<void> handleFileUpload() async {
    // Implement your file upload logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File upload functionality coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Binery Tool')),
      body: WebViewWidget(controller: _controller),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: handleFileDownload,
            tooltip: 'Download File',
            child: const Icon(Icons.download),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: handleFileUpload,
            tooltip: 'Upload File',
            child: const Icon(Icons.upload),
          ),
        ],
      ),
    );
  }
}
