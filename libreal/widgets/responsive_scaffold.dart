import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class ResponsivePage extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool centerContent;

  const ResponsivePage({super.key, required this.child, this.padding, this.centerContent = true});

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding ?? EdgeInsets.all(AppSpacing.pagePadding(context)),
      child: child,
    );
    if (!centerContent) return content;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: AppSpacing.maxContentWidth(context)),
        child: content,
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(18)});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.07),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onPressed;

  const StateMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.buttonText = 'Coba Lagi',
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 54),
            ),
            const SizedBox(height: 18),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, height: 1.5)),
            if (onPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(onPressed: onPressed, icon: const Icon(Icons.refresh_rounded), label: Text(buttonText)),
            ],
          ],
        ),
      ),
    );
  }
}

Color statusColor(String status) {
  final s = status.toLowerCase();
  if (s == 'selesai' || s == '3') return AppColors.success;
  if (s == 'ditolak') return AppColors.danger;
  if (s == 'diproses' || s == '2') return AppColors.warning;
  return AppColors.primary;
}

String statusLabel(String status) {
  final s = status.toLowerCase();
  if (s == '1') return 'Diajukan';
  if (s == '2') return 'Diproses';
  if (s == '3') return 'Selesai';
  if (s == 'diproses') return 'Diproses';
  if (s == 'ditolak') return 'Ditolak';
  if (s == 'selesai') return 'Selesai';
  return status.isEmpty ? '-' : status;
}
