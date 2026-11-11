// Membuat gambar logo & ikon launcher Agenda Kampus tanpa aplikasi desain.
// Jalankan dari folder app/:  dart run tool/buat_aset.dart
import 'dart:io';

import 'package:image/image.dart' as img;

final merah = img.ColorRgb8(0xB3, 0x26, 0x1E);
final merahTua = img.ColorRgb8(0x7A, 0x14, 0x10);
final putih = img.ColorRgb8(0xFF, 0xFF, 0xFF);
final krem = img.ColorRgb8(0xFF, 0xE8, 0xE4);
final emas = img.ColorRgb8(0xFF, 0xC1, 0x07);

/// Gambar kalender putih dengan satu tanggal ditandai.
void gambarKalender(
  img.Image c, {
  required int pusatX,
  required int pusatY,
  required int lebar,
}) {
  final tinggi = (lebar * 0.9).round();
  final x1 = pusatX - lebar ~/ 2;
  final y1 = pusatY - tinggi ~/ 2 + lebar ~/ 20;
  final x2 = x1 + lebar;
  final y2 = y1 + tinggi;
  final r = lebar ~/ 9;

  // Badan kalender
  img.fillRect(c, x1: x1, y1: y1, x2: x2, y2: y2, color: putih, radius: r);
  // Kepala kalender
  final tinggiKepala = tinggi ~/ 4;
  img.fillRect(
    c,
    x1: x1,
    y1: y1,
    x2: x2,
    y2: y1 + tinggiKepala,
    color: krem,
    radius: r,
  );
  img.fillRect(
    c,
    x1: x1,
    y1: y1 + tinggiKepala ~/ 2,
    x2: x2,
    y2: y1 + tinggiKepala,
    color: krem,
  );

  // Cincin pengikat
  final lebarCincin = lebar ~/ 14;
  for (final fx in [0.28, 0.72]) {
    final cx = x1 + (lebar * fx).round();
    img.fillRect(
      c,
      x1: cx - lebarCincin ~/ 2,
      y1: y1 - lebarCincin * 2,
      x2: cx + lebarCincin ~/ 2,
      y2: y1 + lebarCincin * 2,
      color: merahTua,
      radius: lebarCincin ~/ 2,
    );
  }

  // Titik-titik tanggal 4 x 3
  final atas = y1 + tinggiKepala + tinggi ~/ 9;
  final jarakX = lebar ~/ 5;
  final jarakY = (tinggi - tinggiKepala) ~/ 4;
  final rTitik = lebar ~/ 22;
  for (var baris = 0; baris < 3; baris++) {
    for (var kolom = 0; kolom < 4; kolom++) {
      final cx = x1 + jarakX * (kolom + 1) - jarakX ~/ 2 + lebar ~/ 10;
      final cy = atas + jarakY * baris;
      final ditandai = baris == 1 && kolom == 2;
      img.fillCircle(
        c,
        x: cx,
        y: cy,
        radius: ditandai ? (rTitik * 2.2).round() : rTitik,
        color: ditandai ? merah : krem,
        antialias: true,
      );
      if (ditandai) {
        img.fillCircle(
          c,
          x: cx,
          y: cy,
          radius: rTitik,
          color: emas,
          antialias: true,
        );
      }
    }
  }
}

img.Image buatIkon(int ukuran, {required bool latar, double skala = 0.58}) {
  final c = img.Image(width: ukuran, height: ukuran, numChannels: 4);
  if (latar) {
    img.fill(c, color: merah);
  } else {
    img.fill(c, color: img.ColorRgba8(0, 0, 0, 0));
  }
  gambarKalender(
    c,
    pusatX: ukuran ~/ 2,
    pusatY: ukuran ~/ 2,
    lebar: (ukuran * skala).round(),
  );
  return c;
}

void main() {
  Directory('assets/images').createSync(recursive: true);
  Directory('assets/icon').createSync(recursive: true);

  File('assets/icon/ikon.png')
      .writeAsBytesSync(img.encodePng(buatIkon(1024, latar: true)));
  // Lapisan depan ikon adaptif Android (lebih kecil karena zona aman 66%).
  File(
    'assets/icon/ikon_depan.png',
  ).writeAsBytesSync(img.encodePng(buatIkon(1024, latar: false, skala: 0.42)));
  File('assets/images/logo.png')
      .writeAsBytesSync(img.encodePng(buatIkon(512, latar: true)));

  stdout.writeln(
    'Aset dibuat: assets/icon/ikon.png, assets/icon/ikon_depan.png, assets/images/logo.png',
  );
}
