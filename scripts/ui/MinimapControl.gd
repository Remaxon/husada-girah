extends Control
## MinimapControl — Minimap ringkas custom _draw() (~170x118 px) untuk peta luas Stage 1 (3200x2200).
## Menampilkan zona pemukiman, aliran sungai & jembatan, hutan kabut utara, Tabib (hijau),
## Mpu Bahula (merah), warga sakit berkedip (kuning), dan Gerbang Utara.

var map_size: Vector2 = Vector2(3200.0, 2200.0)
var fog_barrier_y: float = 682.0
var river_rect: Rect2 = Rect2(2480.0, 704.0, 130.0, 1496.0)
var bridge_rects: Array = [
	Rect2(2445.0, 985.0, 200.0, 110.0),
	Rect2(2445.0, 1605.0, 200.0, 110.0),
]
var road_rects: Array = [
	Rect2(1540.0, 140.0, 120.0, 1880.0),
	Rect2(420.0, 1000.0, 2460.0, 80.0),
	Rect2(420.0, 1620.0, 2460.0, 80.0),
]
var house_rects: Array = []

var tabib_node: Node2D = null
var bahula_node: Node2D = null
var patients_container: Node2D = null
var north_gate_node: Node2D = null
var camera_node: Camera2D = null

var _blink_time: float = 0.0


func _ready() -> void:
	custom_minimum_size = Vector2(170, 118)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func setup_minimap(config: Dictionary) -> void:
	if config.has("map_size"):
		map_size = config["map_size"]
	if config.has("fog_barrier_y"):
		fog_barrier_y = float(config["fog_barrier_y"])
	if config.has("house_rects"):
		house_rects = config["house_rects"]
	tabib_node = config.get("tabib", null)
	bahula_node = config.get("bahula", null)
	patients_container = config.get("patients", null)
	north_gate_node = config.get("north_gate", null)
	camera_node = config.get("camera", null)
	queue_redraw()


func _process(delta: float) -> void:
	_blink_time += delta
	queue_redraw()


func _to_mini(world_pos: Vector2) -> Vector2:
	var sx: float = size.x / maxf(1.0, map_size.x)
	var sy: float = size.y / maxf(1.0, map_size.y)
	return Vector2(clampf(world_pos.x * sx, 0.0, size.x), clampf(world_pos.y * sy, 0.0, size.y))


func _rect_to_mini(world_rect: Rect2) -> Rect2:
	var tl: Vector2 = _to_mini(world_rect.position)
	var br: Vector2 = _to_mini(world_rect.position + world_rect.size)
	return Rect2(tl, br - tl)


func _draw() -> void:
	if size.x <= 2.0 or size.y <= 2.0:
		return

	# 1. Latar Zona Aman (Desa Girah)
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.36, 0.62, 0.35, 0.96), true)

	# 2. Zona Berbahaya Hutan Kabut Utara
	var fog_y_px: float = _to_mini(Vector2(0.0, fog_barrier_y)).y
	var danger_col: Color = Color(0.24, 0.44, 0.30, 0.96) if GameManager.north_gate_unlocked else Color(0.28, 0.14, 0.38, 0.96)
	draw_rect(Rect2(0.0, 0.0, size.x, fog_y_px), danger_col, true)

	# 3. Jalan Setapak Desa
	for r in road_rects:
		draw_rect(_rect_to_mini(r), Color(0.76, 0.67, 0.49, 0.85), true)

	# 4. Aliran Sungai Biru & Jembatan Kayu
	draw_rect(_rect_to_mini(river_rect), Color(0.22, 0.54, 0.84, 0.95), true)
	for br in bridge_rects:
		draw_rect(_rect_to_mini(br), Color(0.62, 0.41, 0.21, 1.0), true)

	# 5. Rumah-rumah Pemukiman Desa
	for hr in house_rects:
		draw_rect(_rect_to_mini(hr), Color(0.45, 0.27, 0.15, 0.95), true)

	# 6. Garis Batas Kabut Teluh
	var barrier_col: Color = Color(0.42, 0.92, 0.56, 0.85) if GameManager.north_gate_unlocked else Color(0.76, 0.36, 0.92, 0.95)
	draw_line(Vector2(0.0, fog_y_px), Vector2(size.x, fog_y_px), barrier_col, 2.0)

	# 7. Kotak Bidang Pandang Kamera
	if camera_node != null and is_instance_valid(camera_node):
		var view_w: float = 1280.0
		var view_h: float = 720.0
		var cam_center: Vector2 = camera_node.get_screen_center_position()
		var cam_rect: Rect2 = Rect2(cam_center - Vector2(view_w * 0.5, view_h * 0.5), Vector2(view_w, view_h))
		draw_rect(_rect_to_mini(cam_rect), Color(1.0, 0.98, 0.85, 0.38), false, 1.0)

	# 8. Ikon Gerbang Utara (Stage 2)
	if north_gate_node != null and is_instance_valid(north_gate_node):
		var gpos: Vector2 = _to_mini(north_gate_node.global_position)
		var gcol: Color = Color(0.28, 1.0, 0.55, 1.0) if GameManager.north_gate_unlocked else Color(0.72, 0.4, 0.92, 1.0)
		var gsize: float = 5.5 + (1.5 * sin(_blink_time * 5.0) if GameManager.north_gate_unlocked else 0.0)
		var diamond: PackedVector2Array = PackedVector2Array([
			gpos + Vector2(0, -gsize),
			gpos + Vector2(gsize, 0),
			gpos + Vector2(0, gsize),
			gpos + Vector2(-gsize, 0),
		])
		draw_colored_polygon(diamond, gcol)
		draw_polyline(PackedVector2Array([diamond[0], diamond[1], diamond[2], diamond[3], diamond[0]]), Color.WHITE, 1.0)

	# 9. Titik Warga Sakit (Kuning berkedip) / Sembuh (Hijau kecil)
	if patients_container != null:
		var blink_alpha: float = 0.55 + 0.45 * sin(_blink_time * 6.5)
		for child in patients_container.get_children():
			if not (child is Node2D):
				continue
			var ppos: Vector2 = _to_mini(child.global_position)
			var cured: bool = ("is_cured" in child and bool(child.is_cured))
			if cured:
				draw_circle(ppos, 2.5, Color(0.55, 1.0, 0.65, 0.8))
			else:
				draw_circle(ppos, 4.8, Color(1.0, 0.88, 0.16, blink_alpha * 0.5))
				draw_circle(ppos, 3.2, Color(1.0, 0.92, 0.2, blink_alpha))

	# 10. Titik Mpu Bahula (Merah)
	if bahula_node != null and is_instance_valid(bahula_node):
		var bpos: Vector2 = _to_mini(bahula_node.global_position)
		draw_circle(bpos, 4.3, Color(1.0, 1.0, 1.0, 0.95))
		draw_circle(bpos, 3.2, Color(0.92, 0.24, 0.2, 1.0))

	# 11. Titik Tabib Wira (Hijau Cerah)
	if tabib_node != null and is_instance_valid(tabib_node):
		var tpos: Vector2 = _to_mini(tabib_node.global_position)
		draw_circle(tpos, 4.6, Color(1.0, 1.0, 1.0, 0.98))
		draw_circle(tpos, 3.5, Color(0.18, 0.95, 0.36, 1.0))

	# 12. Bingkai luar minimap
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.88, 0.72, 0.22, 0.9), false, 1.5)
