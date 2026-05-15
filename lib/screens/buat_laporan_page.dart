import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../core/app_theme.dart';
import '../models/master_data_model.dart';
import '../services/api_service.dart';
import '../services/connectivity_service.dart';
import '../widgets/no_internet_widget.dart';
import '../widgets/responsive_scaffold.dart';

class BuatLaporanPage extends StatefulWidget {
  const BuatLaporanPage({super.key});

  @override
  State<BuatLaporanPage> createState() => _BuatLaporanPageState();
}

class _BuatLaporanPageState extends State<BuatLaporanPage> {
  final _formKey = GlobalKey<FormState>();

  final kondisiController = TextEditingController();
  final keteranganController = TextEditingController();

  List<InventarisModel> inventaris = [];
  List<RuanganModel> ruangan = [];

  InventarisModel? selectedInventaris;
  int? selectedRuanganId;
  File? imageFile;

  bool loading = true;
  bool submitting = false;
  bool online = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    loadMaster();
  }

  @override
  void dispose() {
    kondisiController.dispose();
    keteranganController.dispose();
    super.dispose();
  }

  Future<void> loadMaster() async {
    setState(() {
      loading = true;
      error = '';
    });

    online = await ConnectivityService.hasConnection();

    if (!online) {
      setState(() => loading = false);
      return;
    }

    final res = await ApiService.getMasterData();

    if (!mounted) return;

    if (res['success'] == true) {
      final data = res['data'] ?? {};

      inventaris = (data['inventaris'] as List? ?? [])
          .map((e) => InventarisModel.fromJson(e))
          .toList();

      ruangan = (data['ruangan'] as List? ?? [])
          .map((e) => RuanganModel.fromJson(e))
          .toList();
    } else {
      error = res['message'].toString();
    }

    setState(() => loading = false);
  }

  Future<void> pick(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 72,
      maxWidth: 1600,
    );

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate() ||
        selectedInventaris == null ||
        selectedRuanganId == null ||
        imageFile == null) {
      _showSnack(
        'Lengkapi semua data dan foto bukti.',
        false,
      );
      return;
    }

    if (!await ConnectivityService.hasConnection()) {
      setState(() => online = false);
      return;
    }

    setState(() => submitting = true);

    final res = await ApiService.createLaporan(
      idInventaris: selectedInventaris!.idInventaris.toString(),
      idRuangan: selectedRuanganId.toString(),
      tanggal: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      keterangan: keteranganController.text.trim(),
      kondisi: kondisiController.text.trim(),
      buktiFoto: imageFile,
    );

    if (!mounted) return;

    setState(() => submitting = false);

    _showSnack(
      res['message'].toString(),
      res['success'] == true,
    );

    if (res['success'] == true) {
      Navigator.pop(context, true);
    }
  }

  void _showSnack(String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
        success ? AppColors.success : AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> pilihBarang() async {
    final result = await showModalBottomSheet<InventarisModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BarangPickerSheet(
        items: inventaris,
      ),
    );

    if (result != null) {
      setState(() {
        selectedInventaris = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!online) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Buat Laporan'),
        ),
        body: NoInternetWidget(
          onRetry: loadMaster,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Laporan'),
      ),
      body: loading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ResponsivePage(
        child: error.isNotEmpty
            ? StateMessage(
          icon: Icons.error_outline_rounded,
          title: 'Gagal Memuat Data',
          message: error,
          onPressed: loadMaster,
        )
            : SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengajuan Kerusakan Barang ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Laporkan kerusakan barang inventaris dengan lengkap dan jelas.',
                      style: TextStyle(
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              AppCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Data Pengajuan',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color:
                          AppColors.primaryDark,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Cari barang berdasarkan nama, nomor barang/NUP, atau kode barang.',
                        style: TextStyle(
                          color: AppColors.muted,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 22),

                      InkWell(
                        onTap: pilihBarang,
                        borderRadius:
                        BorderRadius.circular(18),
                        child: Container(
                          width: double.infinity,
                          padding:
                          const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(
                                18),
                            border: Border.all(
                              color:
                              AppColors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding:
                                const EdgeInsets
                                    .all(12),
                                decoration:
                                BoxDecoration(
                                  color: AppColors
                                      .primary
                                      .withOpacity(
                                      .10),
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                      14),
                                ),
                                child: const Icon(
                                  Icons.search_rounded,
                                  color: AppColors
                                      .primary,
                                ),
                              ),
                              const SizedBox(
                                  width: 14),
                              Expanded(
                                child:
                                selectedInventaris ==
                                    null
                                    ? const Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                                  children: [
                                    Text(
                                      'Cari & Pilih Barang',
                                      style:
                                      TextStyle(
                                        fontWeight:
                                        FontWeight
                                            .w900,
                                        color:
                                        AppColors.primaryDark,
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                        4),
                                    Text(
                                      'Nama barang, nomor barang/NUP, atau kode',
                                      style:
                                      TextStyle(
                                        color:
                                        AppColors.muted,
                                        fontSize:
                                        12,
                                      ),
                                    ),
                                  ],
                                )
                                    : Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                                  children: [
                                    Text(
                                      selectedInventaris!
                                          .namaBarang,
                                      style:
                                      const TextStyle(
                                        fontWeight:
                                        FontWeight
                                            .w900,
                                        color:
                                        AppColors.primaryDark,
                                      ),
                                    ),
                                    const SizedBox(
                                        height:
                                        4),
                                    Text(
                                      'Nomor: ${selectedInventaris!.nomorBarang}',
                                      style:
                                      const TextStyle(
                                        color:
                                        AppColors.muted,
                                        fontSize:
                                        12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons
                                    .keyboard_arrow_down_rounded,
                                color:
                                AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (selectedInventaris !=
                          null) ...[
                        const SizedBox(height: 16),

                        Container(
                          width: double.infinity,
                          padding:
                          const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(
                                0xFFF8FAFC),
                            borderRadius:
                            BorderRadius.circular(
                                18),
                            border: Border.all(
                              color:
                              AppColors.border,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [
                              const Text(
                                'Detail Barang',
                                style: TextStyle(
                                  fontWeight:
                                  FontWeight
                                      .w900,
                                  color: AppColors
                                      .primaryDark,
                                ),
                              ),
                              const SizedBox(
                                  height: 14),
                              _detailItem(
                                'Nama Barang',
                                selectedInventaris!
                                    .namaBarang,
                              ),
                              _detailItem(
                                'Kode Barang',
                                selectedInventaris!
                                    .kodeBarang,
                              ),
                              _detailItem(
                                'Nomor Barang / NUP',
                                selectedInventaris!
                                    .nomorBarang,
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 18),

                      DropdownButtonFormField<int>(
                        initialValue: selectedRuanganId,
                        isExpanded: true,
                        decoration:
                        const InputDecoration(
                          labelText: 'Ruangan',
                          prefixIcon: Icon(
                            Icons
                                .meeting_room_rounded,
                          ),
                        ),
                        items: ruangan.map((e) {
                          return DropdownMenuItem<
                              int>(
                            value: e.idRuangan,
                            child: Text(
                              '${e.namaRuangan} - ${e.kodeRuangan}',
                            ),
                          );
                        }).toList(),
                        onChanged: (v) {
                          setState(() {
                            selectedRuanganId =
                                v;
                          });
                        },
                        validator: (v) {
                          if (v == null) {
                            return 'Pilih ruangan';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: kondisiController,
                        keyboardType:
                        TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter
                              .digitsOnly,
                        ],
                        decoration:
                        const InputDecoration(
                          labelText:
                          'Kondisi Barang (%)',
                          hintText:
                          'Masukkan nilai 1 - 100',
                          prefixIcon: Icon(
                            Icons.percent_rounded,
                          ),
                          suffixText: '%',
                        ),
                        validator: (v) {
                          if (v == null ||
                              v.trim().isEmpty) {
                            return 'Kondisi wajib diisi';
                          }

                          final value =
                          int.tryParse(
                            v.trim(),
                          );

                          if (value == null) {
                            return 'Kondisi harus angka';
                          }

                          if (value < 1 ||
                              value > 100) {
                            return 'Nilai harus 1 - 100';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller:
                        keteranganController,
                        minLines: 4,
                        maxLines: 6,
                        decoration:
                        const InputDecoration(
                          labelText: 'Keterangan',
                          alignLabelWithHint:
                          true,
                          prefixIcon: Icon(
                            Icons.notes_rounded,
                          ),
                        ),
                        validator: (v) {
                          if (v == null ||
                              v.trim().isEmpty) {
                            return 'Keterangan wajib diisi';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      if (imageFile != null)
                        ClipRRect(
                          borderRadius:
                          BorderRadius
                              .circular(18),
                          child: Image.file(
                            imageFile!,
                            height: 190,
                            width:
                            double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),

                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () =>
                                pick(ImageSource
                                    .camera),
                            icon: const Icon(
                              Icons
                                  .camera_alt_rounded,
                            ),
                            label: const Text(
                                'Kamera'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () =>
                                pick(ImageSource
                                    .gallery),
                            icon: const Icon(
                              Icons
                                  .photo_library_rounded,
                            ),
                            label: const Text(
                                'Galeri'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child:
                        ElevatedButton.icon(
                          onPressed: submitting
                              ? null
                              : submit,
                          icon: submitting
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                            CircularProgressIndicator(
                              color:
                              Colors.white,
                              strokeWidth:
                              2,
                            ),
                          )
                              : const Icon(
                            Icons
                                .send_rounded,
                          ),
                          label: Text(
                            submitting
                                ? 'Mengirim...'
                                : 'Kirim Laporan',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailItem(
      String title,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarangPickerSheet extends StatefulWidget {
  final List<InventarisModel> items;

  const _BarangPickerSheet({
    required this.items,
  });

  @override
  State<_BarangPickerSheet> createState() =>
      _BarangPickerSheetState();
}

class _BarangPickerSheetState
    extends State<_BarangPickerSheet> {
  final controller = TextEditingController();

  String keyword = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items.where((item) {
      final q = keyword.toLowerCase();

      return item.namaBarang
          .toLowerCase()
          .contains(q) ||
          item.kodeBarang
              .toLowerCase()
              .contains(q) ||
          item.nomorBarang
              .toLowerCase()
              .contains(q);
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: .86,
      maxChildSize: .94,
      minChildSize: .52,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),

              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius:
                  BorderRadius.circular(100),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText:
                    'Cari nama barang, NUP, atau kode...',
                    prefixIcon:
                    Icon(Icons.search_rounded),
                  ),
                  onChanged: (v) {
                    setState(() {
                      keyword = v;
                    });
                  },
                ),
              ),

              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = filtered[index];

                    return InkWell(
                      onTap: () {
                        Navigator.pop(context, item);
                      },
                      borderRadius:
                      BorderRadius.circular(18),
                      child: Container(
                        padding:
                        const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(
                              18),
                          border: Border.all(
                            color: AppColors.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration:
                              BoxDecoration(
                                color: AppColors
                                    .primary
                                    .withOpacity(.10),
                                borderRadius:
                                BorderRadius
                                    .circular(
                                    14),
                              ),
                              child: const Icon(
                                Icons
                                    .inventory_2_rounded,
                                color:
                                AppColors.primary,
                              ),
                            ),

                            const SizedBox(
                                width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                                children: [
                                  Text(
                                    item.namaBarang,
                                    style:
                                    const TextStyle(
                                      fontWeight:
                                      FontWeight
                                          .w900,
                                      color: AppColors
                                          .primaryDark,
                                    ),
                                  ),
                                  const SizedBox(
                                      height: 5),
                                  Text(
                                    'Kode: ${item.kodeBarang}',
                                    style:
                                    const TextStyle(
                                      color: AppColors
                                          .muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(
                                      height: 3),
                                  Text(
                                    'No/NUP: ${item.nomorBarang}',
                                    style:
                                    const TextStyle(
                                      color: AppColors
                                          .muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}