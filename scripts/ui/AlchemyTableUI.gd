extends CanvasLayer
## AlchemyTableUI — Modal Meja Alkimia (Lumpang & Pipisan).
## Pemain memilih 2-3 herbal dari Kantong Bersama, melihat pratinjau Tag Efek & risiko toksik,
## serta mencocokkannya dengan catatan gejala pasien yang sudah didiagnosa.

signal open_lontar_requested()

var _selected_slots: Array[String] = []
var _reference_patient_id: String = ""

var _pouch_vbox: VBoxContainer
var _slot_buttons: Array[Button] = []
var _preview_tags_flow: HFlowContainer
var _toxic_banner_panel: PanelContainer
var _toxic_banner_label: Label
var _brew_btn: Button
var _potion_count_label: Label
var _status_note_label: Label
var _plague_mode_label: Label
var _patient_tabs_hbox: HBoxContainer
var _patient_info_vbox: VBoxContainer


func _ready() -> void:
	visible = false
	_build_ui()
	EventBus.herb_inventory_changed.connect(_on_inventory_changed)
	EventBus.ready_potions_changed.connect(_on_inventory_changed)


func toggle_alchemy() -> void:
	if visible:
		close_alchemy()
	else:
		open_alchemy()


func open_alchemy() -> void:
	if visible:
		return
	visible = true
	_selected_slots.clear()
	_reference_patient_id = GameManager.last_diagnosed_patient_id
	# Di Stage 1 pengenalan: Wabah Meter dijeda penuh; di Stage 2-4: melambat 25%
	if GameManager.current_stage == 1:
		GameManager.set_plague_paused("cauldron", true)
		if _plague_mode_label != null:
			_plague_mode_label.text = "  WABAH DIJEDA (Stage 1)  "
	else:
		GameManager.set_plague_slow("cauldron", 0.25)
		if _plague_mode_label != null:
			_plague_mode_label.text = "  WABAH MELAMBAT (25%)  "
	GameManager.set_modal_open("cauldron", true)
	_status_note_label.text = "Kuali Portabel siap! Pilih 2 hingga 3 herbal di kiri untuk meracik ramuan di mana saja."
	_status_note_label.add_theme_color_override("font_color", Color(0.92, 0.88, 0.78))
	_refresh_all()
	EventBus.cauldron_toggled.emit(true)


func close_alchemy() -> void:
	if not visible:
		return
	visible = false
	_selected_slots.clear()
	GameManager.set_plague_paused("cauldron", false)
	GameManager.set_plague_slow("cauldron", 1.0)
	GameManager.set_modal_open("cauldron", false)
	EventBus.cauldron_toggled.emit(false)


func _on_inventory_changed() -> void:
	if visible:
		_refresh_all()


func _build_ui() -> void:
	var backdrop: ColorRect = ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.05, 0.03, 0.02, 0.74)
	add_child(backdrop)

	var main_panel: PanelContainer = PanelContainer.new()
	main_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_panel.offset_left = 54.0
	main_panel.offset_top = 42.0
	main_panel.offset_right = -54.0
	main_panel.offset_bottom = -42.0
	main_panel.add_theme_stylebox_override("panel", _make_box(Color(0.18, 0.11, 0.07, 0.98), Color(0.83, 0.63, 0.09), 3, 12))
	add_child(main_panel)

	var root_vbox: VBoxContainer = VBoxContainer.new()
	root_vbox.add_theme_constant_override("separation", 10)
	main_panel.add_child(root_vbox)

	# --- HEADER ---
	var header: HBoxContainer = HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	root_vbox.add_child(header)

	var title_lbl: Label = Label.new()
	title_lbl.text = "KUALI PORTABEL TABIB WIRA — LUMPANG & PIPISAN"
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.add_theme_font_size_override("font_size", 20)
	title_lbl.add_theme_color_override("font_color", Color(0.98, 0.88, 0.52))
	header.add_child(title_lbl)

	var mode_badge: PanelContainer = PanelContainer.new()
	mode_badge.add_theme_stylebox_override("panel", _make_box(Color(0.14, 0.4, 0.22), Color(0.45, 0.85, 0.55), 2, 6))
	header.add_child(mode_badge)
	_plague_mode_label = Label.new()
	_plague_mode_label.text = "  WABAH DIJEDA (Stage 1)  "
	_plague_mode_label.add_theme_font_size_override("font_size", 12)
	_plague_mode_label.add_theme_color_override("font_color", Color(0.92, 1.0, 0.92))
	mode_badge.add_child(_plague_mode_label)

	var lontar_btn: Button = Button.new()
	lontar_btn.text = "  [L] Buku Lontar  "
	lontar_btn.focus_mode = Control.FOCUS_NONE
	lontar_btn.add_theme_stylebox_override("normal", _make_box(Color(0.24, 0.44, 0.26), Color(0.83, 0.63, 0.09), 2, 6))
	lontar_btn.pressed.connect(func() -> void: open_lontar_requested.emit())
	header.add_child(lontar_btn)

	var close_btn: Button = Button.new()
	close_btn.text = "  [X] Tutup (R / Esc)  "
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.add_theme_stylebox_override("normal", _make_box(Color(0.55, 0.18, 0.16), Color(0.95, 0.6, 0.45), 2, 6))
	close_btn.pressed.connect(close_alchemy)
	header.add_child(close_btn)

	# --- 3 KOLOM UTAMA ---
	var cols: HBoxContainer = HBoxContainer.new()
	cols.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cols.add_theme_constant_override("separation", 12)
	root_vbox.add_child(cols)

	# KOLOM 1: Kantong Herbal
	var col1_panel: PanelContainer = PanelContainer.new()
	col1_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col1_panel.size_flags_stretch_ratio = 1.15
	col1_panel.add_theme_stylebox_override("panel", _make_box(Color(0.13, 0.08, 0.05), Color(0.55, 0.38, 0.2), 2, 8))
	cols.add_child(col1_panel)

	var col1_v: VBoxContainer = VBoxContainer.new()
	col1_v.add_theme_constant_override("separation", 6)
	col1_panel.add_child(col1_v)

	var c1_hdr: Label = Label.new()
	c1_hdr.text = "1. KANTONG HERBAL BERSAMA (Klik untuk masukkan)"
	c1_hdr.add_theme_font_size_override("font_size", 13)
	c1_hdr.add_theme_color_override("font_color", Color(0.95, 0.86, 0.6))
	col1_v.add_child(c1_hdr)

	var c1_scroll: ScrollContainer = ScrollContainer.new()
	c1_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col1_v.add_child(c1_scroll)

	_pouch_vbox = VBoxContainer.new()
	_pouch_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_pouch_vbox.add_theme_constant_override("separation", 5)
	c1_scroll.add_child(_pouch_vbox)

	# KOLOM 2: Slot Lumpang & Pratinjau Tag
	var col2_panel: PanelContainer = PanelContainer.new()
	col2_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col2_panel.size_flags_stretch_ratio = 1.1
	col2_panel.add_theme_stylebox_override("panel", _make_box(Color(0.24, 0.16, 0.1), Color(0.83, 0.63, 0.09), 2, 8))
	cols.add_child(col2_panel)

	var col2_v: VBoxContainer = VBoxContainer.new()
	col2_v.add_theme_constant_override("separation", 8)
	col2_panel.add_child(col2_v)

	var c2_hdr: Label = Label.new()
	c2_hdr.text = "2. SLOT LUMPANG RACIKAN (2–3 Herbal)"
	c2_hdr.add_theme_font_size_override("font_size", 14)
	c2_hdr.add_theme_color_override("font_color", Color(0.98, 0.89, 0.56))
	col2_v.add_child(c2_hdr)

	_slot_buttons.clear()
	for i in range(3):
		var slot_btn: Button = Button.new()
		slot_btn.custom_minimum_size = Vector2(0, 44)
		slot_btn.focus_mode = Control.FOCUS_NONE
		slot_btn.add_theme_font_size_override("font_size", 14)
		slot_btn.pressed.connect(_on_slot_clicked.bind(i))
		col2_v.add_child(slot_btn)
		_slot_buttons.append(slot_btn)

	var prev_hdr: Label = Label.new()
	prev_hdr.text = "PRATINJAU GABUNGAN TAG EFEK:"
	prev_hdr.add_theme_font_size_override("font_size", 12)
	prev_hdr.add_theme_color_override("font_color", Color(0.92, 0.86, 0.72))
	col2_v.add_child(prev_hdr)

	_preview_tags_flow = HFlowContainer.new()
	_preview_tags_flow.custom_minimum_size = Vector2(0, 56)
	_preview_tags_flow.add_theme_constant_override("h_separation", 6)
	_preview_tags_flow.add_theme_constant_override("v_separation", 5)
	col2_v.add_child(_preview_tags_flow)

	_toxic_banner_panel = PanelContainer.new()
	col2_v.add_child(_toxic_banner_panel)
	_toxic_banner_label = Label.new()
	_toxic_banner_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_toxic_banner_label.add_theme_font_size_override("font_size", 12)
	_toxic_banner_panel.add_child(_toxic_banner_label)

	var action_hbox: HBoxContainer = HBoxContainer.new()
	action_hbox.add_theme_constant_override("separation", 8)
	col2_v.add_child(action_hbox)

	_brew_btn = Button.new()
	_brew_btn.text = "RACIK RAMUAN!"
	_brew_btn.custom_minimum_size = Vector2(0, 48)
	_brew_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_brew_btn.focus_mode = Control.FOCUS_NONE
	_brew_btn.add_theme_font_size_override("font_size", 16)
	_brew_btn.pressed.connect(_on_brew_pressed)
	action_hbox.add_child(_brew_btn)

	var clear_btn: Button = Button.new()
	clear_btn.text = "Kosongkan"
	clear_btn.custom_minimum_size = Vector2(105, 48)
	clear_btn.focus_mode = Control.FOCUS_NONE
	clear_btn.add_theme_stylebox_override("normal", _make_box(Color(0.35, 0.22, 0.15), Color(0.65, 0.45, 0.3), 1, 6))
	clear_btn.pressed.connect(func() -> void:
		_selected_slots.clear()
		_refresh_all()
	)
	action_hbox.add_child(clear_btn)

	_potion_count_label = Label.new()
	_potion_count_label.add_theme_font_size_override("font_size", 12)
	_potion_count_label.add_theme_color_override("font_color", Color(0.86, 0.92, 0.78))
	col2_v.add_child(_potion_count_label)

	_status_note_label = Label.new()
	_status_note_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status_note_label.add_theme_font_size_override("font_size", 12)
	col2_v.add_child(_status_note_label)

	# KOLOM 3: Rujukan Gejala Pasien Terdiagnosa
	var col3_panel: PanelContainer = PanelContainer.new()
	col3_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col3_panel.size_flags_stretch_ratio = 1.05
	col3_panel.add_theme_stylebox_override("panel", _make_box(Color(0.94, 0.89, 0.77), Color(0.66, 0.46, 0.16), 2, 8))
	cols.add_child(col3_panel)

	var col3_v: VBoxContainer = VBoxContainer.new()
	col3_v.add_theme_constant_override("separation", 8)
	col3_panel.add_child(col3_v)

	var c3_hdr: Label = Label.new()
	c3_hdr.text = "3. RUJUKAN PASIEN TERDIAGNOSA"
	c3_hdr.add_theme_font_size_override("font_size", 14)
	c3_hdr.add_theme_color_override("font_color", Color(0.24, 0.14, 0.07))
	col3_v.add_child(c3_hdr)

	_patient_tabs_hbox = HBoxContainer.new()
	_patient_tabs_hbox.add_theme_constant_override("separation", 5)
	col3_v.add_child(_patient_tabs_hbox)

	var c3_scroll: ScrollContainer = ScrollContainer.new()
	c3_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col3_v.add_child(c3_scroll)

	_patient_info_vbox = VBoxContainer.new()
	_patient_info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_patient_info_vbox.add_theme_constant_override("separation", 6)
	c3_scroll.add_child(_patient_info_vbox)


func _refresh_all() -> void:
	_refresh_pouch_list()
	_refresh_slots_and_preview()
	_refresh_patient_reference()


func _get_used_in_slots(herb_id: String) -> int:
	var c: int = 0
	for s in _selected_slots:
		if s == herb_id:
			c += 1
	return c


func _refresh_pouch_list() -> void:
	for child in _pouch_vbox.get_children():
		child.queue_free()

	var avail: Dictionary = GameManager.get_available_herbs()
	if avail.is_empty():
		var empty_lbl: Label = Label.new()
		empty_lbl.text = "Kantong herbal kosong!\nPetik tanaman obat di Desa Girah atau Zona Kabut (tanaman tumbuh kembali setiap 20 dtk)."
		empty_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty_lbl.add_theme_color_override("font_color", Color(0.95, 0.78, 0.6))
		_pouch_vbox.add_child(empty_lbl)
		return

	var sorted_ids: Array = avail.keys()
	sorted_ids.sort()

	for raw_id in sorted_ids:
		var hid: String = String(raw_id)
		var total_stock: int = int(avail[hid])
		var remaining: int = total_stock - _get_used_in_slots(hid)
		var herb: Dictionary = AlchemyDatabase.get_herb(hid)
		var hname: String = String(herb.get("name", hid))
		var tags: Array = herb.get("effect_tags", [])
		var is_toxic: bool = tags.has("toksik")

		var card_btn: Button = Button.new()
		card_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		card_btn.focus_mode = Control.FOCUS_NONE
		card_btn.disabled = (remaining <= 0 or _selected_slots.size() >= 3)
		card_btn.text = "%s  (Sisa: %d)%s\n  Tag: %s" % [
			hname,
			remaining,
			"  [! TOKSIK]" if is_toxic else "",
			AlchemyDatabase.format_tag_list(tags)
		]
		card_btn.add_theme_font_size_override("font_size", 12)
		var bg: Color = Color(0.35, 0.13, 0.38) if is_toxic else Color(0.24, 0.16, 0.1)
		var border: Color = Color(0.85, 0.35, 0.9) if is_toxic else Color(0.48, 0.34, 0.18)
		card_btn.add_theme_stylebox_override("normal", _make_box(bg, border, 1, 6))
		card_btn.add_theme_color_override("font_color", Color(1.0, 0.85, 1.0) if is_toxic else Color(0.96, 0.92, 0.84))
		card_btn.pressed.connect(func() -> void:
			if _selected_slots.size() < 3 and (GameManager.get_herb_count(hid) - _get_used_in_slots(hid)) > 0:
				_selected_slots.append(hid)
				_refresh_all()
		)
		_pouch_vbox.add_child(card_btn)


func _on_slot_clicked(slot_idx: int) -> void:
	if slot_idx >= 0 and slot_idx < _selected_slots.size():
		_selected_slots.remove_at(slot_idx)
		_refresh_all()


func _refresh_slots_and_preview() -> void:
	for i in range(3):
		var btn: Button = _slot_buttons[i]
		if i < _selected_slots.size():
			var hid: String = _selected_slots[i]
			var hname: String = AlchemyDatabase.get_herb_name(hid)
			btn.text = "Slot %d:  %s   (Klik untuk lepas)" % [i + 1, hname]
			btn.add_theme_stylebox_override("normal", _make_box(Color(0.22, 0.44, 0.25), Color(0.85, 0.72, 0.22), 2, 6))
			btn.add_theme_color_override("font_color", Color(0.98, 0.98, 0.9))
		else:
			btn.text = "Slot %d:  (Kosong — pilih herbal di kiri)" % (i + 1)
			btn.add_theme_stylebox_override("normal", _make_box(Color(0.16, 0.11, 0.07), Color(0.42, 0.3, 0.18), 1, 6))
			btn.add_theme_color_override("font_color", Color(0.7, 0.65, 0.56))

	for child in _preview_tags_flow.get_children():
		child.queue_free()

	var combined: Array[String] = AlchemyDatabase.get_combined_tags(_selected_slots)
	if combined.is_empty():
		var none_lbl: Label = Label.new()
		none_lbl.text = "(Belum ada tag efek — masukkan 2–3 herbal)"
		none_lbl.add_theme_font_size_override("font_size", 12)
		none_lbl.add_theme_color_override("font_color", Color(0.76, 0.7, 0.6))
		_preview_tags_flow.add_child(none_lbl)
	else:
		for tid in combined:
			_preview_tags_flow.add_child(_make_tag_badge(tid))

	var tox: Dictionary = AlchemyDatabase.check_toxicity(_selected_slots)
	if bool(tox["is_dangerous"]):
		_toxic_banner_panel.add_theme_stylebox_override("panel", _make_box(Color(0.44, 0.1, 0.36), Color(1.0, 0.28, 0.35), 2, 6))
		_toxic_banner_label.text = "⚠ BAHAYA TOKSIK AKTIF! Ada bahan beracun TANPA [Penawar Racun / detoks]. Meracik sekarang akan memicu kegagalan beracun (Wabah +5%, Skor -50)!"
		_toxic_banner_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.94))
	elif bool(tox["is_neutralized"]):
		_toxic_banner_panel.add_theme_stylebox_override("panel", _make_box(Color(0.12, 0.42, 0.24), Color(0.45, 0.95, 0.58), 2, 6))
		_toxic_banner_label.text = "✓ TOKSIK DINETRALKAN! Herbal [Penawar Racun / detoks] berhasil menetralkan racun bahan berisiko — aman diracik!"
		_toxic_banner_label.add_theme_color_override("font_color", Color(0.92, 1.0, 0.94))
	else:
		_toxic_banner_panel.add_theme_stylebox_override("panel", _make_box(Color(0.15, 0.24, 0.16), Color(0.35, 0.56, 0.38), 1, 6))
		_toxic_banner_label.text = "✓ Status Keamanan: Aman (Tidak mengandung zat toksik)"
		_toxic_banner_label.add_theme_color_override("font_color", Color(0.84, 0.95, 0.85))

	var can_brew: bool = _selected_slots.size() >= 2 and _selected_slots.size() <= 3
	_brew_btn.disabled = not can_brew
	if not can_brew:
		_brew_btn.text = "Pilih Minimal 2 Herbal (%d/2)" % _selected_slots.size()
		_brew_btn.add_theme_stylebox_override("normal", _make_box(Color(0.28, 0.24, 0.2), Color(0.45, 0.4, 0.35), 1, 6))
	elif bool(tox["is_dangerous"]):
		_brew_btn.text = "⚠ RACIK (BERISIKO TOKSIK!)"
		_brew_btn.add_theme_stylebox_override("normal", _make_box(Color(0.62, 0.14, 0.22), Color(1.0, 0.45, 0.45), 2, 6))
	else:
		_brew_btn.text = "RACIK RAMUAN! (%d Bahan)" % _selected_slots.size()
		_brew_btn.add_theme_stylebox_override("normal", _make_box(Color(0.2, 0.56, 0.28), Color(0.92, 0.78, 0.24), 2, 6))

	_potion_count_label.text = "Slot Ramuan Siap Pakai di Kantong: %d / %d botol" % [
		GameManager.ready_potions.size(),
		GameManager.MAX_READY_POTIONS
	]


func _refresh_patient_reference() -> void:
	for child in _patient_tabs_hbox.get_children():
		child.queue_free()
	for child in _patient_info_vbox.get_children():
		child.queue_free()

	var dark_ink: Color = Color(0.22, 0.13, 0.07)
	var sub_ink: Color = Color(0.38, 0.24, 0.12)

	var active_entries: Array = []
	for pid in GameManager.diagnosed_patients.keys():
		var entry: Dictionary = GameManager.diagnosed_patients[pid]
		if not bool(entry.get("cured", false)):
			active_entries.append(entry)

	if active_entries.is_empty():
		var info: Label = Label.new()
		info.text = "Belum ada pasien sakit yang terdiagnosa.\n\nTips:\n• Dekati warga sakit di Desa Girah dan tekan [E] untuk mendiagnosa gejalanya.\n• Gejala pasien akan otomatis muncul di panel ini sebagai rujukan cepat saat meracik!"
		info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info.add_theme_font_size_override("font_size", 13)
		info.add_theme_color_override("font_color", sub_ink)
		_patient_info_vbox.add_child(info)
		return

	# Pastikan reference patient valid
	var found: bool = false
	for e in active_entries:
		if String(e["id"]) == _reference_patient_id:
			found = true
			break
	if not found:
		_reference_patient_id = String(active_entries[0]["id"])

	# Tombol pilih pasien
	for e in active_entries:
		var eid: String = String(e["id"])
		var btn: Button = Button.new()
		btn.text = String(e["name"])
		btn.focus_mode = Control.FOCUS_NONE
		btn.add_theme_font_size_override("font_size", 12)
		var is_sel: bool = (eid == _reference_patient_id)
		btn.add_theme_stylebox_override("normal", _make_box(Color(0.48, 0.26, 0.12) if is_sel else Color(0.78, 0.7, 0.54), Color(0.6, 0.35, 0.12), 2 if is_sel else 1, 5))
		btn.add_theme_color_override("font_color", Color(1.0, 0.96, 0.85) if is_sel else dark_ink)
		btn.pressed.connect(func() -> void:
			_reference_patient_id = eid
			_refresh_patient_reference()
		)
		_patient_tabs_hbox.add_child(btn)

	# Tampilkan detail pasien terpilih
	var target: Dictionary = GameManager.diagnosed_patients[_reference_patient_id]
	var symptoms: Array = target.get("symptoms", [])
	var req_tags: Array[String] = AlchemyDatabase.get_required_tags_for_symptoms(symptoms)
	var current_tags: Array[String] = AlchemyDatabase.get_combined_tags(_selected_slots)

	var p_hdr: Label = Label.new()
	p_hdr.text = "Pasien: %s (%d Gejala Aktif)" % [String(target["name"]), symptoms.size()]
	p_hdr.add_theme_font_size_override("font_size", 15)
	p_hdr.add_theme_color_override("font_color", dark_ink)
	_patient_info_vbox.add_child(p_hdr)

	for sid_raw in symptoms:
		var sid: String = String(sid_raw)
		var sym: Dictionary = AlchemyDatabase.get_symptom(sid)
		var slbl: Label = Label.new()
		slbl.text = "• %s — %s" % [String(sym.get("name", sid)), AlchemyDatabase.format_tag_list(sym.get("required_tags", []))]
		slbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		slbl.add_theme_font_size_override("font_size", 13)
		slbl.add_theme_color_override("font_color", Color(0.55, 0.16, 0.14))
		_patient_info_vbox.add_child(slbl)

	var chk_hdr: Label = Label.new()
	chk_hdr.text = "\nCHECKLIST TAG PENAWAR WAJIB:"
	chk_hdr.add_theme_font_size_override("font_size", 13)
	chk_hdr.add_theme_color_override("font_color", dark_ink)
	_patient_info_vbox.add_child(chk_hdr)

	for rtag in req_tags:
		var covered: bool = current_tags.has(rtag)
		var clbl: Label = Label.new()
		clbl.text = ("  [✓] %s — TERPENUHI" if covered else "  [ ] %s — Belum ada") % AlchemyDatabase.get_tag_label(rtag)
		clbl.add_theme_font_size_override("font_size", 13)
		clbl.add_theme_color_override("font_color", Color(0.1, 0.48, 0.18) if covered else Color(0.65, 0.18, 0.14))
		_patient_info_vbox.add_child(clbl)

	# Prediksi evaluasi jika >= 2 herbal terpilih
	if _selected_slots.size() >= 2:
		var preview_eval: Dictionary = AlchemyDatabase.evaluate_potion(_selected_slots, symptoms)
		var st: String = String(preview_eval["status"])
		var pred_box: PanelContainer = PanelContainer.new()
		var pbg: Color = Color(0.18, 0.48, 0.24)
		if st == "TOXIC":
			pbg = Color(0.5, 0.12, 0.35)
		elif st == "FAIL":
			pbg = Color(0.56, 0.22, 0.18)
		elif st == "PARTIAL":
			pbg = Color(0.62, 0.44, 0.12)
		elif st == "GOOD":
			pbg = Color(0.24, 0.48, 0.34)
		pred_box.add_theme_stylebox_override("panel", _make_box(pbg, Color(0.95, 0.85, 0.5), 1, 6))
		_patient_info_vbox.add_child(pred_box)

		var plbl: Label = Label.new()
		plbl.text = "Pratinjau untuk %s: %s" % [String(target["name"]), String(preview_eval["title"])]
		plbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		plbl.add_theme_font_size_override("font_size", 12)
		plbl.add_theme_color_override("font_color", Color(1.0, 0.98, 0.92))
		pred_box.add_child(plbl)


func _on_brew_pressed() -> void:
	var result: Dictionary = GameManager.brew_potion_into_pouch(_selected_slots)
	if bool(result.get("ok", false)):
		_selected_slots.clear()
		_status_note_label.text = "✓ Ramuan masuk ke Slot Ramuan! Tutup meja lalu dekati warga sakit dan tekan [E]."
		_status_note_label.add_theme_color_override("font_color", Color(0.62, 1.0, 0.65))
		_refresh_all()
	elif bool(result.get("toxic_explosion", false)):
		_selected_slots.clear()
		_status_note_label.text = "⚠ GAGAL TOKSIK! Bahan terbuang, Wabah +5%, Skor -50. Tambahkan herbal [Penawar Racun / detoks] lain kali!"
		_status_note_label.add_theme_color_override("font_color", Color(1.0, 0.55, 0.65))
		_refresh_all()
	else:
		_status_note_label.text = String(result.get("reason", "Gagal meracik."))
		_status_note_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.45))


func _make_tag_badge(tag_id: String) -> PanelContainer:
	var pc: PanelContainer = PanelContainer.new()
	var col: Color = AlchemyDatabase.get_tag_color(tag_id)
	pc.add_theme_stylebox_override("panel", _make_box(col, col.lightened(0.3), 1, 5))
	var lbl: Label = Label.new()
	lbl.text = " %s " % AlchemyDatabase.get_tag_label(tag_id)
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", Color(0.08, 0.06, 0.05) if col.get_luminance() > 0.6 else Color(1.0, 1.0, 1.0))
	pc.add_child(lbl)
	return pc


func _make_box(bg: Color, border: Color, border_w: int = 2, radius: int = 6) -> StyleBoxFlat:
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.border_width_left = border_w
	sb.border_width_top = border_w
	sb.border_width_right = border_w
	sb.border_width_bottom = border_w
	sb.corner_radius_top_left = radius
	sb.corner_radius_top_right = radius
	sb.corner_radius_bottom_left = radius
	sb.corner_radius_bottom_right = radius
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	return sb
