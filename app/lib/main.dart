import 'package:flutter/material.dart';

import 'pages/halaman_utama.dart';
import 'services/acara_service.dart';
import 'tema.dart';

void main() {
  runApp(AgendaKampusApp());
}

class AgendaKampusApp extends StatefulWidget {
  AgendaKampusApp({super.key, AcaraService? service, this.fontKustom = true})
    : service = service ?? AcaraService();

  final AcaraService service;
  final bool fontKustom;

  @override
  State<AgendaKampusApp> createState() => _AgendaKampusAppState();
}

class _AgendaKampusAppState extends State<AgendaKampusApp> {
  ThemeMode _modeTema = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda Kampus',
      debugShowCheckedModeBanner: false,
      theme: buatTema(Brightness.light, fontKustom: widget.fontKustom),
      darkTheme: buatTema(Brightness.dark, fontKustom: widget.fontKustom),
      themeMode: _modeTema,
      home: HalamanUtama(
        service: widget.service,
        modeTema: _modeTema,
        onGantiModeTema: (mode) => setState(() => _modeTema = mode),
      ),
    );
  }
}
