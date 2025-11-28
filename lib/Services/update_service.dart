import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdateService {
  static final UpdateService _instance = UpdateService._internal();

  factory UpdateService() => _instance;

  UpdateService._internal();

  // Your app store URLs
  static const String androidAppId =
      'com.xamtech.niri9'; // Replace with your actual package name
  static const String iosAppId =
      '123456789'; // Replace with your actual App Store ID

  /// Check for updates and show dialog if needed
  Future<void> checkForUpdates(BuildContext context,
      {bool forceCheck = false}) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      debugPrint('🔍 Current app version: $currentVersion');

      String? latestVersion;
      String? storeUrl;

      if (Platform.isAndroid) {
        latestVersion = await _getAndroidVersion();
        storeUrl =
            'https://play.google.com/store/apps/details?id=$androidAppId';
      } else if (Platform.isIOS) {
        latestVersion = await _getIOSVersion();
        storeUrl = 'https://apps.apple.com/app/id$iosAppId';
      }

      if (latestVersion != null &&
          _shouldUpdate(currentVersion, latestVersion)) {
        debugPrint('🆕 Update available: $currentVersion → $latestVersion');
        _showUpdateDialog(context, storeUrl!);
      } else {
        debugPrint('✅ App is up to date');
        if (forceCheck) {
          _showNoUpdateDialog(context);
        }
      }
    } catch (e) {
      debugPrint('❌ Error checking for updates: $e');
    }
  }

  /// Get latest version from Google Play Store
  Future<String?> _getAndroidVersion() async {
    try {
      final url = 'https://play.google.com/store/apps/details?id=$androidAppId';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Parse HTML to extract version info
        final versionRegex = RegExp(r'Current Version.*?>([\d\.]+)<');
        final match = versionRegex.firstMatch(response.body);
        return match?.group(1);
      }
    } catch (e) {
      debugPrint('Error fetching Android version: $e');
    }
    return null;
  }

  /// Get latest version from iOS App Store
  Future<String?> _getIOSVersion() async {
    try {
      final url = 'https://itunes.apple.com/lookup?id=$iosAppId';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        if (results.isNotEmpty) {
          return results[0]['version'] as String;
        }
      }
    } catch (e) {
      debugPrint('Error fetching iOS version: $e');
    }
    return null;
  }

  /// Compare version numbers
  bool _shouldUpdate(String current, String latest) {
    final currentParts = current.split('.').map(int.parse).toList();
    final latestParts = latest.split('.').map(int.parse).toList();

    // Pad with zeros if needed
    while (currentParts.length < latestParts.length) {
      currentParts.add(0);
    }
    while (latestParts.length < currentParts.length) {
      latestParts.add(0);
    }

    for (int i = 0; i < currentParts.length; i++) {
      if (latestParts[i] > currentParts[i]) {
        return true;
      } else if (latestParts[i] < currentParts[i]) {
        return false;
      }
    }
    return false;
  }

  /// Show update dialog
  void _showUpdateDialog(BuildContext context, String storeUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Row(
            children: [
              Icon(Icons.system_update, color: Colors.blue, size: 28),
              SizedBox(width: 12),
              Text(
                'Update Available',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
          content: const Text(
            'A new version of NIRI9 is available with exciting new features and improvements. Update now to enjoy the latest experience!',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Later',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _launchStore(storeUrl);
              },
              icon: const Icon(Icons.download, color: Colors.white),
              label: const Text(
                'Update Now',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Show no update dialog (for manual checks)
  void _showNoUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Text(
                'You\'re Up to Date!',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
          content: const Text(
            'You\'re using the latest version of NIRI9.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Launch app store
  void _launchStore(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } else {
        debugPrint('Could not launch store URL: $url');
      }
    } catch (e) {
      debugPrint('Error launching store: $e');
    }
  }

  /// Force update check (for settings page)
  Future<void> checkForUpdatesManually(BuildContext context) async {
    await checkForUpdates(context, forceCheck: true);
  }
}
