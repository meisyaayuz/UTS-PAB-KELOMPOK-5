import 'package:flutter/material.dart';

import '../models/acara.dart';
import '../utils/format.dart';
import '../widgets/kartu_acara.dart';

/// Form usulan acara. Hasilnya dikembalikan lewat Navigator.pop(context, acara).
class HalamanFormAcara extends StatefulWidget {
  const HalamanFormAcara({super.key});

  @override
  State<HalamanFormAcara> createState() => _HalamanFormAcaraState();
}

class _HalamanFormAcaraState extends State<HalamanFormAcara> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _penyelenggaraController = TextEditingController();
  final _kuotaController = TextEditingController(text: '50');

  String _jenis = daftarJenisAcara.first;
  DateTime? _mulai;
  bool _berbayar = false;

  @override
  void dispose() {
    _judulController.dispose();
    _lokasiController.dispose();
    _penyelenggaraController.dispose();
    _kuotaController.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggalJam() async {
    final sekarang = DateTime.now();
    final tanggal = await showDatePicker(
      context: context,
      initialDate: _mulai ?? sekarang.add(const Duration(days: 1)),
      firstDate: hanyaTanggal(sekarang),
      lastDate: sekarang.add(const Duration(days: 365)),
      helpText: 'Tanggal acara',
    );
    if (tanggal == null) return;
    if (!mounted) return; // context dipakai lagi setelah await

    final jam = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      helpText: 'Jam mulai',
    );
    if (jam == null || !mounted) return;

    setState(() {
      _mulai = DateTime(
        tanggal.year,
        tanggal.month,
        tanggal.day,
        jam.hour,
        jam.minute,
      );
    });
  }

  void _simpan() {
    final valid = _formKey.currentState!.validate();
    if (_mulai == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal dan jam acara dulu')),
      );
      return;
    }
    if (!valid) return;

    final penyelenggara = _penyelenggaraController.text.trim();
    final acara = Acara(
      id: 'lokal-${DateTime.now().millisecondsSinceEpoch}',
      judul: _judulController.text.trim(),
      penyelenggara: penyelenggara.isEmpty ? 'Usulan Mahasiswa' : penyelenggara,
      jenis: _jenis,
      lokasi: _lokasiController.text.trim(),
      mulai: _mulai!,
      berbayar: _berbayar,
      kuota: int.tryParse(_kuotaController.text) ?? 0,
    );
    Navigator.pop(context, acara);
  }

  String? _wajib(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Usulkan Acara')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              key: const Key('field-judul'),
              controller: _judulController,
              decoration: const InputDecoration(
                labelText: 'Judul acara',
                prefixIcon: Icon(Icons.title),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: _wajib,
            ),
            const SizedBox(height: 16),
            Text('Jenis', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final j in daftarJenisAcara)
                  ChoiceChip(
                    avatar: Icon(ikonJenis(j), size: 18),
                    label: Text(j),
                    selected: _jenis == j,
                    onSelected: (_) => setState(() => _jenis = j),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('field-lokasi'),
              controller: _lokasiController,
              decoration: const InputDecoration(
                labelText: 'Lokasi',
                prefixIcon: Icon(Icons.place_outlined),
              ),
              validator: _wajib,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _penyelenggaraController,
              decoration: const InputDecoration(
                labelText: 'Penyelenggara (opsional)',
                prefixIcon: Icon(Icons.groups_outlined),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pilihTanggalJam,
              icon: const Icon(Icons.event),
              label: Text(
                _mulai == null
                    ? 'Pilih tanggal & jam'
                    : '${formatTanggalPanjang(_mulai!)} · ${formatJam(_mulai!)}',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _kuotaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Kuota peserta',
                prefixIcon: Icon(Icons.people_outline),
              ),
              validator: (v) =>
                  int.tryParse(v ?? '') == null ? 'Isi dengan angka' : null,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Acara berbayar'),
              subtitle: Text(_berbayar ? 'Peserta membayar tiket' : 'Gratis'),
              value: _berbayar,
              activeThumbColor: cs.primary,
              onChanged: (v) => setState(() => _berbayar = v),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _simpan,
              icon: const Icon(Icons.send),
              label: const Text('Kirim usulan'),
            ),
          ],
        ),
      ),
    );
  }
}
