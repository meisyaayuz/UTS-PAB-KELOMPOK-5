import 'dart:convert';

import 'package:agenda_kampus/models/acara.dart';
import 'package:agenda_kampus/services/acara_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('Acara model', () {
    test('fromJson dan toJson saling bolak-balik, termasuk DateTime', () {
      final json = {
        'id': 'acr-001',
        'judul': 'Seminar AI',
        'penyelenggara': 'HMIF',
        'jenis': 'Seminar',
        'lokasi': 'Aula',
        'mulai': '2026-11-14T09:30:00.000',
        'berbayar': true,
        'kuota': 120,
      };
      final acara = Acara.fromJson(json);
      expect(acara.mulai, DateTime(2026, 11, 14, 9, 30));
      expect(acara.berbayar, isTrue);
      expect(acara.kuota, 120);
      expect(acara.toJson(), json);
    });

    test('sudahLewat membandingkan dengan waktu sekarang', () {
      final acara = Acara.fromJson({
        'id': 'x',
        'judul': 'x',
        'jenis': 'Lomba',
        'lokasi': 'x',
        'mulai': '2026-01-01T00:00:00.000',
      });
      expect(acara.sudahLewat(DateTime(2026, 6, 1)), isTrue);
      expect(acara.sudahLewat(DateTime(2025, 6, 1)), isFalse);
    });
  });

  group('AcaraService dengan MockClient', () {
    final contoh = [
      {
        'id': 'acr-001',
        'judul': 'Seminar AI',
        'penyelenggara': 'HMIF',
        'jenis': 'Seminar',
        'lokasi': 'Aula',
        'mulai': '2026-11-14T09:00:00.000',
        'berbayar': false,
        'kuota': 100,
      },
    ];

    test('ambilSemua memanggil GET /acara dan mengurai JSON', () async {
      late Uri dipanggil;
      final service = AcaraService(
        baseUrl: 'http://uji',
        client: MockClient((req) async {
          dipanggil = req.url;
          return http.Response(jsonEncode(contoh), 200);
        }),
      );

      final hasil = await service.ambilSemua();

      expect(dipanggil.toString(), 'http://uji/acara');
      expect(hasil, hasLength(1));
      expect(hasil.first.judul, 'Seminar AI');
      expect(hasil.first.mulai, DateTime(2026, 11, 14, 9));
    });

    test('ambilMendatang memakai endpoint khas /acara/mendatang', () async {
      late String path;
      final service = AcaraService(
        baseUrl: 'http://uji',
        client: MockClient((req) async {
          path = req.url.path;
          return http.Response(jsonEncode(contoh), 200);
        }),
      );
      await service.ambilMendatang();
      expect(path, '/acara/mendatang');
    });

    test('ambilById melempar Exception saat 404', () async {
      final service = AcaraService(
        baseUrl: 'http://uji',
        client: MockClient((_) async => http.Response('{}', 404)),
      );
      expect(service.ambilById('tidak-ada'), throwsException);
    });

    test('ambilSemua melempar Exception saat server error', () async {
      final service = AcaraService(
        baseUrl: 'http://uji',
        client: MockClient((_) async => http.Response('error', 500)),
      );
      expect(service.ambilSemua(), throwsException);
    });

    test('tambah mengirim POST JSON dan membaca balasan 201', () async {
      final service = AcaraService(
        baseUrl: 'http://uji',
        client: MockClient((req) async {
          expect(req.method, 'POST');
          final body = jsonDecode(req.body) as Map<String, dynamic>;
          return http.Response(jsonEncode({...body, 'id': 'acr-015'}), 201);
        }),
      );
      final baru = Acara.fromJson({...contoh.first, 'id': 'lokal-1'});
      final hasil = await service.tambah(baru);
      expect(hasil.id, 'acr-015');
      expect(hasil.judul, 'Seminar AI');
    });
  });
}
