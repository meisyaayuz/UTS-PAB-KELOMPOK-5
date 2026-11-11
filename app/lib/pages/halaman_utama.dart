import 'package:flutter/material.dart';

import '../models/acara.dart';
import '../services/acara_service.dart';
import 'halaman_detail.dart';
import 'halaman_form_acara.dart';
import 'halaman_mendatang.dart';
import 'halaman_profil.dart';
import 'halaman_rsvp.dart';

/// Kerangka aplikasi: NavigationBar 3 tab + IndexedStack.
class HalamanUtama extends StatefulWidget {
  const HalamanUtama({
    super.key,
    required this.service,
    required this.modeTema,
    required this.onGantiModeTema,
  });

  final AcaraService service;
  final ThemeMode modeTema;
  final ValueChanged<ThemeMode> onGantiModeTema;

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  int _indeksTab = 0;
  late Future<List<Acara>> _futureAcara;
  List<Acara> _dariServer = [];
  final List<Acara> _tambahan = [];
  final Set<String> _rsvp = {};

  @override
  void initState() {
    super.initState();
    _futureAcara = _ambil();
  }

  Future<List<Acara>> _ambil() async {
    final data = await widget.service.ambilSemua();
    _dariServer = data;
    // Usulan yang sudah tersimpan di server tidak perlu ditampilkan dua kali.
    _tambahan.removeWhere((t) => data.any((d) => d.id == t.id));
    return data;
  }

  /// Dipakai tombol "Coba lagi" dan pull-to-refresh.
  Future<void> _muatUlang() {
    final future = _ambil();
    setState(() => _futureAcara = future);
    return future.then((_) {}, onError: (_) {});
  }

  /// Gabungan data server + usulan dari form, tanpa duplikat id.
  List<Acara> get _semuaAcara {
    final peta = {for (final a in _dariServer) a.id: a};
    for (final a in _tambahan) {
      peta.putIfAbsent(a.id, () => a);
    }
    return peta.values.toList();
  }

  void _toggleRsvp(Acara acara, {bool denganUndo = true}) {
    final sebelumnya = _rsvp.contains(acara.id);
    setState(() {
      sebelumnya ? _rsvp.remove(acara.id) : _rsvp.add(acara.id);
    });
    if (!denganUndo) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          sebelumnya
              ? 'RSVP "${acara.judul}" dibatalkan'
              : 'Kamu RSVP ke "${acara.judul}"',
        ),
        action: SnackBarAction(
          label: 'Batalkan',
          onPressed: () => setState(() {
            sebelumnya ? _rsvp.add(acara.id) : _rsvp.remove(acara.id);
          }),
        ),
      ),
    );
  }

  Future<void> _bukaDetail(Acara acara) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HalamanDetail(
          acara: acara,
          sudahRsvp: _rsvp.contains(acara.id),
          onToggleRsvp: () => _toggleRsvp(acara, denganUndo: false),
        ),
      ),
    );
  }

  Future<void> _bukaForm() async {
    final baru = await Navigator.push<Acara>(
      context,
      MaterialPageRoute(builder: (_) => const HalamanFormAcara()),
    );
    if (baru == null) return;

    // Nilai tambah: coba kirim ke server dengan POST. Bila gagal,
    // usulan tetap disimpan di memori aplikasi.
    Acara hasil = baru;
    var terkirim = true;
    try {
      hasil = await widget.service.tambah(baru);
    } catch (_) {
      terkirim = false;
    }

    if (!mounted) return; // context dipakai setelah await
    setState(() => _tambahan.add(hasil));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          terkirim
              ? 'Usulan "${hasil.judul}" terkirim ke server'
              : 'Server tidak terjangkau, usulan disimpan di perangkat',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semua = _semuaAcara;
    return Scaffold(
      appBar: AppBar(
        title: Text(const ['Agenda Kampus', 'RSVP Saya', 'Profil'][_indeksTab]),
      ),
      body: IndexedStack(
        index: _indeksTab,
        children: [
          HalamanMendatang(
            futureAcara: _futureAcara,
            tambahan: _tambahan,
            rsvp: _rsvp,
            onMuatUlang: _muatUlang,
            onBukaDetail: _bukaDetail,
            onToggleRsvp: _toggleRsvp,
          ),
          HalamanRsvp(
            acara: semua.where((a) => _rsvp.contains(a.id)).toList(),
            onBukaDetail: _bukaDetail,
            onToggleRsvp: _toggleRsvp,
            onJelajahi: () => setState(() => _indeksTab = 0),
          ),
          HalamanProfil(
            service: widget.service,
            jumlahRsvp: _rsvp.length,
            jumlahUsulan: _tambahan.length,
            modeTema: widget.modeTema,
            onGantiModeTema: widget.onGantiModeTema,
          ),
        ],
      ),
      floatingActionButton: _indeksTab == 0
          ? FloatingActionButton.extended(
              onPressed: _bukaForm,
              icon: const Icon(Icons.add),
              label: const Text('Usulkan'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indeksTab,
        onDestinationSelected: (i) => setState(() => _indeksTab = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Mendatang',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _rsvp.isNotEmpty,
              label: Text('${_rsvp.length}'),
              child: const Icon(Icons.bookmarks_outlined),
            ),
            selectedIcon: const Icon(Icons.bookmarks),
            label: 'RSVP Saya',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
