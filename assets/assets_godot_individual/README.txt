ASSET PNG INDIVIDUAL — GODOT

Isi:
- 32 file PNG transparan, dipisahkan dari sprite sheet yang diberikan.
- Folder dibagi menjadi bangunan, vegetasi, props, dan objek_khusus.
- Titik magenta/pivot guide dari gambar sumber sudah dihapus dari PNG.

Penggunaan di Godot:
1. Ekstrak folder ini ke dalam folder res://assets/ pada proyek Godot.
2. Gunakan PNG sebagai Texture2D pada Sprite2D.
3. Atur Centered sesuai kebutuhan. Untuk objek yang berdiri di tanah,
   gunakan offset/pivot di bagian bawah-tengah objek (origin visual).
4. Tambahkan StaticBody2D + CollisionShape2D untuk bangunan/pohon/pagar
   yang harus menghalangi pemain; gunakan Area2D untuk objek interaktif.

Catatan:
- PNG dipisahkan berdasarkan batas visual dari gambar sumber, bukan di-redraw.
- Ukuran piksel tiap objek mengikuti resolusi gambar sumber dan tidak dipaksa
  menjadi 64/96/128 px agar detail tidak rusak. Skalakan di Godot atau proses
  ulang sesuai grid proyek.
- Koordinat pivot bawah-tengah perlu ditetapkan di Godot berdasarkan kebutuhan
  masing-masing scene; titik panduan pada sumber tidak disertakan pada sprite.
