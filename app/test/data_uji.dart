import 'dart:convert';

import 'package:agenda_kampus/models/acara.dart';
import 'package:agenda_kampus/services/acara_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Data palsu untuk test; tanggal dibuat relatif terhadap sekarang.
List<Acara> buatDataUji() {
  final sekarang = DateTime.now();
  return [
    Acara(
      id: 'u-1',
      judul: 'Seminar Uji Mendatang',
      penyelenggara: 'HMIF',
      jenis: 'Seminar',
      lokasi: 'Aula TULT',
      mulai: sekarang.add(const Duration(days: 3)),
      berbayar: false,
      kuota: 100,
    ),
    Acara(
      id: 'u-2',
      judul: 'Workshop Uji Berbayar',
      penyelenggara: 'GDG',
      jenis: 'Workshop',
      lokasi: 'Lab Mobile',
      mulai: sekarang.add(const Duration(days: 5)),
      berbayar: true,
      kuota: 30,
    ),
    Acara(
      id: 'u-3',
      judul: 'Lomba Uji Sudah Lewat',
      penyelenggara: 'BEM',
      jenis: 'Lomba',
      lokasi: 'Online',
      mulai: sekarang.subtract(const Duration(days: 10)),
      berbayar: false,
      kuota: 50,
    ),
  ];
}

/// AcaraService dengan MockClient: tidak perlu server sungguhan.
AcaraService buatServiceUji({bool gagal = false}) {
  final data = buatDataUji();
  final client = MockClient((req) async {
    if (gagal) return http.Response('error', 500);
    if (req.method == 'POST' && req.url.path == '/acara') {
      final body = jsonDecode(req.body) as Map<String, dynamic>;
      body['id'] = 'srv-99';
      return http.Response(
        jsonEncode(body),
        201,
        headers: {'content-type': 'application/json'},
      );
    }
    if (req.url.path == '/acara') {
      return http.Response(
        jsonEncode(data.map((a) => a.toJson()).toList()),
        200,
      );
    }
    if (req.url.path == '/acara/mendatang') {
      final mendatang = data.where((a) => !a.sudahLewat()).toList();
      return http.Response(
        jsonEncode(mendatang.map((a) => a.toJson()).toList()),
        200,
      );
    }
    return http.Response('{"pesan":"tidak ada"}', 404);
  });
  return AcaraService(client: client, baseUrl: 'http://uji');
}
