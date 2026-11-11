const _namaHari = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];

const _namaBulan = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

String _duaDigit(int n) => n.toString().padLeft(2, '0');

/// Contoh: "Sabtu, 14 November 2026"
String formatTanggalPanjang(DateTime t) =>
    '${_namaHari[t.weekday - 1]}, ${t.day} ${_namaBulan[t.month - 1]} ${t.year}';

/// Contoh: "14 Nov"
String formatTanggalPendek(DateTime t) =>
    '${t.day} ${_namaBulan[t.month - 1].substring(0, 3)}';

/// Contoh: "19.00"
String formatJam(DateTime t) => '${_duaDigit(t.hour)}.${_duaDigit(t.minute)}';

/// Contoh: "NOV"
String singkatanBulan(DateTime t) =>
    _namaBulan[t.month - 1].substring(0, 3).toUpperCase();

/// Tanggal tanpa jam, dipakai untuk mengelompokkan acara per hari.
DateTime hanyaTanggal(DateTime t) => DateTime(t.year, t.month, t.day);
