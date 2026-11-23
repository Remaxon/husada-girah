# Dokumen 02: Game Design Document (GDD) — Husada Girah

**Versi Dokumen:** 1.2 (Pembaruan Minggu 2 — Peta Luas Terhubung 3200×2200, Kuali Portabel `R`, Follow-Then-Dispatch Mpu Bahula, & Navigasi Minimap/Quest Pointer)  
**Engine Target:** Godot 4 Standard (GDScript)  
**Platform:** PC (Windows/Linux) dan Web (HTML5)  
**Mode Permainan:** 1 Pemain (*Single-Player*), 2D *Top-Down*

---

## 1. Ringkasan Eksekutif & Pilar Desain

### 1.1 Ringkasan Eksekutif (*High Concept*)
**Husada Girah** adalah gim edukasi *2D Top-Down Tactical Action-Adventure & Herbal Alchemy* yang mengadaptasi kisah rakyat **Calon Arang** pada masa **Kerajaan Kahuripan** (abad ke-11, Desa Girah / Gurah, Kediri). Pemain mengendalikan dua karakter secara bergantian melalui sistem **Proxy Control**: **Tabib Wira** (non-combat) yang bertugas mendiagnosa gejala wabah warga, memanen herbal aman, dan meracik obat berbasis *Tag Efek* dari 40 herbal Nusantara asli, serta **Mpu Bahula** (lini serang) yang ditugaskan menerobos zona berkabut untuk bertarung melawan penjaga herbal/antek teluh demi mengamankan bahan langka dan membuka celah *Perisai Teluh* Calon Arang.

### 1.2 Pilar Desain Utama (*Design Pillars*)
1. **Edukasi sebagai Mekanik Inti (*Mechanics-First Learning*):** Pemain tidak disuguhi kuis pilihan ganda yang terpisah dari permainan; memahami khasiat nyata herbal Nusantara (seperti antipiretik, antiseptik, detoksifikasi) adalah kunci langsung untuk menyembuhkan warga dan menaklukkan Boss.
2. **Sinergi Duo Karakter (*Tactical Proxy Control*):** Pemisahan tegas antara karakter *non-combat* (otak & penyembuh) dan karakter *combat* (perisai & penjelajah zona bahaya) menciptakan dinamika strategi dan tempo permainan yang bervariasi.
3. **Alkimia Fleksibel Berbasis Tag Efek (*Data-Driven Herbal Alchemy*):** Tidak ada satu resep kaku tunggal untuk satu penyakit; berbagai kombinasi 2–3 herbal dengan tag efek yang tepat dapat menghasilkan ramuan valid sehingga mendorong eksplorasi dan penalaran.
4. **Akurasi Sejarah & Kearifan Lokal:** Seluruh visual, istilah (*Usada*, *Lipyakara*, *Walu Nateng Girah*, *Kahuripan*), dan narasi merujuk langsung pada naskah sejarah dan kajian akademis yang valid.

---

## 2. Core Gameplay Loop

### 2.1 Macro Loop (Alur Antar-Stage)
```text
Menu Utama / Persiapan Lontar Usada
   ↓
Prolog / Briefing Stage (Konteks Cerita Rakyat Kahuripan)
   ↓
Pelaksanaan Stage (Stage 1 → Stage 2 → Stage 3 → Stage 4 Boss Fight)
   ↓
Evaluasi Skor, Peringkat Bintang (1–3), & Rekap Penemuan Herbal di Peta
   ↓
Lanjut Stage Berikutnya / Epilog Desa Girah Pulih
```

### 2.2 Micro Loop (Siklus Inti di Dalam Stage)
1. **Eksplorasi & Diagnosa (*Explore & Diagnose*):** Menggunakan **Minimap Ringkas** dan **Panah Penunjuk Arah (*Quest Pointer*)**, Tabib Wira menjelajahi ekosistem peta luas (ditemani **Mpu Bahula** yang mengikuti di belakangnya) untuk menghampiri warga sakit dan mendiagnosa **1–3 gejala wabah**.
2. **Evaluasi Bahan (*Plan*):** Pemain memeriksa isi Kantong Herbal dan (bila perlu) membuka **Buku Lontar Usada (`L`)** (terbuka penuh 40 herbal & 12 gejala) untuk mencocokkan *Tag Efek* yang dibutuhkan.
3. **Akuisisi Herbal Berbasis Ekosistem (*Gather / Follow-Then-Dispatch*):**
   - **Zona Aman (Pemukiman & Tepi Sungai):** Tabib Wira memanen sendiri tanaman obat sesuai habitat alaminya (kebun belakang rumah untuk herbal dapur, tepi sungai lembap untuk herbal air/lembap).
   - **Zona Berbahaya (Pinggiran Hutan Berkabut):** Saat mendekati Batas Kabut Teluh, pemain menekan **`Tab`**; Tabib berdiri siaga aman di posisinya sementara `Camera2D` meluncur mulus (`0.55 dtk`) ke Mpu Bahula untuk bertarung dan memanen herbal langka/berisiko (`sambiloto`, `biji_kecubung`). Menekan `Tab` lagi mengembalikan kendali ke Tabib dan Mpu Bahula otomatis berjalan menyusul kembali ke belakang Tabib.
4. **Peracikan Portabel (*Portable Brewing*):** Tabib membuka **Kuali Portabel (`R`)** kapan saja dan di mana saja tanpa perlu kembali ke satu meja statis, memilih **2–3 herbal**, mengecek pratinjau *Tag Efek* (dan status `toksik` vs `detoks`), lalu meracik ramuan.
5. **Pengobatan & Umpan Balik (*Treat & Feedback*):** Tabib memberikan ramuan (`E`) kepada pasien target. Sistem menampilkan umpan balik instan (visual, audio, teks edukatif khasiat herbal) serta memperbarui **Skor** dan **Wabah Meter**.
6. **Pembukaan Gerbang & Penyelesaian Stage (*Gate Unlock & Stage Clear*):** Setelah seluruh warga Stage 1 sembuh (4/4), kabut teluh mereda dan **Gerbang Jalan Utara menuju Stage 2** terbuka bercahaya hijau (Quest Pointer mengarah ke gerbang). Melintasi gerbang menuntaskan stage dan menampilkan rincian skor serta peringkat bintang 1–3.

---

## 3. Mekanisme Kontrol & Kamera (*Proxy Control* — Versi B)

### 3.1 Perbandingan Peran Karakter Aktif

| Aspek | Karakter 1: Tabib Wira (*Non-Combat*) | Karakter 2: Mpu Bahula (*Lini Serang / Combat*) |
| :--- | :--- | :--- |
| **Kemampuan Bertarung** | **Tidak ada** (tidak bisa menyerang). | **Ada** (Serangan Tongkat/Keris Kahuripan jarak dekat + *Dash/Dodge* + Dorongan Mantra Ringan). |
| **Akses Zona** | Hanya **Zona Aman** (diblokir secara fisik & visual oleh batas *Kabut Teluh Pekat* agar pemain paham peran). | Dapat menembus **Zona Berbahaya** dan menghadapi antek teluh serta Boss. |
| **Interaksi Utama** | Diagnosa warga, panen herbal umum, akses Meja Alkimia, obati warga, menugaskan Lini Serang. | Bertarung melawan penjaga herbal, memanen herbal langka/sakral, mengaktifkan segel/pilar di Stage 3–4. |
| **Ketahanan (*HP*)** | Tidak ditarget musuh selama di Zona Aman; hanya terkena kerusakan jika menyentuh tepi kabut berbahaya (didorong mundur otomatis). | Memiliki **100 HP** (dapat dipulihkan otomatis perlahan di Zona Aman / Posko Tabib). |

### 3.2 Mekanisme Perilaku Pendamping (*Follow-Then-Dispatch*) & Kamera (`Camera2D`)
1. **Mode Pendamping (*Follow Companion*):**
   - Saat pemain mengendalikan **Tabib Wira** di Zona Aman, **Mpu Bahula** otomatis berjalan mengikuti di belakang Tabib dengan jarak nyaman (`~70 piksel`), tidak menabrak/mendorong Tabib, cerdas melewati jembatan kayu di aliran sungai, dan **berhenti otomatis sebelum garis Batas Kabut Teluh** jika Tabib mendekati perbatasan.
2. **Pemicu Penugasan (*Dispatch* via `Tab`):**
   - Pemain menekan **`Tab`** (atau klik tombol `[Tab] Ganti` di HUD) kapan saja untuk menugaskan Mpu Bahula.
   - Tabib memasuki status **Siaga Aman** di posisinya saat itu; `Camera2D` meluncur mulus (`Tween` `TRANS_CUBIC` / `EASE_IN_OUT` selama `0.55 detik`) menuju Mpu Bahula.
   - Indikator HUD berubah warna aksen dari **Hijau Daun/Emas (Mode Tabib)** menjadi **Merah Bata/Perunggu (Mode Lini Serang)**, menampilkan bilah HP Mpu Bahula, *cooldown* Dash, dan aksi serang.
3. **Pengembalian Kendali (*Return / Recall*):**
   - Setelah Mpu Bahula bertarung dan memanen herbal langka di hutan berkabut, pemain menekan **`Tab`** lagi untuk kembali ke Tabib Wira.
   - Kamera kembali meluncur mulus ke Tabib, herbal langsung tersedia di **Kantong Herbal Bersama**, dan Mpu Bahula otomatis berjalan menyusul kembali ke belakang Tabib (serta memulihkan HP perlahan saat kembali ke Zona Aman).
4. **Penanganan Kondisi Kalah Tempur (*Retreat*):**
   - Jika HP Mpu Bahula mencapai `0`, permainan **tidak langsung Game Over** (kecuali di Boss Fight fase kritis jika *Wabah Meter* penuh). Mpu Bahula mundur darurat (*Tactical Retreat*) kembali ke sisi aman Tabib, kehilangan maksimal 1 herbal bahaya yang belum disetorkan, dan **Wabah Meter** bertambah `+12%` dengan *cooldown* pemulihan 5 detik.

### 3.3 Pemetaan Input (*Control Mapping*)

| Aksi | Tombol Keyboard / Mouse | Berlaku Pada |
| :--- | :--- | :--- |
| **Bergerak (8 Arah)** | `W A S D` atau Tombol Panah (`↑ ↓ ← →`) | Tabib & Mpu Bahula |
| **Interaksi / Diagnosa / Panen / Baca Papan** | `E` | Tabib & Mpu Bahula |
| **Buka Kuali Portabel (`open_cauldron`)** | `R` atau klik tombol **`KUALI RACIK (R)`** di panel Inventory | Tabib (kapan saja & di mana saja) |
| **Serangan Utama (*Melee Slash*)** | `Spasi` | Mpu Bahula (Lini Serang) |
| **Menghindar (*Dash / Dodge*)** | `Shift` | Mpu Bahula (Lini Serang) |
| **Ganti Karakter / Tugaskan (*Proxy Switch*)** | `Tab` atau klik `[Tab] Ganti` di HUD | Global Gameplay |
| **Buka Buku Lontar Usada (`open_lontar`)** | `L` atau klik tombol **`BUKU LONTAR (L)`** di panel Inventory | Global Gameplay |
| **Jeda Permainan (*Pause*)** | `Esc` | Global Gameplay |

---

## 4. Aturan Permainan (*Game Rules*)

### 4.1 Wabah Meter (*Plague Severity Gauge*)
Sebagai mekanik tekanan waktu yang adil (*soft time pressure*) dan representasi penyebaran teluh Calon Arang:
- Setiap stage dimulai dengan **Wabah Meter** pada angka awal sesuai jarak dari pusat kutukan: **Stage 1 (Parameter Terluar Wilayah Girah): `10%` (`+0.25%/dtk`)**, Stage 2: `20%` (`+0.50%/dtk`), Stage 3: `25%` (`+0.65%/dtk`), Stage 4 Boss: `20%` (`+0.75%/dtk`).
- Selama masih ada warga yang belum sembuh (atau selama Calon Arang aktif menyebar teluh di Stage 4), *Wabah Meter* naik perlahan secara berkala. Saat semua warga Stage 1 sembuh dan Gerbang Utara terbuka, *Wabah Meter* berhenti naik.
- **Menyembuhkan warga secara sempurna** menurunkan *Wabah Meter* sebesar `-10%` hingga `-12%`.
- **Kesalahan racik (Gagal/Toksik)** menaikkan *Wabah Meter* sebesar `+5%` (karena membuang waktu berharga dan memperburuk kondisi sementara).
- **Buku Lontar Usada & Kuali Portabel (Mode Belajar):** Saat pemain membuka *Buku Lontar Usada (`L`)*, *Wabah Meter* **dijeda sepenuhnya (*paused*)** agar pemain dapat membaca informasi edukatif herbal tanpa terburu-buru. Saat membuka **Kuali Portabel (`R`)**, laju *Wabah Meter* diperlambat menjadi `25%` dari normal (dan **dijeda penuh `0%` di Stage 1** sebagai fase pengenalan).

### 4.2 Aturan Inventori, Starter Pack Awal, & Panen Herbal
- **Inventory Awalan (*Starter Pack* di `GameManager.gd`):**
  - **Item Permanen 1 — Buku Lontar Usada (`L`):** Selalu tersedia di panel Inventory HUD (bisa diklik langsung maupun via tombol `L`) dengan 40 herbal & 12 gejala terbuka penuh.
  - **Item Permanen 2 — Kuali Racik Portabel (`R`):** Selalu dibawa Tabib Wira di sebelah tombol Buku Lontar Usada pada panel Inventory bawah; memungkinkan Tabib meracik obat **kapan saja dan di mana saja** tanpa perlu pulang ke 1 meja alkimia statis.
  - **Stok Herbal Dasar Terbatas:** Tabib Wira memulai stage dengan bekal awal `kunyit: 3`, `jahe_merah: 3`, `asam_jawa: 2`, `daun_sirih: 2`, dan `temulawak: 2` — cukup untuk menyembuhkan 1–2 pasien awal beserta cadangan 2–3 kali gagal racik sebelum habis dan pemain perlu memanen herbal berbasis ekosistem di peta.
- **Kantong Herbal Bersama (*Shared Herbal Pouch*):** Menyimpan seluruh herbal awal (*Starter Pack*), herbal yang dipanen Tabib (zona aman), maupun yang dipanen/disetor Mpu Bahula (zona berbahaya).
- Setiap node tanaman di peta menghasilkan `1–2` unit herbal dan akan tumbuh kembali (*respawn*) setelah `20–30 detik` agar pemain tidak pernah mengalami kebuntuan (*soft-lock*) jika sempat salah meracik.
- Ramuan yang telah diracik masuk ke **Slot Ramuan Siap Pakai** (kapasitas maksimal 3 botol ramuan secara bersamaan) dan langsung dapat diberikan ke warga yang sakit atau dilemparkan/digunakan saat Boss Fight.

### 4.3 Kondisi Menang (*Win Condition*)
- **Stage 1, 2, dan 3:** Seluruh warga sakit pada gelombang (*wave*) stage tersebut berhasil disembuhkan (dan misi cerita khusus selesai, misal: menyegel 3 titik *Lipyakara* di Stage 3) sebelum *Wabah Meter* mencapai `100%`.
- **Stage 4 (Boss Fight Calon Arang):** Berhasil mematahkan seluruh **3 Fase Perisai Teluh** Calon Arang menggunakan kombinasi celah serangan Mpu Bahula dan **Penawar Suci** racikan Tabib sebelum *Wabah Meter* mencapai `100%`.

### 4.4 Kondisi Kalah (*Lose Condition*)
- **Wabah Meter mencapai `100%`:** Kabut teluh melanda seluruh desa/arena dan posko pengobatan tumbang. Pemain diarahkan ke **Layar Kalah (*Lose Screen*)** dengan opsi **Coba Lagi Stage Ini (*Retry*)** atau **Kembali ke Menu Utama**.

---

## 5. Sistem Skor dan Penilaian Bintang (1–3 Bintang)

Setiap stage memiliki sistem penilaian transparan yang memotivasi pemain untuk mempelajari khasiat herbal secara akurat dan efisien (bukan asal mencoba semua bahan/*trial-and-error* acak).

### 5.1 Komponen Perhitungan Skor

| Komponen Skor | Rumus / Nilai Poin | Tujuan Desain |
| :--- | :--- | :--- |
| **Poin Penyembuhan Dasar** | `+200 poin` × jumlah gejala pada pasien (1 gejala = 200, 2 gejala = 400, 3 gejala = 600) | Menghargai progres utama menyelamatkan warga. |
| **Bonus Akurasi Racikan (*Usada Utama*)** | `+150 poin` per ramuan sempurna (tepat sasaran, tanpa bahan mubazir, tanpa tag toksik aktif) | Mendorong pemain memilih kombinasi herbal paling akurat secara ilmu Usada. |
| **Bonus Tanpa Salah Racik (*Streak*)** | `+50 poin` × jumlah keberhasilan berturut-turut (maks. `+250` per pasien) | Mengurangi kebiasaan *brute-force* asal campur bahan. |
| **Bonus Efisiensi Wabah** | `(100 - Persentase_Akhir_Wabah_Meter) × 10 poin` | Menghargai kecepatan respon dan manajemen *Proxy Control*. |
| **Bonus Eksplorasi / Herbal Langka** | `+100 poin` per jenis herbal baru yang pertama kali dipanen di peta (di luar stok *Starter Pack*) | Mendorong rasa ingin tahu pemain mengeksplorasi 40 herbal Nusantara di lapangan. |
| **Bonus Boss Fight (Stage 4)** | `+500 poin` per fase Perisai Teluh yang dipatahkan + `+300 poin` jika Mpu Bahula tidak pernah *retreat* | Memberikan apresiasi puncak atas penguasaan strategi duo karakter. |
| **Penalti Racikan Salah / Toksik** | `-50 poin` per kegagalan racik (skor total minimum `0`) | Memberikan konsekuensi edukatif atas kesalahan fatal bahan beracun. |

### 5.2 Ambang Batas Peringkat Bintang per Stage

| Stage | Target Pasien / Objektif | Bintang 1 (★☆☆) — Lulus | Bintang 2 (★★☆) — Mahir | Bintang 3 (★★★) — Empu Usada |
| :---: | :--- | :---: | :---: | :---: |
| **Stage 1** | 4 Warga (1–2 gejala) | Stage selesai (`≥ 1.000` poin) | `≥ 1.800` poin | `≥ 2.400` poin (maks. 1 salah racik) |
| **Stage 2** | 5 Warga (2 gejala) | Stage selesai (`≥ 1.800` poin) | `≥ 2.800` poin | `≥ 3.600` poin (0 keracunan toksik) |
| **Stage 3** | 6 Warga (2–3 gejala) + 3 Segel | Stage selesai (`≥ 2.600` poin) | `≥ 3.900` poin | `≥ 4.900` poin (maks. 1 salah racik) |
| **Stage 4** | Boss Calon Arang (3 Fase) | Boss dikalahkan (`≥ 2.500` poin) | `≥ 3.800` poin | `≥ 4.800` poin (0 retreat Mpu Bahula) |

---

## 6. Sistem Umpan Balik Instan (*Instant Feedback System*)

Untuk memenuhi aspek kualitas gim edukasi, setiap tindakan pemain menghasilkan umpan balik **Visual + Audio + Teks Edukatif** secara seketika:

| Peristiwa / Kondisi | Umpan Balik Visual | Umpan Balik Audio | Umpan Balik Teks / Edukatif |
| :--- | :--- | :--- | :--- |
| **Racikan Sempurna (*Usada Utama*)** | Ledakan partikel emas & hijau daun di atas pasien; animasi warga berdiri cerah; popup `+Skor` mengapung. | Denting gamelan/saron harmonis naik (*ascending chime*) + suara helaan napas lega. | *"Usada Utama! Kunyit (anti-radang) dan Jahe Merah (anti-batuk) efektif meredakan keluhan warga!"* |
| **Racikan Tepat (*Usada Madya*)** | Cahaya hijau lembut di atas pasien; warga pulih; ikon ceklis standar. | Nada suling/gender lembut positif. | *"Warga sembuh! Namun satu bahan tidak diperlukan untuk gejala ini. Cermati tag efek agar lebih hemat."* |
| **Racikan Parsial (*Sebagian Cocok*)** | Cahaya kuning berkedip; hanya gejala yang cocok menghilang, sisa ikon gejala bergetar. | Nada pendek menggantung (*neutral ping*). | *"Demam telah turun, tetapi Batuk Kabut belum teratasi. Tambahkan herbal bertag [Anti-Batuk] seperti Kencur atau Daun Sirih."* |
| **Racikan Salah (Tag Tidak Cocok)** | Asap kelabu keluar dari lumpang/botol; layar bergetar halus (*screen shake* ringan). | Suara gong rendah tumpul / gelembung gagal (*fizzle*). | *"Ramuan tidak sesuai gejala! Pasien membutuhkan tag [Pencernaan]. Cek Buku Lontar Usada (`L`)."* |
| **Racikan Berbahaya (Tag `toksik` Aktif)** | Asap ungu pekat dengan ikon tengkorak herbal; kilatan merah tipis di tepi panel; *Wabah Meter* `+5%`. | Suara desis beracun & nada peringatan. | *"Bahaya Toksik! Kecubung mengandung zat beracun. Padukan dengan herbal [Detoks] (mis. Temulawak/Sambiloto) atau ganti bahan aman!"* |
| **Serangan Mpu Bahula (Hit / Perisai Kebal)** | Percikan cahaya keemasan (hit efektif) atau pantulan tameng ungu + teks *"KEBAL!"* pada Perisai Teluh Calon Arang. | Dentuman pukulan kayu/keris (efektif) vs dentingan logam tumpul (kebal). | Pada Boss Fight: *"Perisai Teluh kebal senjata biasa! Hancurkan Pilar Segel lalu tugaskan Tabib meracik Penawar Suci!"* |
| **Panen Herbal Baru Pertama Kali** | Spanduk mini di sisi kanan atas layar bertuliskan *"Lontar Diperbarui"*. | Suara lembaran daun lontar dibuka. | Menampilkan 1 kalimat ringkas khasiat nyata tanaman yang baru ditemukan. |

---

## 7. Spesifikasi Antarmuka (UI/UX) dan Audio

### 7.1 Identitas Visual & Palet Warna
Gim mengusung gaya **2D Pixel Art / Hand-Painted Top-Down** bernuansa **Jawa Timur Klasik (Abad ke-11)**:
- **Warna Utama Latar & UI (*Lontar & Kayu Jati*):** Krem Lontar (`#F2E5C6`), Cokelat Kayu Tua (`#4A2E1B`), Emas Keraton (`#D4A017`).
- **Aksen Zona Aman & Penyembuhan:** Hijau Daun Sirih (`#3A7D44`), Hijau Mint Lembut (`#88C999`).
- **Aksen Zona Berbahaya & Teluh Calon Arang:** Ungu Kabut Teluh (`#5B2C6F`), Merah Bara (`#B03A2E`), Abu Kabut (`#2C2A35`).
- **Tipografi:** Font serif dekoratif bernuansa klasik/aksara untuk judul (mis. *Cinzel* atau *Almendra*, lisensi SIL OFL) dan font sans-serif sangat mudah dibaca untuk HUD serta teks edukasi (mis. *Plus Jakarta Sans* atau *Nunito*, lisensi SIL OFL).

### 7.2 Daftar Layar Antarmuka (*UI Screens*)
1. **Splash / Preloader Screen:** Logo tim & Godot 4, *progress bar* pemuatan JSON, latar siluet Candi Kahuripan.
2. **Menu Utama (*Main Menu*):** Judul *Husada Girah*, tombol *Mulai Permainan*, *Pilih Stage / Lanjutkan*, *Buku Lontar Usada*, *Petunjuk Permainan*, *Pengaturan Audio*, *Kredit & Sumber Aset*, dan *Keluar*.
3. **Layar Petunjuk (*Instructions*):** 3 Tab ringkas bergambar: (1) Kontrol & *Proxy Control*, (2) Cara Meracik Berbasis Tag Efek & Bahaya Toksik, (3) Sistem Skor & Bintang.
4. **Buku Lontar Usada (`LontarUsadaUI.tscn` — Terbuka Penuh Sejak Awal):** Seluruh isi ensiklopedia **terbuka penuh sejak awal tanpa dikunci `???`** agar pemain selalu memiliki referensi edukatif yang jelas saat meracik. Saat dibuka (melalui tombol `L` atau klik item permanen di panel Inventory), **Wabah Meter dijeda sepenuhnya (*paused*)**. Terdiri atas **2 Tab**:
   - **Tab 1 — Daftar Herbal (40 Herbal Nusantara):** Menampilkan seluruh 40 herbal dari `herbs.json` lengkap dengan filter kategori, nama lokal & Latin, badge warna tag efek, lokasi stage & zona, stok saat ini di kantong, catatan khasiat edukatif, serta kotak peringatan mencolok untuk herbal bertag `toksik`.
   - **Tab 2 — Panduan Gejala & Resep Ramuan (12 Gejala Wabah):** Menampilkan seluruh 12 gejala dari `symptoms.json`, deskripsi, **tag penawar wajib**, serta **2–3 contoh resep kombinasi herbal valid** per gejala ditambah panduan kombinasi multi-gejala & aturan penetralan `toksik` + `detoks`.
5. **Gameplay HUD (Adaptif 2 Mode + Navigasi Peta Luas):**
   - **Kiri Atas:** Panel Karakter Aktif (Tabib / Mpu Bahula) + tombol *Proxy Switch* (`Tab`), HP Mpu Bahula, dan indikator *cooldown* Dash.
   - **Tengah Atas:** Bilah **Wabah Meter** (`0–100%`) + Counter Pasien Tersisa (berubah mengarahkan ke Gerbang Utara setelah semua warga sembuh).
   - **Kanan Tengah-Atas:** Skor Saat Ini, Streak, pintasan `[L] Lontar`, `[R] Kuali`, dan `[Esc] Jeda`.
   - **Pojok Kanan Atas — Minimap Ringkas (`~170×118 px`):** Custom `_draw()` ringan menampilkan pemukiman, aliran sungai & jembatan, hutan kabut ungu utara, titik hijau (Tabib), titik merah (Mpu Bahula), titik kuning berkedip (warga sakit), serta ikon Gerbang Utara. Di bawahnya terdapat panel **Catatan Diagnosa Warga**.
   - **Di Sekitar Karakter — Panah Penunjuk Arah (*Quest Pointer*):** Panah dinamis mengorbit karakter aktif mengarah ke warga sakit terdekat (kuning emas) atau ke **Gerbang Utara menuju Stage 2** (hijau zamrud) setelah seluruh warga sembuh.
   - **Bawah:** Panel Inventory berisi dua item permanen berdampingan (**`BUKU LONTAR (L)`** & **`KUALI RACIK (R)`**), ringkasan **Kantong Herbal Bersama** (*Starter Pack* + panen ekosistem), serta **Slot Ramuan Siap Pakai** (maks. 3 slot).
6. **Overlay Kuali Portabel (*Portable Brewing Modal* — tombol `R`):** Panel kiri daftar herbal dimiliki; panel tengah 3 slot lumpang + pratinjau Tag Efek gabungan + peringatan `toksik` vs penetralan `detoks` + tombol **Racik**; panel kanan rujukan gejala pasien yang sudah didiagnosa beserta checklist tag wajib real-time.
7. **Dialog & Cutscene Box:** Potret tokoh (Prabu Airlangga, Mpu Bharada, Ratna Manggali, Calon Arang, dll.), kotak dialog teks berirama (*typewriter effect*), tombol *Lanjut* (`Spasi`/`Klik`) dan *Lewati*.
8. **Layar Menang (*Win Screen*), Layar Kalah (*Lose Screen*), & Epilog:** Menampilkan rincian skor, animasi 1–3 bintang, rangkuman fakta sejarah/herbal stage, serta tombol navigasi jelas.

### 7.3 Spesifikasi Audio (BGM & SFX)

| Kode | Kategori | Nama / Konteks | Nuansa & Durasi Target |
| :---: | :--- | :--- | :--- |
| `BGM_01` | Musik Latar | Menu Utama & Lontar Usada | Gamelan pelog/suling lembut & khidmat (loop 60–90 dtk). |
| `BGM_02` | Musik Latar | Eksplorasi Desa Girah (Stage 1) | Instrumen tradisional hangat dengan sedikit nuansa melankolis (loop). |
| `BGM_03` | Musik Latar | Hutan Bambu & Pedepokan (Stage 2–3) | Tempo sedang, kendang ringan & gesekan rebab misterius (loop). |
| `BGM_04` | Musik Latar | Zona Pertarungan / Lini Serang *(opsional layer dinamis)* | Tambahan ritme kendang & kenong lebih intens saat Proxy Control di zona berbahaya. |
| `BGM_05` | Musik Latar | Boss Fight Calon Arang (Stage 4) | Gamelan dramatis tempo cepat, gong & kempul megah mencekam (loop). |
| `BGM_06` | Musik Latar | Epilog & Kemenangan | Alunan gamelan cerah penuh kemenangan dan kedamaian. |
| `SFX_01–04` | SFX UI | Klik tombol, buka halaman lontar, notifikasi diagnosa, transisi kamera. | Ringkas (`0.1–0.5 dtk`), renyah, tidak memekakkan. |
| `SFX_05–08` | SFX Alkimia | Petik herbal, tumbuk lumpang, racikan benar (emas), racikan salah/toksik. | Sangat kontras antara umpan balik positif vs negatif. |
| `SFX_09–13` | SFX Combat | Ayunan senjata, hit kena musuh, pantulan kebal perisai, dash, musuh kalah. | Responsif untuk mendukung *game feel* Mpu Bahula. |

---

## 8. Arsitektur Teknis Godot 4 (Acuan Implementasi Minggu 2–5)

*(Catatan: Pada Minggu 1 ini tidak dibuat file kode `.gd`/`.tscn`. Bagian ini adalah cetak biru teknis bagi Anggota 2 saat memulai setup Godot 4 di Minggu 2.)*

### 8.1 Konfigurasi Proyek Target
- **Versi Engine:** Godot 4.3+ Standard (GDScript).
- **Renderer:** `Compatibility` (OpenGL 3 / WebGL 2) agar **build Web (HTML5)** dan PC berjalan mulus di laptop spesifikasi rendah.
- **Resolusi Viewport:** `1280 × 720` (rasio 16:9), *Stretch Mode*: `canvas_items`, *Aspect*: `keep`.
- **Ekspor Target:** Windows Desktop (`.exe` + `.pck`) dan Web (`index.html` + `.wasm` + `.pck` siap unggah ke itch.io / hosting lokal).

### 8.2 Struktur Folder Proyek Godot (`res://`)

```text
res://
├── autoload/               # Singleton global (GameManager, AlchemyDatabase, ScoreManager, AudioManager, EventBus)
├── data/                   # Data JSON data-driven (herbs.json, symptoms.json, stages.json, dialogs.json)
├── assets/
│   ├── sprites/            # Sprite karakter (Tabib, Mpu Bahula), NPC, musuh, Boss Calon Arang
│   ├── tilesets/           # Tileset Desa Girah, Hutan Bambu/Sendang, Pedepokan, Altar Durga
│   ├── icons/              # 40 ikon herbal Nusantara, 12 ikon gejala, ikon tag efek & UI
│   ├── ui/                 # Bingkai lontar, tombol, bar wabah, potret dialog
│   ├── audio/              # BGM (.ogg) dan SFX (.wav/.ogg)
│   └── fonts/              # Font berlisensi terbuka (SIL OFL)
├── scenes/
│   ├── ui/                 # Splash, MainMenu, Instructions, LontarUsada, HUD, AlchemyTable, WinLose, DialogBox
│   ├── entities/           # PlayerTabib.tscn, PlayerBahula.tscn, VillagerPatient.tscn, HerbNode.tscn, EnemyBase.tscn, BossCalonArang.tscn
│   ├── stages/             # Stage01_DesaGirah.tscn, Stage02_HutanSendang.tscn, Stage03_Pedepokan.tscn, Stage04_AltarDurga.tscn
│   └── components/         # ProxyCamera2D.tscn, FogBarrier.tscn, AlchemyStation.tscn, SealPillar.tscn
└── scripts/                # Skrip GDScript modular (terpisah rapi mengikuti struktur scenes/)
```

### 8.3 Autoload Singletons & Arsitektur *Signal-Driven*
1. **`EventBus.gd`**: Penghubung sinyal global (*observer pattern*) agar UI dan gameplay tidak saling terikat kaku (contoh sinyal: `patient_diagnosed`, `herb_collected`, `potion_brewed`, `active_character_changed`, `plague_meter_updated`, `boss_phase_changed`).
2. **`AlchemyDatabase.gd`**: Memuat `res://data/herbs.json` dan `res://data/symptoms.json` saat *startup*; menyediakan fungsi murni `evaluate_potion(selected_herb_ids: Array, target_symptom_ids: Array) -> Dictionary` yang mengembalikan status (`PERFECT`, `GOOD`, `PARTIAL`, `FAIL`, `TOXIC`), daftar tag terpenuhi, dan pesan umpan balik edukatif.
3. **`GameManager.gd`**: Mengelola status stage aktif, *Starter Pack* awal (item permanen Buku Lontar Usada + stok herbal dasar `kunyit: 3`, `jahe_merah: 3`, `asam_jawa: 2`, `daun_sirih: 2`, `temulawak: 2`), Kantong Herbal Bersama, Slot Ramuan Siap Pakai, status karakter aktif, *Wabah Meter* (termasuk jeda saat Lontar dibuka), dan pergantian scene.
4. **`ScoreManager.gd`**: Menghitung skor per tindakan, *streak* akurasi, dan menentukan peringkat bintang 1–3 di akhir stage.
5. **`AudioManager.gd`**: Mengelola *crossfade* BGM dan *audio bus* (`Master`, `BGM`, `SFX`) serta tombol pengaturan volume.

---

## 9. Daftar Kebutuhan Aset & Transparansi Sumber Aset / AI

### 9.1 Inventaris Kebutuhan Aset Utama

| Kategori | Rincian Item | Estimasi Jumlah | Penanggung Jawab |
| :--- | :--- | :---: | :--- |
| **Karakter Utama** | Sprite 4-arah (Idle, Walk, Interact/Attack) untuk Tabib Wira & Mpu Bahula | 2 *spritesheet* | Anggota 3 |
| **NPC & Pasien** | Warga Sakit (Sakit vs Sembuh), Ratna Manggali, Mpu Bharada, Potret Dialog (7 tokoh) | 5 *sprite* + 7 potret | Anggota 3 |
| **Musuh & Boss** | Bayangan Kabut, Penjaga Rimbun, Murid Teluh, Roh Lipyakara, Boss Calon Arang (+ efek Perisai Teluh) | 5 *spritesheet* | Anggota 3 |
| **Lingkungan (*Tileset*)** | Tanah/rumput desa, rumah joglo/pendapa klasik, bambu & sendang, tembok candi/pedepokan, altar Durga, kabut teluh | 4 paket *tileset* | Anggota 3 |
| **Ikon Herbal & Gejala** | Ikon 40 herbal Nusantara (dapat dikelompokkan per visual rimpang/daun/akar/bunga dengan variasi warna & bentuk khas) + 12 ikon gejala + 12 ikon tag | 40 + 24 ikon | Anggota 3 |
| **UI & Audio** | Panel Lontar, tombol, HUD bar, 6 BGM, 13 SFX, 2 Font | 1 paket UI + 19 audio | Anggota 3 |

### 9.2 Kebijakan & Tabel Transparansi Sumber Aset / Penggunaan AI (Wajib Tugas Kuliah)

Sesuai etika akademik dan ketentuan tugas mata kuliah Game Programming, **seluruh aset pihak ketiga maupun aset yang dibantu alat AI wajib dicatat secara jujur dan transparan** di dalam menu **Kredit & Sumber Aset** di dalam gim serta pada **Lampiran Laporan Akhir**.

Berikut templat **Log Transparansi Aset** yang wajib diisi oleh Anggota 3 selama Minggu 2–5:

| No. | Nama Aset / File | Kategori | Jenis Sumber *(Orisinal / CC0 / CC-BY / AI-Assisted)* | Nama Pembuat / Platform / Tools | Tautan / Keterangan Modifikasi |
| :---: | :--- | :--- | :--- | :--- | :--- |
| 1 | *(Contoh)* `tileset_girah.png` | Tileset 2D | Orisinal / Modifikasi CC0 | `[Isi Nama / Sumber]` | `[Isi detail lisensi & suntingan]` |
| 2 | *(Contoh)* `bgm_menu_gamelan.ogg` | Audio BGM | CC-BY 4.0 / Bebas Royalti | `[Isi Nama Komposer / Platform]` | `[Isi URL & atribusi wajib]` |
| 3 | *(Contoh)* `portraits_npc.png` | Potret Dialog | AI-Assisted + Suntingan Manual | `[Isi Tools AI & Editor]` | `[Isi keterangan retouch/pixelation]` |
| 4 | *(Contoh)* `font_cinzel.ttf` | Font | SIL Open Font License (OFL) | Google Fonts | Digunakan untuk judul UI |

> **Prinsip Etika Penggunaan AI:** Jika tim memanfaatkan alat AI untuk membantu pembuatan konsep potret, referensi *prompt* ikon, atau bantuan *debugging* kode, tim wajib (1) menyunting dan memverifikasi hasil secara manual agar konsisten secara historis & artistik, serta (2) mencantumkan perannya secara terbuka dalam tabel transparansi di atas dan di menu Kredit dalam gim.
