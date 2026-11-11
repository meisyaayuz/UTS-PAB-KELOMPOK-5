import 'package:flutter/material.dart';

import '../models/acara.dart';
import '../services/acara_service.dart';

/// Tab "Profil": logo, statistik, dan pilihan tema terang/gelap.
class HalamanProfil extends StatefulWidget {
  const HalamanProfil({
    super.key,
    required this.service,
    required this.jumlahRsvp,
    required this.jumlahUsulan,
    required this.modeTema,
    required this.onGantiModeTema,
  });

  final AcaraService service;
  final int jumlahRsvp;
  final int jumlahUsulan;
  final ThemeMode modeTema;
  final ValueChanged<ThemeMode> onGantiModeTema;

  @override
  State<HalamanProfil> createState() => _HalamanProfilState();
}

class _HalamanProfilState extends State<HalamanProfil> {
  // Memakai endpoint khas GET /acara/mendatang.
  late Future<List<Acara>> _futureMendatang = widget.service.ambilMendatang();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final teks = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Image.asset('assets/images/logo.png', width: 96, height: 96),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Mahasiswa Telkom University',
            style: teks.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Center(
          child: Text(
            'Agenda Kampus · Kelompok 05',
            style: teks.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _KotakStat(angka: '${widget.jumlahRsvp}', label: 'RSVP'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KotakStat(
                angka: '${widget.jumlahUsulan}',
                label: 'Usulan',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FutureBuilder<List<Acara>>(
                future: _futureMendatang,
                builder: (context, snap) {
                  final angka = snap.hasData
                      ? '${snap.data!.length}'
                      : snap.hasError
                      ? '–'
                      : '…';
                  return _KotakStat(
                    angka: angka,
                    label: 'Mendatang',
                    onTap: () => setState(() {
                      _futureMendatang = widget.service.ambilMendatang();
                    }),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text('Tampilan', style: teks.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(
              value: ThemeMode.light,
              icon: Icon(Icons.light_mode_outlined),
              label: Text('Terang'),
            ),
            ButtonSegment(
              value: ThemeMode.system,
              icon: Icon(Icons.brightness_auto_outlined),
              label: Text('Sistem'),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              icon: Icon(Icons.dark_mode_outlined),
              label: Text('Gelap'),
            ),
          ],
          selected: {widget.modeTema},
          onSelectionChanged: (s) => widget.onGantiModeTema(s.first),
        ),
        const SizedBox(height: 28),
        Card(
          child: ListTile(
            leading: Icon(Icons.dns_outlined, color: cs.primary),
            title: const Text('Server API'),
            subtitle: Text(widget.service.baseUrl),
          ),
        ),
      ],
    );
  }
}

class _KotakStat extends StatelessWidget {
  const _KotakStat({required this.angka, required this.label, this.onTap});

  final String angka;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.primaryContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(
                angka,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: cs.onPrimaryContainer,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(label, style: TextStyle(color: cs.onPrimaryContainer)),
            ],
          ),
        ),
      ),
    );
  }
}
