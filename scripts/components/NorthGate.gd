extends Area2D
## NorthGate — Gerbang Jalan Utara menuju Stage 2 ("Hutan Bambu & Sendang Girah").
## Terkunci kabut ungu selama warga belum sembuh semua, lalu terbuka bercahaya hijau setelah 4/4 warga sembuh.

@onready var portal_glow: Polygon2D = $PortalGlow
@onready var seal_mist: Polygon2D = $SealMist
@onready var title_label: Label = $TitleLabel
@onready var state_label: Label = $StateLabel
@onready var enter_trigger: Area2D = $EnterTrigger

var is_unlocked: bool = false
var _pulse_time: float = 0.0
var _triggered_complete: bool = false


func _ready() -> void:
	EventBus.all_patients_cured.connect(_on_all_patients_cured)
	EventBus.patient_cured.connect(_on_patient_cured)
	if enter_trigger != null:
		enter_trigger.body_entered.connect(_on_enter_body_entered)
	_refresh_visual()


func _process(delta: float) -> void:
	_pulse_time += delta
	if is_unlocked and portal_glow != null:
		var pulse: float = 0.55 + 0.35 * sin(_pulse_time * 4.2)
		portal_glow.color = Color(0.22, 0.92, 0.48, pulse)
	elif not is_unlocked and seal_mist != null:
		var mist_pulse: float = 0.52 + 0.22 * sin(_pulse_time * 2.5)
		seal_mist.color = Color(0.52, 0.18, 0.66, mist_pulse)


func can_interact(_actor: Node) -> bool:
	return true


func get_interaction_prompt(_actor: Node) -> String:
	if is_unlocked:
		return "[E] Masuk Gerbang Utara → Stage 2: Hutan Bambu & Sendang Girah"
	return "[E] Periksa Gerbang Utara (Terkunci Kabut — Sembuhkan %d/%d Warga)" % [
		GameManager.cured_patients,
		GameManager.total_patients
	]


func interact(_actor: Node) -> void:
	if not is_unlocked:
		EventBus.feedback_requested.emit(
			"FAIL",
			"GERBANG UTARA TERKUNCI KABUT TELUH",
			"Jalan menuju Stage 2 (Hutan Bambu & Sendang Girah) masih tertutup kabut tebal. Sembuhkan seluruh %d warga Desa Girah terlebih dahulu (%d/%d sembuh)." % [
				GameManager.total_patients,
				GameManager.cured_patients,
				GameManager.total_patients
			]
		)
		return

	_complete_stage()


func _on_all_patients_cured() -> void:
	is_unlocked = true
	_refresh_visual()


func _on_patient_cured(_pid: String, _cured: int, _total: int) -> void:
	_refresh_visual()


func _on_enter_body_entered(body: Node2D) -> void:
	if is_unlocked and not _triggered_complete and (body.name == "PlayerTabib" or body.name == "PlayerBahula"):
		_complete_stage()


func _complete_stage() -> void:
	if _triggered_complete:
		return
	_triggered_complete = true
	GameManager.complete_stage_at_gate()


func _refresh_visual() -> void:
	if is_unlocked:
		if seal_mist != null:
			seal_mist.visible = false
		if portal_glow != null:
			portal_glow.visible = true
		if title_label != null:
			title_label.text = "GERBANG UTARA — MENUJU STAGE 2"
			title_label.modulate = Color(0.75, 1.0, 0.8)
		if state_label != null:
			state_label.text = "★ TERBUKA! Hutan Bambu & Sendang Girah [E / Masuk] ★"
			state_label.modulate = Color(0.5, 1.0, 0.65)
	else:
		if seal_mist != null:
			seal_mist.visible = true
		if portal_glow != null:
			portal_glow.visible = false
		if title_label != null:
			title_label.text = "GERBANG UTARA — MENUJU STAGE 2"
			title_label.modulate = Color(0.95, 0.82, 1.0)
		if state_label != null:
			state_label.text = "[TERKUNCI KABUT • Sembuhkan %d/%d Warga]" % [
				GameManager.cured_patients,
				GameManager.total_patients
			]
			state_label.modulate = Color(0.92, 0.62, 0.98)
