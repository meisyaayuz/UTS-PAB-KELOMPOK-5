import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/acara.dart';

/// Alamat API dibaca dari `--dart-define=API_URL=...`.
/// Bawaan `10.0.2.2` = localhost komputer bila dijalankan di emulator Android.
const apiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://10.0.2.2:8080',
);

/// Layanan untuk mengambil data acara dari server shelf.
class AcaraService {
  AcaraService({http.Client? client, this.baseUrl = apiUrl})
    : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  static const _batasWaktu = Duration(seconds: 8);

  /// GET /acara
  Future<List<Acara>> ambilSemua() => _ambilDaftar('/acara');

  /// GET /acara/mendatang (endpoint khas tema)
  Future<List<Acara>> ambilMendatang() => _ambilDaftar('/acara/mendatang');

  /// GET /acara/{id}
  Future<Acara> ambilById(String id) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/acara/$id'))
        .timeout(_batasWaktu);
    if (res.statusCode != 200) {
      throw Exception('Acara $id tidak ditemukan (HTTP ${res.statusCode})');
    }
    return Acara.fromJson(
      jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>,
    );
  }

  /// POST /acara (nilai tambah). Mengembalikan acara versi server.
  Future<Acara> tambah(Acara acara) async {
    final res = await _client
        .post(
          Uri.parse('$baseUrl/acara'),
          headers: {'content-type': 'application/json'},
          body: jsonEncode(acara.toJson()),
        )
        .timeout(_batasWaktu);
    if (res.statusCode != 201) {
      throw Exception('Gagal mengirim usulan (HTTP ${res.statusCode})');
    }
    return Acara.fromJson(
      jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>,
    );
  }

  Future<List<Acara>> _ambilDaftar(String path) async {
    final res = await _client
        .get(Uri.parse('$baseUrl$path'))
        .timeout(_batasWaktu);
    if (res.statusCode != 200) {
      throw Exception('Server membalas HTTP ${res.statusCode}');
    }
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as List;
    return data.map((e) => Acara.fromJson(e as Map<String, dynamic>)).toList();
  }
}
