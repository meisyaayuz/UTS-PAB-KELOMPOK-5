# Agenda Kampus — UTS Pengembangan Aplikasi Bergerak

**Kelompok 05 · Proyek 8: Agenda Kampus (acara, seminar, dan RSVP)**

Kalender acara kampus (seminar, lomba, workshop, hiburan). Mahasiswa melihat acara mendatang
yang dikelompokkan per tanggal, melakukan RSVP (dengan *undo*), dan mengusulkan acara baru.

## Anggota

| Nama | NIM | Tugas |
|------|-----|-------|
| _(isi nama)_ | _(isi NIM)_ | Server API (shelf) & data JSON |
| _(isi nama)_ | _(isi NIM)_ | Model, layanan HTTP, FutureBuilder |
| _(isi nama)_ | _(isi NIM)_ | Halaman daftar, detail, kartu, RSVP |
| _(isi nama)_ | _(isi NIM)_ | Form usulan, tema, ikon, test, README |

## Struktur

```
.
├─ app/                     # proyek Flutter (id.ac.telkomuniversity.agenda_kampus)
│  ├─ lib/
│  │  ├─ main.dart          # MaterialApp, tema terang/gelap
│  │  ├─ tema.dart          # ColorScheme.fromSeed + google_fonts
│  │  ├─ models/acara.dart
│  │  ├─ services/acara_service.dart
│  │  ├─ pages/             # halaman_utama, mendatang, rsvp, profil, detail, form_acara
│  │  ├─ widgets/kartu_acara.dart
│  │  └─ utils/format.dart  # format tanggal Indonesia
│  ├─ test/                 # widget test + test MockClient
│  ├─ assets/               # images/logo.png, icon/ikon.png
│  └─ tool/buat_aset.dart   # skrip pembuat logo & ikon launcher
├─ server/
│  ├─ bin/server.dart       # API shelf + shelf_router
│  └─ data/acara.json       # 14 acara
├─ screenshots/
└─ README.md
```

## Cara menjalankan

Prasyarat: Flutter 3.47+ (Dart 3.13+).

### 1. Nyalakan server

```bash
cd server
dart pub get
dart run bin/server.dart
```

Server berjalan di `http://localhost:8080` (ganti port dengan variabel lingkungan `PORT`).

| Metode | Endpoint | Keterangan |
|--------|----------|------------|
| GET | `/acara` | daftar semua acara (urut waktu) |
| GET | `/acara/{id}` | satu acara berdasarkan id (404 bila tidak ada) |
| GET | `/acara/mendatang` | **endpoint khas**: acara yang `mulai`-nya setelah waktu server |
| POST | `/acara` | tambah usulan acara (nilai tambah) |

### 2. Jalankan aplikasi

```bash
cd app
flutter pub get
```

Emulator Android (`10.0.2.2` = localhost komputer):

```bash
flutter run --dart-define=API_URL=http://10.0.2.2:8080
```

HP Android sungguhan (satu Wi-Fi dengan laptop; ganti dengan IP laptop):

```bash
flutter run --dart-define=API_URL=http://192.168.1.10:8080
```

Browser (opsional):

```bash
flutter run -d chrome --dart-define=API_URL=http://localhost:8080
```

### 3. Test, analyze, dan APK

```bash
flutter analyze
flutter test
flutter build apk --debug --dart-define=API_URL=http://10.0.2.2:8080
```

Ikon launcher dan logo dibuat ulang dengan:

```bash
dart run tool/buat_aset.dart
dart run flutter_launcher_icons
```

## Tangkapan layar

> Ambil dari emulator/HP dan simpan di folder `screenshots/` dengan nama berikut.

| Mendatang | Detail | Form usulan | RSVP Saya | Profil (gelap) |
|---|---|---|---|---|
| ![](screenshots/1_mendatang.png) | ![](screenshots/2_detail.png) | ![](screenshots/3_form.png) | ![](screenshots/4_rsvp.png) | ![](screenshots/5_profil.png) |

## Tabel pemenuhan fitur

Semua path relatif terhadap folder `app/` kecuali yang diawali `server/`.

### P01 & P02

| Poin | File:baris | Keterangan |
|------|-----------|------------|
| `flutter create --org id.ac.telkomuniversity` | `android/app/build.gradle.kts:19` | `applicationId = "id.ac.telkomuniversity.agenda_kampus"` |
| Nama di launcher sesuai tema | `android/app/src/main/AndroidManifest.xml:4` | `android:label="Agenda Kampus"` |
| Berjalan di emulator/HP + 4 screenshot | `../screenshots/` | lihat bagian Tangkapan layar |
| `flutter analyze` bersih | — | `No issues found!` |

### P03

| Poin | File:baris | Keterangan |
|------|-----------|------------|
| StatelessWidget buatan sendiri | `lib/widgets/kartu_acara.dart:24` | `KartuAcara` (juga `HalamanRsvp`, `LencanaTanggal`) |
| StatefulWidget + setState | `lib/pages/halaman_mendatang.dart:8`, `:123` | filter jenis & pencarian mengubah tampilan |
| TextField + controller di-dispose | `lib/pages/halaman_mendatang.dart:31`, `:37` | kolom pencarian; form juga men-dispose 4 controller |
| ≥ 2 jenis tombol Material 3 | `lib/pages/halaman_utama.dart:168`, `lib/pages/halaman_detail.dart:114`, `lib/widgets/kartu_acara.dart:108`, `lib/pages/halaman_mendatang.dart:247` | FloatingActionButton, OutlinedButton, IconButton, FilledButton |
| ChoiceChip / SegmentedButton | `lib/pages/halaman_mendatang.dart:116`, `lib/pages/halaman_profil.dart:96` | filter jenis acara; pilihan tema terang/sistem/gelap |
| SnackBar | `lib/pages/halaman_utama.dart:81` | SnackBar RSVP dengan aksi **Batalkan** |

### P04

| Poin | File:baris | Keterangan |
|------|-----------|------------|
| Model ≥ 6 field, DateTime & bool | `lib/models/acara.dart:5` | `Acara`: 8 field, `mulai` (DateTime), `berbayar` (bool) |
| Kartu dengan Row, Column, Expanded, Stack | `lib/widgets/kartu_acara.dart:53` | Stack `:53`, Row `:57`, Expanded `:62`, Positioned label "Selesai" `:122` |
| ListView.builder | `lib/pages/halaman_mendatang.dart:160` | daftar acara + judul tanggal |
| NavigationBar ≥ 3 tab + IndexedStack | `lib/pages/halaman_utama.dart:174`, `:141` | Mendatang · RSVP Saya · Profil |

### P05

| Poin | File:baris | Keterangan |
|------|-----------|------------|
| Halaman detail via konstruktor | `lib/pages/halaman_utama.dart:95`, `lib/pages/halaman_detail.dart:11` | `HalamanDetail(acara: ...)` lewat `Navigator.push` |
| Form tambah → `Navigator.pop(context, data)` | `lib/pages/halaman_form_acara.dart:86`, `lib/pages/halaman_utama.dart:105` | hasil di-`await` dan langsung tampil di daftar |
| Cek `mounted` setelah await | `lib/pages/halaman_utama.dart:121`, `lib/pages/halaman_form_acara.dart:45` | sebelum memakai `context` |
| ≥ 3 widget test, `flutter test` lulus | `test/widget_test.dart:11` | 7 widget test + 8 unit test, semua lulus |

### P06

| Poin | File:baris | Keterangan |
|------|-----------|------------|
| ColorScheme.fromSeed + darkTheme | `lib/tema.dart:10`, `lib/main.dart:31` | seed merah marun `#B3261E` |
| Warna dari colorScheme | seluruh `lib/` | tidak ada `Colors.xxx`; satu-satunya `Color(...)` adalah warna seed |
| Font kustom | `lib/tema.dart:18` | `google_fonts`: Plus Jakarta Sans |
| Ikon launcher sendiri | `pubspec.yaml:29` | `flutter_launcher_icons`, gambar `assets/icon/ikon.png` |
| Gambar aset lokal | `pubspec.yaml:26`, `lib/pages/halaman_profil.dart:42` | `assets/images/logo.png` di tab Profil |

### P07

| Poin | File:baris | Keterangan |
|------|-----------|------------|
| Server shelf + shelf_router, ≥ 12 item JSON | `server/bin/server.dart:20`, `server/data/acara.json` | 14 acara |
| 3 endpoint GET | `server/bin/server.dart:32`, `:52`, `:39` | `/acara`, `/acara/<id>`, `/acara/mendatang` |
| Paket `http` + `--dart-define=API_URL` | `lib/services/acara_service.dart:9`, `:60` | `String.fromEnvironment('API_URL')` |
| fromJson / toJson + DateTime | `lib/models/acara.dart:30`, `:43` | `DateTime.parse` `:37`, `toIso8601String` `:49` |
| FutureBuilder 3 keadaan | `lib/pages/halaman_mendatang.dart:129` | memuat `:134`, gagal + **Coba lagi** `:137`/`:250`, berhasil |
| Test dengan MockClient | `test/acara_service_test.dart:56` | 5 test layanan API tanpa server |

### Fitur khas tema (Proyek 8)

| Poin | File:baris | Keterangan |
|------|-----------|------------|
| Daftar dikelompokkan per tanggal | `lib/pages/halaman_mendatang.dart:64` | judul "Sabtu, 14 November 2026" di atas grup |
| RSVP + SnackBar "Batalkan" (undo) | `lib/pages/halaman_utama.dart:65` | ikon bookmark di kartu & tombol di detail |
| Acara lewat di bawah, pudar | `lib/pages/halaman_mendatang.dart:70`, `lib/widgets/kartu_acara.dart:47` | bagian "Sudah lewat", `Opacity` 0.45 + label "Selesai" |
| Endpoint `GET /acara/mendatang` | `server/bin/server.dart:39`, `lib/pages/halaman_profil.dart:29` | dipakai untuk statistik "Mendatang" di Profil |

### Nilai tambah

| Poin | File:baris | Keterangan |
|------|-----------|------------|
| POST ke server | `server/bin/server.dart:61`, `lib/pages/halaman_utama.dart:116` | bila server mati, usulan tetap disimpan di memori |
| Pull-to-refresh | `lib/pages/halaman_mendatang.dart:151` | `RefreshIndicator` |
| Animasi Hero | `lib/widgets/kartu_acara.dart:163` | lencana tanggal kartu → detail |
