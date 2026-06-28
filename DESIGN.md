--- 
name: FemMonitor (Adapted Reference)
colors:
  primary: "#3FA37F"        # Mint green (US-21 pastel) — CTA utama, soft & readable
  secondary: "#F4A68A"      # Peach (US-21 pastel) — aksi/apresiasi sekunder
  tertiary: "#7BA7D6"       # Light blue (US-21 pastel) — tombol alternatif & chips
  surface: "#FFFFFF"        # Putih bersih untuk latar belakang card utama
  background: "#F7F8FA"     # Abu-abu sangat terang untuk latar belakang dasar aplikasi
  text-primary: "#eaeaea"   # Abu-abu gelap/Hitam untuk teks utama yang mudah dibaca
  text-secondary: "#212529" # Abu-abu medium untuk teks deskripsi dan placeholder
  outline: "#E0E0E0"        # Garis batas halus untuk memisahkan form atau card
typography:
  h1:
    fontFamily: Plus Jakarta Sans
    fontSize: 2rem
    fontWeight: 700
  title-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 1.125rem
    fontWeight: 600
  body-md:
    fontFamily: beVietnamPro
    fontSize: 0.875rem
    fontWeight: 400
  label-sm:
    fontFamily: beVietnamPro
    fontSize: 0.75rem
    fontWeight: 500
rounded:
  sm: 8px         # Untuk tag kecil atau voucher
  md: 16px        # Standar sudut membulat untuk Card konten utama
  lg: 24px        # Sudut membulat untuk banner besar atau modal bawah
  full: 9999px    # Untuk foto profil dan ikon navigasi sirkular
spacing:
  xs: 4px
  sm: 8px
  md: 16px        # Padding standar layar (kiri-kanan)
  lg: 24px
  xl: 32px
---

# PENJELASAN DESAIN: The Daily Companion

## 1. Overview & Creative North Star
**Creative North Star: "The Daily Companion"**
Desain ini mengadaptasi struktur antarmuka yang sangat *engaging* dan berorientasi pada rutinitas (diambil dari referensi aplikasi retail) ke dalam aplikasi pemantauan emosi wanita (`fem_psychmonitor`). 

Alih-alih menggunakan tampilan medis yang kaku, sistem ini menggunakan pendekatan **"Gamified Wellness"**. Penggunaan elemen *Daily Check-in*, *Progress Bar*, dan *Voucher/Reward Cards* ditransformasikan menjadi pencatatan emosi harian, pemantauan siklus, dan apresiasi *self-care*. Tampilan ini menyeimbangkan kontras yang tegas dengan sudut-sudut membulat (*rounded*) yang memberikan rasa aman, bersahabat, dan mudah dinavigasi setiap hari.

---

## 2. Colors & Surface Philosophy
Palet warna menggunakan kontras yang tinggi untuk memperjelas hierarki informasi, dipadukan dengan latar belakang yang bersih untuk menghindari kelelahan visual (*visual fatigue*).

### Hierarki Warna & Fungsi (Konteks FemMonitor)
- **Primary:** Warna merah hangat digunakan sebagai *call-to-action* (CTA) utama. Dalam konteks pemantauan emosi, warna ini memberikan kesan vitalitas, energi, dan penanda penting (seperti log menstruasi atau simpan jurnal).
- **Secondary:** Warna emas yang memberikan kesan premium dan apresiatif. Digunakan untuk pencapaian (misalnya *streak* mencatat emosi, status level pemahaman diri, atau *rewards* berupa *insights*).
- **Background & Surface:** Area latar selalu menggunakan pergeseran warna dari abu-abu muda (`background`) ke putih murni (`surface`) pada *card* untuk memunculkan konten ke permukaan tanpa perlu bayangan (*shadow*) yang berlebihan.

---

## 3. Typography
Strategi tipografi memadukan **Plus Jakarta Sans** (untuk *Display/Headlines*) karena karakter geometrisnya yang modern dan ramah, dengan **beVietnamPro** (untuk *Body/Labels*) guna memastikan tingkat keterbacaan (*legibility*) maksimal pada layar padat informasi.

- **Headline (`title-md`):** Digunakan untuk judul section seperti "Catat Lagi", "Spesial Hari Ini" (Bisa diadaptasi menjadi "Jurnal Hari Ini", "Insight Emosi").
- **Body (`body-md`):** Digunakan untuk deskripsi panjang atau detail profil.

**Catatan Editorial:** Teks harus selalu memiliki kontras yang baik. Gunakan `text-primary` untuk informasi vital dan `text-secondary` untuk metadata (seperti tanggal atau keterangan tambahan).

---

## 4. Elevation & Depth
Sistem kedalaman pada desain ini bergantung pada **Soft Cards** dan **Subtle Borders**.

- **The Layering Principle:** Komponen diletakkan di dalam *card* putih (`surface`) yang duduk di atas kanvas abu-abu (`background`). 
- **Borders over Shadows:** Jika diperhatikan dari referensi, *card* (seperti *Daily Check-In*) menggunakan garis tepi (`outline` `#E0E0E0`) yang sangat tipis dan halus daripada bayangan tebal. Ini menjaga antarmuka tetap rata (*flat*), modern, dan rapi.
- **Bottom Navigation:** Bar navigasi bawah menggunakan `surface` putih solid dengan ikon-ikon netral abu-abu, dan indikator aktif menggunakan kombinasi merah dan hitam.

---

## 5. Components

### The Progress & Status Banner (Eks-VIP Card)
- **Visual:** *Card* besar dengan *background* gradasi atau solid terang, memiliki sudut `lg` (24px). 
- **Fungsi:** Digunakan untuk menampilkan fase siklus (misalnya "Fase Luteal") atau ringkasan *mood* mingguan. Terdapat *progress bar* yang jelas untuk memantau perjalanan siklus.

### Daily Tracker Cards (Eks-Daily Check-In)
- **Geometri:** Sekumpulan *card* berjejer horizontal (scrollable) dengan sudut `sm` (8px).
- **beVietnamProaksi:** Jika hari ini belum mencatat (Check-in), *card* akan memiliki border berwarna `secondary` (Emas) dan ikon tebal. Hari sebelumnya/selanjutnya diredam dengan *opacity* atau warna abu-abu muda.

### Form Inputs (Eks-Edit Profil)
- **Styling:** Latar belakang *input field* menggunakan warna abu-abu sangat muda (`#F3F3F3`) tanpa garis bawah (no *underline*), dengan sudut `sm` atau `md`. 
- **Aksesibilitas:** Label jelas berada di luar (atas) kolom input, memastikan pengguna selalu tahu data apa yang sedang mereka isi (misalnya "Nama", "Nomor Handphone", atau dalam konteks app ini: "Catatan Jurnal", "Gejala Fisik").

### Tombol Aksi (Prominent Buttons)
- **Shape:** Menggunakan *rounded* `md` (16px) untuk menyesuaikan dengan bentuk *card* di sekitarnya. 
- **Warna:** Solid `primary` (Merah) dengan teks putih. Harus memenuhi minimal lebar layar penuh (*full-width*) dikurangi *padding* saat diletakkan di bawah layar.

---

## 6. Do's and Don'ts

### Do
- **Do use "Card-Based Layouts":** Kelompokkan informasi yang berbeda (Jurnal, *Insight*, Grafik Emosi) ke dalam *card* putih yang terpisah oleh *background* abu-abu.
- **Do emphasize "Streaks" & "Check-ins":** Gunakan gaya visual *Daily Check-in* referensi untuk memotivasi pengguna mencatat emosi dan gejala secara harian.
- **Do keep Forms Clean:** Gunakan form dengan latar belakang abu-abu (*filled fields*) seperti pada halaman Edit Profil untuk tampilan yang tidak terlalu menekan secara kognitif.

### Don't
- **Don't Overcomplicate Navigation:** Pertahankan 4-5 menu pada *Bottom Navigation*. Gunakan desain ikon bergaris (*lineal*) yang bersih, bukan ikon yang terisi penuh (*filled*), kecuali untuk halaman yang sedang aktif.
- **Don't Use Harsh Shadows:** Jangan menggunakan *drop-shadow* berwarna hitam pekat. Sistem desain ini mengandalkan *border* tipis (`outline`) dan warna *background* yang sedikit berbeda untuk separasi elemen.
- **Don't Muddle the Primary Action:** Hanya gunakan warna primer untuk tombol aksi yang paling penting dalam satu layar (misal: "Simpan Jurnal", "Log Hari Ini").