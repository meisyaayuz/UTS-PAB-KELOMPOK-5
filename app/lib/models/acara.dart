/// Jenis acara yang tersedia di Agenda Kampus.
const daftarJenisAcara = ['Seminar', 'Lomba', 'Workshop', 'Hiburan'];

/// Model utama aplikasi: satu acara kampus.
class Acara {
  final String id;
  final String judul;
  final String penyelenggara;
  final String jenis; // Seminar / Lomba / Workshop / Hiburan
  final String lokasi;
  final DateTime mulai;
  final bool berbayar;
  final int kuota;

  const Acara({
    required this.id,
    required this.judul,
    required this.penyelenggara,
    required this.jenis,
    required this.lokasi,
    required this.mulai,
    required this.berbayar,
    required this.kuota,
  });

  /// Acara dianggap sudah lewat bila waktu mulainya sebelum [sekarang].
  bool sudahLewat([DateTime? sekarang]) =>
      mulai.isBefore(sekarang ?? DateTime.now());

  factory Acara.fromJson(Map<String, dynamic> json) {
    return Acara(
      id: json['id'] as String,
      judul: json['judul'] as String,
      penyelenggara: json['penyelenggara'] as String? ?? '-',
      jenis: json['jenis'] as String,
      lokasi: json['lokasi'] as String,
      mulai: DateTime.parse(json['mulai'] as String),
      berbayar: json['berbayar'] as bool? ?? false,
      kuota: (json['kuota'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'judul': judul,
    'penyelenggara': penyelenggara,
    'jenis': jenis,
    'lokasi': lokasi,
    'mulai': mulai.toIso8601String(),
    'berbayar': berbayar,
    'kuota': kuota,
  };
}
