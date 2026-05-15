import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../services/api_service.dart';
import '../services/connectivity_service.dart';
import '../widgets/no_internet_widget.dart';
import '../widgets/responsive_scaffold.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final oldC = TextEditingController();
  final newC = TextEditingController();
  final confirmC = TextEditingController();

  bool loading = false;
  bool checkingInternet = true;
  bool online = true;

  @override
  void initState() {
    super.initState();
    checkInternet();
  }

  @override
  void dispose() {
    oldC.dispose();
    newC.dispose();
    confirmC.dispose();
    super.dispose();
  }

  Future<void> checkInternet() async {
    setState(() {
      checkingInternet = true;
    });

    final connected = await ConnectivityService.hasConnection();

    if (!mounted) return;

    setState(() {
      online = connected;
      checkingInternet = false;
    });
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    final connected = await ConnectivityService.hasConnection();

    if (!connected) {
      setState(() => online = false);
      return;
    }

    setState(() => loading = true);

    final res = await ApiService.changePassword(
      passwordLama: oldC.text.trim(),
      passwordBaru: newC.text.trim(),
      konfirmasiPassword: confirmC.text.trim(),
    );

    if (!mounted) return;

    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['message'].toString()),
        backgroundColor:
        res['success'] == true ? AppColors.success : AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (res['success'] == true) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (checkingInternet) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ubah Password'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!online) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ubah Password'),
        ),
        body: NoInternetWidget(
          onRetry: checkInternet,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Password'),
      ),
      body: ResponsivePage(
        child: SingleChildScrollView(
          child: AppCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Keamanan Akun',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryDark,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Gunakan password baru yang kuat dan mudah diingat.',
                    style: TextStyle(
                      color: AppColors.muted,
                    ),
                  ),

                  const SizedBox(height: 22),

                  _field(
                    controller: oldC,
                    label: 'Password Lama',
                  ),

                  const SizedBox(height: 16),

                  _field(
                    controller: newC,
                    label: 'Password Baru',
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Password baru wajib diisi';
                      }

                      if (v.trim().length < 6) {
                        return 'Minimal 6 karakter';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  _field(
                    controller: confirmC,
                    label: 'Konfirmasi Password',
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Konfirmasi password wajib diisi';
                      }

                      if (v.trim() != newC.text.trim()) {
                        return 'Konfirmasi tidak sama';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: loading ? null : submit,
                      icon: loading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Icon(Icons.save_rounded),
                      label: Text(
                        loading ? 'Menyimpan...' : 'Simpan Password',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_rounded),
      ),
      validator: validator ??
              (v) {
            if (v == null || v.trim().isEmpty) {
              return '$label wajib diisi';
            }

            return null;
          },
    );
  }
}