# Dokumen 01: Konsep Permainan, Latar Sejarah, dan Pembagian Peran Tim

**Proyek Mata Kuliah:** Game Programming  
**Engine Target:** Godot 4 (Versi Standard / GDScript)  
**Platform Target:** PC (Windows/Linux) dan Web (HTML5)  
**Durasi Pengerjaan:** 5 Minggu (3 Mahasiswa)  
**Status Dokumen:** Acuan Tunggal (*Single Source of Truth*) — Minggu 1 (Tahap Perencanaan)

---

## 1. Identitas Permainan

| Atribut | Keterangan |
| :--- | :--- |
| **Judul Kerja (Utama)** | **Husada Girah** |
| **Makna Judul** | *Husada* (dari bahasa Jawa Kuno/Sanskerta *ausadha* atau *usada*) berarti pengobatan atau ramuan penyembuh; *Girah* adalah nama desa kediaman Calon Arang di wilayah Kerajaan Kahuripan. |
| **Alternatif Judul 1** | **Usada Kahuripan: Penawar Teluh Girah** *(menonjolkan latar historis Kerajaan Kahuripan dan tradisi pengobatan Usada)* |
| **Alternatif Judul 2** | **Lontar Usada: Wabah Girah** *(menonjolkan aspek ensiklopedia herbal Nusantara dan krisis wabah yang harus ditanggulangi)* |
| **Genre** | 2D Top-Down Tactical Action-Adventure & Herbal Alchemy (Edukatif) |
| **Sudut Pandang Kamera** | 2D *Top-Down* (`Camera2D`) dengan perpindahan sorotan mulus (*smooth camera switching*) antar dua karakter aktif (*Proxy Control*) |
| **Jumlah Pemain** | 1 Pemain (*Single-Player*) dengan kendali duo karakter bergantian |
| **Jumlah Level / Stage** | 4 Stage Utama (termasuk 1 Stage *Boss Fight* Final) |
| **Target Usia Pemain** | Remaja hingga Dewasa Muda (12–25 tahun; pelajar SMP/SMA, mahasiswa, dan masyarakat umum) |
| **Teknologi Utama** | Godot Engine 4.x Standard (GDScript), Arsitektur *Data-Driven* (JSON) |

---

## 2. Identitas Kelompok dan Pembagian Peran Tim (Sesuai Bab 4)

Proyek ini dikerjakan oleh kelompok beranggotakan 3 (tiga) mahasiswa dengan pembagian tanggung jawab yang terstruktur agar seluruh aspek desain edukasi, pemrograman Godot 4, aset visual-audio, dan pengujian kualitas berjalan paralel dan terukur.

### 2.1 Tabel Identitas Anggota Kelompok

*(Tabel berikut disiapkan kosong pada kolom Nama Lengkap dan NIM untuk diisi oleh anggota kelompok sebelum kompilasi Laporan Akhir.)*

| No. | Peran Utama (Bab 4) | Nama Lengkap | NIM | Program Studi / Kelas |
| :---: | :--- | :--- | :--- | :--- |
| 1 | **Game Designer & Project Manager** | `[Dino Andriano]` | `[2024010009]` |
| 2 | **Game Programmer & Developer** | `[Ahmad Khoirul Anam]` | `[2024010003]` |
| 3 | **UI/UX Designer, Asset Creator & Tester** | `[Febrian Abdulloh Jamil]` | `[20240100012]` |

### 2.2 Rincian Tanggung Jawab per Anggota

#### A. Anggota 1 — Game Designer & Project Manager
Bertanggung jawab atas arah kreatif, keakuratan cerita rakyat serta materi edukasi herbal, keseimbangan permainan (*game balancing*), dan manajemen jadwal proyek 5 minggu.
1. **Perancangan Konsep & GDD:** Menyusun konsep inti, sinopsis, karakterisasi tokoh, aturan permainan, kurva kesulitan, dan *Game Design Document* (GDD).
2. **Desain Sistem Edukasi & Alkimia:** Merancang basis data 40 herbal Nusantara beserta tag efek, gejala wabah, formula skor, dan verifikasi validitas khasiat herbal serta sejarah Kerajaan Kahuripan.
3. **Desain Alur & Level:** Membuat *flowchart* alur permainan, *storyboard* (18 panel), desain peta 4 stage (zona aman vs. berbahaya), dan mekanik *Boss Fight* Calon Arang.
4. **Manajemen Proyek:** Mengatur pembagian tugas mingguan, memantau progres *milestone*, mengelola dokumentasi Laporan Akhir, serta memfasilitasi evaluasi berkala antar anggota.

#### B. Anggota 2 — Game Programmer & Developer
Bertanggung jawab atas arsitektur kode, implementasi mekanik permainan di Godot 4 (GDScript), integrasi basis data JSON, dan stabilitas teknis (*build* PC & Web).
1. **Setup Proyek & Arsitektur Godot 4:** Menyiapkan struktur direktori proyek, *Autoload Singletons* (`GameManager`, `AlchemyDatabase`, `ScoreManager`, `AudioManager`), serta konfigurasi *viewport* dan kontrol input.
2. **Implementasi Mekanik Proxy Control:** Memprogram pergerakan 2D *top-down* Tabib (non-combat) dan Lini Serang (Mpu Bahula), transisi mulus `Camera2D`, batas zona kabut teluh, serta mekanik pertarungan dasar.
3. **Implementasi Sistem Alkimia Data-Driven:** Membangun *parser* `herbs.json` dan `symptoms.json`, algoritma pencocokan tag efek (termasuk deteksi tag `toksik` dan `detoks`), sistem diagnosa multi-gejala, serta sistem skor & bintang 1–3.
4. **Integrasi Level, Boss Fight & Bug Fixing:** Mengintegrasikan seluruh aset ke 4 stage, memprogram *state machine* musuh dan 3 fase *Boss Fight* Calon Arang, memperbaiki *bug*, serta mengekspor *build* final (Windows `.exe` dan Web HTML5).

#### C. Anggota 3 — UI/UX Designer, Asset Creator & Tester
Bertanggung jawab atas identitas visual, kenyamanan antarmuka pengguna, penyediaan aset 2D/audio yang transparan sumbernya, serta pengujian fungsional dan pengalaman pengguna (*playtesting*).
1. **Desain UI/UX:** Merancang tata letak Menu Utama, Layar Petunjuk, Buku Lontar Usada, HUD Tabib & Lini Serang, *overlay* Meja Alkimia, dialog, serta layar Menang/Kalah dengan tema visual Jawa Klasik.
2. **Pembuatan & Kurasi Aset 2D:** Membuat atau mengkurasi *tileset* 2D *top-down* (Desa Girah, Hutan Bambu/Sendang, Pedepokan, Altar Durga), *sprite* karakter & musuh, 40 ikon herbal Nusantara, serta efek partikel visual.
3. **Pengelolaan Audio & Transparansi Aset:** Menyiapkan musik latar (*BGM* bernuansa gamelan/etnik lembut dan tegang) serta efek suara (*SFX* panen, racik benar/salah, serangan), disertai pencatatan lengkap lisensi dan transparansi sumber aset/AI.
4. **Pengujian (QA) & Dokumentasi:** Menyusun skenario uji fungsional (*black-box testing*), melaksanakan *playtesting* UX untuk mengukur keterbacaan edukasi, melaporkan *bug* ke Programmer, dan mendokumentasikan hasil pengujian untuk Laporan Akhir.

### 2.3 Matriks Tanggung Jawab Singkat (RACI)

*(Keterangan: **R** = Responsible/Pelaksana, **A** = Accountable/Penanggung Jawab Akhir, **C** = Consulted/Dimintai Masukan, **I** = Informed/Diberi Informasi)*

| Lingkup Kerja | Anggota 1 (GD & PM) | Anggota 2 (Programmer) | Anggota 3 (UI/Asset/QA) |
| :--- | :---: | :---: | :---: |
| Dokumen Perencanaan Minggu 1 (`docs/`) | **A / R** | C | C |
| Arsitektur Kode & Mekanik Godot 4 | C | **A / R** | I |
| Basis Data JSON Herbal & Gejala | **A** | **R** | C |
| Desain UI/UX, Sprite, Tileset & Audio | C | I | **A / R** |
| Integrasi Level 1–4 & Boss Fight | C | **A / R** | C |
| Pengujian Fungsional, UX & Log Aset | A | C | **R** |
| Kompilasi Laporan Akhir & Presentasi | **A / R** | R | R |

---

## 3. Rencana Kerja 5 Minggu (*Project Timeline*)

Proyek dirancang menggunakan pendekatan iteratif mingguan agar di akhir Minggu ke-4 sudah tersedia *Vertical Slice* lengkap yang dapat dimainkan dari awal hingga tamat (*playable build*), sehingga Minggu ke-5 difokuskan pada pemolesan (*polishing*), pengujian, dan penyusunan laporan akhir.

| Minggu | Fokus Tahapan | Target Utama (*Milestone*) | Keluaran (*Deliverables*) | Penanggung Jawab Utama |
| :---: | :--- | :--- | :--- | :--- |
| **Minggu 1** | **Perencanaan & Desain** | Finalisasi dokumen konsep, GDD, database alkimia, flowchart, dan storyboard. | 5 dokumen lengkap di folder `docs/` (`01` s.d. `05`). | Anggota 1 (didukung Anggota 2 & 3) |
| **Minggu 2** | **Fondasi Teknis & Aset Dasar** | Setup project Godot 4, mekanik gerak duo karakter + `Camera2D` *Proxy Control*, prototipe *parser* JSON alkimia, dan *wireframe* UI/aset dasar. | Project Godot berjalan (*sandbox test scene*), `herbs.json` & `symptoms.json` aktif, *tileset* & *sprite* prototipe Stage 1. | Anggota 2 (kode inti) & Anggota 3 (aset awal/UI) |
| **Minggu 3** | **Core Gameplay & Stage 1–2** | Siklus lengkap (Diagnosa -> Panen -> Proxy Control -> Racik -> Umpan Balik -> Skor) berfungsi penuh di Stage 1 & Stage 2. | *Playable Alpha* Stage 1 (Desa Girah) & Stage 2 (Hutan Bambu & Sendang), HUD & Meja Alkimia fungsional, Buku Lontar Usada. | Anggota 2 (integrasi & combat) & Anggota 3 (aset herbal & UI) |
| **Minggu 4** | **Stage 3–4, Boss Fight & Audio** | Implementasi Stage 3 (Pedepokan Girah), Stage 4 (*Boss Fight* Calon Arang 3 fase), seluruh menu (Splash, Win, Lose, Epilog), dan audio BGM/SFX. | *Playable Beta* lengkap 4 Stage + audio terintegrasi + sistem bintang 1–3. | Anggota 2 (Stage 3–4 & Boss) & Anggota 3 (audio & aset final) |
| **Minggu 5** | **Testing, Polishing & Laporan** | Pengujian fungsional & UX, *balancing* skor/kesulitan, perbaikan *bug*, ekspor PC & Web, transparansi aset, dan kompilasi Laporan Akhir. | *Release Build* (PC & Web), Tabel Hasil Pengujian, Log Sumber Aset/AI, Laporan Akhir & Slide Presentasi. | Seluruh Tim (QA dipimpin Anggota 3, PM Anggota 1, Build Anggota 2) |

---

## 4. Latar Sejarah Akurat dan Referensi Cerita Rakyat

### 4.1 Penegasan Latar Sejarah (Akurasi Historis)

Salah satu tujuan edukasi utama **Husada Girah** adalah meluruskan kesalahpahaman populer mengenai latar waktu dan lokasi kisah Calon Arang. Oleh karena itu, seluruh narasi, dialog, arsitektur lingkungan, dan ensiklopedia di dalam gim berpegang teguh pada fakta historis berikut:

1. **Periode Kerajaan:** Kisah ini berlatar pada masa **Kerajaan Kahuripan** pada **abad ke-11 Masehi (Jawa Timur Klasik)** di bawah pemerintahan **Prabu Airlangga** (memerintah sekitar 1009–1042 M), **BUKAN** pada zaman Kerajaan Majapahit (abad ke-13 hingga ke-15 M).
2. **Lokasi Geografis:** Pusat peristiwa berada di **Desa Girah**, yang secara historis dan berdasarkan kajian toponimi/petilasan lokal kini dikenal sebagai wilayah **Kecamatan Gurah, Kabupaten Kediri, Provinsi Jawa Timur** (termasuk situs petilasan di Desa Sukorejo, Kecamatan Gurah).
3. **Nilai Budaya & Filosofis:** Kisah ini tidak sekadar menyajikan pertarungan baik melawan jahat, tetapi juga mengangkat tradisi pengobatan tradisional Nusantara (*Usada*), konsep keseimbangan kosmis (*Rwa Bhineda*), serta penyelesaian konflik melalui kebijaksanaan dan pengetahuan (bukan semata kekerasan).

### 4.2 Daftar Referensi Wajib dan Penunjang

Referensi berikut digunakan sebagai landasan narasi, penokohan, latar geografis, dan materi edukasi:

1. **Naskah Primer Sastra Klasik:**  
   *Serat Calon Arang* (Naskah Jawa Pertengahan, dikenal pula melalui edisi suntingan dan terjemahan R. Ng. Poerbatjaraka, *"De Calon-Arang"*, *Bijdragen tot de Taal-, Land- en Volkenkunde*, 1926). Menjadi acuan utama alur tokoh Calon Arang, Ratna Manggali, Prabu Airlangga, Mpu Bharada, Mpu Bahula, dan kitab *Lipyakara*.
2. **Ensiklopedia Daring (Referensi Ringkas Tokoh & Kronologi):**  
   Wikipedia Bahasa Indonesia — Artikel **"Calon Arang"** dan **"Mpu Bharada"**. Digunakan sebagai rujukan cepat pemetaan relasi tokoh, kronologi Kerajaan Kahuripan, dan peran Mpu Bharada di pertapaan Lemah Tulis.
3. **Buku Referensi Budaya (E-Book Akademik):**  
   *Calonarang Dalam Kebudayaan Bali* (Penerbit Universitas Warmadewa). Digunakan untuk memperkaya perspektif pelestarian budaya Calon Arang, simbolisme pemujaan Dewi Durga, filosofi keseimbangan, dan keterkaitannya dengan tradisi pengobatan *Usada*.
4. **Jurnal Penelitian Geografis & Folklor Lokal:**  
   Jurnal *"Legenda Petilasan Calon Arang di Desa Sukorejo"* (E-Journal Universitas Negeri Surabaya / Unesa). Digunakan sebagai validasi lokalitas historis Desa Girah di Kecamatan Gurah, Kabupaten Kediri, Jawa Timur serta nilai kearifan lokal masyarakat setempat.
5. **Referensi Penunjang Edukasi Herbal Nusantara:**  
   *Formularium Ramuan Obat Tradisional Indonesia (FROTI)* — Kementerian Kesehatan Republik Indonesia (Keputusan Menteri Kesehatan RI) serta literatur etnobotani tanaman obat Nusantara untuk memastikan khasiat 40 herbal pada sistem alkimia bersifat akurat, edukatif, dan tidak menyesatkan.

---

## 5. Target Pemain dan Tujuan Edukasi

### 5.1 Profil Target Pemain

- **Kelompok Usia Utama:** 12–25 tahun (pelajar tingkat SMP/SMA/SMK, mahasiswa, serta penikmat gim indie 2D).
- **Profil Bermain:** Pemain kasual hingga menengah (*casual-to-midcore*) yang menyukai gim petualangan 2D *top-down*, manajemen strategi ringan (*tactical*), dan mekanik *crafting* / alkimia.
- **Aksesibilitas Perangkat:** Dapat dijalankan dengan lancar pada komputer/laptop spesifikasi standar (PC Windows/Linux) maupun langsung melalui peramban web (*Web Browser / HTML5*) tanpa memerlukan kartu grafis kelas atas.

### 5.2 Tujuan Edukasi (*Learning Objectives*)

Gim ini menerapkan pendekatan **Edukasi Terintegrasi (*Stealth / Embedded Learning*)**, yaitu pengetahuan sejarah dan tanaman herbal menjadi **mekanik inti untuk menang**, bukan sekadar pop-up kuis pilihan ganda yang ditempelkan.

| Dimensi Pembelajaran | Tujuan Spesifik yang Dicapai Pemain | Implementasi dalam Mekanik Gim |
| :--- | :--- | :--- |
| **Kognitif 1: Sejarah & Cerita Rakyat** | Pemain mengenali tokoh, latar waktu (Kerajaan Kahuripan abad ke-11, Prabu Airlangga), dan lokasi akurat (Desa Girah / Gurah, Kediri) kisah Calon Arang. | Dialog prolog/epilog, catatan *lore* antar-stage, dan misi segel kitab *Lipyakara* bersama Ratna Manggali. |
| **Kognitif 2: Fitoterapi / Herbal Nusantara** | Pemain mampu mengidentifikasi minimal 20–40 jenis tanaman obat Indonesia beserta fungsi utamanya (antipiretik, antiseptik, pereda batuk, pencernaan, detoksifikasi, penenang). | Sistem diagnosa gejala warga dan peracikan berbasis *Tag Efek* di Meja Alkimia serta ensiklopedia *Buku Lontar Usada*. |
| **Kognitif 3: Kesadaran Keamanan Bahan Alam** | Pemain memahami bahwa tidak semua tanaman alam aman dikonsumsi langsung; beberapa tanaman berpotensi racun (*toksik*) seperti Kecubung jika tanpa penetralan atau dosis tepat. | Mekanik tag `toksik` yang menimbulkan kegagalan racik kecuali dinetralkan tag `detoks` atau dihindari. |
| **Afektif & Budaya** | Menumbuhkan apresiasi terhadap warisan cerita rakyat Jawa Timur Klasik dan kearifan lokal pengobatan tradisional (*Usada* / Jamu Nusantara). | Estetika visual Jawa Klasik, umpan balik naratif yang menghargai peran penyembuhan, serta epilog pemulihan Desa Girah. |

---

## 6. Genre, Sinopsis, dan Adaptasi Cerita

### 6.1 Rasionalisasi Genre

Pemilihan genre **2D Top-Down Tactical Action-Adventure & Herbal Alchemy** memberikan keseimbangan antara ketegangan aksi dan ketenangan berpikir:
- **Aspek Tactical & Herbal Alchemy (Tabib):** Melatih daya analisis pemain dalam membaca gejala pasien, memilih kombinasi herbal yang tepat guna, dan memutuskan kapan harus mengirim pengawal ke zona berbahaya.
- **Aspek Action-Adventure (Mpu Bahula / Lini Serang):** Menghadirkan variasi tempo (*pacing*) agar gim tidak monoton, memberikan tantangan navigasi serta pertarungan ringan untuk memperoleh herbal langka.

### 6.2 Sinopsis Permainan

Pada abad ke-11 Masehi di wilayah **Kerajaan Kahuripan** yang dipimpin oleh **Prabu Airlangga**, tersiar kabar duka dari **Desa Girah** (kini wilayah Gurah, Kediri). Seorang janda sakti bernama **Calon Arang** (*Walu Nateng Girah*) diliputi amarah karena putrinya yang cantik dan berbudi luhur, **Ratna Manggali**, dijauhi oleh para pemuda desa yang gentar terhadap ilmu hitam ibunya. Di bawah cahaya bulan di Kuil Dewi Durga, Calon Arang membuka kitab terlarang **Lipyakara** dan menyebarkan kabut *teluh* (wabah penyakit misterius) ke seluruh penjuru desa. Warga tumbang dengan beragam gejala—dari demam membara, sesak kabut, ruam bernanah, hingga igau berkepanjangan.

Mengetahui rakyatnya menderita, **Prabu Airlangga** berunding dengan **Patih Narottama** dan pendeta agung **Mpu Bharada** dari pertapaan Lemah Tulis. Mereka menyadari bahwa kekuatan pedang saja tidak cukup untuk menghentikan wabah; rakyat membutuhkan penyembuh sekaligus strategi untuk mematahkan sumber kutukan. Maka diutuslah **Tabib Wira**, murid muda ahli *Usada* (ilmu pengobatan herbal Nusantara) dari padepokan Mpu Bharada, bersama **Mpu Bahula**—murid utama Mpu Bharada yang cakap olah kanuragan dan didampingi dukungan pengawal Kahuripan.

Dalam perjalanan melintasi pinggiran Desa Girah, Hutan Bambu & Sendang, hingga Pedepokan Girah, Tabib Wira harus mendiagnosa warga yang sakit, mengumpulkan herbal Nusantara, dan meracik obat penawar di meja alkimia, sembari menugaskan Mpu Bahula menerobos kabut pekat untuk memanen herbal langka dan menghalau para antek teluh. Dengan bantuan petunjuk dari **Ratna Manggali** yang mendambakan kedamaian, keduanya akhirnya tiba di **Altar Kuil Durga** untuk menghadapi Calon Arang secara langsung—memadukan ketangguhan Mpu Bahula dalam membuka celah Perisai Teluh dengan kecerdasan Tabib Wira dalam meracik **Penawar Suci** demi memulihkan Desa Girah dan mengembalikan ketenteraman Kahuripan.

### 6.3 Daftar Tokoh Utama dan Perannya dalam Gim

| Tokoh | Kedudukan dalam Lore | Peran dalam Gameplay |
| :--- | :--- | :--- |
| **Tabib Wira** *(Protagonis 1)* | Murid muda ilmu *Usada* utusan Mpu Bharada. | **Karakter Utama 1 (Non-Combat):** Mendiagnosa warga, memanen herbal di zona aman, meracik ramuan di Meja Alkimia, mengobati pasien, dan menugaskan Lini Serang. |
| **Mpu Bahula** *(Protagonis 2 / Lini Serang)* | Murid setia Mpu Bharada; cakap bela diri, bijaksana, kelak mempersunting Ratna Manggali dalam naskah asli. | **Karakter Utama 2 (Combat — Proxy Control):** Bergerak ke zona berbahaya atas tugas Tabib, melawan penjaga herbal/antek teluh, memanen herbal langka/sakral, dan membuka celah Perisai Teluh Calon Arang. |
| **Calon Arang (*Walu Nateng Girah*)** | Janda sakti penguasa ilmu hitam di Desa Girah, pemegang kitab *Lipyakara*. | **Antagonis Utama & Final Boss (Stage 4):** Penyebar wabah teluh yang dilindungi Perisai Teluh kebal serangan fisik biasa; harus ditaklukkan dengan kombinasi celah serangan Mpu Bahula dan Penawar Suci Tabib. |
| **Ratna Manggali** | Putri Calon Arang yang lembut hati dan tidak menyetujui penyebaran wabah. | **NPC Kunci (Stage 3):** Memberikan petunjuk rahasia mengenai pola kutukan *Lipyakara* dan lokasi herbal sakral di sekitar Pedepokan Girah. |
| **Prabu Airlangga** | Raja Kerajaan Kahuripan (abad ke-11). | **NPC Narasi (Prolog & Epilog):** Memberi mandat misi penyelamatan Desa Girah dan penghargaan atas pemulihan wilayah. |
| **Mpu Bharada** | Pendeta agung & penasihat spiritual Kahuripan di Lemah Tulis. | **NPC Mentor (Tutorial & Prolog):** Menyediakan *Buku Lontar Usada*, menjelaskan mekanik peracikan, dan membimbing strategi penetralan *Lipyakara*. |
| **Patih Narottama** | Mahapatih Kerajaan Kahuripan yang setia. | **NPC Narasi (Prolog & Transisi Stage):** Melaporkan kondisi tingkat keparahan wabah di lapangan serta mendukung posko pengamanan Kahuripan. |

### 6.4 Adaptasi Alur Cerita ke Struktur 4 Stage

| Stage | Lokasi | Peristiwa Narasi (Adaptasi Cerita Rakyat) | Fokus Edukasi & Gameplay |
| :---: | :--- | :--- | :--- |
| **Stage 1** | **Pinggiran Desa Girah** | Wabah awal mulai menyebar dari arah pedepokan. Posko darurat didirikan di tepi desa. | Tutorial diagnosa 1–2 gejala, panen herbal aman (empon-empon & daun umum), pengenalan *Proxy Control* ringan. |
| **Stage 2** | **Hutan Bambu & Sendang Girah** | Wabah memburuk; herbal umum tidak lagi cukup. Tabib membutuhkan rimpang dan akar dari sendang berkabut yang dijaga antek teluh. | Pengenalan herbal langka, tanaman beracun (*Kecubung* bertag `toksik`), kombinasi 2 gejala menengah, dan pertempuran penjaga herbal. |
| **Stage 3** | **Sekitar Pedepokan Girah** | Mpu Bahula dan Tabib menyusup mendekati kediaman Calon Arang. Ratna Manggali memberi petunjuk untuk menyegel energi kitab *Lipyakara*. | Pasien dengan 2–3 gejala termasuk gejala kutukan (`kutukan_kabut`), pengumpulan herbal sakral (`suci_teluh`), pertarungan intensitas tinggi. |
| **Stage 4** | **Altar Kuil Durga** | Puncak konflik: Calon Arang memanggil kekuatan puncak *Lipyakara*. Perisai Teluhnya kebal terhadap senjata biasa. | **Boss Fight 3 Fase:** Sinergi penuh *Proxy Control*—Mpu Bahula membuka celah perisai, Tabib meracik Penawar Suci sesuai gejala kutukan yang berubah dinamis. |

---

*Catatan: Dokumen ini menjadi acuan bersama bagi seluruh anggota tim dan terhubung langsung dengan `02_GDD.md`, `03_ALCHEMI_HERBAL.md`, `04_FLOWCHART_DAN_LEVEL.md`, dan `05_STORYBOARD.md`.*
