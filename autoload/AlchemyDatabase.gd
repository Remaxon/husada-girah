extends Node
## AlchemyDatabase — Memuat basis data 40 herbal Nusantara & 12 gejala wabah dari JSON
## serta mengevaluasi racikan berbasis pencocokan Tag Efek (termasuk mekanik toksik vs detoks).

const HERBS_DATA_PATH: String = "res://data/herbs.json"
const SYMPTOMS_DATA_PATH: String = "res://data/symptoms.json"

var herbs_list: Array = []
var herbs_by_id: Dictionary = {}
var symptoms_list: Array = []
var symptoms_by_id: Dictionary = {}
var tag_definitions: Dictionary = {}
var category_definitions: Dictionary = {}
var combo_guides: Array = []
var is_loaded: bool = false


func _ready() -> void:
	load_databases()


func load_databases() -> void:
	herbs_list.clear()
	herbs_by_id.clear()
	symptoms_list.clear()
	symptoms_by_id.clear()
	tag_definitions.clear()
	category_definitions.clear()
	combo_guides.clear()

	_load_herbs_json()
	_load_symptoms_json()
	is_loaded = not herbs_list.is_empty() and not symptoms_list.is_empty()
	print("[AlchemyDatabase] Loaded %d herbs and %d symptoms." % [herbs_list.size(), symptoms_list.size()])


func _load_herbs_json() -> void:
	if not FileAccess.file_exists(HERBS_DATA_PATH):
		push_error("[AlchemyDatabase] File tidak ditemukan: " + HERBS_DATA_PATH)
		return
	var file: FileAccess = FileAccess.open(HERBS_DATA_PATH, FileAccess.READ)
	if file == null:
		push_error("[AlchemyDatabase] Gagal membuka: " + HERBS_DATA_PATH)
		return
	var content: String = file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(content)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("[AlchemyDatabase] Format JSON tidak valid pada herbs.json")
		return

	var data: Dictionary = parsed
	if data.has("tag_definitions") and typeof(data["tag_definitions"]) == TYPE_DICTIONARY:
		tag_definitions = data["tag_definitions"]
	if data.has("category_definitions") and typeof(data["category_definitions"]) == TYPE_DICTIONARY:
		category_definitions = data["category_definitions"]
	if data.has("herbs") and typeof(data["herbs"]) == TYPE_ARRAY:
		for item in data["herbs"]:
			if typeof(item) == TYPE_DICTIONARY and item.has("id"):
				herbs_list.append(item)
				herbs_by_id[String(item["id"])] = item


func _load_symptoms_json() -> void:
	if not FileAccess.file_exists(SYMPTOMS_DATA_PATH):
		push_error("[AlchemyDatabase] File tidak ditemukan: " + SYMPTOMS_DATA_PATH)
		return
	var file: FileAccess = FileAccess.open(SYMPTOMS_DATA_PATH, FileAccess.READ)
	if file == null:
		push_error("[AlchemyDatabase] Gagal membuka: " + SYMPTOMS_DATA_PATH)
		return
	var content: String = file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(content)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("[AlchemyDatabase] Format JSON tidak valid pada symptoms.json")
		return

	var data: Dictionary = parsed
	if data.has("symptoms") and typeof(data["symptoms"]) == TYPE_ARRAY:
		for item in data["symptoms"]:
			if typeof(item) == TYPE_DICTIONARY and item.has("id"):
				symptoms_list.append(item)
				symptoms_by_id[String(item["id"])] = item
	if data.has("combo_guides") and typeof(data["combo_guides"]) == TYPE_ARRAY:
		combo_guides = data["combo_guides"]


func get_herb(herb_id: String) -> Dictionary:
	if herbs_by_id.has(herb_id):
		return herbs_by_id[herb_id]
	return {}


func get_all_herbs() -> Array:
	return herbs_list


func get_herbs_by_category(category_id: String) -> Array:
	if category_id == "all" or category_id.is_empty():
		return herbs_list
	var result: Array = []
	for herb in herbs_list:
		if String(herb.get("category", "")) == category_id:
			result.append(herb)
	return result


func get_herb_name(herb_id: String) -> String:
	var herb: Dictionary = get_herb(herb_id)
	return String(herb.get("name", herb_id))


func get_herb_color(herb_id: String) -> Color:
	var herb: Dictionary = get_herb(herb_id)
	var hex: String = String(herb.get("color", "#3A7D44"))
	return Color.from_string(hex, Color(0.23, 0.49, 0.27))


func get_category_label(category_id: String) -> String:
	return String(category_definitions.get(category_id, category_id))


func get_symptom(symptom_id: String) -> Dictionary:
	if symptoms_by_id.has(symptom_id):
		return symptoms_by_id[symptom_id]
	return {}


func get_all_symptoms() -> Array:
	return symptoms_list


func get_symptom_name(symptom_id: String) -> String:
	var sym: Dictionary = get_symptom(symptom_id)
	return String(sym.get("name", symptom_id))


func get_tag_info(tag_id: String) -> Dictionary:
	if tag_definitions.has(tag_id):
		return tag_definitions[tag_id]
	return {"label": tag_id, "color": "#7F8C8D", "description": ""}


func get_tag_label(tag_id: String) -> String:
	var info: Dictionary = get_tag_info(tag_id)
	return String(info.get("label", tag_id))


func get_tag_color(tag_id: String) -> Color:
	var info: Dictionary = get_tag_info(tag_id)
	return Color.from_string(String(info.get("color", "#7F8C8D")), Color(0.5, 0.55, 0.55))


func get_required_tags_for_symptoms(symptom_ids: Array) -> Array[String]:
	var req_tags: Array[String] = []
	for raw_id in symptom_ids:
		var sym_id: String = String(raw_id)
		var sym: Dictionary = get_symptom(sym_id)
		var sym_tags: Array = sym.get("required_tags", [])
		for raw_tag in sym_tags:
			var tag_str: String = String(raw_tag)
			if not req_tags.has(tag_str):
				req_tags.append(tag_str)
	return req_tags


func get_combined_tags(herb_ids: Array) -> Array[String]:
	var combined: Array[String] = []
	for raw_id in herb_ids:
		var herb_id: String = String(raw_id)
		var herb: Dictionary = get_herb(herb_id)
		var tags: Array = herb.get("effect_tags", [])
		for raw_tag in tags:
			var tag_str: String = String(raw_tag)
			if not combined.has(tag_str):
				combined.append(tag_str)
	return combined


func check_toxicity(herb_ids: Array) -> Dictionary:
	var combined: Array[String] = get_combined_tags(herb_ids)
	var has_toxic: bool = combined.has("toksik")
	var has_detoks: bool = combined.has("detoks")
	var toxic_herb_names: Array[String] = []
	var detoks_herb_names: Array[String] = []
	for raw_id in herb_ids:
		var hid: String = String(raw_id)
		var herb: Dictionary = get_herb(hid)
		var tags: Array = herb.get("effect_tags", [])
		if tags.has("toksik"):
			toxic_herb_names.append(String(herb.get("name", hid)))
		if tags.has("detoks"):
			detoks_herb_names.append(String(herb.get("name", hid)))
	return {
		"has_toxic": has_toxic,
		"has_detoks": has_detoks,
		"is_dangerous": has_toxic and not has_detoks,
		"is_neutralized": has_toxic and has_detoks,
		"toxic_herbs": toxic_herb_names,
		"detoks_herbs": detoks_herb_names,
	}


func get_sample_herbs_for_tag(tag_id: String, max_count: int = 3) -> Array[String]:
	var names: Array[String] = []
	for herb in herbs_list:
		var tags: Array = herb.get("effect_tags", [])
		if tags.has(tag_id) and not tags.has("toksik"):
			names.append(String(herb.get("name", "")))
			if names.size() >= max_count:
				break
	return names


func format_tag_list(tag_ids: Array) -> String:
	var labels: PackedStringArray = PackedStringArray()
	for raw_tag in tag_ids:
		labels.append("[%s]" % get_tag_label(String(raw_tag)))
	return ", ".join(labels)


func evaluate_potion(selected_herb_ids: Array, target_symptom_ids: Array) -> Dictionary:
	## Evaluasi deterministik sesuai Dokumen 03:
	## Prioritas 1: Cek toksik vs detoks -> TOXIC jika toksik tanpa detoks.
	## Prioritas 2: Semua tag terpenuhi -> PERFECT (semua bahan relevan) / GOOD (ada bahan mubazir).
	## Prioritas 3: Sebagian tag terpenuhi -> PARTIAL (sembuhkan gejala yang lengkap tag-nya).
	## Prioritas 4: 0 tag cocok -> FAIL.
	var required_tags: Array[String] = get_required_tags_for_symptoms(target_symptom_ids)
	var potion_tags: Array[String] = get_combined_tags(selected_herb_ids)
	var tox_check: Dictionary = check_toxicity(selected_herb_ids)

	var herb_names: PackedStringArray = PackedStringArray()
	for raw_id in selected_herb_ids:
		herb_names.append(get_herb_name(String(raw_id)))

	var matched_tags: Array[String] = []
	var missing_tags: Array[String] = []
	for req_tag in required_tags:
		if potion_tags.has(req_tag):
			matched_tags.append(req_tag)
		else:
			missing_tags.append(req_tag)

	var cured_symptoms: Array[String] = []
	var remaining_symptoms: Array[String] = []
	for raw_sym in target_symptom_ids:
		var sym_id: String = String(raw_sym)
		var sym: Dictionary = get_symptom(sym_id)
		var sym_req: Array = sym.get("required_tags", [])
		var sym_covered: bool = not sym_req.is_empty()
		for t in sym_req:
			if not potion_tags.has(String(t)):
				sym_covered = false
				break
		if sym_covered:
			cured_symptoms.append(sym_id)
		else:
			remaining_symptoms.append(sym_id)

	# 1. Cek Keamanan Toksik (Prioritas Tertinggi)
	if bool(tox_check["is_dangerous"]):
		var toxic_names: String = ", ".join(PackedStringArray(tox_check["toxic_herbs"]))
		return {
			"status": "TOXIC",
			"title": "BAHAYA TOKSIK!",
			"message": "Ramuan gagal dan beracun! %s mengandung zat [Peringatan Toksik]. Padukan dengan herbal [Penawar Racun / detoks] (seperti Temulawak, Sambiloto, atau Akar Alang-Alang) atau ganti bahan aman!" % toxic_names,
			"required_tags": required_tags,
			"potion_tags": potion_tags,
			"matched_tags": matched_tags,
			"missing_tags": missing_tags,
			"cured_symptoms": [],
			"remaining_symptoms": _to_string_array(target_symptom_ids),
			"toxic_neutralized": false,
			"wasted_herbs": [],
		}

	var toxic_neutralized: bool = bool(tox_check["is_neutralized"])
	var toxic_note: String = ""
	if toxic_neutralized:
		var detoks_names: String = ", ".join(PackedStringArray(tox_check["detoks_herbs"]))
		toxic_note = " Hebat! Racun toksik berhasil dinetralkan oleh %s ([Penawar Racun])." % detoks_names

	# 2. Kasus A: Semua Tag Terpenuhi
	if missing_tags.is_empty() and not required_tags.is_empty():
		var wasted_herbs: Array[String] = []
		var wasted_names: PackedStringArray = PackedStringArray()
		for raw_id in selected_herb_ids:
			var hid: String = String(raw_id)
			var herb: Dictionary = get_herb(hid)
			var h_tags: Array = herb.get("effect_tags", [])
			var contributes: bool = false
			for t in h_tags:
				var ts: String = String(t)
				if required_tags.has(ts):
					contributes = true
					break
				if toxic_neutralized and ts == "detoks":
					contributes = true
					break
			if not contributes:
				wasted_herbs.append(hid)
				wasted_names.append(String(herb.get("name", hid)))

		if wasted_herbs.is_empty():
			return {
				"status": "PERFECT",
				"title": "USADA UTAMA! (Racikan Sempurna)",
				"message": "Pasien sembuh total! Kombinasi %s tepat memenuhi %s tanpa bahan mubazir.%s" % [
					" + ".join(herb_names),
					format_tag_list(matched_tags),
					toxic_note
				],
				"required_tags": required_tags,
				"potion_tags": potion_tags,
				"matched_tags": matched_tags,
				"missing_tags": missing_tags,
				"cured_symptoms": cured_symptoms,
				"remaining_symptoms": [],
				"toxic_neutralized": toxic_neutralized,
				"wasted_herbs": [],
			}
		else:
			return {
				"status": "GOOD",
				"title": "USADA MADYA (Warga Sembuh)",
				"message": "Warga sembuh! Namun %s tidak diperlukan untuk gejala ini. Cermati tag efek agar lebih hemat herbal.%s" % [
					", ".join(wasted_names),
					toxic_note
				],
				"required_tags": required_tags,
				"potion_tags": potion_tags,
				"matched_tags": matched_tags,
				"missing_tags": missing_tags,
				"cured_symptoms": cured_symptoms,
				"remaining_symptoms": [],
				"toxic_neutralized": toxic_neutralized,
				"wasted_herbs": wasted_herbs,
			}

	# 3. Kasus B: Sebagian Tag Terpenuhi
	if not matched_tags.is_empty():
		var cured_names: PackedStringArray = PackedStringArray()
		for cid in cured_symptoms:
			cured_names.append(get_symptom_name(cid))
		var remain_names: PackedStringArray = PackedStringArray()
		for rid in remaining_symptoms:
			remain_names.append(get_symptom_name(rid))
		var suggest_tag: String = missing_tags[0]
		var samples: Array[String] = get_sample_herbs_for_tag(suggest_tag, 3)
		var cured_part: String = ""
		if not cured_names.is_empty():
			cured_part = "%s telah mereda, tetapi " % ", ".join(cured_names)
		return {
			"status": "PARTIAL",
			"title": "SEBAGIAN COCOK (Kurang Ampuh)",
			"message": "%s%s belum teratasi. Tambahkan herbal bertag %s (mis. %s).%s" % [
				cured_part,
				", ".join(remain_names),
				format_tag_list(missing_tags),
				", ".join(PackedStringArray(samples)),
				toxic_note
			],
			"required_tags": required_tags,
			"potion_tags": potion_tags,
			"matched_tags": matched_tags,
			"missing_tags": missing_tags,
			"cured_symptoms": cured_symptoms,
			"remaining_symptoms": remaining_symptoms,
			"toxic_neutralized": toxic_neutralized,
			"wasted_herbs": [],
		}

	# 4. Kasus C: Tidak Ada Tag Cocok
	var first_missing: String = missing_tags[0] if not missing_tags.is_empty() else ""
	var hint_herbs: Array[String] = get_sample_herbs_for_tag(first_missing, 3) if not first_missing.is_empty() else []
	return {
		"status": "FAIL",
		"title": "RACIKAN SALAH!",
		"message": "Ramuan (%s) tidak sesuai gejala pasien! Pasien membutuhkan tag %s (mis. %s). Tekan [L] untuk melihat Buku Lontar Usada." % [
			" + ".join(herb_names),
			format_tag_list(required_tags),
			", ".join(PackedStringArray(hint_herbs))
		],
		"required_tags": required_tags,
		"potion_tags": potion_tags,
		"matched_tags": [],
		"missing_tags": missing_tags,
		"cured_symptoms": [],
		"remaining_symptoms": _to_string_array(target_symptom_ids),
		"toxic_neutralized": toxic_neutralized,
		"wasted_herbs": _to_string_array(selected_herb_ids),
	}


func _to_string_array(items: Array) -> Array[String]:
	var result: Array[String] = []
	for item in items:
		result.append(String(item))
	return result
