import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/app_theme.dart';
import '../models/laporan_model.dart';
import '../services/api_service.dart';
import '../services/connectivity_service.dart';
import '../widgets/no_internet_widget.dart';
import '../widgets/responsive_scaffold.dart';
import 'detail_laporan_page.dart';

class UpdateStatusKalebPage extends StatefulWidget {
  const UpdateStatusKalebPage({super.key});

  @override
  State<UpdateStatusKalebPage> createState() =>
      _UpdateStatusKalebPageState();
}

class _UpdateStatusKalebPageState
    extends State<UpdateStatusKalebPage> {

  bool loading = true;
  bool online = true;
  String error = '';

  List<LaporanModel> items = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {

    setState(() {
      loading = true;
      error = '';
    });

    online =
    await ConnectivityService.hasConnection();

    if (!online) {
      setState(() {
        loading = false;
      });
      return;
    }

    final res =
    await ApiService.getUpdateStatusKaleb();

    if (!mounted) return;

    if (res['success'] == true) {

      final data =
      (res['data'] as List? ?? []);

      items =
          data
              .map(
                (e) =>
                LaporanModel.fromJson(e),
          )
              .toList();

    } else {

      error =
          res['message'] ??
              'Gagal memuat';

    }

    setState(() {
      loading = false;
    });
  }

  String fmt(String value) {

    try {

      return DateFormat(
        'dd MMM yyyy',
      ).format(
        DateTime.parse(value),
      );

    } catch (_) {

      return value;

    }
  }

  @override
  Widget build(BuildContext context) {

    if (!online) {

      return Scaffold(
        appBar:
        AppBar(
          title:
          const Text(
            "Update Status",
          ),
        ),
        body:
        NoInternetWidget(
          onRetry: load,
        ),
      );

    }

    return Scaffold(

      backgroundColor:
      const Color(
        0xFFF6F9FC,
      ),

      appBar:
      AppBar(
        title:
        const Text(
          "Update Status",
        ),
        centerTitle: true,
      ),

      body:

      loading

          ? const Center(
        child:
        CircularProgressIndicator(),
      )

          : ResponsivePage(

        child:

        Column(

          children: [

            const SizedBox(
              height: 10,
            ),

            Text(

              "Total ${items.length} Laporan",

              style:
              const TextStyle(
                fontSize: 15,
                fontWeight:
                FontWeight
                    .w900,
              ),

            ),

            const SizedBox(
              height: 15,
            ),

            Expanded(

              child:

              RefreshIndicator(

                onRefresh:
                load,

                child:

                ListView
                    .builder(

                  itemCount:
                  items.length,

                  itemBuilder:
                      (
                      context,
                      index,
                      ) {

                    final item =
                    items[index];

                    return _UpdateCard(

                      laporan:
                      item,

                      tanggal:
                      fmt(
                        item
                            .tanggal,
                      ),

                      onTap:
                          () {

                        Navigator
                            .push(

                          context,

                          MaterialPageRoute(

                            builder:
                                (_) =>
                                DetailLaporanPage(

                                  idLaporan:
                                  item.idLaporan,

                                ),

                          ),

                        );

                      },

                      onUpdated:
                      load,

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
}



class _UpdateCard
    extends StatefulWidget {

  final LaporanModel laporan;

  final String tanggal;

  final VoidCallback onTap;

  final VoidCallback onUpdated;

  const _UpdateCard({

    required this.laporan,

    required this.tanggal,

    required this.onTap,

    required this.onUpdated,

  });

  @override
  State<_UpdateCard>
  createState() =>
      _UpdateCardState();
}



class _UpdateCardState
    extends State<_UpdateCard> {

  late String selectedStatus;

  late TextEditingController
  ketController;

  bool saving = false;

  @override
  void initState() {

    super.initState();

    selectedStatus =
        widget.laporan.status;

    ketController =
        TextEditingController(

          text:
          widget.laporan
              .keteranganAdmin,

        );
  }

  @override
  void dispose() {

    ketController.dispose();

    super.dispose();
  }

  Future<void>
  simpanValidasi() async {

    setState(() {
      saving = true;
    });

    final res =
    await ApiService
        .updateLaporanKaleb(

      idLaporan:
      widget
          .laporan
          .idLaporan,

      status:
      selectedStatus,

      keteranganAdmin:
      ketController.text,

    );

    setState(() {
      saving = false;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(

      SnackBar(

        content:

        Text(

          res['message'] ??
              'Berhasil',

        ),

      ),

    );

    if (res['success'] ==
        true) {

      widget.onUpdated();

    }
  }

  @override
  Widget build(
      BuildContext context) {

    final color =
    statusColor(
      selectedStatus,
    );

    return Container(

      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),

      padding:
      const EdgeInsets.all(
        14,
      ),

      decoration:
      BoxDecoration(

        color: Colors.white,

        borderRadius:
        BorderRadius.circular(
          20,
        ),

      ),

      child:

      Column(

        children: [

          ListTile(

            onTap:
            widget.onTap,

            title:

            Text(
              widget
                  .laporan
                  .namaBarang,
            ),

            subtitle:

            Text(

              widget.tanggal,

            ),

          ),

          DropdownButtonFormField<String>(

            initialValue:
            selectedStatus,

            decoration:

            const InputDecoration(

              labelText:
              'Validasi Status',

            ),

            items:

            const [

              DropdownMenuItem(
                value:
                'menunggu',
                child:
                Text(
                  'Menunggu',
                ),
              ),

              DropdownMenuItem(
                value:
                'diproses',
                child:
                Text(
                  'Diproses',
                ),
              ),

              DropdownMenuItem(
                value:
                'selesai',
                child:
                Text(
                  'Selesai',
                ),
              ),

              DropdownMenuItem(
                value:
                'ditolak',
                child:
                Text(
                  'Ditolak',
                ),
              ),

            ],

            onChanged:
                (v) {

              if (v != null) {

                setState(() {

                  selectedStatus =
                      v;

                });

              }

            },

          ),

          const SizedBox(
            height: 10,
          ),

          TextField(

            controller:
            ketController,

            maxLines: 3,

            decoration:

            const InputDecoration(

              labelText:
              'Keterangan Admin',

              hintText:
              'Masukkan keterangan',

            ),

          ),

          const SizedBox(
            height: 15,
          ),

          SizedBox(

            width:
            double.infinity,

            child:

            ElevatedButton.icon(

              onPressed:

              saving
                  ? null
                  : simpanValidasi,

              icon:

              saving

                  ? const SizedBox(

                width:
                20,

                height:
                20,

                child:
                CircularProgressIndicator(),

              )

                  : const Icon(
                Icons
                    .save,
              ),

              label:

              Text(

                saving
                    ? 'Menyimpan...'
                    : 'Simpan Validasi',

              ),

            ),

          )

        ],

      ),

    );
  }
}