import 'package:agenda_kampus/main.dart';
import 'package:agenda_kampus/models/acara.dart';
import 'package:agenda_kampus/pages/halaman_form_acara.dart';
import 'package:agenda_kampus/widgets/kartu_acara.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'data_uji.dart';

void main() {
  testWidgets('KartuAcara menampilkan judul, jenis, dan label Gratis/Selesai', (
    tester,
  ) async {
    final lewat = buatDataUji()[2];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KartuAcara(
            acara: lewat,
            sudahRsvp: false,
            onTap: () {},
            onRsvp: () {},
          ),
        ),
      ),
    );

    expect(find.text('Lomba Uji Sudah Lewat'), findsOneWidget);
    expect(find.text('Lomba'), findsOneWidget);
    expect(find.text('Gratis'), findsOneWidget);
    expect(find.text('Selesai'), findsOneWidget);
  });

  testWidgets('Daftar: memuat lalu menampilkan data dari API', (tester) async {
    await tester.pumpWidget(
      AgendaKampusApp(service: buatServiceUji(), fontKustom: false),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.text('Seminar Uji Mendatang'), findsOneWidget);
    expect(find.text('Workshop Uji Berbayar'), findsOneWidget);
    expect(find.text('Sudah lewat'), findsOneWidget);
  });

  testWidgets('Daftar: keadaan gagal punya tombol Coba lagi', (tester) async {
    await tester.pumpWidget(
      AgendaKampusApp(service: buatServiceUji(gagal: true), fontKustom: false),
    );
    await tester.pumpAndSettle();

    expect(find.text('Gagal memuat acara'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
  });

  testWidgets('Filter ChoiceChip menyaring jenis acara', (tester) async {
    await tester.pumpWidget(
      AgendaKampusApp(service: buatServiceUji(), fontKustom: false),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Workshop'));
    await tester.pumpAndSettle();

    expect(find.text('Workshop Uji Berbayar'), findsOneWidget);
    expect(find.text('Seminar Uji Mendatang'), findsNothing);
  });

  testWidgets(
    'RSVP memunculkan SnackBar yang bisa dibatalkan, dan tab berganti',
    (tester) async {
      await tester.pumpWidget(
        AgendaKampusApp(service: buatServiceUji(), fontKustom: false),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('RSVP').first);
      await tester.pump();
      expect(find.textContaining('Kamu RSVP ke'), findsOneWidget);

      await tester.tap(find.text('RSVP Saya'));
      await tester.pumpAndSettle();
      expect(find.textContaining('1 acara'), findsOneWidget);

      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(find.byType(SegmentedButton<ThemeMode>), findsOneWidget);
    },
  );

  testWidgets('Form usulan menolak data kosong', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HalamanFormAcara()));
    await tester.scrollUntilVisible(
      find.text('Kirim usulan'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.tap(find.text('Kirim usulan'));
    await tester.pump();

    expect(find.text('Pilih tanggal dan jam acara dulu'), findsOneWidget);
  });

  testWidgets('Form tambah mengembalikan acara baru yang muncul di daftar', (
    tester,
  ) async {
    await tester.pumpWidget(
      AgendaKampusApp(service: buatServiceUji(), fontKustom: false),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Usulkan'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('field-judul')),
      'Nobar Final Liga Kampus',
    );
    await tester.enterText(find.byKey(const Key('field-lokasi')), 'Aula');
    await tester.tap(find.text('Pilih tanggal & jam'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK')); // showDatePicker
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK')); // showTimePicker
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Kirim usulan'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Kirim usulan'));
    await tester.pumpAndSettle();

    expect(find.byType(HalamanFormAcara), findsNothing);
    expect(find.text('Nobar Final Liga Kampus'), findsOneWidget);
    expect(find.textContaining('terkirim ke server'), findsOneWidget);
  });

  test('daftarJenisAcara berisi empat jenis sesuai tema', () {
    expect(daftarJenisAcara, ['Seminar', 'Lomba', 'Workshop', 'Hiburan']);
  });
}
