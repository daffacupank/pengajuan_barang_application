import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/responsive_scaffold.dart';
import 'buat_laporan_page.dart';
import 'change_password_page.dart';
import 'login_page.dart';
import 'riwayat_page.dart';

class PenggunaHomePage extends StatelessWidget {
  const PenggunaHomePage({super.key});

  Future<void> _logout(BuildContext context) async {
    await ApiService.logout();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final crossAxis = width >= 900 ? 3 : width >= 560 ? 2 : 1;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 210,
            pinned: true,
            backgroundColor: AppColors.primary,
            actions: [IconButton(onPressed: () => _logout(context), icon: const Icon(Icons.logout_rounded))],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.pagePadding(context)),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.account_balance_rounded, color: AppColors.accent, size: 42),
                        SizedBox(height: 12),
                        Text('PENS Surabaya', style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w900)),
                        SizedBox(height: 4),
                        Text('Sistem Pengajuan Barang Pengguna', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ResponsivePage(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Menu Layanan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: crossAxis,
                    childAspectRatio: width >= 560 ? 1.7 : 2.8,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _MenuCard(icon: Icons.add_task_rounded, title: 'Buat Laporan', subtitle: 'Ajukan kerusakan barang', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BuatLaporanPage()))),
                      _MenuCard(icon: Icons.history_rounded, title: 'Riwayat', subtitle: 'Pantau status pengajuan', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RiwayatPage()))),
                      _MenuCard(icon: Icons.lock_reset_rounded, title: 'Ubah Password', subtitle: 'Amankan akun pengguna', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage()))),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const AppCard(child: Text('Pastikan laporan dilengkapi foto bukti agar admin lebih mudah melakukan validasi.', style: TextStyle(color: AppColors.muted, height: 1.5))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _MenuCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AppCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(.1), borderRadius: BorderRadius.circular(18)),
              child: Icon(icon, color: AppColors.primary, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
            ])),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
