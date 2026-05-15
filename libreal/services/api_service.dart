import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // GANTI sesuai IP backend kamu.
  // Android emulator: http://10.0.2.2:3000
  // HP fisik: http://IP-LAPTOP:3000, contoh http://192.168.1.32:3000
  static const String baseUrl = 'http://100.101.204.109:3000';
  static const String imageBaseUrl = '$baseUrl/uploads/';
  static const Duration timeoutDuration = Duration(seconds: 12);

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.trim().isNotEmpty;
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  static Map<String, dynamic> _decode(String body) {
    try {
      final data = jsonDecode(body);
      if (data is Map<String, dynamic>) return data;
      return {'success': false, 'message': 'Format respon server tidak valid'};
    } catch (_) {
      return {'success': false, 'message': 'Respon server bukan JSON valid'};
    }
  }

  static String _friendlyError(Object e) {
    if (e is TimeoutException) return 'Server tidak merespon. Periksa koneksi atau IP backend.';
    if (e is SocketException) return 'Tidak bisa terhubung ke server. Pastikan terhubung internet.';
    return 'Terjadi kesalahan: $e';
  }

  static Future<Map<String, dynamic>> login({required String email, required String password}) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/login'),
            headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(timeoutDuration);

      final data = _decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final token = (data['token'] ?? data['data']?['token'] ?? '').toString();
        if (token.isEmpty) {
          return {'success': false, 'message': 'Login berhasil, tapi token tidak dikirim backend.'};
        }
        await saveToken(token);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(data['user'] ?? data['data']?['user'] ?? {}));
        return data;
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Login gagal (${response.statusCode}). Cek email/password.',
      };
    } catch (e) {
      return {'success': false, 'message': _friendlyError(e)};
    }
  }

  static Future<Map<String, String>> _authHeaders({bool json = false}) async {
    final token = await getToken();
    return {
      if (json) 'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> getMasterData() async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Sesi login tidak ditemukan'};
      final response = await http
          .get(Uri.parse('$baseUrl/api/pengguna/master-data'), headers: await _authHeaders())
          .timeout(timeoutDuration);
      final data = _decode(response.body);
      if (response.statusCode == 401 || response.statusCode == 403) await logout();
      return response.statusCode == 200 ? data : {'success': false, 'message': data['message'] ?? 'Error ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': _friendlyError(e)};
    }
  }

  static Future<Map<String, dynamic>> getRiwayat() async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Sesi login tidak ditemukan'};
      final ts = DateTime.now().millisecondsSinceEpoch;
      final response = await http
          .get(Uri.parse('$baseUrl/api/pengguna/riwayat-laporan?ts=$ts'), headers: await _authHeaders())
          .timeout(timeoutDuration);
      final data = _decode(response.body);
      if (response.statusCode == 401 || response.statusCode == 403) await logout();
      return response.statusCode == 200 ? data : {'success': false, 'message': data['message'] ?? 'Error ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': _friendlyError(e)};
    }
  }

  static Future<Map<String, dynamic>> getDetailLaporan(int id) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Sesi login tidak ditemukan'};
      final response = await http
          .get(Uri.parse('$baseUrl/api/pengguna/riwayat-laporan/$id'), headers: await _authHeaders())
          .timeout(timeoutDuration);
      final data = _decode(response.body);
      if (response.statusCode == 401 || response.statusCode == 403) await logout();
      return response.statusCode == 200 ? data : {'success': false, 'message': data['message'] ?? 'Error ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': _friendlyError(e)};
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    required String passwordLama,
    required String passwordBaru,
    required String konfirmasiPassword,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/api/pengguna/change-password'),
            headers: await _authHeaders(json: true),
            body: jsonEncode({
              'password_lama': passwordLama,
              'password_baru': passwordBaru,
              'konfirmasi_password': konfirmasiPassword,
            }),
          )
          .timeout(timeoutDuration);
      final data = _decode(response.body);
      if (response.statusCode == 401 || response.statusCode == 403) await logout();
      return response.statusCode == 200 ? data : {'success': false, 'message': data['message'] ?? 'Error ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': _friendlyError(e)};
    }
  }

  static Future<Map<String, dynamic>> createLaporan({
    required String idInventaris,
    required String idRuangan,
    required String tanggal,
    required String keterangan,
    required String kondisi,
    File? buktiFoto,
  }) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Sesi login tidak ditemukan'};
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/pengguna/laporan'));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.fields.addAll({
        'id_inventaris': idInventaris,
        'id_ruangan': idRuangan,
        'tanggal': tanggal,
        'keterangan': keterangan,
        'kondisi': kondisi,
      });
      if (buktiFoto != null) {
        request.files.add(await http.MultipartFile.fromPath('bukti_foto', buktiFoto.path));
      }
      final streamed = await request.send().timeout(timeoutDuration);
      final response = await http.Response.fromStream(streamed).timeout(timeoutDuration);
      final data = _decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': data['success'] ?? true, 'message': data['message'] ?? 'Laporan berhasil dikirim', 'data': data['data']};
      }
      if (response.statusCode == 401 || response.statusCode == 403) await logout();
      return {'success': false, 'message': data['message'] ?? 'Upload gagal (${response.statusCode})'};
    } catch (e) {
      return {'success': false, 'message': _friendlyError(e)};
    }
  }
}
