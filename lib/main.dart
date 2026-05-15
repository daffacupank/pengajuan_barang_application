import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'screens/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PENS Pengajuan Barang',
      theme: AppTheme.light,
      home: const AuthGate(),
    );
  }
}
