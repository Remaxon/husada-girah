# Dokumen 05: Storyboard Permainan — Husada Girah (18 Panel / 2 Halaman Grid 3×3)

**Acuan untuk:** Anggota 1 (Alur Narasi & Pengalaman Pemain), Anggota 2 (Alur Transisi Scene), Anggota 3 (Desain Layar UI/UX & Ilustrasi Panel Laporan Akhir)  
**Format Tata Letak:** 18 Panel dibagi merata ke dalam **2 Halaman (Grid 3×3 per Halaman)** — siap disalin langsung ke Laporan Akhir atau diekspor ke PDF.

---

## HALAMAN 1: MENU, CERITA & EKSPLORASI (Panel SB-01 s.d. SB-09)

### Peta Grid 3×3 — Halaman 1

| Kolom 1 | Kolom 2 | Kolom 3 |
| :--- | :--- | :--- |
| **SB-01:** Preloader / Splash Screen | **SB-02:** Menu Utama | **SB-03:** Petunjuk (*Instructions*) |
| **SB-04:** Buku Lontar Usada | **SB-05:** Prolog Desa Girah | **SB-06:** Diagnosa Warga Multi-Gejala |
| **SB-07:** Panen Herbal Aman | **SB-08:** Penugasan Pengawal (*Camera Switch*) | **SB-09:** Pertarungan Penjaga Herbal |

---

### Panel SB-01
- **ID:** `SB-01`
- **Scene:** `SplashScreen.tscn`
- **Sequence:** Halaman 1 — Grid [1,1] (Urutan 01/18 — Pembuka Aplikasi)
- **Sketsa Visual Layar (UI):**
```text
+----------------------------------------------------+
|                                                    |
|              [ Siluet Candi Kahuripan ]            |
|                 & Daun Lontar Emas                 |
|                                                    |
|                H U S A D A   G I R A H             |
|            Logo Tim Proyek & Godot 4               |
|                                                    |
|          [==============>        ] 78%             |
|          Memuat basis data Lontar Usada...         |
+----------------------------------------------------+
```
  *Komposisi Visual:* Latar belakang cokelat kayu tua (`#4A2E1B`) dengan siluet gapura Jawa Timur Klasik abad ke-11 dan aksen emas hangat; di bagian bawah terdapat *progress bar* pemuatan data JSON.
- **Keterangan Interaksi:**
  1. Gim secara otomatis memuat `herbs.json`, `symptoms.json`, dan aset audio tanpa memerlukan input pemain.
  2. Setelah pemuatan mencapai 100%, layar melakukan *fade-out* halus dan langsung beralih menuju Menu Utama (`SB-02`).

---

### Panel SB-02
- **ID:** `SB-02`
- **Scene:** `MainMenu.tscn`
- **Sequence:** Halaman 1 — Grid [1,2] (Urutan 02/18 — Navigasi Utama)
- **Sketsa Visual Layar (UI):**
```text
+----------------------------------------------------+
| [Suara: ON]       HUSADA GIRAH          [v1.0 Edu] |
|          Kisah Calon Arang - Kahuripan             |
|                                                    |
|   [ > MULAI PERMAINAN ]       (Ilustrasi Tabib     |
|   [   PILIH STAGE     ]        Wira & Mpu Bahula   |
|   [   LONTAR USADA    ]        menghadap Desa      |
|   [   PETUNJUK        ]        Girah berkabut)     |
|   [   KREDIT & ASET   ]                            |
|   [   KELUAR          ]                            |
+----------------------------------------------------+
```
  *Komposisi Visual:* Ilustrasi *key art* Desa Girah berkabut ungu di sisi kanan dengan efek partikel kabut bergerak pelan; deretan tombol bermotif papan lontar rapi di sisi kiri disertai musik gamelan lembut (`BGM_01`).
- **Keterangan Interaksi:**
  1. Pemain mengarahkan kursor/tombol panah dan menekan `Klik Kiri` atau `Enter` pada salah satu menu utama.
  2. Memilih **Mulai Permainan** memulai Prolog (`SB-05`), **Petunjuk** membuka `SB-03`, dan **Lontar Usada** membuka `SB-04`.

---

### Panel SB-03
- **ID:** `SB-03`
- **Scene:** `InstructionsMenu.tscn`
- **Sequence:** Halaman 1 — Grid [1,3] (Urutan 03/18 — Panduan Bermain)
- **Sketsa Visual Layar (UI):**
```text
+----------------------------------------------------+
| [< Kembali]       PETUNJUK PERMAINAN               |
|  [1. Kontrol & Proxy] [2. Alkimia Tag] [3. Skor]   |
| +------------------------------------------------+ |
| | [Tabib - Aman]        [Mpu Bahula - Tempur]    | |
| |  WASD : Gerak          WASD   : Gerak          | |
| |  E    : Diagnosa/Racik Spasi  : Serang         | |
| |  Tab  : Tugaskan --->  Shift  : Dash/Hindar    | |
| |  L    : Buka Lontar    Tab    : Kembali Posko  | |
| +------------------------------------------------+ |
+----------------------------------------------------+
```
  *Komposisi Visual:* Bingkai gulungan lontar warna krem (`#F2E5C6`) dengan 3 tab bergambar ikon tombol keyboard/mouse agar pemain langsung memahami pembagian peran duo karakter dan mekanik tag efek.
- **Keterangan Interaksi:**
  1. Pemain mengklik tiga tab panduan untuk membaca kontrol *Proxy Control*, cara mencocokkan tag efek (termasuk peringatan `toksik`), dan aturan Bintang 1–3.
  2. Menekan tombol **Kembali** atau `Esc` mengembalikan pemain ke Menu Utama (`SB-02`).

---

### Panel SB-04
- **ID:** `SB-04`
- **Scene:** `LontarUsadaUI.tscn`
- **Sequence:** Halaman 1 — Grid [2,1] (Urutan 04/18 — Ensiklopedia Edukasi 40 Herbal)
- **Sketsa Visual Layar (UI):**
```text
+----------------------------------------------------+
| [< Tutup]   BUKU LONTAR USADA (12/40 Terbuka)      |
| Filter: [Semua][Rimpang][Daun][Akar][Rempah][Sakral]|
| +-------------------+ +--------------------------+ |
| | [*] Jahe Merah    | |  JAHE MERAH (Jae Abang)  | |
| | [*] Kunyit        | |  Zingiber officinale     | |
| | [*] Temulawak     | |  Tag: [Sirkulasi]        | |
| | [*] Sambiloto     | |       [Anti-Batuk]       | |
| | [?] ??? (Stage 2) | |       [Anti-Radang]      | |
| | [?] ??? (Stage 3) | |  Khasiat: Menghangatkan..| |
| +-------------------+ +--------------------------+ |
+----------------------------------------------------+
```
  *Komposisi Visual:* Tata letak dua kolom bergaya naskah lontar kuno; sisi kiri daftar 40 herbal dengan filter kategori, sisi kanan kartu detail lengkap berisi ikon, nama Latin, badge warna tag efek, lokasi stage, dan catatan khasiat nyata.
- **Keterangan Interaksi:**
  1. Pemain memilih kategori filter atau mengklik salah satu herbal yang telah ditemukan untuk membaca khasiat dan tag efeknya.
  2. Jika diakses saat gameplay (`L`), *Wabah Meter* dijeda otomatis hingga pemain menekan `Tutup` atau `L` lagi.

---

### Panel SB-05
- **ID:** `SB-05`
- **Scene:** `PrologCutscene.tscn`
- **Sequence:** Halaman 1 — Grid [2,2] (Urutan 05/18 — Pembuka Cerita Rakyat)
- **Sketsa Visual Layar (UI):**
```text
+----------------------------------------------------+
|         [ Latar Pendapa Kerajaan Kahuripan ]       |
|         [     Abad ke-11 M — Jawa Timur    ]       |
|                                                    |
|  [Potret Prabu Airlangga]   [Potret Mpu Bharada]   |
| +------------------------------------------------+ |
| | MPU BHARADA:                                   | |
| | "Wabah teluh dari Desa Girah kian meluas,      | |
| |  Paduka. Tabib Wira dan Mpu Bahula siap kami   | |
| |  utus membawa ilmu Usada ke Girah..."  [Lanjut]| |
| +------------------------------------------------+ |
+----------------------------------------------------+
```
  *Komposisi Visual:* Ilustrasi pendapa Kerajaan Kahuripan dengan potret ekspresif Prabu Airlangga, Patih Narottama, dan Mpu Bharada di atas kotak dialog transparan gelap berbingkai emas.
- **Keterangan Interaksi:**
  1. Teks dialog muncul bertahap (*typewriter*) memperkenalkan latar historis Kahuripan, Desa Girah, dan ancaman Calon Arang.
  2. Pemain menekan `Spasi` / `Klik Kiri` untuk melanjutkan dialog, atau tombol **Lewati** untuk langsung masuk ke Stage 1 (`SB-06`).

---

### Panel SB-06
- **ID:** `SB-06`
- **Scene:** `Stage01_DesaGirah.tscn`
- **Sequence:** Halaman 1 — Grid [2,3] (Urutan 06/18 — Eksplorasi & Diagnosa)
- **Sketsa Visual Layar (Top-Down + HUD):**
```text
+----------------------------------------------------+
| [Tabib] [Tab:Bahula] | WABAH [===     ] 18% | 0200 |
|                      | Pasien: 0/4   [L][||]|      |
|    (Rumah Warga)           +-------------------+   |
|                            | DIAGNOSA WARGA #1 |   |
|      (@) Tabib ---> [!]    | Gejala:           |   |
|                     Warga  | - Demam Membara   |   |
|                     Sakit  | - Mual & Mulas    |   |
|                            +-------------------+   |
| [Kantong Herbal: Jahe(1), Kunyit(1)]  [Ramuan: 0/3]|
+----------------------------------------------------+
```
  *Komposisi Visual:* Tampilan *2D Top-Down* halaman Desa Girah bernuansa hangat di zona aman; karakter Tabib Wira berdiri di samping warga sakit berikon tanda seru (`!`), memunculkan panel diagnosa berisi 2 gejala beserta ikon warnanya.
- **Keterangan Interaksi:**
  1. Pemain menggerakkan Tabib dengan `WASD` mendekati warga sakit dan menekan `E` (atau klik warga) untuk mendiagnosa.
  2. Sistem menampilkan daftar 1–3 gejala pasien dan menyimpannya sebagai catatan rujukan di sudut layar serta di Meja Alkimia.

---

### Panel SB-07
- **ID:** `SB-07`
- **Scene:** `Stage01_DesaGirah.tscn`
- **Sequence:** Halaman 1 — Grid [3,1] (Urutan 07/18 — Panen Herbal Zona Aman)
- **Sketsa Visual Layar (Top-Down + HUD):**
```text
+----------------------------------------------------+
| [Tabib] [Tab:Bahula] | WABAH [===     ] 20% | 0300 |
|                                                    |
|   [Kebun Empon-Empon Desa Girah - Zona Aman]       |
|                                                    |
|       * * *         (@) Tabib --- [E] Petik        |
|      Meniran       (Animasi memetik Asam Jawa)     |
|                     +1 Asam Jawa!                  |
|                                  [Spanduk Kanan:]  |
|                                  "Lontar Diperbarui|
|                                   +100 Poin Baru!" |
| [Kantong: Jahe(1), Kunyit(1), Asam Jawa(1)]        |
+----------------------------------------------------+
```
  *Komposisi Visual:* Sudut pandang *top-down* kebun herbal desa dengan sprite tanaman yang berkilau halus saat didekati; teks melayang `+1 Asam Jawa` dan notifikasi pembaruan Lontar muncul di kanan atas.
- **Keterangan Interaksi:**
  1. Pemain mendekati tanaman obat di zona aman dan menekan `E` untuk memanennya ke dalam Kantong Herbal Bersama.
  2. Jika herbal baru pertama kali ditemukan, entri di Buku Lontar Usada terbuka otomatis dan pemain memperoleh bonus `+100 poin`.

---

### Panel SB-08
- **ID:** `SB-08`
- **Scene:** `Stage01_DesaGirah.tscn` (`ProxyCamera2D`)
- **Sequence:** Halaman 1 — Grid [3,2] (Urutan 08/18 — Penugasan Proxy Control)
- **Sketsa Visual Layar (Top-Down + Transisi Kamera):**
```text
+----------------------------------------------------+
| [Peralihan Kamera -> Mpu Bahula]   WABAH [==== ]24%|
| ~~~~~~~ ZONA BERBAHAYA (KABUT TELUH UNGU) ~~~~~~~~ |
|                                                    |
|               [===> Camera2D Tween ===>]           |
|                                                    |
|  (@) Tabib [Siaga Aman]         (X) Mpu Bahula     |
|  "Tolong ambilkan Sambiloto      Siap menerobos!   |
|   di tepi sawah berkabut!"       HP [==========]   |
|                                                    |
| [HUD Berubah Aksen Merah Bata — Mode Lini Serang]  |
+----------------------------------------------------+
```
  *Komposisi Visual:* Garis kabut ungu memisahkan zona aman (hijau hangat) dan zona berbahaya (gelap berkabut); `Camera2D` meluncur mulus (`0.55 dtk`) dari Tabib yang bersiaga aman menuju Mpu Bahula di gerbang kabut.
- **Keterangan Interaksi:**
  1. Tabib mendekati Mpu Bahula (atau menekan `Tab`) untuk menugaskan pengambilan herbal langka di area berkabut.
  2. Input berpindah sepenuhnya ke Mpu Bahula, warna aksen HUD berubah ke Mode Lini Serang, dan bilah HP tempur muncul.

---

### Panel SB-09
- **ID:** `SB-09`
- **Scene:** `Stage01_DesaGirah.tscn` / `Stage02_HutanSendang.tscn`
- **Sequence:** Halaman 1 — Grid [3,3] (Urutan 09/18 — Pertarungan Zona Berbahaya)
- **Sketsa Visual Layar (Top-Down Combat):**
```text
+----------------------------------------------------+
| [Mpu Bahula] HP [========  ] 80/100 | WABAH 27%    |
| [Tab: Kembali saat Aman]            |              |
|                                                    |
|   (Kabut Ungu)          [*] Rumpun Sambiloto       |
|                            (Target Herbal Langka)  |
|         (X) Mpu Bahula --/ ) )  (M) Bayangan Kabut |
|          [Tebasan Emas!]        HP [===   ] -20!   |
|                                                    |
| [Spasi: Serang] [Shift: Dash (Siap)] [E: Panen]    |
+----------------------------------------------------+
```
  *Komposisi Visual:* Tampilan *top-down* zona berbahaya berkabut ungu; Mpu Bahula melancarkan tebasan cahaya emas ke arah musuh penjaga herbal dengan angka kerusakan melayang dan rumpun herbal langka berkilau di belakangnya.
- **Keterangan Interaksi:**
  1. Pemain menggerakkan Mpu Bahula (`WASD`), menghindar serangan musuh (`Shift`), dan menyerang (`Spasi`/`Klik Kiri`) hingga area aman.
  2. Setelah memanen herbal langka (`E`), pemain kembali ke batas posko untuk menyetorkan bahan dan mengembalikan kamera ke Tabib.

---

## HALAMAN 2: ALKIMIA, PROGRESI & AKHIR (Panel SB-10 s.d. SB-18)

### Peta Grid 3×3 — Halaman 2

| Kolom 1 | Kolom 2 | Kolom 3 |
| :--- | :--- | :--- |
| **SB-10:** Meja Racik Alkimia | **SB-11:** Umpan Balik Racikan Benar | **SB-12:** Umpan Balik Racikan Salah |
| **SB-13:** Eksplorasi Stage 2 / 3 | **SB-14:** Boss Fight — Fase Perisai Teluh | **SB-15:** Boss Fight — Fase Penawar Suci |
| **SB-16:** Layar Menang (*Win* + Bintang) | **SB-17:** Layar Kalah (*Lose* + *Retry*) | **SB-18:** Epilog Desa Girah Pulih |

---

### Panel SB-10
- **ID:** `SB-10`
- **Scene:** `AlchemyTableModal.tscn`
- **Sequence:** Halaman 2 — Grid [1,1] (Urutan 10/18 — Peracikan Berbasis Tag Efek)
- **Sketsa Visual Layar (UI Modal):**
```text
+----------------------------------------------------+
|        MEJA ALKIMIA (LUMPANG & PIPISAN)       [X]  |
| +---------------+ +---------------+ +------------+ |
| | KANTONG HERBAL| | SLOT RACIKAN  | | GEJALA     | |
| | > Kunyit  (2) | | [1. Kunyit  ] | | PASIEN #1: | |
| | > AsamJw  (1) | | [2. AsamJawa] | | - Demam    | |
| | > Jahe    (1) | | [3. (Kosong)] | | - Mual     | |
| | > Sirih   (2) | |  Pratinjau:   | | Tag Obat:  | |
| |               | | [Anti-Demam]  | | [OK] Penuh | |
| |               | | [Pencernaan]  | |            | |
| +---------------+ |  [ RACIK! ]   | +------------+ |
+----------------------------------------------------+
```
  *Komposisi Visual:* Overlay meja kayu dan lumpang batu di tengah layar; panel kiri berisi daftar herbal, tengah berisi 3 slot bahan + pratinjau tag efek gabungan (dan ikon peringatan jika ada `toksik`), kanan menampilkan catatan gejala pasien target.
- **Keterangan Interaksi:**
  1. Pemain mengklik 2–3 herbal dari Kantong untuk memasukkannya ke Slot Racikan dan mengamati gabungan Tag Efek yang terbentuk.
  2. Pemain menekan tombol **RACIK!** untuk menumbuk bahan menjadi ramuan siap pakai lalu memberikannya kepada pasien.

---

### Panel SB-11
- **ID:** `SB-11`
- **Scene:** `Stage01_DesaGirah.tscn` (Feedback Overlay)
- **Sequence:** Halaman 2 — Grid [1,2] (Urutan 11/18 — Umpan Balik Positif)
- **Sketsa Visual Layar (Top-Down + Popup Umpan Balik):**
```text
+----------------------------------------------------+
| [Tabib] | WABAH [==      ] 10% (-12%) | SKOR: 0850 |
|                                                    |
|               * * * KILAU EMAS * * *               |
|             (@) Tabib      (^_^) Warga Sembuh!     |
|                                                    |
|  +----------------------------------------------+  |
|  | [V] USADA UTAMA! (+400 Sembuh +150 Akurasi)  |  |
|  | Kunyit (pencernaan) & Asam Jawa (anti-demam) |  |
|  | berhasil menyembuhkan keluhan warga!         |  |
|  +----------------------------------------------+  |
+----------------------------------------------------+
```
  *Komposisi Visual:* Partikel cahaya emas dan hijau daun membumbung di atas warga yang kembali berdiri tegak; bilah *Wabah Meter* berkurang dengan animasi hijau, disertai kotak umpan balik edukatif di bagian bawah.
- **Keterangan Interaksi:**
  1. Saat ramuan memenuhi seluruh tag gejala secara efisien (`PERFECT`), sistem memutar denting gamelan harmonis dan menambah skor serta bonus akurasi.
  2. Pemain langsung menerima penegasan khasiat nyata herbal yang baru digunakan sebelum beralih ke pasien berikutnya.

---

### Panel SB-12
- **ID:** `SB-12`
- **Scene:** `Stage02_HutanSendang.tscn` (Feedback Overlay)
- **Sequence:** Halaman 2 — Grid [1,3] (Urutan 12/18 — Umpan Balik Negatif / Toksik)
- **Sketsa Visual Layar (Top-Down + Popup Peringatan):**
```text
+----------------------------------------------------+
| [Tabib] | WABAH [=====   ] 38% (+5%)  | SKOR: 0800 |
|           (Layar Bergetar Ringan)                  |
|               ~ ~ ~ ASAP UNGU ~ ~ ~                |
|             (@) Tabib      (x_x) Gagal Racik!      |
|                                                    |
|  +----------------------------------------------+  |
|  | [!] BAHAYA TOKSIK! (-50 Poin, Wabah +5%)     |  |
|  | Kecubung mengandung racun. Padukan dengan    |  |
|  | herbal [Detoks] (Temulawak/Sambiloto)!       |  |
|  +----------------------------------------------+  |
+----------------------------------------------------+
```
  *Komposisi Visual:* Kepulan asap ungu/kelabu keluar dari botol ramuan disertai getaran layar halus (*screen shake*) dan bingkai merah peringatan di kotak pesan edukatif.
- **Keterangan Interaksi:**
  1. Jika tag tidak sesuai atau tag `toksik` tidak dinetralkan oleh `detoks`, suara gong sumbang terdengar, bahan terpakai habis, dan *Wabah Meter* naik `+5%`.
  2. Teks umpan balik memberi petunjuk berbasis *tag efek* agar pemain dapat memperbaiki racikan lewat Lontar Usada tanpa rasa frustrasi.

---

### Panel SB-13
- **ID:** `SB-13`
- **Scene:** `Stage03_Pedepokan.tscn`
- **Sequence:** Halaman 2 — Grid [2,1] (Urutan 13/18 — Eksplorasi Lanjut Stage 2 & 3)
- **Sketsa Visual Layar (Top-Down Lingkungan Lanjut):**
```text
+----------------------------------------------------+
| [Tabib] | WABAH [======  ] 46% | Segel: 1/3 | 2150 |
|                                                    |
|  [Pelataran Batu Pedepokan Girah - Kabut Pekat]    |
|   [Segel Lipyakara #2]  [*] Daun Bidara (Sakral)   |
|  ~~~~~~~~~~~~~~~~ BATAS KABUT ~~~~~~~~~~~~~~~~~~~  |
|  (@) Tabib   <->   (R) Ratna Manggali              |
|  +----------------------------------------------+  |
|  | RATNA MANGGALI: "Hancurkan 3 Segel Lipyakara |  |
|  |  dan gunakan Daun Bidara atau Cendana untuk  |  |
|  |  mematahkan Belenggu Kabut Teluh ibuku..."   |  |
|  +----------------------------------------------+  |
+----------------------------------------------------+
```
  *Komposisi Visual:* Nuansa senja keunguan khas hutan bambu/pedepokan batu candi klasik; Ratna Manggali berdiri di lorong tersembunyi zona aman sementara Batu Segel bercahaya merah-ungu tampak di balik batas kabut.
- **Keterangan Interaksi:**
  1. Pemain berinteraksi dengan Ratna Manggali (`E`) untuk memperoleh informasi lokasi herbal sakral (`suci_teluh`) dan mekanik segel *Lipyakara*.
  2. Pemain bergantian mengatur Mpu Bahula (menghancurkan 3 segel & memanen herbal sakral) serta Tabib (mengobati pasien 2–3 gejala).

---

### Panel SB-14
- **ID:** `SB-14`
- **Scene:** `Stage04_AltarDurga.tscn`
- **Sequence:** Halaman 2 — Grid [2,2] (Urutan 14/18 — Boss Fight: Perisai Teluh)
- **Sketsa Visual Layar (Top-Down Boss Arena — Mode Lini Serang):**
```text
+----------------------------------------------------+
| BOSS: CALON ARANG (Fase 1/3) [========|====|====]  |
| Kutukan: [Amarah Lipyakara] + [Batuk Kabut]        |
| [Mpu Bahula] HP [=======   ]  | WABAH [====  ] 32% |
|                                                    |
|   [Pilar Segel Kiri]  ((( CALON ARANG )))  [Pilar] |
|    HP [==  ] <--- (X)   (Perisai Ungu:     Kanan   |
|                  Bahula  "KEBAL FISIK!")           |
|   [*] Wijaya Kusuma                    [*] Cendana |
|======== LINGKARAN MANTRA POSKO TABIB (AMAN) =======|
+----------------------------------------------------+
```
  *Komposisi Visual:* Altar Kuil Durga diterangi sinar purnama; Calon Arang melayang di tengah dikelilingi kubah ungu *Perisai Teluh*. Serangan langsung ke Calon Arang memantul dengan teks `"KEBAL!"`, mengarahkan Mpu Bahula menghancurkan kedua Pilar Segel.
- **Keterangan Interaksi:**
  1. Pemain mengendalikan Mpu Bahula untuk menghindari gelombang kabut teluh (`Shift`), menghancurkan kedua Pilar Segel (`Spasi`), dan memanen herbal sakral altar bila diperlukan.
  2. Setelah kedua Pilar Segel hancur, Perisai Teluh Calon Arang memasuki status **Celah Terbuka (25 detik)** dan HUD berkedip memberi aba-aba beralih ke Tabib (`Tab`).

---

### Panel SB-15
- **ID:** `SB-15`
- **Scene:** `Stage04_AltarDurga.tscn`
- **Sequence:** Halaman 2 — Grid [2,3] (Urutan 15/18 — Boss Fight: Penawar Suci)
- **Sketsa Visual Layar (Top-Down Boss Arena — Sinergi Penawar Suci):**
```text
+----------------------------------------------------+
| BOSS: CALON ARANG — CELAH TERBUKA! (14 dtk)        |
| Penawar Siap: [Kayu Cendana + Jahe Merah] -> VALID |
|                                                    |
|                  * * RETAK EMAS! * *               |
|                ((   CALON ARANG   ))               |
|                        ^                           |
|             (Pancaran Cahaya Penawar Suci)         |
|                        |                           |
|===== LINGKARAN POSKO ==|===========================|
|        (@) Tabib Wira [E: Lontarkan Penawar!]      |
+----------------------------------------------------+
```
  *Komposisi Visual:* Di sisi selatan, Tabib Wira menyelesaikan racikan Penawar Suci yang cocok dengan tag kutukan Boss (`penenang`, `suci_teluh`, `anti_batuk`); seberkas cahaya emas melesat menembus celah perisai dan memecahkan kubah ungu Calon Arang.
- **Keterangan Interaksi:**
  1. Tabib meracik Penawar Suci di Meja Alkimia Posko lalu menekan `E` di Titik Serah Penawar saat Celah Perisai aktif.
  2. Perisai Teluh meledak hancur, kekuatan Calon Arang turun satu fase (`+500 poin`), dan pertempuran berlanjut ke Fase 2 & 3 hingga Calon Arang takluk.

---

### Panel SB-16
- **ID:** `SB-16`
- **Scene:** `WinScreen.tscn`
- **Sequence:** Halaman 2 — Grid [3,1] (Urutan 16/18 — Evaluasi Kemenangan Stage)
- **Sketsa Visual Layar (UI):**
```text
+----------------------------------------------------+
|              STAGE SELESAI — DESA TERSELAMATKAN!   |
|                    [ ★ ]  [ ★ ]  [ ★ ]             |
|                     EMPU USADA (3/3)               |
| +------------------------------------------------+ |
| | Penyembuhan Warga    : +1.400                  | |
| | Bonus Akurasi & Streak: +650                   | |
| | Efisiensi Wabah (18%): +820                    | |
| | TOTAL SKOR STAGE     : 2.870                   | |
| +------------------------------------------------+ |
| Fakta Kahuripan: Desa Girah kini bernama Kec. Gurah|
|   [ Lanjut Stage Berikutnya ]   [ Menu Utama ]     |
+----------------------------------------------------+
```
  *Komposisi Visual:* Panel lontar terang berhias animasi 1 hingga 3 bintang emas yang menyala berurutan, tabel rincian skor transparan, serta satu kotak kecil berisi fakta sejarah Kahuripan/herbal.
- **Keterangan Interaksi:**
  1. Sistem menyimpan rekor skor dan jumlah bintang stage secara otomatis serta membuka stage berikutnya.
  2. Pemain menekan **Lanjut Stage Berikutnya** (atau menuju Epilog jika Stage 4 baru saja diselesaikan) atau **Menu Utama**.

---

### Panel SB-17
- **ID:** `SB-17`
- **Scene:** `LoseScreen.tscn`
- **Sequence:** Halaman 2 — Grid [3,2] (Urutan 17/18 — Kondisi Kalah & Evaluasi)
- **Sketsa Visual Layar (UI):**
```text
+----------------------------------------------------+
|                KABUT TELUH MELUAS (100%)           |
|              Posko Pengobatan Terpaksa Mundur      |
|                                                    |
| +------------------------------------------------+ |
| | Warga Disembuhkan : 3 / 5                      | |
| | Catatan Evaluasi  : 2x Gagal Racik Toksik      | |
| | Tips Usada:                                    | |
| | "Gunakan tombol [L] membuka Lontar Usada       | |
| |  (waktu terjeda!) untuk mengecek tag [Detoks]." | |
| +------------------------------------------------+ |
|                                                    |
|        [ Coba Lagi Stage Ini ]   [ Menu Utama ]    |
+----------------------------------------------------+
```
  *Komposisi Visual:* Latar belakang gelap berkabut ungu redup dengan bingkai batu retak, namun tetap menyajikan pesan evaluasi konstruktif dan tips edukatif yang ramah pemain.
- **Keterangan Interaksi:**
  1. Muncul otomatis saat *Wabah Meter* mencapai `100%` di stage mana pun.
  2. Pemain dapat langsung menekan **Coba Lagi Stage Ini** untuk mengulang stage dengan cepat atau kembali ke **Menu Utama**.

---

### Panel SB-18
- **ID:** `SB-18`
- **Scene:** `EpilogCutscene.tscn`
- **Sequence:** Halaman 2 — Grid [3,3] (Urutan 18/18 — Penutup & Pesan Budaya)
- **Sketsa Visual Layar (UI Cutscene):**
```text
+----------------------------------------------------+
|      [ Desa Girah Cerah di Bawah Mentari Pagi ]    |
|      [ Warga Pulih, Sawah Hijau, Kabut Sirna  ]    |
|                                                    |
|   [Mpu Bharada]  [Tabib Wira]  [Mpu Bahula & Ratna]|
| +------------------------------------------------+ |
| | PRABU AIRLANGGA: "Berkat kebijaksanaan Usada   | |
| |  dan keberanian kalian, Desa Girah kembali     | |
| |  damai. Wariskan pengetahuan herbal ini bagi   | |
| |  anak cucu Nusantara..."                       | |
| +------------------------------------------------+ |
|        [ Lihat Kredit & Sumber Aset ] [ Menu ]     |
+----------------------------------------------------+
```
  *Komposisi Visual:* Transisi visual dramatis dari gelap kabut teluh menjadi panorama pagi keemasan Desa Girah yang asri dengan iringan gamelan kemenangan (`BGM_06`), ditutup rangkuman pencapaian total bintang dan koleksi Lontar Usada.
- **Keterangan Interaksi:**
  1. Pemain membaca rangkaian dialog epilog pemulihan Desa Girah dan pesan pelestarian cerita rakyat serta pengobatan herbal Nusantara.
  2. Di akhir cutscene, pemain dapat meninjau layar **Kredit & Transparansi Sumber Aset** atau kembali ke **Menu Utama** untuk melengkapi 3 bintang dan koleksi 40 herbal.
