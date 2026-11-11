import 'package:flutter/material.dart';

import '../models/acara.dart';
import '../utils/format.dart';

/// Ikon untuk tiap jenis acara.
IconData ikonJenis(String jenis) {
  switch (jenis) {
    case 'Seminar':
      return Icons.mic_external_on_outlined;
    case 'Lomba':
      return Icons.emoji_events_outlined;
    case 'Workshop':
      return Icons.build_circle_outlined;
    case 'Hiburan':
      return Icons.music_note_outlined;
    default:
      return Icons.event_outlined;
  }
}

/// Kartu satu acara: lencana tanggal di kiri, info di kanan,
/// label "Selesai" ditumpuk di pojok bila acara sudah lewat.
class KartuAcara extends StatelessWidget {
  const KartuAcara({
    super.key,
    required this.acara,
    required this.sudahRsvp,
    required this.onTap,
    required this.onRsvp,
    this.sekarang,
  });

  final Acara acara;
  final bool sudahRsvp;
  final VoidCallback onTap;
  final VoidCallback onRsvp;
  final DateTime? sekarang;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final teks = Theme.of(context).textTheme;
    final lewat = acara.sudahLewat(sekarang);

    return Opacity(
      opacity: lewat ? 0.45 : 1,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LencanaTanggal(acara: acara),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            acara.judul,
                            style: teks.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          _BarisInfo(
                            ikon: Icons.schedule,
                            teks: '${formatJam(acara.mulai)} WIB',
                          ),
                          _BarisInfo(
                            ikon: Icons.place_outlined,
                            teks: acara.lokasi,
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _Label(
                                teks: acara.jenis,
                                ikon: ikonJenis(acara.jenis),
                                latar: cs.secondaryContainer,
                                depan: cs.onSecondaryContainer,
                              ),
                              _Label(
                                teks: acara.berbayar ? 'Berbayar' : 'Gratis',
                                latar: acara.berbayar
                                    ? cs.tertiaryContainer
                                    : cs.primaryContainer,
                                depan: acara.berbayar
                                    ? cs.onTertiaryContainer
                                    : cs.onPrimaryContainer,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: sudahRsvp ? 'Batalkan RSVP' : 'RSVP',
                      onPressed: lewat ? null : onRsvp,
                      icon: Icon(
                        sudahRsvp
                            ? Icons.bookmark_added
                            : Icons.bookmark_add_outlined,
                        color: sudahRsvp ? cs.primary : cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (lewat)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: cs.inverseSurface,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Selesai',
                      style: teks.labelSmall?.copyWith(
                        color: cs.onInverseSurface,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lencana tanggal (dibungkus Hero agar beranimasi ke halaman detail).
class LencanaTanggal extends StatelessWidget {
  const LencanaTanggal({super.key, required this.acara, this.besar = false});

  final Acara acara;
  final bool besar;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ukuran = besar ? 84.0 : 58.0;
    return Hero(
      tag: 'tanggal-${acara.id}',
      child: Material(
        color: cs.primary,
        borderRadius: BorderRadius.circular(besar ? 20 : 14),
        child: SizedBox(
          width: ukuran,
          height: ukuran,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${acara.mulai.day}',
                style: TextStyle(
                  color: cs.onPrimary,
                  fontSize: besar ? 32 : 22,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              Text(
                singkatanBulan(acara.mulai),
                style: TextStyle(
                  color: cs.onPrimary,
                  fontSize: besar ? 14 : 11,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarisInfo extends StatelessWidget {
  const _BarisInfo({required this.ikon, required this.teks});

  final IconData ikon;
  final String teks;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(ikon, size: 14, color: cs.onSurfaceVariant),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              teks,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({
    required this.teks,
    required this.latar,
    required this.depan,
    this.ikon,
  });

  final String teks;
  final Color latar;
  final Color depan;
  final IconData? ikon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: latar,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ikon != null) ...[
            Icon(ikon, size: 12, color: depan),
            const SizedBox(width: 4),
          ],
          Text(
            teks,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: depan, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
