import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

/// Server REST API Agenda Kampus.
///
/// Endpoint:
///   GET  /acara              daftar semua acara
///   GET  /acara/mendatang    acara yang `mulai`-nya setelah waktu server (endpoint khas)
///   GET  /acara/{id}         satu acara berdasarkan id
///   POST /acara              tambah usulan acara (nilai tambah)
Future<void> main(List<String> args) async {
  final fileData = File.fromUri(Platform.script.resolve('../data/acara.json'));
  final daftarAcara = (jsonDecode(await fileData.readAsString()) as List)
      .cast<Map<String, dynamic>>();

  final router = Router()
    ..get('/', (Request req) {
      return _json({
        'nama': 'Agenda Kampus API',
        'endpoint': [
          'GET /acara',
          'GET /acara/mendatang',
          'GET /acara/<id>',
          'POST /acara',
        ],
      });
    })
    ..get('/acara', (Request req) {
      final urut = [
        ...daftarAcara,
      ]..sort((a, b) => (a['mulai'] as String).compareTo(b['mulai'] as String));
      return _json(urut);
    })
    // Rute khusus harus didaftarkan sebelum /acara/<id>.
    ..get('/acara/mendatang', (Request req) {
      final sekarang = DateTime.now();
      final mendatang =
          daftarAcara
              .where(
                (a) => DateTime.parse(a['mulai'] as String).isAfter(sekarang),
              )
              .toList()
            ..sort(
              (a, b) => (a['mulai'] as String).compareTo(b['mulai'] as String),
            );
      return _json(mendatang);
    })
    ..get('/acara/<id>', (Request req, String id) {
      final hasil = daftarAcara.where((a) => a['id'] == id);
      if (hasil.isEmpty) {
        return _json({
          'pesan': 'Acara dengan id $id tidak ditemukan',
        }, status: 404);
      }
      return _json(hasil.first);
    })
    ..post('/acara', (Request req) async {
      try {
        final body =
            jsonDecode(await req.readAsString()) as Map<String, dynamic>;
        for (final kunci in ['judul', 'jenis', 'lokasi', 'mulai']) {
          if ((body[kunci] ?? '').toString().trim().isEmpty) {
            return _json({'pesan': 'Field "$kunci" wajib diisi'}, status: 400);
          }
        }
        DateTime.parse(body['mulai'] as String);
        final baru = <String, dynamic>{
          'id': 'acr-${(daftarAcara.length + 1).toString().padLeft(3, '0')}',
          'judul': body['judul'],
          'penyelenggara': body['penyelenggara'] ?? 'Usulan Mahasiswa',
          'jenis': body['jenis'],
          'lokasi': body['lokasi'],
          'mulai': body['mulai'],
          'berbayar': body['berbayar'] ?? false,
          'kuota': body['kuota'] ?? 0,
        };
        daftarAcara.add(baru);
        return _json(baru, status: 201);
      } on FormatException {
        return _json({
          'pesan': 'Body bukan JSON atau tanggal tidak valid',
        }, status: 400);
      }
    });

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_cors())
      .addHandler(router.call);

  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  print('Agenda Kampus API berjalan di http://localhost:${server.port}');
  print('${daftarAcara.length} acara dimuat dari ${fileData.path}');
}

Response _json(Object data, {int status = 200}) => Response(
  status,
  body: jsonEncode(data),
  headers: {'content-type': 'application/json; charset=utf-8'},
);

/// Header CORS agar aplikasi juga bisa dicoba di browser (flutter run -d chrome).
Middleware _cors() {
  const headers = {
    'access-control-allow-origin': '*',
    'access-control-allow-methods': 'GET, POST, OPTIONS',
    'access-control-allow-headers': 'content-type',
  };
  return (Handler inner) {
    return (Request req) async {
      if (req.method == 'OPTIONS') return Response.ok('', headers: headers);
      final res = await inner(req);
      return res.change(headers: headers);
    };
  };
}
