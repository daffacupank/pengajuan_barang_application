class InventarisModel {
  final int idInventaris;
  final String namaBarang;
  final String kodeBarang;
  final String nomorBarang;
  final String serialNumber;
  final String statusServis;
  final String merk;
  final String kondisi;

  InventarisModel({
    required this.idInventaris,
    required this.namaBarang,
    required this.kodeBarang,
    required this.nomorBarang,
    required this.serialNumber,
    required this.statusServis,
    required this.merk,
    required this.kondisi,
  });

  factory InventarisModel.fromJson(Map<String, dynamic> json) {
    String pick(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value != null && value.toString().trim().isNotEmpty && value.toString() != 'null') {
          return value.toString().trim();
        }
      }
      return '';
    }

    return InventarisModel(
      idInventaris: int.tryParse(pick(['id_inventaris', 'idInventaris', 'id'])) ?? 0,
      namaBarang: pick(['nama_barang', 'namaBarang', 'nama', 'barang']),
      kodeBarang: pick(['kode_barang', 'kodeBarang', 'kode', 'kode_inventaris']),
      nomorBarang: pick(['nomor_barang', 'no_barang', 'no_inventaris', 'nomor', 'nup', 'NUP']),
      serialNumber: pick(['serial_number', 'serialNumber', 'sn', 'SN', 'no_seri', 'nomor_seri']),
      statusServis: pick(['status_servis', 'status_service', 'servicing', 'statusServis', 'status_service_barang']),
      merk: pick(['merk', 'brand', 'merek']),
      kondisi: pick(['kondisi', 'kondisi_barang', 'status_kondisi']),
    );
  }

  String get kodeAtauNomor {
    if (kodeBarang.isNotEmpty) return kodeBarang;
    if (nomorBarang.isNotEmpty) return nomorBarang;
    return '-';
  }

  String get searchText => [
        namaBarang,
        kodeBarang,
        nomorBarang,
        serialNumber,
        statusServis,
        merk,
        kondisi,
      ].join(' ').toLowerCase();
}

class RuanganModel {
  final int idRuangan;
  final String namaRuangan;
  final String kodeRuangan;

  RuanganModel({
    required this.idRuangan,
    required this.namaRuangan,
    required this.kodeRuangan,
  });

  factory RuanganModel.fromJson(Map<String, dynamic> json) {
    return RuanganModel(
      idRuangan: int.tryParse(json['id_ruangan']?.toString() ?? json['id']?.toString() ?? '0') ?? 0,
      namaRuangan: json['nama_ruangan']?.toString() ?? json['namaRuangan']?.toString() ?? json['nama']?.toString() ?? '',
      kodeRuangan: json['kode_ruangan']?.toString() ?? json['kodeRuangan']?.toString() ?? json['kode']?.toString() ?? '',
    );
  }
}
