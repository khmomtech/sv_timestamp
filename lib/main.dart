import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sv_timestamp/screens/camera_screen.dart';
import 'package:sv_timestamp/theme/app_theme.dart';
import 'package:sv_timestamp/utils/emoji_manager.dart';
import 'package:sv_timestamp/utils/metadata_service.dart';
import 'package:sv_timestamp/utils/storage_service.dart';
import 'package:sv_timestamp/utils/app_shortcuts.dart'; // Import AppShortcuts

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EmojiManager.init();
  await Hive.initFlutter();
  await MetadataService.initializeSettings();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => StorageService())],
      child: MaterialApp(
        title: 'SV TimeStamp',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const CameraScreenWithShortcuts(), // Use wrapped version
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// Wrapper widget to initialize shortcuts
class CameraScreenWithShortcuts extends StatefulWidget {
  const CameraScreenWithShortcuts({super.key});

  @override
  State<CameraScreenWithShortcuts> createState() =>
      _CameraScreenWithShortcutsState();
}

class _CameraScreenWithShortcutsState extends State<CameraScreenWithShortcuts> {
  @override
  void initState() {
    super.initState();
    // Initialize shortcuts after the widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppShortcuts.initialize(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const CameraScreen();
  }
}
