import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_theme.dart';
import '../models/laporan_model.dart';
import '../services/api_service.dart';
import '../services/connectivity_service.dart';
import '../widgets/no_internet_widget.dart';
import '../widgets/responsive_scaffold.dart';

class DetailLaporanPage extends StatefulWidget {
  final int idLaporan;
  const DetailLaporanPage({super.key, required this.idLaporan});
  @override
  State<DetailLaporanPage> createState() => _DetailLaporanPageState();
}

class _DetailLaporanPageState extends State<DetailLaporanPage> {
  bool loading = true;
  bool online = true;
  String error = '';
  LaporanModel? laporan;

  @override
  void initState() { super.initState(); load(); }

  Future<void> load() async {
    setState(() { loading = true; error = ''; });
    online = await ConnectivityService.hasConnection();
    if (!online) { setState(() => loading = false); return; }
    final res = await ApiService.getDetailLaporan(widget.idLaporan);
    if (!mounted) return;
    if (res['success'] == true && res['data'] != null) {
      laporan = LaporanModel.fromJson(res['data']);
    } else {
      error = res['message']?.toString() ?? 'Data tidak ditemukan';
    }
    setState(() => loading = false);
  }

  String fmt(String v) { try { return DateFormat('dd MMMM yyyy').format(DateTime.parse(v)); } catch (_) { return v; } }

  @override
  Widget build(BuildContext context) {
    if (!online) return Scaffold(appBar: AppBar(title: const Text('Detail Laporan')), body: NoInternetWidget(onRetry: load));
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Laporan')),
      body: loading ? const Center(child: CircularProgressIndicator()) : ResponsivePage(
        child: error.isNotEmpty || laporan == null ? StateMessage(icon: Icons.error_outline_rounded, title: 'Data Tidak Tersedia', message: error, onPressed: load) : SingleChildScrollView(child: _detail(laporan!)),
      ),
    );
  }

  Widget _detail(LaporanModel l) {
    final c = statusColor(l.status);
    final foto = l.buktiFoto.isEmpty ? '' : '${ApiService.imageBaseUrl}${l.buktiFoto}';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(l.namaBarang, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primaryDark))),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: c.withOpacity(.12), borderRadius: BorderRadius.circular(99)), child: Text(statusLabel(l.status), style: TextStyle(color: c, fontWeight: FontWeight.w900))),
        ]),
        const SizedBox(height: 12),
        _row('Kode Barang', l.kodeBarang),
        _row('Ruangan', l.namaRuangan),
        _row('Tanggal', fmt(l.tanggal)),
        _row('Merk', l.merk),
        _row('Kategori', l.kategori),
        _row('Lokasi', l.lokasi),
      ])),
      const SizedBox(height: 16),
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Kondisi & Keterangan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
        const SizedBox(height: 12),
        _row('Kondisi', l.kondisi),
        const SizedBox(height: 8),
        Text(l.keterangan, style: const TextStyle(color: AppColors.text, height: 1.5)),
      ])),
      const SizedBox(height: 16),
      if (foto.isNotEmpty) AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Bukti Foto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
        const SizedBox(height: 12),
        ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.network(foto, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const StateMessage(icon: Icons.broken_image_rounded, title: 'Foto Tidak Bisa Dibuka', message: 'Pastikan URL upload backend benar.'))),
      ])),
    ]);
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 115, child: Text(label, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700))),
      Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.text))),
    ]),
  );
}
