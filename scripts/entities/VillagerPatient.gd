extends Node2D
## VillagerPatient — Warga sakit multi-gejala di Zona Aman.
## Tabib Wira dapat menekan E untuk mendiagnosa gejala lalu memberikan ramuan hasil racikan Meja Alkimia.

@export var patient_id: String = "patient_1"
@export var patient_name: String = "Pak Kartono"
@export var initial_symptoms: PackedStringArray = PackedStringArray(["demam_panas", "mual_perut"])

@onready var body_visual: Polygon2D = $BodyVisual
@onready var name_label: Label = $NameLabel
@onready var symptom_label: Label = $SymptomLabel
@onready var burst_particles: CPUParticles2D = $BurstParticles

var current_symptoms: Array[String] = []
var original_symptom_count: int = 0
var is_diagnosed: bool = false
var is_cured: bool = false


func _ready() -> void:
	current_symptoms.clear()
	for s in initial_symptoms:
		current_symptoms.append(String(s))
	original_symptom_count = current_symptoms.size()
	if name_label != null:
		name_label.text = patient_name
	_refresh_visual()


func can_interact(_actor: Node) -> bool:
	return true


func get_interaction_prompt(actor: Node) -> String:
	if actor.name == "PlayerBahula":
		return "[Tab] Kembalikan ke Tabib Wira untuk memeriksa %s" % patient_name
	if is_cured:
		return "[E] Sapa %s (Sudah Sembuh)" % patient_name
	if not is_diagnosed:
		return "[E] Diagnosa %s" % patient_name
	var potion: Dictionary = GameManager.get_selected_potion()
	if not potion.is_empty():
		return "[E] Berikan Ramuan (%s) ke %s" % [String(potion.get("label", "Ramuan")), patient_name]
	return "[E] Cek Gejala %s  •  Tekan [R] buka Kuali Racik" % patient_name


func interact(actor: Node) -> void:
	if actor.name == "PlayerBahula":
		EventBus.feedback_requested.emit(
			"INFO",
			"TUGAS TABIB WIRA",
			"Hanya Tabib Wira yang bisa mendiagnosa dan mengobati %s. Tekan [Tab] untuk kembali ke Tabib." % patient_name
		)
		return

	if is_cured:
		EventBus.feedback_requested.emit(
			"GOOD",
			"WARGA PULIH",
			"%s: \"Terima kasih Tabib Wira! Berkat ilmu Usada, tubuhku sudah segar kembali.\"" % patient_name
		)
		return

	if not is_diagnosed:
		_diagnose()
		return

	# Jika sudah didiagnosa dan Tabib membawa ramuan siap pakai -> berikan ramuan!
	if not GameManager.ready_potions.is_empty():
		_apply_selected_potion()
	else:
		GameManager.last_diagnosed_patient_id = patient_id
		var req_tags: Array[String] = AlchemyDatabase.get_required_tags_for_symptoms(current_symptoms)
		EventBus.feedback_requested.emit(
			"INFO",
			"DIAGNOSA %s" % patient_name.to_upper(),
			"Gejala aktif: %s. Tag penawar dibutuhkan: %s. Tekan [R] buka Kuali Portabel di mana saja untuk meracik, atau [L] buka Buku Lontar Usada!" % [
				_format_symptom_names(current_symptoms),
				AlchemyDatabase.format_tag_list(req_tags)
			]
		)


func _diagnose() -> void:
	is_diagnosed = true
	GameManager.register_patient_diagnosed(patient_id, patient_name, current_symptoms)
	_refresh_visual()

	var req_tags: Array[String] = AlchemyDatabase.get_required_tags_for_symptoms(current_symptoms)
	EventBus.feedback_requested.emit(
		"INFO",
		"DIAGNOSA: %s" % patient_name.to_upper(),
		"Gejala terdeteksi (%d): %s. Butuh tag penawar: %s. Tekan [R] untuk langsung meracik 2–3 herbal di Kuali Portabel!" % [
			current_symptoms.size(),
			_format_symptom_names(current_symptoms),
			AlchemyDatabase.format_tag_list(req_tags)
		]
	)
	_spawn_floating_text("TERDIAGNOSA!", Color(1.0, 0.9, 0.35))


func _apply_selected_potion() -> void:
	var potion: Dictionary = GameManager.consume_selected_potion()
	if potion.is_empty():
		return

	var herb_ids: Array = potion.get("herb_ids", [])
	var eval_res: Dictionary = AlchemyDatabase.evaluate_potion(herb_ids, current_symptoms)
	var status: String = String(eval_res.get("status", "FAIL"))
	var title: String = String(eval_res.get("title", ""))
	var message: String = String(eval_res.get("message", ""))

	EventBus.patient_treated.emit(patient_id, eval_res)

	match status:
		"PERFECT", "GOOD":
			is_cured = true
			current_symptoms.clear()
			_refresh_visual()
			_play_burst(Color(1.0, 0.85, 0.2) if status == "PERFECT" else Color(0.35, 0.9, 0.45))
			_spawn_floating_text("SEMBUH! (" + status + ")", Color(0.95, 0.9, 0.25))
			GameManager.record_patient_cured(patient_id, original_symptom_count, status)
			EventBus.feedback_requested.emit(status, title, message)
		"PARTIAL":
			var remain: Array = eval_res.get("remaining_symptoms", [])
			current_symptoms.clear()
			for r in remain:
				current_symptoms.append(String(r))
			GameManager.update_patient_symptoms(patient_id, current_symptoms, false)
			_refresh_visual()
			_play_burst(Color(1.0, 0.78, 0.25))
			_spawn_floating_text("SEBAGIAN PULIH", Color(1.0, 0.85, 0.3))
			EventBus.feedback_requested.emit("PARTIAL", title, message)
		"FAIL", "TOXIC":
			var is_tox: bool = status == "TOXIC"
			_play_burst(Color(0.65, 0.25, 0.75) if is_tox else Color(0.55, 0.55, 0.58))
			_spawn_floating_text("GAGAL!", Color(1.0, 0.35, 0.35))
			GameManager.add_plague(5.0)
			ScoreManager.record_brew_failure(is_tox)
			EventBus.feedback_requested.emit(status, title, message)


func _refresh_visual() -> void:
	if is_cured:
		if body_visual != null:
			body_visual.color = Color(0.28, 0.76, 0.42)
		if symptom_label != null:
			symptom_label.text = "[✓] SEMBUH"
			symptom_label.modulate = Color(0.75, 1.0, 0.75)
	elif is_diagnosed:
		if body_visual != null:
			body_visual.color = Color(0.86, 0.52, 0.25)
		if symptom_label != null:
			var lines: PackedStringArray = PackedStringArray()
			for sid in current_symptoms:
				lines.append("• " + AlchemyDatabase.get_symptom_name(sid))
			symptom_label.text = "\n".join(lines)
			symptom_label.modulate = Color(1.0, 0.92, 0.72)
	else:
		if body_visual != null:
			body_visual.color = Color(0.82, 0.32, 0.32)
		if symptom_label != null:
			symptom_label.text = "[!] SAKIT — Tekan [E]"
			symptom_label.modulate = Color(1.0, 0.78, 0.45)


func _format_symptom_names(symptom_ids: Array) -> String:
	var names: PackedStringArray = PackedStringArray()
	for raw_id in symptom_ids:
		names.append(AlchemyDatabase.get_symptom_name(String(raw_id)))
	return ", ".join(names)


func _play_burst(burst_color: Color) -> void:
	if burst_particles == null:
		return
	burst_particles.color = burst_color
	burst_particles.restart()
	burst_particles.emitting = true


func _spawn_floating_text(text: String, color: Color) -> void:
	var lbl: Label = Label.new()
	lbl.text = text
	lbl.modulate = color
	lbl.position = Vector2(-50, -76)
	lbl.z_index = 25
	add_child(lbl)
	var tw: Tween = create_tween()
	tw.set_parallel(true)
	tw.tween_property(lbl, "position:y", lbl.position.y - 34.0, 0.9)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.9)
	tw.chain().tween_callback(lbl.queue_free)
