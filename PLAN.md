# Product Requirements Document (PRD)

# Fem-Psychmonitor
**Aplikasi Monitoring Emosi Wanita Berbasis Speech Emotion Recognition (SER)**

| | |
|---|---|
| Platform | Android (asumsi: Flutter, mengacu pada `DESIGN.md` yang sudah dibuat — beri tahu jika target sebenarnya native Kotlin/Jetpack Compose) |
| Status | Draft v1.0 |
| Tanggal | 22 Juli 2026 |

---

## 1. Ringkasan Produk

Fem-Psychmonitor adalah aplikasi Android yang memantau kondisi emosi harian wanita melalui **Speech Emotion Recognition (SER)** dari rekaman suara. Setiap rekaman diklasifikasikan ke dalam salah satu dari **6 emosi**: Marah, Sedih, Bahagia, Jijik, Takut, dan Netral. Hasil deteksi ini diakumulasikan menjadi **skor kesehatan mental** yang naik-turun seiring waktu, dilengkapi dengan asesmen kesehatan mental awal dan profil kepribadian OCEAN (Big Five) untuk memberi saran yang lebih personal.

Aplikasi dirancang **offline-first**: bisa dipakai sepenuhnya tanpa internet (mode Guest, data lokal) maupun dengan akun (mode User, data hybrid lokal+cloud).

## 2. Tujuan Produk

- Memberi wanita cara pasif dan rendah-friksi untuk memantau kondisi emosinya lewat suara, bukan input manual mood-tracker.
- Menyediakan indikator kesehatan mental yang berkembang dari waktu ke waktu, bukan snapshot sesaat.
- Mendeteksi pola berisiko lebih awal dan mengarahkan pengguna ke bantuan profesional saat dibutuhkan.
- Tetap dapat diandalkan tanpa koneksi internet, dengan sinkronisasi yang aman ketika online.
## 3. Target Pengguna

- Wanita dewasa yang ingin memantau kesehatan emosinya secara rutin.
- Pengguna yang baru ingin mencoba tanpa komitmen akun (Guest).
- Pengguna dengan riwayat kerentanan psikologis yang butuh sinyal dini dan jalur ke bantuan profesional.
> **Catatan penting:** aplikasi ini adalah alat *monitoring* dan *dukungan awal*, bukan alat diagnosis klinis. Seluruh salinan (copy) yang menyinggung skor kesehatan mental, hasil asesmen, atau notifikasi "butuh bantuan" sebaiknya direview oleh psikolog klinis sebelum rilis — ini dicatat sebagai *open question* di §14.

## 4. Ruang Lingkup

**Termasuk (in-scope):** autentikasi dasar, mode guest, asesmen awal, perekaman & deteksi emosi, riwayat & kalender, jurnal statistik, skor kesehatan mental, saran berbasis skor+OCEAN, sinkronisasi hybrid, onboarding, pengaturan.

**Di luar lingkup v1 (out-of-scope, dicatat sebagai kandidat fase berikutnya):** konsultasi psikolog in-app (chat/video call), integrasi wearable, mode multi-bahasa penuh (selain switch bahasa UI), model SER kustom per-pengguna (personalization/fine-tuning).

## 5. Istilah Kunci

| Istilah | Definisi |
|---|---|
| SER | Speech Emotion Recognition — model yang mengklasifikasikan emosi dari audio suara |
| 6 Emosi | Marah, Sedih, Bahagia, Jijik, Takut, Netral |
| Skor Kesehatan Mental | Nilai kumulatif (disarankan skala 0–100) yang naik/turun berdasarkan hasil deteksi emosi |
| OCEAN | Model kepribadian Big Five: Openness, Conscientiousness, Extraversion, Agreeableness, Neuroticism |
| Guest | Pengguna tanpa akun; seluruh data hanya tersimpan lokal di perangkat |
| User | Pengguna dengan akun (email+password); data tersimpan lokal **dan** cloud, disinkron dengan strategi *last-write-wins* |
| Rentan | Kondisi ketika sistem mendeteksi indikasi risiko psikologis berdasarkan skor/pola emosi, memicu ajakan mencari bantuan |

## 6. Mode Pengguna: Guest vs User (FR-02)

| Aspek | Guest | User (login) |
|---|---|---|
| Penyimpanan | Lokal saja (on-device DB, mis. SQLite/Drift/Isar) | Hybrid — lokal + cloud |
| Sinkronisasi | Tidak ada | Ya, otomatis saat online |
| Konflik data | Tidak relevan | **Last-write-wins**: setiap record punya `updated_at`; saat sync, record dengan `updated_at` terbaru menang dan menimpa versi lain, baik lokal maupun cloud |
| Akses halaman Profile | ❌ tidak bisa (FR-24) | ✅ bisa |
| Reset password | ❌ tidak relevan | ✅ tersedia di Settings |
| Upgrade jalur | Guest → Register memindahkan seluruh data lokal ke akun baru (one-time migration saat register) | — |

**Trigger sinkronisasi:** saat app dibuka (foreground), saat koneksi kembali online (connectivity listener), dan manual (pull-to-refresh di Discover/Home). Setiap entity (Recording, JournalNote, ScoreHistory, Assessment) disinkron independen per-record, bukan per-batch penuh, supaya konflik last-write-wins granular per item.

## 7. Autentikasi & Sesi (FR-03, FR-05, FR-06, FR-07)

- **FR-03 — Login**: email + password. Validasi format email, error state jelas untuk kredensial salah/tidak ada koneksi.
- **FR-05 — Logout**: menghapus sesi/token lokal; data lokal *tidak* dihapus (agar bisa dipakai lagi offline setelah login ulang, dan tetap tersinkron saat login ulang).
- **FR-06 — Hapus data / reset aplikasi**: tersedia untuk Guest **dan** User. Menghapus seluruh data lokal: skor, riwayat rekaman, jurnal, catatan, hasil asesmen. Untuk User, ini adalah **reset device-local** — perlu diklarifikasikan (lihat §14) apakah juga menghapus data di cloud atau hanya lokal. Wajib dialog konfirmasi 2-langkah ("Anda yakin?" → ketik "HAPUS" atau tahan tombol 3 detik) karena ini destruktif dan tidak bisa dibatalkan.
- **FR-07 — Register + force assessment**: setelah register berhasil, cek flag `has_completed_assessment`. Jika belum, user **wajib** diarahkan ke alur asesmen awal sebelum bisa mengakses halaman lain manapun (termasuk Home) — tidak bisa di-skip atau di-back.
## 8. Onboarding & Splash (FR-22, FR-23)

- **FR-22 — Splash Screen**: logo + nama aplikasi, durasi singkat (~1.5–2 detik) sambil app melakukan init (cek sesi, cek status asesmen, cek koneksi).
- **FR-23 — Onboarding 3 slide**: ditampilkan hanya di first-launch (flag lokal `has_seen_onboarding`). Tiga slide, masing-masing menjelaskan satu pilar fitur:
  1. **Rekam & Deteksi** — cukup bicara, aplikasi mendeteksi 6 emosi secara otomatis.
  2. **Skor Kesehatan Mental** — pantau skor yang berkembang dari waktu ke waktu, berbasis hasil deteksi nyata.
  3. **Kalender & Jurnal** — lihat pola emosi harian, mingguan, sampai tahunan dalam satu tempat.
  - Kontrol: swipe/dot indicator, tombol "Lewati" di slide 1–2, tombol "Mulai" di slide 3 → lanjut ke Auth Landing (Login/Register/Guest).
## 9. Screening Awal / Asesmen (FR-04)

Wajib untuk **Guest maupun User** sebelum mengakses fitur inti. Terdiri dari dua bagian berurutan:

1. **Asesmen kesehatan mental** (mis. berbasis instrumen tervalidasi seperti DASS-21 atau SRQ-20 — pemilihan instrumen final perlu masukan psikolog, lihat §14).
2. **Asesmen OCEAN** (Big Five) — instrumen ringkas (mis. BFI-10/BFI-44 versi pendek untuk mengurangi drop-off).
Hasil kedua asesmen menghasilkan:
- `initial_mental_score` (skor awal, basis perhitungan skor berjalan selanjutnya)
- `ocean_profile` (5 skor trait, disimpan permanen, dipakai untuk mesin saran FR-18/FR-19)
Asesmen tidak bisa di-skip. Progress asesmen disimpan sementara (draft) jika app ditutup di tengah jalan, agar user tidak perlu mengulang dari awal.

## 10. Home (FR-08, FR-19)

Home menampilkan (top-to-bottom):
1. **Ucapan selamat datang + hari** — mis. "Selamat pagi, Aya — Rabu, 22 Juli"
2. **Kartu Skor Kesehatan Mental** — nilai terkini + tren singkat (naik/turun vs kemarin/minggu lalu)
3. **Jumlah rekaman hari ini** — counter
4. **Login streak + rekaman streak** — dua metrik terpisah: berapa hari berturut-turut user membuka app, dan berapa hari berturut-turut user merekam minimal 1x
5. **Jumlah rekaman berhasil positif** — total rekaman dengan hasil emosi "positif" (Bahagia; jika Netral dianggap netral bukan positif — perlu konfirmasi definisi "positif" di §14)
6. **Kartu Saran (FR-19)** — 1 saran singkat berbasis kombinasi skor terkini + profil OCEAN (lihat §13.3)
## 11. Discover — Kalender (FR-09, FR-10, FR-11)

- **FR-09**: halaman Discover berisi dua sub-bagian: Kalender dan Rangkuman Jurnal (lihat §12).
- **FR-10 — Emoji per tanggal**: kalender bulan berjalan menampilkan default ke bulan & tanggal hari ini. Setiap tanggal yang punya ≥1 rekaman menampilkan 1 emoji/vector yang mewakili **emosi dengan jumlah deteksi terbanyak** pada hari itu.
  - Contoh: 10 rekaman pada tanggal X → 6 Bahagia, 2 Sedih, 2 Netral → tanggal X menampilkan emoji Bahagia.
  - Tie-breaking: jika ada 2 emosi dengan jumlah sama-sama tertinggi, prioritaskan berdasarkan urutan keparahan (emosi negatif lebih diprioritaskan ditampilkan agar tidak menyamarkan sinyal risiko) — mis. urutan prioritas Marah > Takut > Sedih > Jijik > Netral > Bahagia saat terjadi seri. *(Aturan tie-break ini asumsi produk, perlu dikonfirmasi.)*
- **FR-11 — Klik tanggal → daftar rekaman → detail**: tap tanggal membuka bottom sheet/halaman berisi list seluruh rekaman hari itu (waktu, emoji emosi, durasi singkat). Tap item rekaman → buka Detail Riwayat Rekaman (§13).
## 12. Discover — Jurnal (FR-09, FR-21)

Rangkuman jurnal menampilkan:
1. **Pergerakan skor emosi** — line chart skor kesehatan mental dari waktu ke waktu.
2. **Statistik keseluruhan emosi** — total & persentase tiap 6 emosi sepanjang riwayat (atau dalam rentang yang dipilih).
3. **Distribusi emosi per rentang waktu**, dengan granularitas bar chart yang berbeda per rentang:
| Rentang | Jumlah bar | Granularitas per bar |
|---|---|---|
| 7 hari | 7 bar | 1 bar / hari |
| 1 bulan | 4 bar | 1 bar / minggu |
| 6 bulan | 6 bar | 1 bar / bulan |
| 1 tahun | 12 bar | 1 bar / bulan |

- Setiap bar adalah **stacked bar** (6 emosi ditumpuk dalam 1 bar per periode), menggunakan Emotion Color System (lihat `DESIGN.md`).
- Tap/hover pada bar menampilkan tooltip/detail popup: jumlah rekaman per emosi pada periode tersebut.
## 13. Riwayat Rekaman & Detail (FR-12, FR-13, FR-15, FR-16, FR-17, FR-18, FR-20)

Halaman detail satu rekaman menampilkan:
- Hasil emosi terdeteksi (+ ikon warna sesuai Emotion Color System)
- **FR-12 — Akurasi model** (lihat rumus §13.1)
- **FR-15 — Chart distribusi emosi** untuk rekaman ini (donut/bar 6 kelas, dari rata-rata per-segmen)
- **FR-16 — Catatan pribadi** — text field, tersimpan per rekaman
- **FR-18 — Saran berbasis skor + OCEAN** — sama seperti mesin saran di Home tapi dikontekskan ke hasil rekaman ini
- **FR-17 — Banner "Butuh Bantuan"** jika rekaman ini (atau pola terbaru) memicu kondisi rentan (lihat §13.4)
- **FR-13 — Tombol Koreksi** hasil model (lihat aturan §13.2), hanya aktif ≤24 jam sejak rekaman dibuat
- **FR-20 — Tombol "Retake Recording"** (rekam ulang, membuat entry baru, entry lama tetap ada kecuali dihapus manual) dan **tombol "Hapus Rekaman Ini"** (hard delete entry ini, dengan konfirmasi)
### 13.1 Rumus Akurasi Model (FR-12)

Model SER mengevaluasi rekaman dalam beberapa **segmen/window** (mis. tiap 1–2 detik). Setiap segmen menghasilkan skor probabilitas untuk keenam emosi. Akurasi dihitung sebagai **rata-rata per-emosi di seluruh segmen**, dengan pembagi (N) yang **sama untuk semua emosi** — walaupun suatu emosi mendapat 0% di sebagian besar segmen, ia tetap dibagi dengan N total segmen, bukan hanya segmen di mana ia terdeteksi >0%. Emosi final = emosi dengan rata-rata tertinggi; **akurasi yang ditampilkan = nilai rata-rata tertinggi tersebut.**

**Contoh** (3 segmen, 6 emosi):

| Segmen | Marah | Sedih | Bahagia | Jijik | Takut | Netral |
|---|---|---|---|---|---|---|
| 1 | 5% | 10% | 70% | 0% | 5% | 10% |
| 2 | 0% | 5% | 80% | 0% | 0% | 15% |
| 3 | 10% | 5% | 65% | 5% | 5% | 10% |
| **Rata-rata (÷3)** | 5% | 6.7% | **71.7%** | 1.7% | 3.3% | 11.7% |

→ Emosi final: **Bahagia**, Akurasi model ditampilkan: **71.7%**.

### 13.2 Rumus Penambahan Skor (FR-14)

```
Kondisi normal (belum dikoreksi):
  Δ skor = Akurasi Model (%) × Base Score Emosi

Setelah dikoreksi user:
  Δ skor = 70% × Base Score Emosi (dari label emosi hasil koreksi)
```

Koreksi hanya bisa dilakukan **≤24 jam** setelah waktu rekaman (FR-13). Setelah itu tombol Koreksi disembunyikan/nonaktif, dengan helper text singkat menjelaskan batas waktunya.

**Base Score Emosi** — contoh nilai awal (⚠️ **placeholder, wajib divalidasi oleh psikolog klinis sebelum rilis** — bobot ini secara langsung membentuk skor kesehatan mental pengguna):

| Emosi | Base Score (contoh) |
|---|---|
| Bahagia | +8 |
| Netral | +2 |
| Jijik | −4 |
| Sedih | −5 |
| Takut | −6 |
| Marah | −8 |

Skor kesehatan mental disarankan pada skala **0–100**, dengan hasil `Δ` di-clamp agar skor tidak keluar dari rentang tersebut. `initial_mental_score` dari asesmen awal (§9) menjadi titik mulai.

### 13.3 Mesin Saran Berbasis Skor + OCEAN (FR-18, FR-19)

Pendekatan rule-based sederhana: kombinasikan **band skor** (mis. Sehat ≥70, Cukup Sehat 40–69, Perlu Perhatian 20–39, Rentan <20) dengan **trait OCEAN yang menonjol** untuk memilih 1 dari beberapa saran yang telah disiapkan per kombinasi. Contoh:

| Band Skor | Trait Menonjol | Contoh Saran |
|---|---|---|
| Perlu Perhatian | Neuroticism tinggi | "Coba teknik pernapasan 4-7-8 selama 2 menit sebelum tidur." |
| Perlu Perhatian | Extraversion rendah | "Hubungi satu teman dekat hari ini, sekadar menyapa." |
| Sehat | Conscientiousness tinggi | "Pertahankan rutinitasmu — konsistensi ini yang membuat skor stabil." |

Isi/konten saran final **perlu ditulis bersama psikolog** — bukan sekadar copy generik, karena menyentuh kesehatan mental pengguna secara langsung.

### 13.4 Deteksi Rentan & "Butuh Bantuan" (FR-17)

Trigger contoh (perlu divalidasi klinis, lihat §14):
- Skor kesehatan mental jatuh di bawah ambang tertentu (mis. <20), **atau**
- Emosi negatif (Marah/Sedih/Takut/Jijik) terdeteksi dominan pada mayoritas rekaman dalam window bergulir (mis. ≥5 dari 7 rekaman terakhir), **atau**
- Hasil asesmen awal menempatkan user pada kategori risiko tinggi.
Ketika terpicu, tampilkan **kartu/banner non-blocking** (bukan modal paksa — hindari kesan menghakimi) berjudul "Kamu tidak sendirian" dengan jalur bantuan nyata, bukan sekadar teks generik:

- **Healing119.id** — layanan hotline kesehatan jiwa Kemenkes RI, gratis, 24 jam, bekerja sama dengan Ikatan Psikolog Klinis Indonesia (IPK Indonesia); bisa lewat telepon **119 ekstensi 8** atau chat di healing119.id.<cite index="1-1,2-1">Kementerian Kesehatan menghadirkan Healing119.id, layanan hotline kesehatan mental berbasis daring yang dapat diakses 24 jam, dan sejak 31 Juli 2025 Kemenkes RI resmi mengaktifkan kembali layanan ini bekerja sama dengan IPK Indonesia sebagai saluran darurat bagi masyarakat yang mengalami krisis mental.</cite>
- **Halo Kemenkes** — <cite index="7-1">bisa dihubungi di nomor 1500 567, atau lewat WhatsApp di +62 812-6050-0567</cite>.
- Rujukan ke **psikolog/psikiater terdekat** (Puskesmas/RS Jiwa) — <cite index="4-1">Kemenkes merekomendasikan warga yang butuh bantuan kejiwaan untuk langsung menghubungi profesional kesehatan jiwa di Puskesmas atau Rumah Sakit terdekat</cite>.
- Untuk kondisi darurat mengancam nyawa: nomor darurat **119**.
Data/nomor di atas perlu di-*refresh* saat implementasi (layanan pemerintah bisa berubah); jangan hardcode tanpa recheck menjelang rilis.

## 14. Profile (FR-24)

Hanya dapat diakses oleh **User** (login). Guest yang mencoba mengakses menu ini diarahkan ke prompt "Buat akun untuk membuka Profile" dengan CTA ke Register. Berisi minimal: nama, email, ringkasan skor, ringkasan OCEAN, tombol edit profil dasar.

## 15. Settings (FR-25)

Menu dikelompokkan (grouped list), contoh struktur:

**Akun**
- Reset Password *(User only)*
- Logout
**Data**
- Hapus Data Aplikasi (reset total)
**Preferensi**
- Ganti Bahasa
- Ganti Tema (Light/Dark — mengacu ke `DESIGN.md`)
**Bantuan & Informasi**
- Panduan Aplikasi
- Lisensi
## 16. Model Data (Ringkas)

| Entity | Field kunci |
|---|---|
| `User` | id, email, password_hash, created_at, is_guest |
| `Assessment` | user_id, type (mental_health / ocean), answers, result_score/profile, completed_at |
| `Recording` | id, user_id, created_at, audio_ref, segments[] (per-segmen probabilitas 6 emosi), final_emotion, accuracy, is_corrected, corrected_emotion, note, updated_at (untuk last-write-wins) |
| `ScoreHistory` | id, user_id, recording_id, delta, resulting_score, created_at |
| `JournalAggregate` | (computed/cached) per hari/minggu/bulan, count per emosi |
| `Settings` | user_id, theme, language |

Semua entity User-owned membawa `updated_at` untuk mendukung sinkronisasi last-write-wins per §6.

## 17. Kebutuhan Non-Fungsional

- **Offline-first**: seluruh fitur inti (rekam, lihat riwayat, kalender, jurnal, skor) berfungsi penuh tanpa internet untuk Guest maupun User; hanya sinkronisasi cloud yang butuh koneksi.
- **Privasi & keamanan**: data kesehatan mental adalah data pribadi yang sangat sensitif (termasuk kategori data sensitif menurut UU PDP). Audio rekaman idealnya diproses on-device (model SER lokal) atau, jika perlu cloud inference, dienkripsi in-transit dan tidak disimpan lebih lama dari kebutuhan pemrosesan. Password di-hash (bukan disimpan plaintext), DB lokal sebaiknya dienkripsi (mis. SQLCipher).
- **Performa**: klasifikasi SER pada rekaman singkat (≤30 detik) idealnya selesai dalam hitungan detik agar tidak terasa seperti "menunggu".
- **Aksesibilitas**: kontras warna & ukuran teks mengikuti `DESIGN.md` (WCAG AA), target teks minimum 14sp untuk body.
- **Lokalisasi**: minimal Bahasa Indonesia sebagai default; struktur string sudah disiapkan untuk Bahasa Inggris via switch bahasa (FR-25).
## 18. Metrik Keberhasilan (contoh)

- Retensi 7-hari & 30-hari pengguna terdaftar
- Rata-rata rekaman per pengguna aktif per minggu (rekaman streak)
- Rasio Guest → Register (konversi)
- Tingkat penggunaan tombol "Koreksi" (indikator akurasi model yang dirasakan user)
- Tingkat klik pada banner "Butuh Bantuan" ke salah satu jalur bantuan
## 19. Risiko & Pertanyaan Terbuka

1. **Base Score Emosi & ambang "rentan" (§13.2, §13.4) adalah placeholder** — perlu divalidasi bersama psikolog klinis sebelum dipakai pada pengguna nyata.
2. Definisi "rekaman berhasil positif" (FR-08) — apakah Netral dihitung positif atau hanya Bahagia?
3. Aturan tie-break emoji kalender (FR-10) saat 2 emosi seri jumlahnya — perlu konfirmasi.
4. FR-06 (hapus data) untuk User — apakah menghapus juga salinan cloud, atau hanya device lokal?
5. Instrumen asesmen final (DASS-21/SRQ-20/PHQ-9, dsb.) dan instrumen OCEAN (BFI-10/44) belum ditentukan — pemilihan berdampak ke desain form & skor awal.
6. Target platform aktual: dokumen ini dan `DESIGN.md` mengasumsikan Flutter (mengikuti diskusi sebelumnya) — konfirmasi jika ternyata native Android.
7. Model SER: on-device (mis. TFLite dari arsitektur CNN-KAN yang sudah kamu kembangkan) vs. cloud inference — berdampak besar ke §17 (privasi & performa).


## 20. SER

- [ ] `female_model.tflite` sudah dikonversi dari `final_female_model.keras`
      (cek apakah butuh Flex delegate karena ada LSTM/MultiHeadAttention/LayerNormalization)
- [ ] `norm_female_model.json` (berisi `mean` dan `std`, masing-masing 121 nilai)
      sudah digenerate dari notebook training dan disertakan sebagai **asset** Flutter
- [ ] Pastikan urutan langkah preprocessing **tidak dibalik** — urutan adalah bagian dari kontrak, bukan opsional

```dart
// ── Audio processing ──
const int SR = 16000;              // target sample rate (Hz)
const double DURATION = 3.0;       // durasi fix audio (detik)
const int TARGET_LENGTH = 48000;   // = (DURATION * SR).toInt()

// ── MFCC extraction ──
const int N_MFCC = 40;             // jumlah koefisien MFCC
const int N_FFT = 2048;            // ukuran FFT window
const int HOP_LENGTH = 512;        // hop length (dipakai sama untuk MFCC & ZCR)
const double FMAX = SR / 2;        // = 8000 Hz (Nyquist)

// ── ZCR (Zero Crossing Rate) ──
const int ZCR_FRAME_LENGTH = 2048; // sama dengan N_FFT
const int ZCR_HOP_LENGTH = 512;    // sama dengan HOP_LENGTH

// ── Feature stacking ──
// Urutan wajib: [MFCC, delta(MFCC), delta2(MFCC), ZCR]
const int N_FEATURES = N_MFCC * 3 + 1;  // = 121 (dimensi fitur per frame)

// ── Padding waktu ──
const int MAX_PAD_LEN = 128;       // jumlah frame tetap (time steps)

// ── Shape input akhir ke model ──
// INPUT_SHAPE = (1, MAX_PAD_LEN, N_FEATURES) = (1, 128, 121)

// ── Label mapping (urutan index output softmax) ──
const Map<int, String> emotionMap = {
  0: 'happy',
  1: 'sad',
  2: 'angry',
  3: 'fearful',
  4: 'disgust',
  5: 'neutral',
};
```

**Sumber statistik normalisasi global** (wajib di-load dari `models/norm_female_model.json`,
BUKAN di-hardcode karena nilainya spesifik hasil training):

```json
{
  "mean": [ /* 121 nilai float */ ],
  "std":  [ /* 121 nilai float */ ],
  "n_features": 121
}
```

---

## Pipeline Preprocessing — Urutan Wajib

Input: file/stream audio mentah.
Output: tensor `(1, 128, 121)` siap masuk ke `Interpreter.run()`.

### Step 1 — Load Audio
- Decode audio ke PCM float (rentang umumnya sudah [-1, 1] tergantung decoder).

### Step 2 — Noise Reduction *(opsional, trade-off)*
- Training memakai `noisereduce.reduce_noise(stationary=True)`.
- Di Dart tidak ada equivalent langsung. Opsi:
  - Skip langkah ini (paling umum dilakukan, terima sedikit train/inference mismatch), **atau**
  - Cari/porting algoritma noise reduction stationary yang setara.
- **Keputusan harus konsisten** — jangan diterapkan di sebagian sample dan tidak di sebagian lain.

### Step 3 — Resample ke `SR` (16000 Hz)
- Jika sample rate asli ≠ 16000, resample ke 16000 Hz.

### Step 4 — Fix Durasi ke `TARGET_LENGTH` (48000 sample)
- Jika `len(audio) > 48000` → potong ke 48000 sample pertama.
- Jika `len(audio) < 48000` → pad dengan nol (`0.0`) di akhir hingga 48000.

### Step 5 — Peak Normalization
```
audio = audio / max(abs(audio))   // hanya jika max(abs(audio)) > 0
```
- Dilakukan **sebelum** ekstraksi MFCC, bukan sesudah.

### Step 6 — Ekstraksi Fitur (MFCC + Delta + Delta2 + ZCR)
1. Hitung MFCC: `n_mfcc=40, n_fft=2048, hop_length=512, fmax=8000`
2. Hitung Delta MFCC (order 1) dari MFCC di atas
3. Hitung Delta2 MFCC (order 2) dari MFCC di atas
4. Hitung Zero Crossing Rate: `frame_length=2048, hop_length=512`
5. Gabungkan (concat) sepanjang axis fitur, **urutan wajib**:
   ```
   features = concat([mfcc.T, mfcc_delta.T, mfcc_delta2.T, zcr.T], axis=1)
   ```
   Shape sementara: `(n_frame, 121)` di mana `n_frame` tergantung panjang audio.

### Step 7 — Pad/Truncate Time Axis ke `MAX_PAD_LEN` (128 frame)
- Jika `n_frame > 128` → potong ke 128 frame pertama.
- Jika `n_frame < 128` → pad dengan nol di baris tambahan hingga 128.
- Shape akhir: `(128, 121)`.

### Step 8 — Normalisasi Z-score Per-Kolom, Per-Sample
Untuk setiap kolom fitur `i` (dari 121 kolom), hitung mean & std **dari 128 frame kolom itu sendiri** (bukan global):
```
for i in 0..<121:
  std_i = std(features[:, i])
  if std_i > 0:
    features[:, i] = (features[:, i] - mean(features[:, i])) / std_i
```

### Step 9 — Normalisasi Global (Dataset-level)
Menggunakan `mean`/`std` dari `norm_female_model.json` (121 nilai masing-masing):
```
features = (features - mean_female) / std_female
```
- **Wajib dijalankan setelah Step 8**, bukan menggantikannya.

### Step 10 — Reshape ke Tensor Input Model
```
input_tensor shape = (1, 128, 121)   // batch dimension = 1
```

### Step 11 — Jalankan Inferensi TFLite
```dart
interpreter.run(inputTensor, outputTensor);
// outputTensor shape: (1, 6) → softmax probabilities
```

### Step 12 — Mapping Output ke Label Emosi
```dart
int predictedIndex = argmax(outputTensor[0]);
String predictedEmotion = emotionMap[predictedIndex]!;
```

---

## File dan asset pendukungnya
1. Logo : ![Logo](assets/logo-transparant.png)
2.

## Assesment file
1. Pertanyaan asesment kesehatan mental ada di file [assesment kesehatan mental](assets/questions/psych.json), kemudian untuk untuk pertanyaan Big Five OCEAN ADA DI BAWAH INI
2. Pertanyaan OCEAN Ada di [OCEAN ASSESMENT](assets/questions/ocean.json) dan [Saran Berdasarkan OCEAN](assets/questions/saran_ocean.json)

### Kode Dimensi OCEAN
  | No | Dimensi (Kode) | Nama Dimensi                       | Arah Skoring (keyed) | Pernyataan                                                                         | Catatan Skoring                      |
|----|----------------|------------------------------------|----------------------|------------------------------------------------------------------------------------|--------------------------------------|
| 1  | E              | Extraversion (Ekstraversi)         | Positif (+)          | Saya adalah sosok yang menghidupkan suasana dalam sebuah pesta atau kumpul-kumpul. | Skor langsung (1=STS ... 5=SS)       |
| 2  | A              | Agreeableness (Keramahan)          | Positif (+)          | Saya mudah berempati dengan apa yang dirasakan orang lain.                         | Skor langsung (1=STS ... 5=SS)       |
| 3  | C              | Conscientiousness (Kehati-hatian)  | Positif (+)          | Saya langsung menyelesaikan tugas atau pekerjaan rumah begitu ada kesempatan.      | Skor langsung (1=STS ... 5=SS)       |
| 4  | N              | Neuroticism (Neurotisisme)         | Positif (+)          | Suasana hati saya sering berubah-ubah.                                             | Skor langsung (1=STS ... 5=SS)       |
| 5  | O              | Openness / Intellect (Keterbukaan) | Positif (+)          | Saya memiliki imajinasi yang hidup.                                                | Skor langsung (1=STS ... 5=SS)       |
| 6  | E              | Extraversion (Ekstraversi)         | Negatif (-)          | Saya cenderung tidak banyak bicara.                                                | Skor dibalik (1<->5, 2<->4, 3 tetap) |
| 7  | A              | Agreeableness (Keramahan)          | Negatif (-)          | Saya tidak terlalu peduli dengan masalah yang dihadapi orang lain.                 | Skor dibalik (1<->5, 2<->4, 3 tetap) |
| 8  | C              | Conscientiousness (Kehati-hatian)  | Negatif (-)          | Saya sering lupa mengembalikan barang ke tempat asalnya.                           | Skor dibalik (1<->5, 2<->4, 3 tetap) |
| 9  | N              | Neuroticism (Neurotisisme)         | Negatif (-)          | Saya cenderung merasa tenang hampir sepanjang waktu.                               | Skor dibalik (1<->5, 2<->4, 3 tetap) |
| 10 | O              | Openness / Intellect (Keterbukaan) | Negatif (-)          | Saya tidak tertarik dengan ide-ide yang abstrak.                                   | Skor dibalik (1<->5, 2<->4, 3 tetap) |
| 11 | E              | Extraversion (Ekstraversi)         | Positif (+)          | Saya senang mengobrol dengan banyak orang berbeda saat menghadiri acara.           | Skor langsung (1=STS ... 5=SS)       |
| 12 | A              | Agreeableness (Keramahan)          | Positif (+)          | Saya bisa merasakan emosi yang sedang dirasakan orang lain.                        | Skor langsung (1=STS ... 5=SS)       |
| 13 | C              | Conscientiousness (Kehati-hatian)  | Positif (+)          | Saya menyukai keteraturan dalam segala hal.                                        | Skor langsung (1=STS ... 5=SS)       |
| 14 | N              | Neuroticism (Neurotisisme)         | Positif (+)          | Saya mudah merasa kesal atau marah.                                                | Skor langsung (1=STS ... 5=SS)       |
| 15 | O              | Openness / Intellect (Keterbukaan) | Negatif (-)          | Saya kesulitan memahami ide-ide yang abstrak.                                      | Skor dibalik (1<->5, 2<->4, 3 tetap) |
| 16 | E              | Extraversion (Ekstraversi)         | Negatif (-)          | Saya lebih suka berada di belakang layar daripada tampil di depan.                 | Skor dibalik (1<->5, 2<->4, 3 tetap) |
| 17 | A              | Agreeableness (Keramahan)          | Negatif (-)          | Sebenarnya saya tidak terlalu tertarik pada orang lain.                            | Skor dibalik (1<->5, 2<->4, 3 tetap) |
| 18 | C              | Conscientiousness (Kehati-hatian)  | Negatif (-)          | Saya cenderung membuat kekacauan dalam mengerjakan sesuatu.                        | Skor dibalik (1<->5, 2<->4, 3 tetap) |
| 19 | N              | Neuroticism (Neurotisisme)         | Negatif (-)          | Saya jarang merasa sedih atau murung.                                              | Skor dibalik (1<->5, 2<->4, 3 tetap) |
| 20 | O              | Openness / Intellect (Keterbukaan) | Negatif (-)          | Saya merasa daya imajinasi saya kurang berkembang.                                 | Skor dibalik (1<->5, 2<->4, 3 tetap) |


Skala Jawaban
- 1:	Sangat Tidak Sesuai
- 2:	Tidak Sesuai
- 3:	Netral / Ragu-ragu
- 4:	Sesuai
- 5:	Sangat Sesuai

Ambang Batas Interpretasi Skor Trait (skala 1.00–5.00)
| Kategori | Rentang Skor | Keterangan                                                                     |
|----------|--------------|--------------------------------------------------------------------------------|
| Rendah   | 1.00 – 2.79  | Trait cenderung rendah                                                         |
| Netral   | 2.80 – 3.20  | Trait tidak dominan ke arah mana pun (margin kesalahan pengukuran diakomodasi) |
| Tinggi   | 3.21 – 5.00  | Trait cenderung tinggi                                                         |


Tabel Saran — Basis Data Rekomendasi Big Five + Emosi
5 trait x 2 level (Tinggi/Rendah) x 6 emosi x 5 saran = 300 baris saran

### Logika Sistem — Lapisan Keselamatan & Aturan Tampilan Saran
semua trait non-netral ditampilkan (maks 2 saran/trait); lapisan keselamatan kini juga dipicu oleh skor kesehatan mental.
|  |                                                                                                                   |                                                                                                                                                                                                                                 |   |
|----------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---|
|                                                                                                                                                    |                                                                                                                   |                                                                                                                                                                                                                                 |   |
| A. Kelas Skor Kesehatan Mental (skala 0-100)                                                                                                       |                                                                                                                   |                                                                                                                                                                                                                                 |   |
| Kelas                                                                                                                                              | Rentang Skor                                                                                                      | Memicu Lapisan Keselamatan?                                                                                                                                                                                                     |   |
| Butuh Perhatian                                                                                                                                    | 0 - 25                                                                                                            | YA — tampilkan rujukan Sejiwa                                                                                                                                                                                                   |   |
| Rentan                                                                                                                                             | 26 - 50                                                                                                           | Tidak                                                                                                                                                                                                                           |   |
| Cukup Sehat                                                                                                                                        | 51 - 75                                                                                                           | Tidak                                                                                                                                                                                                                           |   |
| Sehat                                                                                                                                              | 76 - 100                                                                                                          | Tidak                                                                                                                                                                                                                           |   |
|                                                                                                                                                    |                                                                                                                   |                                                                                                                                                                                                                                 |   |
|                                                                                                                                                    |                                                                                                                   |                                                                                                                                                                                                                                 |   |
| B. Seluruh Kondisi Pemicu Lapisan Keselamatan                                                                                                      |                                                                                                                   |                                                                                                                                                                                                                                 |   |
| ID Kondisi                                                                                                                                         | Kondisi                                                                                                           | Penjelasan                                                                                                                                                                                                                      |   |
| krisis_eksplisit                                                                                                                                   | input.indikasiKrisis == true                                                                                      | Ada indikasi keinginan menyakiti diri sendiri atau orang lain, eksplisit maupun tersirat.                                                                                                                                       |   |
| distres_berkepanjangan                                                                                                                             | input.emosi IN lapisan_keselamatan.emosi_negatif AND input.intensitas == 'Kuat' AND input.berlangsungLama == true | Emosi negatif dengan intensitas kuat yang berlangsung lama/berulang, bukan sesaat.                                                                                                                                              |   |
| skor_mental_butuh_perhatian                                                                                                                        | input.skorMental <= 25  (setara dengan: kelas skor mental == 'Butuh Perhatian')                                   | Skor dari instrumen skrining kesehatan mental terpisah berada pada kelas 'Butuh Perhatian' (0-25 dari skala 0-100). Kondisi ini berdiri sendiri - berlaku terlepas dari skor Big Five, jenis emosi, intensitas, atau durasinya. |   |
|                                                                                                                                                    |                                                                                                                   |                                                                                                                                                                                                                                 |   |
| Tindakan yang ditampilkan jika lapisan keselamatan terpicu:                                                                                        |                                                                                                                   |                                                                                                                                                                                                                                 |   |
| - Hubungi Sejiwa (layanan bantuan psikologis) di 119 ekstensi 8 — tersedia 24 jam.                                                                 |                                                                                                                   |                                                                                                                                                                                                                                 |   |
| - Jika ada bahaya langsung terhadap keselamatan, segera hubungi layanan darurat setempat (110/118).                                                |                                                                                                                   |                                                                                                                                                                                                                                 |   |
| - Cari satu orang yang kamu percaya untuk menemani sampai bantuan profesional tersedia.                                                            |                                                                                                                   |                                                                                                                                                                                                                                 |   |
|                                                                                                                                                    |                                                                                                                   |                                                                                                                                                                                                                                 |   |
|                                                                                                                                                    |                                                                                                                   |                                                                                                                                                                                                                                 |   |
| C. Aturan Tampilan Saran (v3) — Jika Lapisan Keselamatan TIDAK Terpicu                                                                             |                                                                                                                   |                                                                                                                                                                                                                                 |   |
| 1. Hitung deviasi tiap trait dari titik tengah 3.0 (deviasi = ABS(skor - 3.0)).                                                                    |                                                                                                                   |                                                                                                                                                                                                                                 |   |
| 2. Saring trait yang berada DI LUAR zona Netral (2.80-3.20) -> trait_ditampilkan.                                                                  |                                                                                                                   |                                                                                                                                                                                                                                 |   |
| 3. Jika trait_ditampilkan kosong (semua trait netral) -> pakai saran_default_netral, berhenti.                                                     |                                                                                                                   |                                                                                                                                                                                                                                 |   |
| 4. SEMUA trait pada trait_ditampilkan disertakan (TIDAK dibatasi 2 trait seperti v2), diurutkan dari deviasi terbesar ke terkecil.                 |                                                                                                                   |                                                                                                                                                                                                                                 |   |
| 5. Tiap trait ditampilkan MAKSIMAL 2 saran (index ke-1 dan ke-2) sesuai level (Tinggi/Rendah) dan emosi pengguna.                                  |                                                                                                                   |                                                                                                                                                                                                                                 |   |
| 6. Total saran yang tampil = (maks 2) x (jumlah trait non-netral); rentang realistis 2 - 10 saran.                                                 |                                                                                                                   |                                                                                                                                                                                                                                 |   |
