import 'package:flutter/material.dart';

import '../models/acara.dart';
import '../utils/format.dart';
import '../widgets/kartu_acara.dart';

/// Halaman detail: menerima objek [Acara] lewat konstruktor.
class HalamanDetail extends StatefulWidget {
  const HalamanDetail({
    super.key,
    required this.acara,
    required this.sudahRsvp,
    required this.onToggleRsvp,
  });

  final Acara acara;
  final bool sudahRsvp;
  final VoidCallback onToggleRsvp;

  @override
  State<HalamanDetail> createState() => _HalamanDetailState();
}

class _HalamanDetailState extends State<HalamanDetail> {
  late bool _sudahRsvp = widget.sudahRsvp;

  void _toggle() {
    widget.onToggleRsvp();
    setState(() => _sudahRsvp = !_sudahRsvp);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            _sudahRsvp ? 'Sampai jumpa di acara!' : 'RSVP dibatalkan',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.acara;
    final cs = Theme.of(context).colorScheme;
    final teks = Theme.of(context).textTheme;
    final lewat = a.sudahLewat();

    return Scaffold(
      appBar: AppBar(title: Text(a.jenis)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              LencanaTanggal(acara: a, besar: true),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  a.judul,
                  style: teks.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _InfoTile(
            ikon: Icons.calendar_today_outlined,
            judul: formatTanggalPanjang(a.mulai),
            sub: 'Mulai pukul ${formatJam(a.mulai)} WIB',
          ),
          _InfoTile(ikon: Icons.place_outlined, judul: a.lokasi, sub: 'Lokasi'),
          _InfoTile(
            ikon: Icons.groups_outlined,
            judul: a.penyelenggara,
            sub: 'Penyelenggara',
          ),
          _InfoTile(
            ikon: ikonJenis(a.jenis),
            judul: a.jenis,
            sub: 'Jenis acara',
          ),
          _InfoTile(
            ikon: Icons.confirmation_number_outlined,
            judul: a.berbayar ? 'Berbayar' : 'Gratis',
            sub: 'Kuota ${a.kuota} peserta',
          ),
          const SizedBox(height: 24),
          if (lewat)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Acara ini sudah berlangsung.'),
            )
          else
            FilledButton.icon(
              onPressed: _toggle,
              style: _sudahRsvp
                  ? FilledButton.styleFrom(
                      backgroundColor: cs.secondaryContainer,
                      foregroundColor: cs.onSecondaryContainer,
                    )
                  : null,
              icon: Icon(_sudahRsvp ? Icons.check : Icons.bookmark_add),
              label: Text(
                _sudahRsvp ? 'Sudah RSVP · Batalkan' : 'RSVP Sekarang',
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Kembali ke daftar'),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.ikon, required this.judul, required this.sub});

  final IconData ikon;
  final String judul;
  final String sub;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        child: Icon(ikon),
      ),
      title: Text(judul),
      subtitle: Text(sub),
    );
  }
}
