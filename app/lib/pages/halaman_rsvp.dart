import 'package:flutter/material.dart';

import '../models/acara.dart';
import '../utils/format.dart';
import '../widgets/kartu_acara.dart';

/// Tab "RSVP Saya": acara yang sudah kamu RSVP.
class HalamanRsvp extends StatelessWidget {
  const HalamanRsvp({
    super.key,
    required this.acara,
    required this.onBukaDetail,
    required this.onToggleRsvp,
    required this.onJelajahi,
  });

  final List<Acara> acara;
  final ValueChanged<Acara> onBukaDetail;
  final ValueChanged<Acara> onToggleRsvp;
  final VoidCallback onJelajahi;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (acara.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bookmarks_outlined, size: 64, color: cs.outline),
              const SizedBox(height: 12),
              const Text('Belum ada acara yang kamu RSVP.'),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onJelajahi,
                icon: const Icon(Icons.explore_outlined),
                label: const Text('Jelajahi acara'),
              ),
            ],
          ),
        ),
      );
    }

    final urut = [...acara]..sort((a, b) => a.mulai.compareTo(b.mulai));
    final berikutnya = urut.where((a) => !a.sudahLewat()).firstOrNull;

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: urut.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Text(
              berikutnya == null
                  ? '${urut.length} acara · semuanya sudah lewat'
                  : '${urut.length} acara · berikutnya '
                        '${formatTanggalPendek(berikutnya.mulai)}, '
                        '${formatJam(berikutnya.mulai)}',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
          );
        }
        final a = urut[i - 1];
        return KartuAcara(
          acara: a,
          sudahRsvp: true,
          onTap: () => onBukaDetail(a),
          onRsvp: () => onToggleRsvp(a),
        );
      },
    );
  }
}
