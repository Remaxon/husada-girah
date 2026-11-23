extends CanvasLayer
## LontarUsadaUI — Buku Lontar Usada (Terbuka penuh sejak awal: 40/40 Herbal & 12/12 Gejala).
## Tab 1: Daftar seluruh 40 herbal Nusantara dengan filter kategori, tag efek, lokasi, khasiat, & peringatan toksik.
## Tab 2: Panduan seluruh 12 gejala wabah, tag penawar wajib, & 2-3 contoh resep kombinasi herbal valid.
## Saat dibuka, Wabah Meter dijeda penuh (paused).

var _current_category: String = "all"
var _selected_herb_id: String = "kunyit"
var _selected_symptom_id: String = "demam_panas"

var _filter_buttons: Dictionary = {}
var _herb_list_vbox: VBoxContainer
var _herb_detail_vbox: VBoxContainer
var _symptom_list_vbox: VBoxContainer
var _symptom_detail_vbox: VBoxContainer
var _tab_container: TabContainer
var _header_count_label: Label


func _ready() -> void:
	visible = false
	_build_ui()


func open_lontar(default_tab: int = 0) -> void:
	if visible:
		return
	visible = true
	GameManager.set_plague_paused("lontar", true)
	GameManager.set_modal_open("lontar", true)
	if _tab_container != null:
		_tab_container.current_tab = clampi(default_tab, 0, 1)
	_populate_herb_list()
	_show_herb_detail(_selected_herb_id)
	_populate_symptom_list()
	_show_symptom_detail(_selected_symptom_id)
	EventBus.lontar_toggled.emit(true)


func close_lontar() -> void:
	if not visible:
		return
	visible = false
	GameManager.set_plague_paused("lontar", false)
	GameManager.set_modal_open("lontar", false)
	EventBus.lontar_toggled.emit(false)


func toggle_lontar() -> void:
	if visible:
		close_lontar()
	else:
		open_lontar()


func _build_ui() -> void:
	var backdrop: ColorRect = ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.06, 0.04, 0.03, 0.78)
	add_child(backdrop)

	var main_panel: PanelContainer = PanelContainer.new()
	main_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_panel.offset_left = 48.0
	main_panel.offset_top = 32.0
	main_panel.offset_right = -48.0
	main_panel.offset_bottom = -32.0
	main_panel.add_theme_stylebox_override("panel", _make_box(Color(0.19, 0.12, 0.08, 0.98), Color(0.83, 0.63, 0.09), 3, 12))
	add_child(main_panel)

	var root_vbox: VBoxContainer = VBoxContainer.new()
	root_vbox.add_theme_constant_override("separation", 10)
	main_panel.add_child(root_vbox)

	# --- HEADER ---
	var header_hbox: HBoxContainer = HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 12)
	root_vbox.add_child(header_hbox)

	var title_vbox: VBoxContainer = VBoxContainer.new()
	title_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(title_vbox)

	var title_lbl: Label = Label.new()
	title_lbl.text = "BUKU LONTAR USADA — ENSIKLOPEDIA HERBAL NUSANTARA"
	title_lbl.add_theme_font_size_override("font_size", 21)
	title_lbl.add_theme_color_override("font_color", Color(0.97, 0.88, 0.56))
	title_vbox.add_child(title_lbl)

	_header_count_label = Label.new()
	_header_count_label.text = "Terbuka Penuh: 40/40 Herbal Nusantara & 12/12 Gejala Wabah • Gunakan untuk mencocokkan Tag Efek saat meracik"
	_header_count_label.add_theme_font_size_override("font_size", 12)
	_header_count_label.add_theme_color_override("font_color", Color(0.88, 0.82, 0.7))
	title_vbox.add_child(_header_count_label)

	var pause_badge: PanelContainer = PanelContainer.new()
	pause_badge.add_theme_stylebox_override("panel", _make_box(Color(0.14, 0.42, 0.22), Color(0.45, 0.88, 0.55), 2, 6))
	header_hbox.add_child(pause_badge)
	var pause_lbl: Label = Label.new()
	pause_lbl.text = "  WABAH METER DIJEDA  "
	pause_lbl.add_theme_font_size_override("font_size", 13)
	pause_lbl.add_theme_color_override("font_color", Color(0.92, 1.0, 0.92))
	pause_badge.add_child(pause_lbl)

	var close_btn: Button = Button.new()
	close_btn.text = "  [X] Tutup (L / Esc)  "
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.add_theme_stylebox_override("normal", _make_box(Color(0.55, 0.18, 0.16), Color(0.95, 0.6, 0.45), 2, 6))
	close_btn.pressed.connect(close_lontar)
	header_hbox.add_child(close_btn)

	# --- TABS ---
	_tab_container = TabContainer.new()
	_tab_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tab_container.add_theme_font_size_override("font_size", 15)
	root_vbox.add_child(_tab_container)

	_build_tab_herbs()
	_build_tab_symptoms()
	_tab_container.set_tab_title(0, "Tab 1: Daftar 40 Herbal Nusantara")
	_tab_container.set_tab_title(1, "Tab 2: Panduan 12 Gejala & Resep Ramuan")


func _build_tab_herbs() -> void:
	var tab1: VBoxContainer = VBoxContainer.new()
	tab1.name = "TabHerbs"
	tab1.add_theme_constant_override("separation", 8)
	_tab_container.add_child(tab1)

	# Filter Bar
	var filter_hbox: HBoxContainer = HBoxContainer.new()
	filter_hbox.add_theme_constant_override("separation", 6)
	tab1.add_child(filter_hbox)

	var filters: Array = [
		["all", "Semua (40)"],
		["owned", "Di Kantong"],
		["empon_empon", "Empon-Empon"],
		["daun_berkhasiat", "Daun"],
		["akar_batang_kulit", "Akar & Kayu"],
		["rempah_biji", "Rempah & Biji"],
		["bunga_buah_sakral", "Bunga & Sakral"],
		["toksik", "! Toksik"],
	]
	for f in filters:
		var fid: String = String(f[0])
		var flabel: String = String(f[1])
		var btn: Button = Button.new()
		btn.text = flabel
		btn.focus_mode = Control.FOCUS_NONE
		btn.add_theme_font_size_override("font_size", 12)
		btn.pressed.connect(_on_filter_selected.bind(fid))
		filter_hbox.add_child(btn)
		_filter_buttons[fid] = btn

	# Split Content: Left List + Right Detail Card
	var split: HBoxContainer = HBoxContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.add_theme_constant_override("separation", 12)
	tab1.add_child(split)

	var left_panel: PanelContainer = PanelContainer.new()
	left_panel.custom_minimum_size = Vector2(360, 0)
	left_panel.add_theme_stylebox_override("panel", _make_box(Color(0.14, 0.09, 0.06), Color(0.55, 0.4, 0.22), 2, 8))
	split.add_child(left_panel)

	var left_scroll: ScrollContainer = ScrollContainer.new()
	left_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_panel.add_child(left_scroll)

	_herb_list_vbox = VBoxContainer.new()
	_herb_list_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_herb_list_vbox.add_theme_constant_override("separation", 4)
	left_scroll.add_child(_herb_list_vbox)

	var right_panel: PanelContainer = PanelContainer.new()
	right_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_panel.add_theme_stylebox_override("panel", _make_box(Color(0.95, 0.90, 0.78), Color(0.68, 0.48, 0.16), 2, 8))
	split.add_child(right_panel)

	var right_scroll: ScrollContainer = ScrollContainer.new()
	right_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_panel.add_child(right_scroll)

	_herb_detail_vbox = VBoxContainer.new()
	_herb_detail_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_herb_detail_vbox.add_theme_constant_override("separation", 10)
	right_scroll.add_child(_herb_detail_vbox)


func _build_tab_symptoms() -> void:
	var tab2: HBoxContainer = HBoxContainer.new()
	tab2.name = "TabSymptoms"
	tab2.add_theme_constant_override("separation", 12)
	_tab_container.add_child(tab2)

	var left_panel: PanelContainer = PanelContainer.new()
	left_panel.custom_minimum_size = Vector2(360, 0)
	left_panel.add_theme_stylebox_override("panel", _make_box(Color(0.14, 0.09, 0.06), Color(0.55, 0.4, 0.22), 2, 8))
	tab2.add_child(left_panel)

	var left_scroll: ScrollContainer = ScrollContainer.new()
	left_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_panel.add_child(left_scroll)

	_symptom_list_vbox = VBoxContainer.new()
	_symptom_list_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_symptom_list_vbox.add_theme_constant_override("separation", 5)
	left_scroll.add_child(_symptom_list_vbox)

	var right_panel: PanelContainer = PanelContainer.new()
	right_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_panel.add_theme_stylebox_override("panel", _make_box(Color(0.95, 0.90, 0.78), Color(0.68, 0.48, 0.16), 2, 8))
	tab2.add_child(right_panel)

	var right_scroll: ScrollContainer = ScrollContainer.new()
	right_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_panel.add_child(right_scroll)

	_symptom_detail_vbox = VBoxContainer.new()
	_symptom_detail_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_symptom_detail_vbox.add_theme_constant_override("separation", 10)
	right_scroll.add_child(_symptom_detail_vbox)


func _on_filter_selected(category_id: String) -> void:
	_current_category = category_id
	_populate_herb_list()


func _populate_herb_list() -> void:
	if _herb_list_vbox == null:
		return
	for child in _herb_list_vbox.get_children():
		child.queue_free()

	# Highlight tombol filter aktif
	for fid in _filter_buttons.keys():
		var b: Button = _filter_buttons[fid]
		if String(fid) == _current_category:
			b.add_theme_stylebox_override("normal", _make_box(Color(0.83, 0.63, 0.09), Color(1.0, 0.92, 0.6), 2, 5))
			b.add_theme_color_override("font_color", Color(0.12, 0.07, 0.04))
		else:
			b.add_theme_stylebox_override("normal", _make_box(Color(0.28, 0.18, 0.11), Color(0.55, 0.4, 0.22), 1, 5))
			b.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))

	var all_herbs: Array = AlchemyDatabase.get_all_herbs()
	var filtered: Array = []
	for herb in all_herbs:
		var hid: String = String(herb.get("id", ""))
		var cat: String = String(herb.get("category", ""))
		var tags: Array = herb.get("effect_tags", [])
		if _current_category == "all":
			filtered.append(herb)
		elif _current_category == "owned":
			if GameManager.get_herb_count(hid) > 0:
				filtered.append(herb)
		elif _current_category == "toksik":
			if tags.has("toksik"):
				filtered.append(herb)
		elif cat == _current_category:
			filtered.append(herb)

	if filtered.is_empty():
		var empty_lbl: Label = Label.new()
		empty_lbl.text = "Tidak ada herbal pada filter ini."
		empty_lbl.add_theme_color_override("font_color", Color(0.8, 0.75, 0.65))
		_herb_list_vbox.add_child(empty_lbl)
		return

	var index_num: int = 1
	for herb in filtered:
		var hid: String = String(herb.get("id", ""))
		var hname: String = String(herb.get("name", hid))
		var tags: Array = herb.get("effect_tags", [])
		var is_toxic: bool = tags.has("toksik")
		var stock: int = GameManager.get_herb_count(hid)

		var btn: Button = Button.new()
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.focus_mode = Control.FOCUS_NONE
		var suffix: String = ""
		if stock > 0:
			suffix += "  [Stok: %d]" % stock
		if is_toxic:
			suffix += "  [! TOKSIK]"
		btn.text = "%02d. %s%s" % [index_num, hname, suffix]
		btn.add_theme_font_size_override("font_size", 13)

		var is_sel: bool = (hid == _selected_herb_id)
		var bg: Color = Color(0.45, 0.28, 0.14) if is_sel else (Color(0.32, 0.14, 0.36) if is_toxic else Color(0.22, 0.14, 0.09))
		var border: Color = Color(0.95, 0.78, 0.22) if is_sel else (Color(0.75, 0.35, 0.85) if is_toxic else Color(0.4, 0.28, 0.16))
		btn.add_theme_stylebox_override("normal", _make_box(bg, border, 2 if is_sel else 1, 5))
		btn.add_theme_color_override("font_color", Color(1.0, 0.82, 1.0) if is_toxic else Color(0.96, 0.92, 0.82))
		btn.pressed.connect(func() -> void:
			_selected_herb_id = hid
			_populate_herb_list()
			_show_herb_detail(hid)
		)
		_herb_list_vbox.add_child(btn)
		index_num += 1


func _show_herb_detail(herb_id: String) -> void:
	if _herb_detail_vbox == null:
		return
	for child in _herb_detail_vbox.get_children():
		child.queue_free()

	var herb: Dictionary = AlchemyDatabase.get_herb(herb_id)
	if herb.is_empty():
		return

	var dark_ink: Color = Color(0.22, 0.13, 0.07)
	var sub_ink: Color = Color(0.38, 0.24, 0.13)
	var tags: Array = herb.get("effect_tags", [])
	var is_toxic: bool = tags.has("toksik")
	var stock: int = GameManager.get_herb_count(herb_id)

	var title_hbox: HBoxContainer = HBoxContainer.new()
	title_hbox.add_theme_constant_override("separation", 12)
	_herb_detail_vbox.add_child(title_hbox)

	var swatch: ColorRect = ColorRect.new()
	swatch.custom_minimum_size = Vector2(44, 44)
	swatch.color = AlchemyDatabase.get_herb_color(herb_id)
	title_hbox.add_child(swatch)

	var name_vbox: VBoxContainer = VBoxContainer.new()
	title_hbox.add_child(name_vbox)

	var name_lbl: Label = Label.new()
	name_lbl.text = "%s (%s)" % [String(herb.get("name", "")), String(herb.get("local_name", ""))]
	name_lbl.add_theme_font_size_override("font_size", 22)
	name_lbl.add_theme_color_override("font_color", dark_ink)
	name_vbox.add_child(name_lbl)

	var latin_lbl: Label = Label.new()
	latin_lbl.text = "Nama Latin: %s" % String(herb.get("latin_name", ""))
	latin_lbl.add_theme_font_size_override("font_size", 14)
	latin_lbl.add_theme_color_override("font_color", sub_ink)
	name_vbox.add_child(latin_lbl)

	# Info Metadata
	var cat_label: String = AlchemyDatabase.get_category_label(String(herb.get("category", "")))
	var rarity_text: String = String(herb.get("rarity", "umum")).replace("_", " ").capitalize()
	var loc_text: String = String(herb.get("location_label", "Stage 1"))
	var meta_lbl: Label = Label.new()
	meta_lbl.text = "Kategori: %s   |   Kelangkaan: %s\nLokasi Tumbuh: %s   |   Stok di Kantong: %d" % [cat_label, rarity_text, loc_text, stock]
	meta_lbl.add_theme_font_size_override("font_size", 13)
	meta_lbl.add_theme_color_override("font_color", dark_ink)
	meta_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_herb_detail_vbox.add_child(meta_lbl)

	# Peringatan Toksik jika ada
	if is_toxic:
		var warn_box: PanelContainer = PanelContainer.new()
		warn_box.add_theme_stylebox_override("panel", _make_box(Color(0.36, 0.11, 0.42), Color(0.95, 0.35, 0.45), 2, 6))
		_herb_detail_vbox.add_child(warn_box)
		var warn_lbl: Label = Label.new()
		warn_lbl.text = "⚠ PERINGATAN BAHAN TOKSIK!\nTanaman ini membawa tag [Peringatan Toksik]. Jika diracik TANPA herbal bertag [Penawar Racun / detoks], ramuan akan gagal beracun (Wabah Meter +5%, Skor -50). Padukan dengan Temulawak, Sambiloto, atau Akar Alang-Alang untuk menetralkannya!"
		warn_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		warn_lbl.add_theme_font_size_override("font_size", 13)
		warn_lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.95))
		warn_box.add_child(warn_lbl)

	# Tag Efek
	var tag_header: Label = Label.new()
	tag_header.text = "TAG EFEK FARMAKOLOGIS:"
	tag_header.add_theme_font_size_override("font_size", 14)
	tag_header.add_theme_color_override("font_color", dark_ink)
	_herb_detail_vbox.add_child(tag_header)

	var tag_flow: HFlowContainer = HFlowContainer.new()
	tag_flow.add_theme_constant_override("h_separation", 8)
	tag_flow.add_theme_constant_override("v_separation", 6)
	_herb_detail_vbox.add_child(tag_flow)

	for raw_tag in tags:
		var tid: String = String(raw_tag)
		tag_flow.add_child(_make_tag_badge(tid))

	for raw_tag in tags:
		var tid: String = String(raw_tag)
		var tinfo: Dictionary = AlchemyDatabase.get_tag_info(tid)
		var tdesc: Label = Label.new()
		tdesc.text = "• [%s] (%s): %s" % [String(tinfo.get("label", tid)), tid, String(tinfo.get("description", ""))]
		tdesc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		tdesc.add_theme_font_size_override("font_size", 12)
		tdesc.add_theme_color_override("font_color", sub_ink)
		_herb_detail_vbox.add_child(tdesc)

	# Khasiat Edukatif
	var note_panel: PanelContainer = PanelContainer.new()
	note_panel.add_theme_stylebox_override("panel", _make_box(Color(0.89, 0.82, 0.66), Color(0.62, 0.45, 0.2), 1, 6))
	_herb_detail_vbox.add_child(note_panel)

	var note_vbox: VBoxContainer = VBoxContainer.new()
	note_panel.add_child(note_vbox)

	var note_title: Label = Label.new()
	note_title.text = "CATATAN KHASIAT EDUKATIF (ILMU USADA & ETNOBOTANI):"
	note_title.add_theme_font_size_override("font_size", 13)
	note_title.add_theme_color_override("font_color", dark_ink)
	note_vbox.add_child(note_title)

	var note_body: Label = Label.new()
	note_body.text = String(herb.get("educational_note", ""))
	note_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note_body.add_theme_font_size_override("font_size", 14)
	note_body.add_theme_color_override("font_color", Color(0.18, 0.1, 0.05))
	note_vbox.add_child(note_body)


func _populate_symptom_list() -> void:
	if _symptom_list_vbox == null:
		return
	for child in _symptom_list_vbox.get_children():
		child.queue_free()

	var idx: int = 1
	for sym in AlchemyDatabase.get_all_symptoms():
		var sid: String = String(sym.get("id", ""))
		var sname: String = String(sym.get("name", sid))
		var sev: String = String(sym.get("severity", "ringan")).capitalize()
		var min_st: int = int(sym.get("min_stage", 1))

		var btn: Button = Button.new()
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.focus_mode = Control.FOCUS_NONE
		btn.text = "%02d. %s  (S%d • %s)" % [idx, sname, min_st, sev]
		btn.add_theme_font_size_override("font_size", 13)

		var is_sel: bool = (sid == _selected_symptom_id)
		var bg: Color = Color(0.48, 0.26, 0.14) if is_sel else Color(0.22, 0.14, 0.09)
		var border: Color = Color(0.95, 0.78, 0.22) if is_sel else Color(0.45, 0.3, 0.16)
		btn.add_theme_stylebox_override("normal", _make_box(bg, border, 2 if is_sel else 1, 5))
		btn.add_theme_color_override("font_color", Color(0.97, 0.93, 0.84))
		btn.pressed.connect(func() -> void:
			_selected_symptom_id = sid
			_populate_symptom_list()
			_show_symptom_detail(sid)
		)
		_symptom_list_vbox.add_child(btn)
		idx += 1

	# Tombol khusus Panduan Multi-Gejala
	var sep: HSeparator = HSeparator.new()
	_symptom_list_vbox.add_child(sep)

	var combo_btn: Button = Button.new()
	combo_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	combo_btn.focus_mode = Control.FOCUS_NONE
	combo_btn.text = "★ Panduan Kombinasi Multi-Gejala & Toksik"
	combo_btn.add_theme_font_size_override("font_size", 13)
	var is_combo_sel: bool = (_selected_symptom_id == "__COMBO_GUIDE__")
	combo_btn.add_theme_stylebox_override("normal", _make_box(Color(0.2, 0.42, 0.24) if is_combo_sel else Color(0.16, 0.28, 0.18), Color(0.85, 0.75, 0.25), 2, 5))
	combo_btn.add_theme_color_override("font_color", Color(0.96, 0.98, 0.86))
	combo_btn.pressed.connect(func() -> void:
		_selected_symptom_id = "__COMBO_GUIDE__"
		_populate_symptom_list()
		_show_combo_guides()
	)
	_symptom_list_vbox.add_child(combo_btn)


func _show_symptom_detail(symptom_id: String) -> void:
	if symptom_id == "__COMBO_GUIDE__":
		_show_combo_guides()
		return
	if _symptom_detail_vbox == null:
		return
	for child in _symptom_detail_vbox.get_children():
		child.queue_free()

	var sym: Dictionary = AlchemyDatabase.get_symptom(symptom_id)
	if sym.is_empty():
		return

	var dark_ink: Color = Color(0.22, 0.13, 0.07)
	var sub_ink: Color = Color(0.36, 0.22, 0.12)

	var name_lbl: Label = Label.new()
	name_lbl.text = String(sym.get("name", symptom_id))
	name_lbl.add_theme_font_size_override("font_size", 22)
	name_lbl.add_theme_color_override("font_color", dark_ink)
	_symptom_detail_vbox.add_child(name_lbl)

	var meta_lbl: Label = Label.new()
	meta_lbl.text = "Tingkat: %s   |   Muncul Mulai: Stage %d" % [
		String(sym.get("severity", "ringan")).capitalize(),
		int(sym.get("min_stage", 1))
	]
	meta_lbl.add_theme_font_size_override("font_size", 13)
	meta_lbl.add_theme_color_override("font_color", sub_ink)
	_symptom_detail_vbox.add_child(meta_lbl)

	var desc_lbl: Label = Label.new()
	desc_lbl.text = String(sym.get("description", ""))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.add_theme_font_size_override("font_size", 14)
	desc_lbl.add_theme_color_override("font_color", dark_ink)
	_symptom_detail_vbox.add_child(desc_lbl)

	# Tag Penawar Wajib
	var req_hdr: Label = Label.new()
	req_hdr.text = "TAG PENAWAR WAJIB:"
	req_hdr.add_theme_font_size_override("font_size", 14)
	req_hdr.add_theme_color_override("font_color", dark_ink)
	_symptom_detail_vbox.add_child(req_hdr)

	var tag_flow: HFlowContainer = HFlowContainer.new()
	tag_flow.add_theme_constant_override("h_separation", 8)
	_symptom_detail_vbox.add_child(tag_flow)
	for raw_tag in sym.get("required_tags", []):
		tag_flow.add_child(_make_tag_badge(String(raw_tag)))

	var hint_lbl: Label = Label.new()
	hint_lbl.text = "Petunjuk Usada: %s" % String(sym.get("hint_text", ""))
	hint_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint_lbl.add_theme_font_size_override("font_size", 13)
	hint_lbl.add_theme_color_override("font_color", sub_ink)
	_symptom_detail_vbox.add_child(hint_lbl)

	# Contoh Resep Valid (2-3 kombinasi)
	var rec_hdr: Label = Label.new()
	rec_hdr.text = "CONTOH RESEP KOMBINASI HERBAL VALID (2-3 BAHAN):"
	rec_hdr.add_theme_font_size_override("font_size", 14)
	rec_hdr.add_theme_color_override("font_color", dark_ink)
	_symptom_detail_vbox.add_child(rec_hdr)

	var recipes: Array = sym.get("example_recipes", [])
	var r_idx: int = 1
	for rec in recipes:
		if typeof(rec) != TYPE_DICTIONARY:
			continue
		var r_herbs: Array = rec.get("herbs", [])
		var r_note: String = String(rec.get("note", ""))

		var card: PanelContainer = PanelContainer.new()
		card.add_theme_stylebox_override("panel", _make_box(Color(0.89, 0.82, 0.67), Color(0.55, 0.4, 0.18), 1, 6))
		_symptom_detail_vbox.add_child(card)

		var cv: VBoxContainer = VBoxContainer.new()
		cv.add_theme_constant_override("separation", 4)
		card.add_child(cv)

		var hnames: PackedStringArray = PackedStringArray()
		var all_in_stock: bool = true
		for hid_raw in r_herbs:
			var hid: String = String(hid_raw)
			var cnt: int = GameManager.get_herb_count(hid)
			if cnt <= 0:
				all_in_stock = false
			hnames.append("%s (Stok:%d)" % [AlchemyDatabase.get_herb_name(hid), cnt])

		var r_title: Label = Label.new()
		r_title.text = "Resep #%d: %s%s" % [
			r_idx,
			"  +  ".join(hnames),
			"   [✓ SIAP DIRACIK!]" if all_in_stock else ""
		]
		r_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		r_title.add_theme_font_size_override("font_size", 14)
		r_title.add_theme_color_override("font_color", Color(0.12, 0.42, 0.18) if all_in_stock else dark_ink)
		cv.add_child(r_title)

		var comb_tags: Array[String] = AlchemyDatabase.get_combined_tags(r_herbs)
		var cflow: HFlowContainer = HFlowContainer.new()
		cflow.add_theme_constant_override("h_separation", 6)
		cflow.add_theme_constant_override("v_separation", 4)
		cv.add_child(cflow)
		for t in comb_tags:
			cflow.add_child(_make_tag_badge(t))

		var r_note_lbl: Label = Label.new()
		r_note_lbl.text = r_note
		r_note_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		r_note_lbl.add_theme_font_size_override("font_size", 12)
		r_note_lbl.add_theme_color_override("font_color", sub_ink)
		cv.add_child(r_note_lbl)
		r_idx += 1


func _show_combo_guides() -> void:
	if _symptom_detail_vbox == null:
		return
	for child in _symptom_detail_vbox.get_children():
		child.queue_free()

	var dark_ink: Color = Color(0.22, 0.13, 0.07)

	var title_lbl: Label = Label.new()
	title_lbl.text = "PANDUAN KOMBINASI MULTI-GEJALA & ATURAN TOKSIK"
	title_lbl.add_theme_font_size_override("font_size", 20)
	title_lbl.add_theme_color_override("font_color", dark_ink)
	_symptom_detail_vbox.add_child(title_lbl)

	var intro: Label = Label.new()
	intro.text = "Pasien di Desa Girah sering menderita 2–3 gejala sekaligus. Masukkan 2–3 herbal ke Meja Alkimia agar gabungan Tag Efeknya memenuhi seluruh gejala pasien (usahakan tidak ada bahan yang mubazir untuk skor USADA UTAMA!)."
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.add_theme_font_size_override("font_size", 13)
	intro.add_theme_color_override("font_color", Color(0.32, 0.2, 0.1))
	_symptom_detail_vbox.add_child(intro)

	for guide in AlchemyDatabase.combo_guides:
		if typeof(guide) != TYPE_DICTIONARY:
			continue
		var card: PanelContainer = PanelContainer.new()
		card.add_theme_stylebox_override("panel", _make_box(Color(0.89, 0.82, 0.67), Color(0.55, 0.4, 0.18), 2, 6))
		_symptom_detail_vbox.add_child(card)

		var cv: VBoxContainer = VBoxContainer.new()
		cv.add_theme_constant_override("separation", 5)
		card.add_child(cv)

		var g_title: Label = Label.new()
		g_title.text = String(guide.get("title", ""))
		g_title.add_theme_font_size_override("font_size", 15)
		g_title.add_theme_color_override("font_color", dark_ink)
		g_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		cv.add_child(g_title)

		var tflow: HFlowContainer = HFlowContainer.new()
		tflow.add_theme_constant_override("h_separation", 6)
		cv.add_child(tflow)
		for raw_t in guide.get("required_tags", []):
			tflow.add_child(_make_tag_badge(String(raw_t)))

		for raw_line in guide.get("recipes", []):
			var line_lbl: Label = Label.new()
			line_lbl.text = "  • " + String(raw_line)
			line_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			line_lbl.add_theme_font_size_override("font_size", 13)
			line_lbl.add_theme_color_override("font_color", Color(0.2, 0.12, 0.06))
			cv.add_child(line_lbl)


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
