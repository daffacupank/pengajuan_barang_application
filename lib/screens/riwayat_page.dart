import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/app_theme.dart';
import '../models/laporan_model.dart';
import '../services/api_service.dart';
import '../services/connectivity_service.dart';
import '../widgets/no_internet_widget.dart';
import '../widgets/responsive_scaffold.dart';
import 'detail_laporan_page.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  bool loading = true;
  bool online = true;
  String error = '';

  List<LaporanModel> items = [];

  String status = 'all';
  String keyword = '';
  DateTime? selectedDate;

  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = '';
    });

    online = await ConnectivityService.hasConnection();

    if (!online) {
      setState(() => loading = false);
      return;
    }

    final res = await ApiService.getRiwayat();

    if (!mounted) return;

    if (res['success'] == true) {
      final data = (res['data'] as List? ?? []);
      items = data.map((e) => LaporanModel.fromJson(e)).toList();
    } else {
      error = res['message'].toString();
    }

    setState(() => loading = false);
  }

  List<LaporanModel> get filtered {
    return items.where((e) {
      final cocokStatus =
          status == 'all' || e.status.toLowerCase() == status.toLowerCase();

      final q = keyword.toLowerCase().trim();

      final cocokSearch = q.isEmpty ||
          e.namaBarang.toLowerCase().contains(q) ||
          e.namaRuangan.toLowerCase().contains(q) ||
          e.status.toLowerCase().contains(q) ||
          e.keterangan.toLowerCase().contains(q) ||
          e.keteranganAdmin.toLowerCase().contains(q);

      final tanggal = _parseDate(e.tanggal);

      final cocokTanggal = selectedDate == null ||
          (tanggal != null &&
              tanggal.year == selectedDate!.year &&
              tanggal.month == selectedDate!.month &&
              tanggal.day == selectedDate!.day);

      return cocokStatus && cocokSearch && cocokTanggal;
    }).toList();
  }

  DateTime? _parseDate(String value) {
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  String fmt(String value) {
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(value));
    } catch (_) {
      return value;
    }
  }

  String fmtDate(DateTime? value) {
    if (value == null) return 'Semua tanggal';
    return DateFormat('dd MMM yyyy').format(value);
  }

  Future<void> pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 2),
      helpText: 'Pilih Tanggal',
      confirmText: 'Pilih',
      cancelText: 'Batal',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.text,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  void resetFilter() {
    setState(() {
      status = 'all';
      keyword = '';
      selectedDate = null;
      searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!online) {
      return Scaffold(
        appBar: AppBar(title: const Text('Riwayat')),
        body: NoInternetWidget(onRetry: load),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      appBar: AppBar(
        title: const Text('Riwayat Pengajuan'),
        centerTitle: true,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ResponsivePage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FilterCard(),

            const SizedBox(height: 16),

            Text(
              'Total ${filtered.length} Laporan',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.primaryDark,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 12),

            if (error.isNotEmpty)
              Expanded(
                child: StateMessage(
                  icon: Icons.error_outline_rounded,
                  title: 'Gagal Memuat Data',
                  message: error,
                  onPressed: load,
                ),
              )
            else if (filtered.isEmpty)
              Expanded(
                child: StateMessage(
                  icon: Icons.inbox_rounded,
                  title: 'Data Tidak Ditemukan',
                  message:
                  'Tidak ada riwayat yang sesuai filter pencarian.',
                  onPressed: resetFilter,
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: load,
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 18),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _ReportCard(
                        laporan: filtered[index],
                        tanggal: fmt(filtered[index].tanggal),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailLaporanPage(
                                idLaporan: filtered[index].idLaporan,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _FilterCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.055),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(color: const Color(0xFFE6ECF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Filter Riwayat',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              Icon(
                Icons.tune_rounded,
                color: AppColors.primary,
              ),
            ],
          ),

          const SizedBox(height: 14),

          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Cari barang, ruangan, status, atau keterangan...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: keyword.isEmpty
                  ? null
                  : IconButton(
                onPressed: () {
                  setState(() {
                    keyword = '';
                    searchController.clear();
                  });
                },
                icon: const Icon(Icons.cancel_rounded),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: const BorderSide(color: Color(0xFFE3E9F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: const BorderSide(color: Color(0xFFE3E9F0)),
              ),
            ),
            onChanged: (value) {
              setState(() => keyword = value);
            },
          ),

          const SizedBox(height: 14),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _StatusPill('all', 'Semua'),
                _StatusPill('diproses', 'Diproses'),
                _StatusPill('ditolak', 'Ditolak'),
                _StatusPill('selesai', 'Selesai'),
              ],
            ),
          ),

          const SizedBox(height: 14),

          _DateFilterButton(
            value: fmtDate(selectedDate),
            selected: selectedDate != null,
            onTap: pickDate,
          ),

          if (status != 'all' || keyword.isNotEmpty || selectedDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: InkWell(
                onTap: resetFilter,
                borderRadius: BorderRadius.circular(14),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Reset Filter',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _StatusPill(String value, String label) {
    final selected = status == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => setState(() => status = value),
        borderRadius: BorderRadius.circular(99),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFE2E8F0),
            ),
            boxShadow: selected
                ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(.18),
                blurRadius: 16,
                offset: const Offset(0, 8),
              )
            ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.text,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _DateFilterButton extends StatelessWidget {
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _DateFilterButton({
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppColors.primary.withOpacity(.65)
                : const Color(0xFFE2E8F0),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(.09),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Kalender',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final LaporanModel laporan;
  final String tanggal;
  final VoidCallback onTap;

  const _ReportCard({
    required this.laporan,
    required this.tanggal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = statusColor(laporan.status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.045),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: const Color(0xFFE7EDF3)),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: color.withOpacity(.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.inventory_2_rounded,
                color: color,
                size: 28,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    laporan.namaBarang,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryDark,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${laporan.namaRuangan} • $tanggal',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (laporan.keteranganAdmin.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Admin: ${laporan.keteranganAdmin}',
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: color.withOpacity(.12),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                statusLabel(laporan.status),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ),

            const SizedBox(width: 6),

            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primaryDark,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}