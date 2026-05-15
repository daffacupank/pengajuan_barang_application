import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../services/api_service.dart';
import '../services/connectivity_service.dart';
import '../widgets/no_internet_widget.dart';
import '../widgets/responsive_scaffold.dart';
import 'pengguna_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool obscure = true;
  bool online = true;

  Future<void> submitLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final hasNet = await ConnectivityService.hasConnection();
    if (!hasNet) {
      setState(() => online = false);
      return;
    }
    setState(() => isLoading = true);
    final res = await ApiService.login(email: emailController.text.trim(), password: passwordController.text.trim());
    if (!mounted) return;
    setState(() => isLoading = false);
    if (res['success'] == true) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const PenggunaHomePage()), (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['message'].toString()),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> retryInternet() async {
    final ok = await ConnectivityService.hasConnection();
    setState(() => online = ok);
  }

  @override
  Widget build(BuildContext context) {
    if (!online) return Scaffold(body: NoInternetWidget(onRetry: retryInternet));
    final isWide = MediaQuery.sizeOf(context).width >= 800;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: isWide ? double.infinity : MediaQuery.sizeOf(context).height * .42,
            width: isWide ? MediaQuery.sizeOf(context).width * .42 : double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(46)),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.pagePadding(context)),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: isWide ? Row(children: [_brand(), const SizedBox(width: 40), Expanded(child: _card())]) : Column(children: [_brand(), const SizedBox(height: 28), _card()]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _brand() => Expanded(
    flex: 0,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: Colors.white.withOpacity(.15), shape: BoxShape.circle, border: Border.all(color: Colors.white30)),
            child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 64),
          ),
          const SizedBox(height: 18),
          const Text('PENS SURABAYA', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w900, letterSpacing: 1.8)),
          const SizedBox(height: 8),
          const Text('Sistem Pengajuan Barang', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      ),
    ),
  );

  Widget _card() => AppCard(
    padding: const EdgeInsets.all(26),
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Masuk Pengguna', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
          const SizedBox(height: 8),
          const Text('Gunakan akun yang sudah dibuat oleh admin.', style: TextStyle(color: AppColors.muted)),
          const SizedBox(height: 26),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email', hintText: 'user@pens.ac.id', prefixIcon: Icon(Icons.alternate_email_rounded)),
            validator: (v) => v == null || v.trim().isEmpty ? 'Email wajib diisi' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: passwordController,
            obscureText: obscure,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_rounded),
              suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded), onPressed: () => setState(() => obscure = !obscure)),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Password wajib diisi' : null,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: isLoading ? null : submitLogin,
              child: isLoading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4)) : const Text('MASUK'),
            ),
          ),
          const SizedBox(height: 14),
          const Text('Jika tidak bisa masuk, pastikan IP backend benar dan server Express aktif.', style: TextStyle(color: AppColors.muted, fontSize: 12)),
        ],
      ),
    ),
  );
}
