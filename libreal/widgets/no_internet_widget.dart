import 'package:flutter/material.dart';
import 'responsive_scaffold.dart';

class NoInternetWidget extends StatelessWidget {
  final VoidCallback onRetry;
  const NoInternetWidget({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return StateMessage(
      icon: Icons.wifi_off_rounded,
      title: 'Tidak Ada Koneksi Internet',
      message: 'Periksa jaringan internet Anda, lalu tekan tombol Coba Lagi.',
      onPressed: onRetry,
    );
  }
}
