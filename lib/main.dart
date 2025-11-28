import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:niri9/Constants/assets.dart';
import 'package:niri9/Functions/Notifications/notification_service.dart';
import 'package:niri9/Functions/Notifications/watch_progress_service.dart';
import 'package:niri9/Helper/error_handler.dart';
import 'package:niri9/Services/apple_iap_service.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import 'Navigation/Navigate.dart';
import 'Repository/repository.dart';
import 'Router/router.dart';
import 'Theme/apptheme.dart';
import 'Helper/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize global error handler first
  GlobalErrorHandler.initialize();

  // Initialize storage first
  Storage.instance.initializeStorage();

  // Load environment variables and initialize Firebase in parallel
  await Future.wait([
    dotenv.load(fileName: ".env"),
    Firebase.initializeApp(),
  ]);

  // Initialize notification service
  await NotificationService().initialize();

  // Initialize watch progress service
  await WatchProgressService().initialize();

  // Initialize Apple In-App Purchase service on iOS
  if (Platform.isIOS) {
    try {
      await AppleIAPService.instance.initialize();
      debugPrint('Apple IAP service initialized in main.dart');
    } catch (e) {
      debugPrint('Error initializing Apple IAP service: $e');
    }
  }

  // Configure system UI for better performance
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: Upgrader(
        durationUntilAlertAgain: const Duration(days: 1),
      ),
      child: MaterialApp(
        title: 'NIRI9',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        builder: EasyLoading.init(),
        debugShowCheckedModeBanner: false,
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // Record app open for watch progress reminders
    WatchProgressService().recordAppOpen();

    // Show ad popup after 2 seconds instead of 5 for better UX
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _showAdPopup();
    });
  }

  void _showSnackBar(String text) {
    final context = _scaffoldKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(text),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showAdPopup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (_) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300, maxHeight: 600),
          child: Material(
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            elevation: 24,
            child: InkWell(
              onTap: () => launchUrl(
                Uri.parse("https://niri9.com/backend"),
                mode: LaunchMode.externalApplication,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue.shade100, Colors.blue.shade300],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 500,
                      width: double.infinity,
                      child: Image.asset(
                        Assets.advertiseBannerImage,
                        fit: BoxFit.cover,
                        cacheWidth: 300,
                        cacheHeight: 500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Repository(),
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Niri9',
            theme: AppTheme.getTheme(),
            navigatorKey: Navigation.instance.navigatorKey,
            navigatorObservers: [Navigation.instance.routeObserver],
            onGenerateRoute: generateRoute,
            // Add performance optimizations
            showPerformanceOverlay: false,
            checkerboardRasterCacheImages: false,
            checkerboardOffscreenLayers: false,
          );
        },
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
