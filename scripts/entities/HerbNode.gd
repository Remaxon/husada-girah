extends Area2D
## HerbNode — Titik panen tanaman herbal di peta (Desa / Zona Hutan).
## Respawn anti-camping: tumbuh kembali setelah 90 detik DAN jarak karakter aktif > 450 px.
## Herbal di Zona Hutan dipetik Mpu Bahula dan masuk sementara ke Kantong Ekspedisi Bahula.

@export var herb_id: String = "kunyit"
@export var harvest_amount: int = 2
@export var respawn_time: float = 90.0
@export var min_respawn_player_distance: float = 450.0
@export var is_danger_zone: bool = false

@onready var leaf_visual: Polygon2D = $LeafVisual
@onready var flower_visual: Polygon2D = $FlowerVisual
@onready var toxic_aura: Polygon2D = $ToxicAura
@onready var name_label: Label = $NameLabel
@onready var state_label: Label = $StateLabel

var is_ready_to_harvest: bool = true
var _respawn_timer: float = 0.0
var _is_toxic_herb: bool = false
var _herb_name: String = ""


func _ready() -> void:
	var herb: Dictionary = AlchemyDatabase.get_herb(herb_id)
	_herb_name = String(herb.get("name", herb_id))
	var tags: Array = herb.get("effect_tags", [])
	_is_toxic_herb = tags.has("toksik")

	if flower_visual != null:
		flower_visual.color = AlchemyDatabase.get_herb_color(herb_id)
	if toxic_aura != null:
		toxic_aura.visible = _is_toxic_herb
	if name_label != null:
		name_label.text = _herb_name + (" [! TOKSIK]" if _is_toxic_herb else "")
		if _is_toxic_herb:
			name_label.modulate = Color(0.95, 0.65, 1.0)
	_refresh_visual()


func _process(delta: float) -> void:
	if is_ready_to_harvest or GameManager.is_gameplay_blocked():
		return

	if _respawn_timer > 0.0:
		_respawn_timer = maxf(0.0, _respawn_timer - delta)

	if _respawn_timer <= 0.0:
		# Syarat anti-camping: hanya boleh tumbuh ulang jika karakter aktif berjarak > 450 px
		var active_pos: Vector2 = GameManager.get_active_player_position()
		if global_position.distance_to(active_pos) > min_respawn_player_distance:
			is_ready_to_harvest = true
			_respawn_timer = 0.0
			_refresh_visual()
		elif state_label != null:
			state_label.text = "Tumbuh saat area sepi..."
	elif state_label != null:
		state_label.text = "Tumbuh: %d dtk" % int(ceilf(_respawn_timer))


func can_interact(actor: Node) -> bool:
	if not is_ready_to_harvest:
		return false
	if is_danger_zone and actor != null and actor.name != "PlayerBahula":
		return false
	return true


func get_interaction_prompt(actor: Node) -> String:
	if not is_ready_to_harvest:
		if _respawn_timer <= 0.0:
			return "%s menunggu area sepi (>450px) untuk tumbuh kembali" % _herb_name
		return "%s sedang tumbuh (%d dtk)" % [_herb_name, int(ceilf(_respawn_timer))]
	var warn: String = " [HATI-HATI: TOKSIK!]" if _is_toxic_herb else ""
	if is_danger_zone and actor != null and actor.name == "PlayerBahula":
		return "[E] Petik %s (+%d → Kantong Bahula)%s" % [_herb_name, harvest_amount, warn]
	return "[E] Petik %s (+%d)%s" % [_herb_name, harvest_amount, warn]


func interact(actor: Node) -> void:
	if not is_ready_to_harvest:
		return

	if is_danger_zone and (actor == null or actor.name != "PlayerBahula"):
		EventBus.feedback_requested.emit(
			"FAIL",
			"PERAN PEMETIK HERBAL HUTAN",
			"Terlalu berbahaya bagi Tabib! Tekan [Tab] untuk mengutus Mpu Bahula ke hutan."
		)
		return

	is_ready_to_harvest = false
	_respawn_timer = respawn_time
	_refresh_visual()

	var herb: Dictionary = AlchemyDatabase.get_herb(herb_id)
	var tags: Array = herb.get("effect_tags", [])

	if is_danger_zone and actor != null and actor.name == "PlayerBahula":
		var is_first: bool = GameManager.add_herb_to_bahula_pouch(herb_id, harvest_amount)
		var total_pouch: int = GameManager.get_bahula_pouch_total()
		_spawn_floating_text(
			"+%d %s (Kantong Bahula)" % [harvest_amount, _herb_name],
			Color(0.92, 0.72, 1.0) if _is_toxic_herb else Color(0.65, 1.0, 0.72)
		)
		if _is_toxic_herb:
			EventBus.feedback_requested.emit(
				"INFO",
				"PANEN HUTAN BERISIKO: %s (+%d) • Kantong Bahula: %d" % [_herb_name.to_upper(), harvest_amount, total_pouch],
				"Tag: %s. PERINGATAN: Kecubung bertag [Peringatan Toksik] (netralkan dengan [detoks])! Kembali ke Desa / dekati Tabib untuk setor bahan." % AlchemyDatabase.format_tag_list(tags)
			)
		elif is_first:
			EventBus.feedback_requested.emit(
				"PERFECT",
				"HERBAL HUTAN BARU: %s (+100 Poin) • Kantong Bahula: %d" % [_herb_name.to_upper(), total_pouch],
				"%s (Tag: %s). Kembali ke Zona Aman / Tabib Wira untuk menyetorkannya ke Kuali!" % [String(herb.get("educational_note", "")), AlchemyDatabase.format_tag_list(tags)]
			)
		else:
			EventBus.feedback_requested.emit(
				"INFO",
				"PANEN HUTAN: %s (+%d) • Kantong Bahula: %d bahan" % [_herb_name, harvest_amount, total_pouch],
				"Tersimpan di Kantong Bahula (Tag: %s). Kembali ke Desa / dekati Tabib untuk menyetorkan ke Kuali!" % AlchemyDatabase.format_tag_list(tags)
			)
		return

	# Herbal dasar di Zona Aman langsung masuk ke inventori Tabib
	var is_first_safe: bool = GameManager.add_herb(herb_id, harvest_amount, false)
	_spawn_floating_text("+%d %s" % [harvest_amount, _herb_name], Color(0.65, 1.0, 0.65))
	if is_first_safe:
		EventBus.feedback_requested.emit(
			"PERFECT",
			"HERBAL BARU DIPANEN: %s (+100 Poin)" % _herb_name.to_upper(),
			"%s (Tag: %s)" % [String(herb.get("educational_note", "")), AlchemyDatabase.format_tag_list(tags)]
		)
	else:
		EventBus.feedback_requested.emit(
			"INFO",
			"PANEN DESA: %s (+%d)" % [_herb_name, harvest_amount],
			"Masuk ke inventori Kuali Tabib. Tag efek: %s." % AlchemyDatabase.format_tag_list(tags)
		)


func _refresh_visual() -> void:
	if leaf_visual != null:
		leaf_visual.modulate.a = 1.0 if is_ready_to_harvest else 0.3
	if flower_visual != null:
		flower_visual.visible = is_ready_to_harvest
	if toxic_aura != null:
		toxic_aura.visible = _is_toxic_herb and is_ready_to_harvest
	if state_label != null:
		if is_ready_to_harvest:
			state_label.text = "[E] Panen (+%d)" % harvest_amount
			state_label.modulate = Color(0.88, 1.0, 0.85)
		else:
			state_label.text = "Tumbuh: %d dtk" % int(ceilf(_respawn_timer))
			state_label.modulate = Color(0.75, 0.75, 0.78)


func _spawn_floating_text(text: String, color: Color) -> void:
	var lbl: Label = Label.new()
	lbl.text = text
	lbl.modulate = color
	lbl.position = Vector2(-64, -56)
	lbl.z_index = 25
	add_child(lbl)
	var tw: Tween = create_tween()
	tw.set_parallel(true)
	tw.tween_property(lbl, "position:y", lbl.position.y - 32.0, 0.9)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.9)
	tw.chain().tween_callback(lbl.queue_free)
