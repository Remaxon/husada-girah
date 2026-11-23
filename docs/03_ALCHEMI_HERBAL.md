# Dokumen 03: Desain Sistem Alkimia Herbal & Basis Data (Data-Driven)

**Acuan untuk:** Anggota 1 (Validasi Edukasi), Anggota 2 (Implementasi `AlchemyDatabase.gd` & JSON), Anggota 3 (Ikon 40 Herbal & UI Meja Alkimia)  
**Arsitektur:** *Data-Driven Tag-Based Herbal Alchemy* (`herbs.json` & `symptoms.json`)

---

## 1. Konsep & Arsitektur Sistem Alkimia Berbasis Tag Efek

Berbeda dari gim *crafting* konvensional yang memakai resep keras (*hardcoded recipe*, mis. *"Hanya Jahe + Madu = Obat Batuk"*), **Husada Girah** menggunakan **Sistem Alkimia Berbasis Tag Efek (*Effect-Tag Matching*)**.

### 1.1 Keunggulan Edukatif & Teknis
1. **Ratusan Kombinasi Ramuan Valid:** Setiap herbal memiliki **2 hingga 3 Tag Efek** yang sesuai dengan khasiat nyatanya dalam pengobatan tradisional Nusantara (*Usada* / Jamu). Dengan 40 herbal dan sistem pasien multi-gejala (1–3 gejala), terdapat **ratusan kombinasi 2–3 herbal yang sah secara farmakologis**. Pemain diajak bernalar menggunakan sifat tanaman, bukan menghafal resep mati.
2. **Skalabilitas Tinggi (*Data-Driven*):** Seluruh data herbal dan gejala disimpan di berkas eksternal `res://data/herbs.json` dan `res://data/symptoms.json`. Menambah herbal ke-41 hingga ke-100+ tidak memerlukan perubahan logika kode GDScript.
3. **Pengenalan Keamanan Bahan Alam:** Menyertakan mekanik tag `toksik` untuk mengajarkan bahwa tanaman tertentu (seperti Kecubung) memiliki efek keras/beracun yang berbahaya bila diracik sembarangan tanpa penetralan `detoks`.

---

## 2. Daftar 12 Tag Efek Resmi (*Canonical Effect Tags*)

Seluruh herbal dan gejala di dalam gim merujuk secara konsisten pada 12 kode *tag* berikut:

| No. | Kode Tag (`tag_id`) | Nama Tampilan UI | Warna Badge UI | Fungsi / Makna Edukatif |
| :---: | :--- | :--- | :--- | :--- |
| 1 | `anti_demam` | Penurun Panas | Biru Muda (`#3498DB`) | Antipiretik — menurunkan demam tinggi dan rasa terbakar. |
| 2 | `anti_radang` | Pereda Radang | Oranye Hangat (`#E67E22`) | Antiinflamasi — meredakan pembengkakan dan peradangan sendi/jaringan. |
| 3 | `anti_batuk` | Pelega Napas | Toska (`#1ABC9C`) | Antitusif & ekspektoran — mengencerkan dahak, meredakan batuk dan sesak. |
| 4 | `pencernaan` | Penenang Perut | Kuning Kunyit (`#F1C40F`) | Karminatif & antidiare — meredakan mual, kembung, mulas, dan diare. |
| 5 | `detoks` | Penawar Racun | Hijau Zamrud (`#27AE60`) | Detoksifikasi — menetralkan racun/bisa darah serta **menetralkan tag `toksik`**. |
| 6 | `penenang` | Penenang Jiwa | Lavender (`#9B59B6`) | Sedatif alami — menenangkan gelisah, igau, dan gangguan tidur akibat teluh. |
| 7 | `imunitas` | Pemulih Daya | Hijau Daun (`#2ECC71`) | Imunomodulator & tonikum — memulihkan stamina, lesu, dan daya tahan tubuh. |
| 8 | `antiseptik` | Antiseptik Luka | Merah Muda Tua (`#E84393`) | Antimikroba — membersihkan ruam, infeksi kulit, dan luka bernanah. |
| 9 | `sirkulasi` | Penghangat Tubuh | Merah Jahe (`#C0392B`) | Vasodilator/penghangat — melancarkan peredaran darah dan mengusir dingin menggigil. |
| 10 | `anti_nyeri` | Pereda Nyeri | Cokelat Rempah (`#A0522D`) | Analgesik alami — mengurangi sakit kepala hebat, pegal, dan kejang otot. |
| 11 | `suci_teluh` | Penawar Suci *(Sakral)* | Emas Keraton (`#D4A017`) | Tag khusus *lore* Usada dari herbal sakral untuk memecah kutukan *Lipyakara* dan *Perisai Teluh*. |
| 12 | `toksik` | **Peringatan Toksik** *(Risiko)* | Ungu Gelap (`#5B2C6F`) | Tag bahaya pada tanaman beracun dosis tinggi; **harus dinetralkan oleh minimal 1 herbal bertag `detoks`** dalam racikan yang sama. |

---

## 3. Aturan & Algoritma Pencocokan Ramuan

Saat Tabib memasukkan **2 hingga 3 herbal** (maksimal 3 slot; minimal 2 herbal agar menjadi *ramuan*, kecuali tutorial darurat 1 gejala tertentu tetap disarankan 2 herbal untuk efisiensi) di Meja Alkimia, `AlchemyDatabase.gd` mengevaluasi ramuan dengan langkah deterministik berikut:

1. **Kumpulkan Tag Kebutuhan Pasien (`R`):** Gabungkan seluruh `required_tags` unik dari gejala yang diderita pasien (atau kutukan aktif Boss).
2. **Kumpulkan Tag Ramuan (`P`):** Gabungkan seluruh `effect_tags` unik dari herbal yang dimasukkan pemain ke dalam 2–3 slot lumpang.
3. **Cek Keamanan Toksik (Prioritas Tertinggi):**
   - Jika `"toksik" in P` **DAN** `"detoks" not in P` → Status: **`TOXIC` (Gagal Berbahaya)**. Ramuan tidak boleh diberikan/menyebabkan reaksi buruk, *Wabah Meter* `+5%`, skor `-50`, muncul edukasi penetralan racun.
   - Jika `"toksik" in P` **DAN** `"detoks" in P` → Efek `toksik` **dinetralkan**, lanjut ke langkah 4 (pemain bahkan mendapat catatan pujian edukatif karena mampu mengolah bahan berisiko secara aman!).
4. **Cek Kecocokan Tag (`Matched = R ∩ P`):**
   - **Kasus A — Semua Tag Terpenuhi (`Matched == R`):**
     - Cek **Efisiensi Bahan**: Apakah setiap herbal yang dimasukkan menyumbang minimal 1 tag yang dibutuhkan `R` (atau bertindak sebagai penetral `detoks` untuk bahan `toksik`)?
       - Jika **YA** (tidak ada herbal yang sama sekali tidak relevan) → Status: **`PERFECT` (*Usada Utama*)**. Pasien 100% sembuh + Skor Penuh + Bonus Akurasi (`+150`).
       - Jika **TIDAK** (ada 1 herbal yang tidak menyumbang tag relevan sama sekali) → Status: **`GOOD` (*Usada Madya*)**. Pasien 100% sembuh + Skor Dasar (tanpa bonus akurasi) + saran efisiensi.
   - **Kasus B — Sebagian Tag Terpenuhi (`0 < |Matched| < |R|`):**
     - Status: **`PARTIAL` (*Kurang Ampuh*)**. Gejala yang tag-nya terpenuhi langsung sembuh dan hilang dari pasien, sedangkan gejala sisanya tetap bertahan. Umpan balik menyebut jelas nama gejala yang belum teratasi dan tag yang masih dibutuhkan.
   - **Kasus C — Tidak Ada Tag Cocok (`|Matched| == 0`):**
     - Status: **`FAIL` (*Racikan Salah*)**. Bahan terbuang, *Wabah Meter* `+5%`, skor `-50`, muncul petunjuk edukatif merujuk ke *Buku Lontar Usada*.

---

## 4. Daftar Lengkap 40 Herbal Nusantara Asli

Basis data awal gim terdiri atas **40 tanaman obat asli Nusantara** yang dikelompokkan ke dalam **5 kategori botani**. Seluruh khasiat didasarkan pada pengetahuan etnobotani Indonesia, tradisi *Usada*, dan acuan Formularium Obat Tradisional Indonesia.

### Kategori A: Empon-Empon / Rimpang (10 Herbal)

| No. | ID JSON (`id`) | Nama Indonesia (Lokal) & *Nama Latin* | Tag Efek (2–3 Tag) | Kelangkaan | Lokasi Stage & Zona | Catatan Edukasi Khasiat Nyata |
| :---: | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | `jahe_merah` | **Jahe Merah** (*Zingiber officinale var. rubrum*) | `sirkulasi`, `anti_batuk`, `anti_radang` | Umum | Stage 1 (Zona Aman) | Mengandung *gingerol* & *shogaol* tinggi yang menghangatkan tubuh, melancarkan darah, dan melegakan batuk. |
| 2 | `kunyit` | **Kunyit / Kunir** (*Curcuma longa*) | `anti_radang`, `pencernaan`, `antiseptik` | Umum | Stage 1 (Zona Aman) | Kaya *kurkumin* yang ampuh meredakan peradangan, menenangkan lambung/mual, dan membantu penyembuhan luka. |
| 3 | `temulawak` | **Temulawak** (*Curcuma zanthorrhiza*) | `imunitas`, `pencernaan`, `detoks` | Umum | Stage 1 (Zona Aman) | Mengandung *xanthorrhizol* untuk menjaga kesehatan hati (detoksifikasi alami), nafsu makan, dan daya tahan tubuh. |
| 4 | `kencur` | **Kencur / Cikur** (*Kaempferia galanga*) | `anti_batuk`, `anti_nyeri`, `sirkulasi` | Umum | Stage 1 (Zona Aman) | Rimpang andalan jamu beras kencur; efektif melegakan tenggorokan/batuk, meredakan pegal nyeri, dan menghangatkan. |
| 5 | `lengkuas` | **Lengkuas / Laos** (*Alpinia galanga*) | `antiseptik`, `pencernaan`, `sirkulasi` | Umum | Stage 1 (Zona Aman) | Bersifat antimikroba/antijamur alami untuk gangguan kulit, menghangatkan tubuh, dan meredakan kembung. |
| 6 | `temu_kunci` | **Temu Kunci** (*Boesenbergia rotunda*) | `pencernaan`, `anti_batuk`, `antiseptik` | Umum | Stage 1 (Zona Aman) | Sering digunakan dalam ramuan tradisional Jawa untuk meredakan gangguan perut, batuk kering, dan sariawan/infeksi ringan. |
| 7 | `temu_ireng` | **Temu Ireng / Temu Hitam** (*Curcuma aeruginosa*) | `detoks`, `pencernaan`, `imunitas` | Tidak Umum | Stage 2 (Zona Aman) | Rimpang pahit berkhasiat membersihkan racun pencernaan, cacingan, dan memulihkan kebugaran pascasakit. |
| 8 | `lempuyang` | **Lempuyang Wangi** (*Zingiber zerumbet*) | `anti_demam`, `anti_nyeri`, `anti_radang` | Tidak Umum | Stage 2 (Zona Aman) | Mengandung *zerumbon* yang secara tradisional digunakan dalam jamu cabe puyang untuk meredakan demam dan nyeri sendi. |
| 9 | `bangle` | **Bangle / Bengle** (*Zingiber montanum*) | `anti_demam`, `anti_nyeri`, `penenang` | Tidak Umum | Stage 2 (Zona Berbahaya) | Rimpang aromatik tajam dalam tradisi *Usada* untuk meredakan demam, sakit kepala, dan menenangkan rasa gelisah. |
| 10 | `temu_putih` | **Temu Putih** (*Curcuma zedoaria*) | `detoks`, `anti_radang`, `imunitas` | Langka | Stage 3 (Zona Berbahaya) | Rimpang langka bernilai tinggi dalam pengobatan tradisional sebagai antiinflamasi kuat dan penetral racun jaringan. |

### Kategori B: Daun Berkhasiat (10 Herbal)

| No. | ID JSON (`id`) | Nama Indonesia (Lokal) & *Nama Latin* | Tag Efek (2–3 Tag) | Kelangkaan | Lokasi Stage & Zona | Catatan Edukasi Khasiat Nyata |
| :---: | :--- | :--- | :--- | :--- | :--- | :--- |
| 11 | `daun_sirih` | **Daun Sirih Hijau** (*Piper betle*) | `antiseptik`, `anti_batuk`, `anti_radang` | Umum | Stage 1 (Zona Aman) | Mengandung minyak atsiri *kavikol* & *eugenol* sebagai antiseptik kuat untuk luka/ruam serta peluruh batuk. |
| 12 | `sambiloto` | **Sambiloto** (*Andrographis paniculata*) | `anti_demam`, `detoks`, `imunitas` | Tidak Umum | Stage 1 (Zona Berbahaya) & Stage 2 | Dijuluki *Raja Pahit*; mengandung *andrografolid* yang sangat efektif menurunkan demam tinggi dan menstimulasi imunitas. |
| 13 | `meniran` | **Meniran** (*Phyllanthus niruri*) | `imunitas`, `anti_demam`, `detoks` | Umum | Stage 1 (Zona Aman) | Tanaman liar berkhasiat imunomodulator tinggi (memperkuat sistem kekebalan), membantu fungsi hati, dan meredakan demam. |
| 14 | `daun_jambu_biji` | **Daun Jambu Biji** (*Psidium guajava*) | `pencernaan`, `antiseptik` | Umum | Stage 1 (Zona Aman) | Kaya *tanin* dan *kuersetin* yang telah teruji secara klinis tradisional untuk mengatasi diare, mulas, dan infeksi luka ringan. |
| 15 | `daun_salam` | **Daun Salam** (*Syzygium polyanthum*) | `pencernaan`, `anti_radang`, `sirkulasi` | Umum | Stage 1 (Zona Aman) | Daun rempah Nusantara yang membantu menenangkan gangguan pencernaan, meredakan radang sendi, dan melancarkan peredaran. |
| 16 | `daun_kelor` | **Daun Kelor** (*Moringa oleifera*) | `imunitas`, `anti_radang`, `detoks` | Umum | Stage 1 (Zona Aman) | Dikenal luas dalam budaya Jawa sebagai *pohon ajaib*; padat nutrisi antioksidan untuk memulihkan kelelahan dan peradangan. |
| 17 | `pegagan` | **Pegagan / Antanan** (*Centella asiatica*) | `penenang`, `antiseptik`, `sirkulasi` | Tidak Umum | Stage 2 (Zona Aman) | Tumbuh di tepi sendang lembap; mengandung *asiatikosida* untuk mempercepat regenerasi luka kulit, menenangkan saraf, dan melancarkan aliran darah. |
| 18 | `kumis_kucing` | **Kumis Kucing** (*Orthosiphon aristatus*) | `detoks`, `anti_radang` | Tidak Umum | Stage 2 (Zona Aman) | Bersifat diuretik alami untuk membantu pembuangan racun metabolik tubuh serta meredakan bengkak/radang. |
| 19 | `daun_saga` | **Daun Saga Manis** (*Abrus precatorius*) | `anti_batuk`, `anti_demam`, `anti_radang` | Tidak Umum | Stage 2 (Zona Aman) | Daunnya (bukan bijinya) dimanfaatkan secara turun-temurun untuk meredakan batuk serak, panas dalam, dan radang tenggorokan. |
| 20 | `daun_bidara` | **Daun Bidara** (*Ziziphus mauritiana*) | `antiseptik`, `penenang`, `suci_teluh` | Langka | Stage 3 (Zona Berbahaya) | Selain bersifat antibakteri luka dan penenang alami, dalam tradisi budaya Nusantara daun bidara dipercaya membantu pembersihan energi buruk. |

### Kategori C: Akar, Batang & Kulit Kayu (7 Herbal)

| No. | ID JSON (`id`) | Nama Indonesia (Lokal) & *Nama Latin* | Tag Efek (2–3 Tag) | Kelangkaan | Lokasi Stage & Zona | Catatan Edukasi Khasiat Nyata |
| :---: | :--- | :--- | :--- | :--- | :--- | :--- |
| 21 | `akar_alang_alang` | **Akar Alang-Alang** (*Imperata cylindrica*) | `anti_demam`, `detoks`, `penenang` | Umum | Stage 1 (Zona Aman) | Ramuan pendingin klasik Nusantara untuk menurunkan panas dalam/demam, melancarkan pembuangan racun, dan menyejukkan gelisah. |
| 22 | `kayu_manis` | **Kayu Manis** (*Cinnamomum verum*) | `sirkulasi`, `pencernaan`, `anti_radang` | Umum | Stage 1 (Zona Aman) | Kulit kayu aromatik penghangat tubuh, pereda mual/kembung, dan kaya antioksidan antiinflamasi. |
| 23 | `kayu_secang` | **Kayu Secang** (*Biancaea sappan*) | `sirkulasi`, `antiseptik`, `imunitas` | Tidak Umum | Stage 2 (Zona Aman) | Menghasilkan warna merah alami dari senyawa *brazilin*; bahan utama wedang uwuh untuk menghangatkan darah dan meningkatkan stamina. |
| 24 | `brotowali` | **Brotowali / Bratawali** (*Tinospora crispa*) | `anti_demam`, `detoks`, `anti_nyeri` | Tidak Umum | Stage 2 (Zona Berbahaya) | Batang merambat berasa sangat pahit yang terkenal ampuh meredakan demam malaria/panas tinggi, nyeri sendi, dan detoksifikasi. |
| 25 | `pasak_bumi` | **Pasak Bumi** (*Eurycoma longifolia*) | `imunitas`, `anti_demam`, `sirkulasi` | Langka | Stage 3 (Zona Berbahaya) | Akar kuat khas Nusantara yang dimanfaatkan sebagai tonikum pemulih daya tahan ekstrem dan penurun demam berat. |
| 26 | `kulit_pule` | **Kulit Kayu Pule / Pulai** (*Alstonia scholaris*) | `anti_demam`, `anti_nyeri`, `detoks` | Langka | Stage 3 (Zona Berbahaya) | Pohon keramat Jawa-Bali; kulit batangnya tercatat dalam naskah *Usada* sebagai obat demam tinggi, nyeri hebat, dan penawar racun. |
| 27 | `kayu_cendana` | **Kayu Cendana** (*Santalum album*) | `penenang`, `antiseptik`, `suci_teluh` | Sangat Langka | Stage 3 & Stage 4 (Zona Berbahaya) | Aromanya menenangkan pikiran (*santalol*), bersifat antiseptik kulit, serta menjadi bahan sakral ritual pembersihan Jawa-Bali klasik. |

### Kategori D: Rempah, Biji & Batang Wangi (7 Herbal)

| No. | ID JSON (`id`) | Nama Indonesia (Lokal) & *Nama Latin* | Tag Efek (2–3 Tag) | Kelangkaan | Lokasi Stage & Zona | Catatan Edukasi Khasiat Nyata |
| :---: | :--- | :--- | :--- | :--- | :--- | :--- |
| 28 | `serai_wangi` | **Serai / Sereh** (*Cymbopogon citratus*) | `sirkulasi`, `penenang`, `anti_nyeri` | Umum | Stage 1 (Zona Aman) | Mengandung *sitronelal* & *geraniol* yang merelaksasi otot tegang, meredakan nyeri kepala, dan menghangatkan tubuh. |
| 29 | `adas_manis` | **Adas / Adas Pulosari** (*Foeniculum vulgare*) | `anti_batuk`, `pencernaan`, `anti_radang` | Umum | Stage 1 (Zona Aman) | Biji rempah lembut untuk mengencerkan dahak batuk, mengusir angin/mulas perut, dan meredakan radang ringan. |
| 30 | `ketumbar` | **Ketumbar** (*Coriandrum sativum*) | `pencernaan`, `anti_radang`, `penenang` | Umum | Stage 1 (Zona Aman) | Biji rempah dapur yang membantu meredakan mual, mengurangi peradangan ringan, dan memberikan efek menenangkan. |
| 31 | `cengkeh` | **Cengkeh** (*Syzygium aromaticum*) | `anti_nyeri`, `antiseptik`, `sirkulasi` | Tidak Umum | Stage 2 (Zona Aman) | Rempah asli Kepulauan Nusantara; kandungan *eugenol*-nya kuat meredakan nyeri, membunuh kuman luka, dan menghangatkan tubuh. |
| 32 | `kapulaga` | **Kapulaga Jawa** (*Wurfbainia compacta*) | `anti_batuk`, `pencernaan`, `sirkulasi` | Tidak Umum | Stage 2 (Zona Aman) | Rempah endemik Jawa yang melegakan pernapasan/batuk berkabut, menyehatkan lambung, dan melancarkan peredaran. |
| 33 | `lada_hitam` | **Lada Hitam / Merica** (*Piper nigrum*) | `sirkulasi`, `anti_batuk`, `imunitas` | Tidak Umum | Stage 2 (Zona Aman) | Senyawa *piperin* meningkatkan kehangatan tubuh, membantu melegakan saluran napas, dan meningkatkan penyerapan khasiat herbal lain. |
| 34 | `biji_pala` | **Biji Pala** (*Myristica fragrans*) | `penenang`, `pencernaan`, `anti_nyeri` | Tidak Umum | Stage 2 (Zona Berbahaya) | Rempah bernilai tinggi asal Nusantara; dalam takaran tepat efektif menenangkan insomnia/igau, meredakan mulas, dan mengurangi nyeri. |

### Kategori E: Bunga, Buah & Herbal Langka / Sakral (6 Herbal)

| No. | ID JSON (`id`) | Nama Indonesia (Lokal) & *Nama Latin* | Tag Efek (2–3 Tag) | Kelangkaan | Lokasi Stage & Zona | Catatan Edukasi Khasiat Nyata |
| :---: | :--- | :--- | :--- | :--- | :--- | :--- |
| 35 | `asam_jawa` | **Asam Jawa** (*Tamarindus indica*) | `anti_demam`, `pencernaan`, `anti_radang` | Umum | Stage 1 (Zona Aman) | Pasangan klasik kunyit (*kunir asem*); membantu menyejukkan suhu demam, melancarkan pencernaan, dan meredakan radang. |
| 36 | `jeruk_nipis` | **Jeruk Nipis** (*Citrus aurantiifolia*) | `anti_batuk`, `detoks`, `imunitas` | Umum | Stage 1 (Zona Aman) | Kaya vitamin C & asam sitrat; tradisional digunakan untuk meluruhkan dahak batuk, membantu detoksifikasi, dan menjaga imunitas. |
| 37 | `bunga_melati` | **Bunga Melati** (*Jasminum sambac*) | `penenang`, `anti_demam`, `antiseptik` | Tidak Umum | Stage 2 (Zona Aman) | Aromanya menenangkan kegelisahan, sedangkan kompres daun/bunganya secara tradisional dipakai membantu meredakan panas dan ruam. |
| 38 | `bunga_kenanga` | **Bunga Kenanga** (*Cananga odorata*) | `penenang`, `anti_nyeri`, `suci_teluh` | Langka | Stage 3 (Zona Berbahaya) | Minyak atsirinya berkhasiat aromaterapi penenang & pereda ketegangan; bagian dari bunga setaman sakral tradisi Jawa Klasik. |
| 39 | `biji_kecubung` | **Kecubung Gunung** (*Datura metel*) | `anti_nyeri`, `penenang`, **`toksik`** | Langka *(Berisiko)* | Stage 2 & Stage 3 (Zona Berbahaya) | **Peringatan Edukatif:** Mengandung alkaloid tropana (*skopolamin*) pereda nyeri/penenang kuat, tetapi **BERACUN** jika dikonsumsi mentah! Wajib dinetralkan dengan herbal bertag `detoks` di dalam gim. |
| 40 | `bunga_wijayakusuma` | **Wijaya Kusuma / Sekar Kahuripan** (*Epiphyllum oxypetalum*) | `suci_teluh`, `imunitas`, `detoks` | Sangat Langka | Stage 4 (Zona Altar Durga) | Bunga mekar malam yang melegenda dalam budaya keraton Jawa sebagai lambang pemulihan kejayaan dan penawar kutukan tertinggi. |

---

## 5. Daftar 12 Gejala Wabah (*Symptoms*) & Sistem Multi-Gejala

### 5.1 Tabel 12 Gejala Wabah Girah

| No. | ID JSON (`id`) | Nama Gejala | Tingkat | Tag Penawar Wajib (`required_tags`) | Muncul Mulai | Deskripsi Gejala (Tampil saat Diagnosa) |
| :---: | :--- | :--- | :--- | :--- | :---: | :--- |
| 1 | `demam_panas` | **Demam Membara** | Ringan | `["anti_demam"]` | Stage 1 | Tubuh warga terasa sangat panas bagai bara setelah terpapar angin Desa Girah. |
| 2 | `batuk_kabut` | **Batuk Kabut & Sesak** | Ringan | `["anti_batuk"]` | Stage 1 | Batuk kering berkepanjangan dan napas pendek akibat menghirup asap teluh. |
| 3 | `mual_perut` | **Mual & Mulas Wabah** | Ringan | `["pencernaan"]` | Stage 1 | Perut melilit, mual hebat, dan diare sehingga tidak mampu menelan makanan. |
| 4 | `luka_ruam` | **Ruam & Luka Bernanah** | Ringan | `["antiseptik"]` | Stage 1 | Muncul bintik ruam merah dan borok kulit yang rentan terinfeksi. |
| 5 | `bengkak_sendi` | **Radang & Sendi Bengkak** | Ringan | `["anti_radang"]` | Stage 1 | Persendian membengkak dan kaku sehingga warga tidak sanggup berjalan. |
| 6 | `menggigil_beku` | **Menggigil Dingin Teluh** | Menengah | `["sirkulasi"]` | Stage 1 | Ujung jari membiru dan tubuh menggigil hebat meski di bawah terik matahari. |
| 7 | `nyeri_kepala` | **Nyeri Kepala Menusuk** | Menengah | `["anti_nyeri"]` | Stage 2 | Sakit kepala luar biasa dan otot leher menegang bagai dihimpit batu. |
| 8 | `lemah_lesu` | **Lesu & Kehilangan Daya** | Menengah | `["imunitas"]` | Stage 1 | Tubuh terkulai lemas, pucat, dan daya tahan menurun drastis. |
| 9 | `racun_darah` | **Keracunan Bisa Gelap** | Menengah | `["detoks"]` | Stage 2 | Nadi berdenyut lemah dengan bercak kehitaman menandakan racun masuk aliran darah. |
| 10 | `igau_resah` | **Igau & Mimpi Buruk** | Menengah | `["penenang"]` | Stage 2 | Warga mengigau ketakutan, gelisah, dan dihantui bayangan buruk teluh. |
| 11 | `kutukan_kabut` | **Belenggu Kabut Teluh** | Kutukan | `["detoks", "suci_teluh"]` | Stage 3 | Asap hitam melilit tubuh warga; hanya dapat dipatahkan gabungan penawar racun dan herbal sakral. |
| 12 | `segel_durga` | **Amarah Lipyakara** *(Khusus Boss)* | Kutukan Boss | `["penenang", "suci_teluh"]` | Stage 4 | Aura murka kitab *Lipyakara* Calon Arang; menuntut penawar suci penenang jiwa dan pemecah teluh. |

### 5.2 Contoh Studi Kasus Pasien Multi-Gejala & Pembuktian Ratusan Kombinasi Valid

Karena satu warga sakit memiliki **1 hingga 3 gejala** dan setiap herbal membawa **2 hingga 3 tag**, pemain dapat memecahkan satu kasus pasien dengan beragam kombinasi cerdas:

| Contoh Kasus Pasien | Gejala yang Terdiagnosa | Tag Wajib (`R`) | Contoh Kombinasi Valid **Usada Utama (2–3 Herbal)** | Catatan Variasi Kombinasi |
| :--- | :--- | :--- | :--- | :--- |
| **Pasien Stage 1 (Warga Tani)** | `demam_panas` + `mual_perut` | `anti_demam`, `pencernaan` | • `asam_jawa` + `kunyit`<br>• `meniran` + `temulawak`<br>• `akar_alang_alang` + `daun_jambu_biji` | Terdapat **> 40 pasangan** herbal Stage 1 yang sah! |
| **Pasien Stage 2 (Penjaga Sendang)** | `racun_darah` + `nyeri_kepala` + `igau_resah` | `detoks`, `anti_nyeri`, `penenang` | • `brotowali` (`detoks`, `anti_nyeri`) + `bunga_melati` (`penenang`)<br>• `biji_kecubung` (`anti_nyeri`, `penenang`, `toksik`) + `temulawak` (`detoks` penetral toksik!)<br>• `kumis_kucing` + `cengkeh` + `pegagan` | Menunjukkan sinergi brilian: *Kecubung* bisa aman jika dipasangkan dengan penetral `detoks`! |
| **Pasien Stage 3 (Warga Dekat Pedepokan)** | `kutukan_kabut` + `luka_ruam` | `detoks`, `suci_teluh`, `antiseptik` | • `temu_putih` (`detoks`) + `daun_bidara` (`antiseptik`, `suci_teluh`)<br>• `kulit_pule` (`detoks`) + `kayu_cendana` (`antiseptik`, `suci_teluh`)<br>• `sambiloto` + `bunga_kenanga` + `daun_sirih` | Membuka puluhan kombinasi 2–3 bahan dengan tingkat efisiensi berbeda. |
| **Boss Stage 4 (Fase 3 Calon Arang)** | `segel_durga` + `racun_darah` + `demam_panas` | `penenang`, `suci_teluh`, `detoks`, `anti_demam` | • `bunga_wijayakusuma` (`suci_teluh`, `detoks`) + `bunga_melati` (`penenang`, `anti_demam`)<br>• `kayu_cendana` (`penenang`, `suci_teluh`) + `sambiloto` (`anti_demam`, `detoks`) | Pemain harus cermat memilih herbal bernilai tag ganda agar cukup dalam batas **maksimal 3 slot lumpang**! |

> **Perhitungan Kombinasi:** Dengan 40 herbal dalam sistem kombinasi 2 bahan ($\binom{40}{2} = 780$ pasangan) dan 3 bahan ($\binom{40}{3} = 9.880$ kombinasi tripel), terdapat lebih dari **10.600 kemungkinan campuran** dengan ratusan ramuan valid yang relevan untuk berbagai profil 1–3 gejala pasien.

---

## 6. Contoh Skema Struktur JSON untuk Programmer

Dokumen ini menetapkan struktur baku untuk berkas `res://data/herbs.json` dan `res://data/symptoms.json` yang akan dibuat oleh Anggota 2 pada Minggu 2.

### 6.1 Skema `data/herbs.json`

```json
{
  "schema_version": "1.0",
  "herbs": [
    {
      "id": "jahe_merah",
      "name": "Jahe Merah",
      "local_name": "Jae Abang",
      "latin_name": "Zingiber officinale var. rubrum",
      "category": "empon_empon",
      "effect_tags": ["sirkulasi", "anti_batuk", "anti_radang"],
      "rarity": "umum",
      "stages": [1, 2, 3, 4],
      "zone_type": "safe",
      "icon_path": "res://assets/icons/herbs/jahe_merah.png",
      "educational_note": "Mengandung gingerol dan shogaol tinggi yang efektif menghangatkan tubuh, melancarkan peredaran darah, dan meredakan batuk."
    },
    {
      "id": "biji_kecubung",
      "name": "Kecubung Gunung",
      "local_name": "Kecubung",
      "latin_name": "Datura metel",
      "category": "bunga_buah_sakral",
      "effect_tags": ["anti_nyeri", "penenang", "toksik"],
      "rarity": "langka",
      "stages": [2, 3],
      "zone_type": "danger",
      "icon_path": "res://assets/icons/herbs/biji_kecubung.png",
      "educational_note": "PERINGATAN: Mengandung alkaloid beracun. Dalam tradisi pengobatan, penggunaannya sangat berisiko dan dalam gim wajib dinetralkan dengan herbal bertag Detoks."
    },
    {
      "id": "bunga_wijayakusuma",
      "name": "Wijaya Kusuma",
      "local_name": "Sekar Kahuripan",
      "latin_name": "Epiphyllum oxypetalum",
      "category": "bunga_buah_sakral",
      "effect_tags": ["suci_teluh", "imunitas", "detoks"],
      "rarity": "sangat_langka",
      "stages": [4],
      "zone_type": "danger",
      "icon_path": "res://assets/icons/herbs/bunga_wijayakusuma.png",
      "educational_note": "Bunga mekar malam yang melegenda di tradisi keraton Jawa sebagai lambang pemulihan kejayaan dan penawar kutukan tertinggi."
    }
  ]
}
```

### 6.2 Skema `data/symptoms.json`

```json
{
  "schema_version": "1.0",
  "symptoms": [
    {
      "id": "demam_panas",
      "name": "Demam Membara",
      "severity": "ringan",
      "required_tags": ["anti_demam"],
      "min_stage": 1,
      "icon_path": "res://assets/icons/symptoms/demam_panas.png",
      "description": "Tubuh warga terasa panas membara akibat paparan kabut teluh awal Desa Girah.",
      "hint_text": "Cari herbal berkhasiat Penurun Panas (anti_demam) seperti Meniran, Akar Alang-Alang, Asam Jawa, atau Sambiloto."
    },
    {
      "id": "kutukan_kabut",
      "name": "Belenggu Kabut Teluh",
      "severity": "kutukan",
      "required_tags": ["detoks", "suci_teluh"],
      "min_stage": 3,
      "icon_path": "res://assets/icons/symptoms/kutukan_kabut.png",
      "description": "Asap gelap melilit tubuh warga dan menahan energi kehidupannya.",
      "hint_text": "Membutuhkan perpaduan Penawar Racun (detoks) dan herbal sakral Penawar Suci (suci_teluh)."
    },
    {
      "id": "segel_durga",
      "name": "Amarah Lipyakara",
      "severity": "boss",
      "required_tags": ["penenang", "suci_teluh"],
      "min_stage": 4,
      "icon_path": "res://assets/icons/symptoms/segel_durga.png",
      "description": "Kutukan puncak kitab Lipyakara yang memperkuat Perisai Teluh Calon Arang.",
      "hint_text": "Padukan herbal Penenang Jiwa (penenang) dengan Penawar Suci (suci_teluh) untuk meretakkan Perisai Teluh!"
    }
  ]
}
```

---

## 7. Skema Ekspansi Basis Data hingga 100+ Herbal Nusantara

Agar gim **Husada Girah** tetap mudah dikembangkan pasca-proyek mata kuliah (misalnya ekspansi wilayah kerajaan lain atau penambahan ensiklopedia *Usada Nusantara* hingga 100+ tanaman obat), arsitektur ini menetapkan standar ekspansi berikut:

1. **Zero-Code Expansion:** Seluruh logika UI *Buku Lontar Usada*, *Meja Alkimia*, dan *Evaluator Tag* membaca larik `herbs` secara dinamis dari `herbs.json`. Penambahan herbal ke-41 hingga ke-100+ cukup dilakukan dengan menambah objek JSON baru dan file ikon `.png` (atau *fallback icon* berdasarkan `category`).
2. **Standar Penamaan & Validasi:**
   - Gunakan `id` berformat `snake_case` unik (mis. `daun_binahong`, `akar_wangi`, `mahkota_dewa`, `buah_mengkudu`, `daun_dewa`).
   - Setiap entri baru **wajib** memakai `effect_tags` dari daftar 12 tag kanonik (atau menambah definisi warna/label tag baru di tabel `tag_definitions` di dalam `herbs.json`).
   - Setiap herbal memiliki minimal 2 dan maksimal 3 tag agar keseimbangan permainan terjaga (mencegah satu herbal menjadi terlalu kuat/*overpowered* untuk semua penyakit).
3. **Kandidat Jalur Ekspansi Kategori (Herbal #41–#100+):**
   - *Rimpang & Umbi Lanjutan:* Bawang Dayak, Bawang Putih Tunggal, Temu Mangga, Temu Giring, Ganyong, Gadung (bertag `toksik`!).
   - *Daun Tradisional Lanjutan:* Daun Binahong, Daun Sirsak, Daun Beluntas, Daun Dewa, Daun Ungu, Daun Katuk, Daun Kemangi, Daun Pandan, Daun Sembung, Daun Tapak Dara.
   - *Rempah & Buah Nusantara:* Kapulaga Sabrang, Kemukus, Cabe Jawa, Pulosari, Kayu Rapet, Mahkota Dewa (bertag `toksik` bila biji mentah!), Mengkudu, Belimbing Wuluh, Rosella, Secang Merah, Kulit Manggis.
   - *Pengelompokan Wilayah Ekspansi:* Field opsional `"region": "jawa_timur" | "bali" | "kalimantan" | "sumatra" | "maluku"` dapat ditambahkan di `herbs.json` versi `1.1` tanpa merusak kompatibilitas versi `1.0`.
