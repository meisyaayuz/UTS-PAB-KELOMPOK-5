import 'package:flutter/material.dart';

import '../models/acara.dart';
import '../utils/format.dart';
import '../widgets/kartu_acara.dart';

/// Tab "Mendatang": daftar acara dari server, dikelompokkan per tanggal.
class HalamanMendatang extends StatefulWidget {
  const HalamanMendatang({
    super.key,
    required this.futureAcara,
    required this.tambahan,
    required this.rsvp,
    required this.onMuatUlang,
    required this.onBukaDetail,
    required this.onToggleRsvp,
  });

  final Future<List<Acara>> futureAcara;
  final List<Acara> tambahan;
  final Set<String> rsvp;
  final Future<void> Function() onMuatUlang;
  final ValueChanged<Acara> onBukaDetail;
  final ValueChanged<Acara> onToggleRsvp;

  @override
  State<HalamanMendatang> createState() => _HalamanMendatangState();
}

class _HalamanMendatangState extends State<HalamanMendatang> {
  final _cariController = TextEditingController();
  String _jenisTerpilih = 'Semua';
  String _kataKunci = '';

  @override
  void dispose() {
    _cariController.dispose();
    super.dispose();
  }

  List<_Baris> _susunBaris(List<Acara> data) {
    final sekarang = DateTime.now();
    final kunci = _kataKunci.toLowerCase();
    final tersaring = data.where((a) {
      final cocokJenis = _jenisTerpilih == 'Semua' || a.jenis == _jenisTerpilih;
      final cocokKata =
          kunci.isEmpty ||
          a.judul.toLowerCase().contains(kunci) ||
          a.penyelenggara.toLowerCase().contains(kunci) ||
          a.lokasi.toLowerCase().contains(kunci);
      return cocokJenis && cocokKata;
    });

    final mendatang = tersaring.where((a) => !a.sudahLewat(sekarang)).toList()
      ..sort((a, b) => a.mulai.compareTo(b.mulai));
    final lewat = tersaring.where((a) => a.sudahLewat(sekarang)).toList()
      ..sort((a, b) => b.mulai.compareTo(a.mulai));

    final baris = <_Baris>[];
    DateTime? tanggalTerakhir;
    for (final a in mendatang) {
      final tgl = hanyaTanggal(a.mulai);
      if (tgl != tanggalTerakhir) {
        baris.add(_Baris.judul(formatTanggalPanjang(tgl)));
        tanggalTerakhir = tgl;
      }
      baris.add(_Baris.acara(a));
    }
    if (lewat.isNotEmpty) {
      baris.add(_Baris.judul('Sudah lewat', pudar: true));
      baris.addAll(lewat.map(_Baris.acara));
    }
    return baris;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: TextField(
            controller: _cariController,
            onChanged: (v) => setState(() => _kataKunci = v.trim()),
            decoration: InputDecoration(
              hintText: 'Cari acara, penyelenggara, lokasi…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _kataKunci.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Hapus pencarian',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _cariController.clear();
                        setState(() => _kataKunci = '');
                      },
                    ),
              filled: true,
              fillColor: cs.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final jenis in ['Semua', ...daftarJenisAcara])
                ChoiceChip(
                  avatar: Icon(
                    jenis == 'Semua' ? Icons.apps : ikonJenis(jenis),
                    size: 18,
                  ),
                  label: Text(jenis),
                  selected: _jenisTerpilih == jenis,
                  onSelected: (_) => setState(() => _jenisTerpilih = jenis),
                ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Acara>>(
            future: widget.futureAcara,
            builder: (context, snapshot) {
              // 1) Memuat
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              // 2) Gagal
              if (snapshot.hasError) {
                return _TampilanGagal(
                  pesan: '${snapshot.error}',
                  onCobaLagi: widget.onMuatUlang,
                );
              }
              // 3) Berhasil
              final data = [
                ...snapshot.data!,
                ...widget.tambahan.where(
                  (t) => snapshot.data!.every((d) => d.id != t.id),
                ),
              ];
              final baris = _susunBaris(data);
              return RefreshIndicator(
                onRefresh: widget.onMuatUlang,
                child: baris.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 80),
                          Center(child: Text('Tidak ada acara yang cocok.')),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 96),
                        itemCount: baris.length,
                        itemBuilder: (context, i) {
                          final b = baris[i];
                          if (b.acara == null) {
                            return JudulTanggal(teks: b.judul!, pudar: b.pudar);
                          }
                          final acara = b.acara!;
                          return KartuAcara(
                            acara: acara,
                            sudahRsvp: widget.rsvp.contains(acara.id),
                            onTap: () => widget.onBukaDetail(acara),
                            onRsvp: () => widget.onToggleRsvp(acara),
                          );
                        },
                      ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Satu baris di ListView: judul tanggal atau kartu acara.
class _Baris {
  _Baris.judul(this.judul, {this.pudar = false}) : acara = null;
  _Baris.acara(this.acara) : judul = null, pudar = false;

  final String? judul;
  final Acara? acara;
  final bool pudar;
}

class JudulTanggal extends StatelessWidget {
  const JudulTanggal({super.key, required this.teks, this.pudar = false});

  final String teks;
  final bool pudar;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(
        teks,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: pudar ? cs.outline : cs.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TampilanGagal extends StatelessWidget {
  const _TampilanGagal({required this.pesan, required this.onCobaLagi});

  final String pesan;
  final VoidCallback onCobaLagi;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 64, color: cs.error),
            const SizedBox(height: 12),
            Text(
              'Gagal memuat acara',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              pesan,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onCobaLagi,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
