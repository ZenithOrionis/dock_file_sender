import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/upload_provider.dart';
import 'screens/upload_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UploadProvider()),
      ],
      child: const DockFileSenderApp(),
    ),
  );
}

class DockFileSenderApp extends StatelessWidget {
  const DockFileSenderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dock File Sender',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        appBarTheme: const AppBarTheme(
          color: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
      ),
      home: const UploadScreen(),
    );
  }
}
