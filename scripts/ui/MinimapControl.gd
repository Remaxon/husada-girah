extends Control
## MinimapControl — Minimap ringkas custom _draw() untuk peta luas Stage 1 (Desa + Hutan 4x = 3200x4220).
## Menampilkan 4 landmark hutan, desa pinggiran, klaster herbal hutan (titik hijau),
## wilayah hewan buas (titik merah), warga sakit berkedip (kuning), Tabib Wira, Mpu Bahula, & Gerbang Utara.

var map_size: Vector2 = Vector2(3200.0, 4220.0)
var fog_barrier_y: float = 2700.0
var river_rect: Rect2 = Rect2(2420.0, 1280.0, 130.0, 1400.0)
var bridge_rects: Array = []
var road_rects: Array = []
var house_rects: Array = []
var landmark_rects: Array = []

var tabib_node: Node2D = null
var bahula_node: Node2D = null
var patients_container: Node2D = null
var herbs_container: Node2D = null
var enemies_container: Node2D = null
var north_gate_node: Node2D = null
var camera_node: Camera2D = null

var _blink_time: float = 0.0


func _ready() -> void:
	custom_minimum_size = Vector2(152, 192)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func setup_minimap(config: Dictionary) -> void:
	if config.has("map_size"):
		map_size = config["map_size"]
	if config.has("fog_barrier_y"):
		fog_barrier_y = float(config["fog_barrier_y"])
	if config.has("river_rect"):
		river_rect = config["river_rect"]
	if config.has("bridge_rects"):
		bridge_rects = config["bridge_rects"]
	if config.has("road_rects"):
		road_rects = config["road_rects"]
	if config.has("house_rects"):
		house_rects = config["house_rects"]
	if config.has("landmark_rects"):
		landmark_rects = config["landmark_rects"]
	tabib_node = config.get("tabib", null)
	bahula_node = config.get("bahula", null)
	patients_container = config.get("patients", null)
	herbs_container = config.get("herbs", null)
	enemies_container = config.get("enemies", null)
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

	# 1. Latar Zona Aman (Desa Pinggiran Girah - Selatan)
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.45, 0.72, 0.43, 0.96), true)

	# 2. Zona Hutan Liar 4x Luas (Utara)
	var barrier_y_px: float = _to_mini(Vector2(0.0, fog_barrier_y)).y
	draw_rect(Rect2(0.0, 0.0, size.x, barrier_y_px), Color(0.14, 0.30, 0.19, 0.96), true)

	# 3. 4 Sub-Area / Landmark Hutan (bambu, reruntuhan, sarang babi, tepi sungai)
	for lm in landmark_rects:
		if typeof(lm) == TYPE_DICTIONARY and lm.has("rect") and lm.has("color"):
			draw_rect(_rect_to_mini(lm["rect"]), lm["color"], true)

	# 4. Jalan Setapak Tanah (Desa & Hutan)
	for r in road_rects:
		draw_rect(_rect_to_mini(r), Color(0.76, 0.66, 0.48, 0.85), true)

	# 5. Sungai Hutan & Jembatan Kayu
	draw_rect(_rect_to_mini(river_rect), Color(0.22, 0.56, 0.86, 0.95), true)
	for br in bridge_rects:
		draw_rect(_rect_to_mini(br), Color(0.64, 0.43, 0.22, 1.0), true)

	# 6. Rumah-rumah Pemukiman Desa
	for hr in house_rects:
		draw_rect(_rect_to_mini(hr), Color(0.48, 0.29, 0.16, 0.96), true)

	# 7. Garis Batas Hutan & Tepi Koridor Jalan Setapak Aman (Terbuka lurus ke Gerbang Utara)
	var corr_left_px: float = _to_mini(Vector2(GameManager.SAFE_CORRIDOR_MIN_X, 0.0)).x
	var corr_right_px: float = _to_mini(Vector2(GameManager.SAFE_CORRIDOR_MAX_X, 0.0)).x
	var border_col: Color = Color(0.92, 0.44, 0.24, 0.95)
	draw_line(Vector2(0.0, barrier_y_px), Vector2(corr_left_px, barrier_y_px), border_col, 2.0)
	draw_line(Vector2(corr_right_px, barrier_y_px), Vector2(size.x, barrier_y_px), border_col, 2.0)
	draw_line(Vector2(corr_left_px, 0.0), Vector2(corr_left_px, barrier_y_px), border_col, 1.5)
	draw_line(Vector2(corr_right_px, 0.0), Vector2(corr_right_px, barrier_y_px), border_col, 1.5)

	# 8. Klaster Herbal Hutan (Titik Hijau)
	if herbs_container != null:
		for child in herbs_container.get_children():
			if not (child is Node2D):
				continue
			var is_forest: bool = ("is_danger_zone" in child and bool(child.is_danger_zone))
			if not is_forest:
				continue
			var hpos: Vector2 = _to_mini(child.global_position)
			var ready_h: bool = ("is_ready_to_harvest" in child and bool(child.is_ready_to_harvest))
			if ready_h:
				draw_circle(hpos, 3.0, Color(0.24, 0.98, 0.45, 0.95))
			else:
				draw_circle(hpos, 1.8, Color(0.3, 0.62, 0.36, 0.45))

	# 9. Wilayah / Posisi Hewan Buas (Titik Merah)
	if enemies_container != null:
		for child in enemies_container.get_children():
			if not (child is Node2D) or not is_instance_valid(child):
				continue
			var epos: Vector2 = _to_mini(child.global_position)
			draw_circle(epos, 4.6, Color(0.95, 0.18, 0.18, 0.3))
			draw_circle(epos, 2.7, Color(1.0, 0.22, 0.22, 0.98))

	# 10. Kotak Bidang Pandang Kamera
	if camera_node != null and is_instance_valid(camera_node):
		var view_w: float = 1280.0
		var view_h: float = 720.0
		var cam_center: Vector2 = camera_node.get_screen_center_position()
		var cam_rect: Rect2 = Rect2(cam_center - Vector2(view_w * 0.5, view_h * 0.5), Vector2(view_w, view_h))
		draw_rect(_rect_to_mini(cam_rect), Color(1.0, 0.98, 0.85, 0.38), false, 1.0)

	# 11. Ikon Gerbang Utara (Stage 2)
	if north_gate_node != null and is_instance_valid(north_gate_node):
		var gpos: Vector2 = _to_mini(north_gate_node.global_position)
		var gcol: Color = Color(0.28, 1.0, 0.55, 1.0) if GameManager.north_gate_unlocked else Color(0.76, 0.44, 0.96, 1.0)
		var gsize: float = 5.2 + (1.4 * sin(_blink_time * 5.0) if GameManager.north_gate_unlocked else 0.0)
		var diamond: PackedVector2Array = PackedVector2Array([
			gpos + Vector2(0, -gsize),
			gpos + Vector2(gsize, 0),
			gpos + Vector2(0, gsize),
			gpos + Vector2(-gsize, 0),
		])
		draw_colored_polygon(diamond, gcol)
		draw_polyline(PackedVector2Array([diamond[0], diamond[1], diamond[2], diamond[3], diamond[0]]), Color.WHITE, 1.0)

	# 12. Titik Warga Sakit (Kuning berkedip) / Sembuh (Hijau kecil)
	if patients_container != null:
		var blink_alpha: float = 0.55 + 0.45 * sin(_blink_time * 6.5)
		for child in patients_container.get_children():
			if not (child is Node2D):
				continue
			var ppos: Vector2 = _to_mini(child.global_position)
			var cured: bool = ("is_cured" in child and bool(child.is_cured))
			if cured:
				draw_circle(ppos, 2.3, Color(0.65, 1.0, 0.72, 0.85))
			else:
				draw_circle(ppos, 4.6, Color(1.0, 0.88, 0.16, blink_alpha * 0.5))
				draw_circle(ppos, 3.0, Color(1.0, 0.92, 0.2, blink_alpha))

	# 13. Penanda Mpu Bahula (Kotak Oranye-Merah Berbingkai Putih)
	if bahula_node != null and is_instance_valid(bahula_node):
		var bpos: Vector2 = _to_mini(bahula_node.global_position)
		draw_rect(Rect2(bpos - Vector2(4.2, 4.2), Vector2(8.4, 8.4)), Color.WHITE, true)
		draw_rect(Rect2(bpos - Vector2(3.0, 3.0), Vector2(6.0, 6.0)), Color(1.0, 0.42, 0.14, 1.0), true)

	# 14. Penanda Tabib Wira (Lingkaran Cyan-Hijau Berbingkai Putih)
	if tabib_node != null and is_instance_valid(tabib_node):
		var tpos: Vector2 = _to_mini(tabib_node.global_position)
		draw_circle(tpos, 4.6, Color.WHITE)
		draw_circle(tpos, 3.3, Color(0.15, 0.94, 0.76, 1.0))

	# 15. Bingkai luar minimap
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.88, 0.72, 0.22, 0.92), false, 1.5)
