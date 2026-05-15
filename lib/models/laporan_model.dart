class LaporanModel {
  final int idLaporan;
  final String namaBarang;
  final String kodeBarang;
  final String namaRuangan;
  final String tanggal;
  final String status;
  final String keterangan;
  final String kondisi;
  final String buktiFoto;
  final String merk;
  final String kategori;
  final String lokasi;
  final String keteranganAdmin;

  LaporanModel({
    required this.idLaporan,
    required this.namaBarang,
    required this.kodeBarang,
    required this.namaRuangan,
    required this.tanggal,
    required this.status,
    required this.keterangan,
    required this.kondisi,
    required this.buktiFoto,
    required this.merk,
    required this.kategori,
    required this.lokasi,
    required this.keteranganAdmin,
  });

  factory LaporanModel.fromJson(Map<String, dynamic> json) {
    return LaporanModel(
      idLaporan: int.tryParse(json['id_laporan'].toString()) ?? 0,
      namaBarang: json['nama_barang']?.toString() ?? '-',
      kodeBarang: json['kode_barang']?.toString() ?? '-',
      namaRuangan: json['nama_ruangan']?.toString() ?? '-',
      tanggal: json['tanggal']?.toString() ?? '-',
      status: json['status']?.toString() ?? 'diproses',
      keterangan: json['keterangan']?.toString() ?? '-',
      kondisi: json['kondisi']?.toString() ?? '0',
      buktiFoto: json['bukti_foto']?.toString() ?? '',
      merk: json['merk']?.toString() ?? '-',
      kategori: json['kategori']?.toString() ?? '-',
      lokasi: json['lokasi']?.toString() ?? '-',
      keteranganAdmin: (json['keterangan_admin'] ?? json['keteranganAdmin'] ?? '').toString(),
    );
  }

  String get statusLabel {
    switch (status.toLowerCase()) {
      case '1':
        return 'Diajukan';
      case '2':
      case 'diproses':
        return 'Diproses';
      case 'ditolak':
        return 'Ditolak';
      case '3':
      case 'selesai':
        return 'Selesai';
      default:
        return status;
    }
  }
}
