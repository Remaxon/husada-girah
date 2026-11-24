extends Node
## GameManager — Mengelola Wabah Meter, Kantong Herbal Bersama (Starter Pack + Buku Lontar Usada permanen),
## Slot Ramuan Siap Pakai, status karakter aktif (Tabib Wira / Mpu Bahula), serta kondisi menang/kalah.

enum ActiveCharacter {
	TABIB,
	BAHULA,
}

const PERMANENT_LONTAR_ID: String = "buku_lontar_usada"
const MAX_READY_POTIONS: int = 3

## Batas Zona Aman Stage 1: Desa Pinggiran (y >= 2700) + Koridor Jalan Setapak Utama (x = 1516..1684)
const SAFE_VILLAGE_MIN_Y: float = 2700.0
const SAFE_CORRIDOR_MIN_X: float = 1516.0
const SAFE_CORRIDOR_MAX_X: float = 1684.0

## Starter Pack Stage 1: tepat 2 dosis ramuan Kunir Asem (Kunyit + Asam Jawa) untuk menyembuhkan
## Pasien #1 Pak Kartono (Demam Membara + Mual & Mulas) + 1 dosis cadangan bila gagal meracik.
const STARTER_HERBS: Dictionary = {
	"kunyit": 2,
	"asam_jawa": 2,
}

var current_stage: int = 1
var active_character: int = ActiveCharacter.TABIB
var is_switching_camera: bool = false
var tabib_node: Node2D = null
var bahula_node: Node2D = null

## Item permanen, Inventori Tabib (Kuali), & Kantong Ekspedisi Mpu Bahula
var has_lontar_usada: bool = true
var has_portable_cauldron: bool = true
var herbal_inventory: Dictionary = {}
var bahula_expedition_pouch: Dictionary = {}
var discovered_herbs: Dictionary = {}
var ready_potions: Array = []
var selected_potion_index: int = 0
var _next_potion_uid: int = 1

## Wabah Meter & jeda waktu (Stage 1 diperlambat 35%: 0.25 * 0.65 = 0.1625%/detik)
var plague_meter: float = 10.0
var plague_rate_per_sec: float = 0.1625
var plague_rate_multiplier: float = 1.0
var plague_pause_sources: Array[String] = []
var plague_slow_sources: Dictionary = {}
var modal_sources: Array[String] = []

## Progres Pasien Stage & Gerbang Utara
var total_patients: int = 0
var cured_patients: int = 0
var north_gate_unlocked: bool = false
var diagnosed_patients: Dictionary = {}
var last_diagnosed_patient_id: String = ""
var stage_ended: bool = false

## Status Lini Serang (Mpu Bahula)
var bahula_hp: int = 100
var bahula_max_hp: int = 100
var bahula_retreat_cooldown: float = 0.0
var bahula_retreat_count: int = 0
var unbanked_danger_herbs: Array[String] = []

var _plague_emit_accum: float = 0.0


func _ready() -> void:
	_init_starter_inventory()


func _process(delta: float) -> void:
	if stage_ended:
		return

	var modal_active: bool = is_gameplay_blocked()

	# Hitung mundur cooldown pemulihan Mpu Bahula setelah Tactical Retreat
	if bahula_retreat_cooldown > 0.0 and not modal_active:
		bahula_retreat_cooldown = maxf(0.0, bahula_retreat_cooldown - delta)
		EventBus.bahula_retreat_cooldown_updated.emit(bahula_retreat_cooldown)

	# Laju Wabah Meter berhenti total saat dijeda (mis. saat membuka Buku Lontar Usada / Pause / Tutorial Alkimia)
	if not is_plague_paused() and total_patients > 0 and cured_patients < total_patients:
		plague_meter = clampf(plague_meter + plague_rate_per_sec * plague_rate_multiplier * delta, 0.0, 100.0)
		_plague_emit_accum += delta
		if _plague_emit_accum >= 0.1 or plague_meter >= 100.0:
			_plague_emit_accum = 0.0
			EventBus.plague_meter_updated.emit(plague_meter, false)
		if plague_meter >= 100.0:
			_trigger_stage_lost()


func reset_for_stage(stage_number: int, initial_plague: float, plague_rate: float, patient_count: int) -> void:
	current_stage = stage_number
	active_character = ActiveCharacter.TABIB
	is_switching_camera = false
	stage_ended = false

	plague_meter = clampf(initial_plague, 0.0, 99.0)
	plague_rate_per_sec = plague_rate
	plague_rate_multiplier = 1.0
	plague_pause_sources.clear()
	plague_slow_sources.clear()
	modal_sources.clear()

	total_patients = patient_count
	cured_patients = 0
	north_gate_unlocked = false
	diagnosed_patients.clear()
	last_diagnosed_patient_id = ""

	bahula_hp = bahula_max_hp
	bahula_retreat_cooldown = 0.0
	bahula_retreat_count = 0
	unbanked_danger_herbs.clear()
	bahula_expedition_pouch.clear()

	ready_potions.clear()
	selected_potion_index = 0
	_next_potion_uid = 1

	_init_starter_inventory()
	ScoreManager.reset_stage_score(stage_number)

	EventBus.active_character_changed.emit(active_character)
	EventBus.herb_inventory_changed.emit()
	EventBus.bahula_pouch_changed.emit(0, bahula_expedition_pouch)
	EventBus.ready_potions_changed.emit()
	EventBus.plague_meter_updated.emit(plague_meter, is_plague_paused())
	EventBus.bahula_hp_changed.emit(bahula_hp, bahula_max_hp)
	EventBus.patient_cured.emit("", cured_patients, total_patients)


func register_players(tabib: Node2D, bahula: Node2D) -> void:
	tabib_node = tabib
	bahula_node = bahula


func get_active_player_position() -> Vector2:
	if active_character == ActiveCharacter.BAHULA and bahula_node != null and is_instance_valid(bahula_node):
		return bahula_node.global_position
	if tabib_node != null and is_instance_valid(tabib_node):
		return tabib_node.global_position
	return Vector2.ZERO


func is_position_in_village(world_pos: Vector2) -> bool:
	return world_pos.y >= SAFE_VILLAGE_MIN_Y


func is_position_in_safe_corridor(world_pos: Vector2) -> bool:
	return world_pos.x >= SAFE_CORRIDOR_MIN_X and world_pos.x <= SAFE_CORRIDOR_MAX_X


func is_position_in_safe_zone(world_pos: Vector2) -> bool:
	return is_position_in_village(world_pos) or is_position_in_safe_corridor(world_pos)


func _init_starter_inventory() -> void:
	has_lontar_usada = true
	has_portable_cauldron = true
	herbal_inventory.clear()
	discovered_herbs.clear()
	for herb_id in STARTER_HERBS.keys():
		herbal_inventory[String(herb_id)] = int(STARTER_HERBS[herb_id])
		# Starter herbs sudah dimiliki sejak awal, bukan penemuan panen peta baru
		discovered_herbs[String(herb_id)] = true


## --- Manajemen Modal & Jeda / Perlambatan Wabah ---

func set_plague_paused(source: String, paused: bool) -> void:
	if paused:
		if not plague_pause_sources.has(source):
			plague_pause_sources.append(source)
	else:
		plague_pause_sources.erase(source)
	var now_paused: bool = is_plague_paused()
	EventBus.plague_paused_changed.emit(now_paused)
	EventBus.plague_meter_updated.emit(plague_meter, now_paused)


func set_plague_slow(source: String, multiplier: float) -> void:
	if multiplier >= 1.0:
		plague_slow_sources.erase(source)
	else:
		plague_slow_sources[source] = clampf(multiplier, 0.0, 1.0)
	var effective: float = 1.0
	for k in plague_slow_sources.keys():
		effective = minf(effective, float(plague_slow_sources[k]))
	plague_rate_multiplier = effective


func is_plague_paused() -> bool:
	return not plague_pause_sources.is_empty() or stage_ended or north_gate_unlocked


func set_modal_open(source: String, is_open: bool) -> void:
	if is_open:
		if not modal_sources.has(source):
			modal_sources.append(source)
	else:
		modal_sources.erase(source)


func is_gameplay_blocked() -> bool:
	return not modal_sources.is_empty() or stage_ended


func add_plague(delta_percent: float) -> void:
	if stage_ended:
		return
	plague_meter = clampf(plague_meter + delta_percent, 0.0, 100.0)
	EventBus.plague_meter_updated.emit(plague_meter, is_plague_paused())
	if plague_meter >= 100.0:
		_trigger_stage_lost()


## --- Manajemen Kantong Herbal Bersama ---

func add_herb(herb_id: String, amount: int = 1, from_danger_zone: bool = false) -> bool:
	if amount <= 0:
		return false
	var current_count: int = int(herbal_inventory.get(herb_id, 0))
	herbal_inventory[herb_id] = current_count + amount

	if from_danger_zone:
		for _i in range(amount):
			unbanked_danger_herbs.append(herb_id)

	var is_first_discovery: bool = not discovered_herbs.has(herb_id)
	if is_first_discovery:
		discovered_herbs[herb_id] = true
		ScoreManager.record_new_herb_discovery(herb_id)

	EventBus.herb_collected.emit(herb_id, amount, is_first_discovery)
	EventBus.herb_inventory_changed.emit()
	return is_first_discovery


func get_herb_count(herb_id: String) -> int:
	return int(herbal_inventory.get(herb_id, 0))


func get_available_herbs() -> Dictionary:
	var result: Dictionary = {}
	for hid in herbal_inventory.keys():
		var cnt: int = int(herbal_inventory[hid])
		if cnt > 0:
			result[String(hid)] = cnt
	return result


func can_consume_herbs(herb_ids: Array) -> bool:
	var needed: Dictionary = {}
	for raw_id in herb_ids:
		var hid: String = String(raw_id)
		needed[hid] = int(needed.get(hid, 0)) + 1
	for hid in needed.keys():
		if get_herb_count(String(hid)) < int(needed[hid]):
			return false
	return true


func consume_herbs(herb_ids: Array) -> bool:
	if not can_consume_herbs(herb_ids):
		return false
	for raw_id in herb_ids:
		var hid: String = String(raw_id)
		herbal_inventory[hid] = maxi(0, get_herb_count(hid) - 1)
	EventBus.herb_inventory_changed.emit()
	return true


func clear_unbanked_danger_herbs() -> void:
	unbanked_danger_herbs.clear()


## --- Kantong Ekspedisi Mpu Bahula ---

func add_herb_to_bahula_pouch(herb_id: String, amount: int = 1) -> bool:
	if amount <= 0:
		return false
	var current_count: int = int(bahula_expedition_pouch.get(herb_id, 0))
	bahula_expedition_pouch[herb_id] = current_count + amount
	var is_first_discovery: bool = not discovered_herbs.has(herb_id)
	if is_first_discovery:
		discovered_herbs[herb_id] = true
		ScoreManager.record_new_herb_discovery(herb_id)
	EventBus.herb_collected.emit(herb_id, amount, is_first_discovery)
	EventBus.bahula_pouch_changed.emit(get_bahula_pouch_total(), bahula_expedition_pouch)
	return is_first_discovery


func get_bahula_pouch_total() -> int:
	var total: int = 0
	for hid in bahula_expedition_pouch.keys():
		total += int(bahula_expedition_pouch[hid])
	return total


func transfer_bahula_pouch_to_tabib() -> int:
	var total_moved: int = get_bahula_pouch_total()
	if total_moved <= 0:
		return 0

	var summary_parts: PackedStringArray = PackedStringArray()
	for raw_id in bahula_expedition_pouch.keys():
		var hid: String = String(raw_id)
		var cnt: int = int(bahula_expedition_pouch[hid])
		if cnt <= 0:
			continue
		herbal_inventory[hid] = int(herbal_inventory.get(hid, 0)) + cnt
		summary_parts.append("%s x%d" % [AlchemyDatabase.get_herb_name(hid), cnt])

	bahula_expedition_pouch.clear()
	var summary_text: String = ", ".join(summary_parts)

	EventBus.bahula_pouch_changed.emit(0, bahula_expedition_pouch)
	EventBus.herb_inventory_changed.emit()
	EventBus.bahula_pouch_transferred.emit(total_moved, summary_text)
	EventBus.feedback_requested.emit(
		"GOOD",
		"KANTONG BAHULA DISETOR (+%d BAHAN)!" % total_moved,
		"Mpu Bahula menyerahkan %s ke inventori/Kuali Tabib Wira. Tekan [R] untuk meracik!" % summary_text
	)
	return total_moved


## --- Slot Ramuan Siap Pakai ---

func brew_potion_into_pouch(selected_herb_ids: Array) -> Dictionary:
	## Memeriksa stok & toksisitas langsung saat meracik di Meja Alkimia.
	## Jika TOKSIK tanpa detoks -> bahan terbuang, penalti skor & Wabah Meter +5% langsung terjadi!
	## Jika aman -> masuk ke Slot Ramuan Siap Pakai (maks. 3 botol).
	if selected_herb_ids.size() < 2 or selected_herb_ids.size() > 3:
		return {"ok": false, "reason": "Pilih 2 hingga 3 herbal untuk meracik ramuan."}
	if not can_consume_herbs(selected_herb_ids):
		return {"ok": false, "reason": "Stok herbal di kantong tidak mencukupi."}

	var tox: Dictionary = AlchemyDatabase.check_toxicity(selected_herb_ids)
	if bool(tox["is_dangerous"]):
		consume_herbs(selected_herb_ids)
		add_plague(5.0)
		ScoreManager.record_brew_failure(true)
		var toxic_names: String = ", ".join(PackedStringArray(tox["toxic_herbs"]))
		var msg: String = "Ramuan meledak berasap ungu di lumpang! %s mengandung [Peringatan Toksik]. Padukan dengan herbal [Penawar Racun / detoks] seperti Temulawak, Sambiloto, atau Akar Alang-Alang! (-50 Skor, Wabah +5%%)" % toxic_names
		EventBus.feedback_requested.emit("TOXIC", "BAHAYA TOKSIK!", msg)
		return {"ok": false, "toxic_explosion": true, "reason": msg}

	if ready_potions.size() >= MAX_READY_POTIONS:
		return {"ok": false, "reason": "Slot Ramuan penuh (maks. 3 botol). Berikan ke pasien atau buang salah satu botol dulu."}

	consume_herbs(selected_herb_ids)
	var clean_ids: Array[String] = []
	var names: PackedStringArray = PackedStringArray()
	for raw_id in selected_herb_ids:
		var hid: String = String(raw_id)
		clean_ids.append(hid)
		names.append(AlchemyDatabase.get_herb_name(hid))

	var tags: Array[String] = AlchemyDatabase.get_combined_tags(clean_ids)
	var potion: Dictionary = {
		"uid": _next_potion_uid,
		"herb_ids": clean_ids,
		"label": " + ".join(names),
		"tags": tags,
		"toxic_neutralized": bool(tox["is_neutralized"]),
	}
	_next_potion_uid += 1
	ready_potions.append(potion)
	selected_potion_index = ready_potions.size() - 1
	EventBus.ready_potions_changed.emit()

	var ready_msg: String = "Ramuan (%s) siap dipakai! Dekati warga sakit lalu tekan [E] untuk mengobati." % potion["label"]
	if bool(potion["toxic_neutralized"]):
		ready_msg = "Racun Kecubung berhasil dinetralkan oleh [Penawar Racun]! " + ready_msg
	EventBus.feedback_requested.emit("INFO", "RAMUAN SELESAI DIRACIK", ready_msg)
	return {"ok": true, "potion": potion}


func get_selected_potion() -> Dictionary:
	if ready_potions.is_empty():
		return {}
	selected_potion_index = clampi(selected_potion_index, 0, ready_potions.size() - 1)
	return ready_potions[selected_potion_index]


func select_potion(index: int) -> void:
	if index >= 0 and index < ready_potions.size():
		selected_potion_index = index
		EventBus.ready_potions_changed.emit()


func consume_selected_potion() -> Dictionary:
	if ready_potions.is_empty():
		return {}
	selected_potion_index = clampi(selected_potion_index, 0, ready_potions.size() - 1)
	var potion: Dictionary = ready_potions[selected_potion_index]
	ready_potions.remove_at(selected_potion_index)
	if ready_potions.is_empty():
		selected_potion_index = 0
	else:
		selected_potion_index = clampi(selected_potion_index, 0, ready_potions.size() - 1)
	EventBus.ready_potions_changed.emit()
	return potion


func discard_potion(index: int) -> void:
	if index >= 0 and index < ready_potions.size():
		ready_potions.remove_at(index)
		selected_potion_index = clampi(selected_potion_index, 0, maxi(0, ready_potions.size() - 1))
		EventBus.ready_potions_changed.emit()


## --- Manajemen Pasien ---

func register_patient_diagnosed(patient_id: String, patient_name: String, symptoms: Array) -> void:
	var sym_copy: Array[String] = []
	for s in symptoms:
		sym_copy.append(String(s))
	var entry: Dictionary = {
		"id": patient_id,
		"name": patient_name,
		"symptoms": sym_copy,
		"cured": sym_copy.is_empty(),
	}
	diagnosed_patients[patient_id] = entry
	last_diagnosed_patient_id = patient_id
	EventBus.patient_diagnosed.emit(entry)


func update_patient_symptoms(patient_id: String, remaining_symptoms: Array, is_cured: bool) -> void:
	if diagnosed_patients.has(patient_id):
		var entry: Dictionary = diagnosed_patients[patient_id]
		var sym_copy: Array[String] = []
		for s in remaining_symptoms:
			sym_copy.append(String(s))
		entry["symptoms"] = sym_copy
		entry["cured"] = is_cured
		diagnosed_patients[patient_id] = entry
		EventBus.patient_diagnosed.emit(entry)


func record_patient_cured(patient_id: String, original_symptom_count: int, eval_status: String) -> void:
	cured_patients += 1
	update_patient_symptoms(patient_id, [], true)

	if eval_status == "PERFECT":
		add_plague(-12.0)
	else:
		add_plague(-10.0)

	ScoreManager.record_patient_cured(original_symptom_count, eval_status == "PERFECT")
	EventBus.patient_cured.emit(patient_id, cured_patients, total_patients)

	if cured_patients >= total_patients and total_patients > 0 and not north_gate_unlocked and not stage_ended:
		north_gate_unlocked = true
		EventBus.plague_meter_updated.emit(plague_meter, true)
		EventBus.all_patients_cured.emit()
		EventBus.feedback_requested.emit(
			"PERFECT",
			"SEMUA WARGA DESA GIRAH TELAH SEMBUH! (%d/%d)" % [cured_patients, total_patients],
			"Gerbang Jalan Utara menuju Stage 2 (Hutan Bambu & Sendang Girah) kini TERBUKA bercahaya hijau! Susuri jalan setapak utama ke utara menuju Gerbang Stage 2."
		)


func complete_stage_at_gate() -> void:
	if north_gate_unlocked and not stage_ended:
		_trigger_stage_won()


## --- Manajemen Proxy Control & HP Mpu Bahula ---

func can_switch_character() -> bool:
	if is_gameplay_blocked() or is_switching_camera:
		return false
	if active_character == ActiveCharacter.TABIB and bahula_retreat_cooldown > 0.0:
		EventBus.feedback_requested.emit(
			"FAIL",
			"MPU BAHULA SEDANG PEMULIHAN",
			"Mpu Bahula sedang memulihkan tenaga di Posko (%.1f detik tersisa)." % bahula_retreat_cooldown
		)
		return false
	return true


func request_switch_character() -> bool:
	if not can_switch_character():
		return false
	var target: int = ActiveCharacter.BAHULA if active_character == ActiveCharacter.TABIB else ActiveCharacter.TABIB
	is_switching_camera = true
	EventBus.interaction_prompt_changed.emit("")
	EventBus.camera_switch_started.emit(target)
	return true


func complete_switch_character(target_character: int) -> void:
	active_character = target_character
	is_switching_camera = false
	EventBus.active_character_changed.emit(active_character)
	EventBus.camera_switch_finished.emit(active_character)


func damage_bahula(amount: int) -> bool:
	if stage_ended or amount <= 0:
		return false
	bahula_hp = maxi(0, bahula_hp - amount)
	EventBus.bahula_hp_changed.emit(bahula_hp, bahula_max_hp)
	if bahula_hp <= 0:
		_trigger_bahula_retreat()
		return true
	return false


func heal_bahula(amount: int) -> void:
	if bahula_hp >= bahula_max_hp or amount <= 0:
		return
	bahula_hp = mini(bahula_max_hp, bahula_hp + amount)
	EventBus.bahula_hp_changed.emit(bahula_hp, bahula_max_hp)


func _trigger_bahula_retreat() -> void:
	bahula_retreat_count += 1
	bahula_retreat_cooldown = 5.0
	bahula_hp = int(bahula_max_hp * 0.5)

	var lost_note: String = ""
	if get_bahula_pouch_total() > 0:
		var pouch_keys: Array = bahula_expedition_pouch.keys()
		var lost_id: String = String(pouch_keys[pouch_keys.size() - 1])
		var new_cnt: int = int(bahula_expedition_pouch[lost_id]) - 1
		if new_cnt <= 0:
			bahula_expedition_pouch.erase(lost_id)
		else:
			bahula_expedition_pouch[lost_id] = new_cnt
		EventBus.bahula_pouch_changed.emit(get_bahula_pouch_total(), bahula_expedition_pouch)
		lost_note = " 1x %s terjatuh dari Kantong Bahula saat mundur." % AlchemyDatabase.get_herb_name(lost_id)
	unbanked_danger_herbs.clear()

	add_plague(12.0)
	EventBus.bahula_hp_changed.emit(bahula_hp, bahula_max_hp)
	EventBus.bahula_retreated.emit(bahula_retreat_cooldown)
	EventBus.feedback_requested.emit(
		"TOXIC",
		"MUNDUR DARURAT (TACTICAL RETREAT)",
		"HP Mpu Bahula habis akibat serangan hewan buas! Mpu Bahula mundur ke Zona Aman (cooldown 5 dtk, Wabah +12%%).%s" % lost_note
	)


## --- Menang / Kalah Stage ---

func _trigger_stage_won() -> void:
	stage_ended = true
	set_plague_paused("stage_end", true)
	var summary: Dictionary = ScoreManager.finalize_stage(plague_meter, bahula_retreat_count)
	summary["cured_patients"] = cured_patients
	summary["total_patients"] = total_patients
	summary["plague_meter"] = plague_meter
	EventBus.stage_won.emit(summary)


func _trigger_stage_lost() -> void:
	if stage_ended:
		return
	stage_ended = true
	set_plague_paused("stage_end", true)
	var summary: Dictionary = ScoreManager.get_current_breakdown(plague_meter)
	summary["cured_patients"] = cured_patients
	summary["total_patients"] = total_patients
	summary["plague_meter"] = plague_meter
	EventBus.stage_lost.emit(summary)
