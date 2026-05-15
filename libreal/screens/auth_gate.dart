import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../services/api_service.dart';
import '../services/connectivity_service.dart';
import '../widgets/no_internet_widget.dart';
import 'login_page.dart';
import 'pengguna_home_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool loading = true;
  bool online = true;
  bool loggedIn = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    setState(() => loading = true);
    online = await ConnectivityService.hasConnection();
    loggedIn = await ApiService.isLoggedIn();
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    if (!online) {
      return Scaffold(body: NoInternetWidget(onRetry: _check));
    }
    return loggedIn ? const PenggunaHomePage() : const LoginPage();
  }
}
