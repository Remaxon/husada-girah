extends CanvasLayer
## GameHUD — HUD Adaptif 2 Mode (Tabib Wira vs Mpu Bahula), Wabah Meter, Skor,
## Minimap Ringkas pojok kanan atas, Panel Inventory (item permanen Buku Lontar Usada [L] & Kuali Racik [R]),
## Slot Ramuan Siap Pakai, Catatan Diagnosa, Popup Umpan Balik Instan, serta Pause & Win/Lose Overlay.

signal lontar_button_pressed()
signal cauldron_button_pressed()
signal switch_button_pressed()
signal pause_button_pressed()
signal retry_stage_requested()

const MinimapControlScript = preload("res://scripts/ui/MinimapControl.gd")

var _char_panel: PanelContainer
var _char_name_label: Label
var _char_controls_label: Label
var _bahula_hp_bar: ProgressBar
var _bahula_hp_label: Label
var _dash_status_label: Label

var _plague_label: Label
var _plague_bar: ProgressBar
var _plague_bar_fill_style: StyleBoxFlat
var _patient_counter_label: Label

var _score_label: Label
var _streak_label: Label

var _minimap_control: Control
var _diag_list_vbox: VBoxContainer
var _prompt_panel: PanelContainer
var _prompt_label: Label

var _feedback_panel: PanelContainer
var _feedback_title_label: Label
var _feedback_msg_label: Label
var _feedback_timer: float = 0.0

var _herbs_flow: HFlowContainer
var _potions_hbox: HBoxContainer

var _pause_overlay: Control
var _end_overlay: Control
var _end_title_label: Label
var _end_stars_label: Label
var _end_body_label: Label


func _ready() -> void:
	_build_hud()
	_connect_signals()
	_refresh_all()


func setup_minimap(config: Dictionary) -> void:
	if _minimap_control != null and _minimap_control.has_method("setup_minimap"):
		_minimap_control.setup_minimap(config)


func _process(delta: float) -> void:
	if _feedback_timer > 0.0:
		_feedback_timer -= delta
		if _feedback_timer <= 0.0 and _feedback_panel != null:
			_feedback_panel.visible = false


func _connect_signals() -> void:
	EventBus.active_character_changed.connect(_on_character_changed)
	EventBus.plague_meter_updated.connect(_on_plague_updated)
	EventBus.score_updated.connect(_on_score_updated)
	EventBus.herb_inventory_changed.connect(_refresh_inventory)
	EventBus.ready_potions_changed.connect(_refresh_potions)
	EventBus.patient_diagnosed.connect(_on_patient_diagnosed)
	EventBus.patient_cured.connect(_on_patient_cured)
	EventBus.all_patients_cured.connect(_on_all_patients_cured)
	EventBus.interaction_prompt_changed.connect(_on_prompt_changed)
	EventBus.feedback_requested.connect(_on_feedback_requested)
	EventBus.bahula_hp_changed.connect(_on_bahula_hp_changed)
	EventBus.bahula_dash_cooldown_updated.connect(_on_dash_cd_updated)
	EventBus.bahula_retreat_cooldown_updated.connect(_on_retreat_cd_updated)
	EventBus.stage_won.connect(_on_stage_won)
	EventBus.stage_lost.connect(_on_stage_lost)


func set_pause_overlay_visible(is_open: bool) -> void:
	if _pause_overlay != null:
		_pause_overlay.visible = is_open


func is_pause_overlay_visible() -> bool:
	return _pause_overlay != null and _pause_overlay.visible


func _refresh_all() -> void:
	_on_character_changed(GameManager.active_character)
	_on_plague_updated(GameManager.plague_meter, GameManager.is_plague_paused())
	_on_score_updated(ScoreManager.total_score, 0, ScoreManager.current_streak, "")
	_on_bahula_hp_changed(GameManager.bahula_hp, GameManager.bahula_max_hp)
	_on_patient_cured("", GameManager.cured_patients, GameManager.total_patients)
	_refresh_inventory()
	_refresh_potions()
	_refresh_diagnosis_panel()


func _build_hud() -> void:
	var root: Control = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	# ===================== TOP BAR (Memberi ruang bagi Minimap di Pojok Kanan Atas) =====================
	var top_hbox: HBoxContainer = HBoxContainer.new()
	top_hbox.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_hbox.offset_left = 12.0
	top_hbox.offset_top = 8.0
	top_hbox.offset_right = -208.0
	top_hbox.offset_bottom = 90.0
	top_hbox.add_theme_constant_override("separation", 10)
	top_hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(top_hbox)

	# --- Kiri Atas: Karakter Aktif & HP Bahula ---
	_char_panel = PanelContainer.new()
	_char_panel.custom_minimum_size = Vector2(360, 0)
	top_hbox.add_child(_char_panel)

	var char_vbox: VBoxContainer = VBoxContainer.new()
	char_vbox.add_theme_constant_override("separation", 2)
	_char_panel.add_child(char_vbox)

	var char_top: HBoxContainer = HBoxContainer.new()
	char_vbox.add_child(char_top)

	_char_name_label = Label.new()
	_char_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_char_name_label.add_theme_font_size_override("font_size", 14)
	_char_name_label.add_theme_color_override("font_color", Color(1.0, 0.96, 0.85))
	char_top.add_child(_char_name_label)

	var switch_btn: Button = Button.new()
	switch_btn.text = "[Tab] Ganti"
	switch_btn.focus_mode = Control.FOCUS_NONE
	switch_btn.add_theme_font_size_override("font_size", 11)
	switch_btn.add_theme_stylebox_override("normal", _make_box(Color(0.28, 0.19, 0.11), Color(0.88, 0.72, 0.22), 1, 5))
	switch_btn.pressed.connect(func() -> void: switch_button_pressed.emit())
	char_top.add_child(switch_btn)

	_char_controls_label = Label.new()
	_char_controls_label.add_theme_font_size_override("font_size", 11)
	_char_controls_label.add_theme_color_override("font_color", Color(0.92, 0.9, 0.8))
	char_vbox.add_child(_char_controls_label)

	var hp_hbox: HBoxContainer = HBoxContainer.new()
	hp_hbox.add_theme_constant_override("separation", 6)
	char_vbox.add_child(hp_hbox)

	_bahula_hp_label = Label.new()
	_bahula_hp_label.text = "HP Bahula: 100/100"
	_bahula_hp_label.add_theme_font_size_override("font_size", 11)
	_bahula_hp_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.82))
	hp_hbox.add_child(_bahula_hp_label)

	_bahula_hp_bar = ProgressBar.new()
	_bahula_hp_bar.custom_minimum_size = Vector2(105, 13)
	_bahula_hp_bar.max_value = 100.0
	_bahula_hp_bar.value = 100.0
	_bahula_hp_bar.show_percentage = false
	_bahula_hp_bar.add_theme_stylebox_override("background", _make_box(Color(0.18, 0.08, 0.08), Color(0.45, 0.2, 0.2), 1, 4))
	_bahula_hp_bar.add_theme_stylebox_override("fill", _make_box(Color(0.82, 0.24, 0.2), Color(1.0, 0.55, 0.4), 0, 4))
	hp_hbox.add_child(_bahula_hp_bar)

	_dash_status_label = Label.new()
	_dash_status_label.text = "Dash: Siap"
	_dash_status_label.add_theme_font_size_override("font_size", 11)
	_dash_status_label.add_theme_color_override("font_color", Color(0.98, 0.88, 0.45))
	hp_hbox.add_child(_dash_status_label)

	# --- Tengah Atas: Wabah Meter & Pasien ---
	var center_panel: PanelContainer = PanelContainer.new()
	center_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_panel.add_theme_stylebox_override("panel", _make_box(Color(0.17, 0.11, 0.08, 0.92), Color(0.83, 0.63, 0.09), 2, 8))
	top_hbox.add_child(center_panel)

	var center_vbox: VBoxContainer = VBoxContainer.new()
	center_vbox.add_theme_constant_override("separation", 4)
	center_panel.add_child(center_vbox)

	var plague_top: HBoxContainer = HBoxContainer.new()
	center_vbox.add_child(plague_top)

	_plague_label = Label.new()
	_plague_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_plague_label.add_theme_font_size_override("font_size", 13)
	_plague_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.72))
	plague_top.add_child(_plague_label)

	_patient_counter_label = Label.new()
	_patient_counter_label.add_theme_font_size_override("font_size", 13)
	_patient_counter_label.add_theme_color_override("font_color", Color(0.68, 0.96, 0.72))
	plague_top.add_child(_patient_counter_label)

	_plague_bar = ProgressBar.new()
	_plague_bar.custom_minimum_size = Vector2(0, 20)
	_plague_bar.max_value = 100.0
	_plague_bar.value = 10.0
	_plague_bar.show_percentage = false
	_plague_bar.add_theme_stylebox_override("background", _make_box(Color(0.12, 0.07, 0.14), Color(0.45, 0.3, 0.5), 1, 5))
	_plague_bar_fill_style = _make_box(Color(0.24, 0.65, 0.36), Color(0.6, 0.95, 0.68), 0, 5)
	_plague_bar.add_theme_stylebox_override("fill", _plague_bar_fill_style)
	center_vbox.add_child(_plague_bar)

	# --- Kanan Tengah-Atas: Skor & Pintasan ---
	var right_panel: PanelContainer = PanelContainer.new()
	right_panel.custom_minimum_size = Vector2(248, 0)
	right_panel.add_theme_stylebox_override("panel", _make_box(Color(0.17, 0.11, 0.08, 0.92), Color(0.83, 0.63, 0.09), 2, 8))
	top_hbox.add_child(right_panel)

	var right_vbox: VBoxContainer = VBoxContainer.new()
	right_vbox.add_theme_constant_override("separation", 4)
	right_panel.add_child(right_vbox)

	var score_row: HBoxContainer = HBoxContainer.new()
	right_vbox.add_child(score_row)

	_score_label = Label.new()
	_score_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_score_label.text = "SKOR: 0"
	_score_label.add_theme_font_size_override("font_size", 15)
	_score_label.add_theme_color_override("font_color", Color(0.98, 0.85, 0.35))
	score_row.add_child(_score_label)

	_streak_label = Label.new()
	_streak_label.text = "Streak: 0x"
	_streak_label.add_theme_font_size_override("font_size", 11)
	_streak_label.add_theme_color_override("font_color", Color(0.75, 0.95, 0.78))
	score_row.add_child(_streak_label)

	var util_row: HBoxContainer = HBoxContainer.new()
	util_row.add_theme_constant_override("separation", 5)
	right_vbox.add_child(util_row)

	var top_lontar_btn: Button = Button.new()
	top_lontar_btn.text = "[L] Lontar"
	top_lontar_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_lontar_btn.focus_mode = Control.FOCUS_NONE
	top_lontar_btn.add_theme_font_size_override("font_size", 11)
	top_lontar_btn.add_theme_stylebox_override("normal", _make_box(Color(0.24, 0.45, 0.27), Color(0.85, 0.7, 0.2), 1, 5))
	top_lontar_btn.pressed.connect(func() -> void: lontar_button_pressed.emit())
	util_row.add_child(top_lontar_btn)

	var top_cauldron_btn: Button = Button.new()
	top_cauldron_btn.text = "[R] Kuali"
	top_cauldron_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_cauldron_btn.focus_mode = Control.FOCUS_NONE
	top_cauldron_btn.add_theme_font_size_override("font_size", 11)
	top_cauldron_btn.add_theme_stylebox_override("normal", _make_box(Color(0.22, 0.38, 0.45), Color(0.7, 0.88, 0.95), 1, 5))
	top_cauldron_btn.pressed.connect(func() -> void: cauldron_button_pressed.emit())
	util_row.add_child(top_cauldron_btn)

	var pause_btn: Button = Button.new()
	pause_btn.text = "[Esc]"
	pause_btn.focus_mode = Control.FOCUS_NONE
	pause_btn.add_theme_font_size_override("font_size", 11)
	pause_btn.add_theme_stylebox_override("normal", _make_box(Color(0.32, 0.2, 0.14), Color(0.68, 0.48, 0.28), 1, 5))
	pause_btn.pressed.connect(func() -> void: pause_button_pressed.emit())
	util_row.add_child(pause_btn)

	# ===================== POJOK KANAN ATAS: MINIMAP RINGKAS =====================
	var mini_panel: PanelContainer = PanelContainer.new()
	mini_panel.anchor_left = 1.0
	mini_panel.anchor_right = 1.0
	mini_panel.offset_left = -198.0
	mini_panel.offset_top = 8.0
	mini_panel.offset_right = -10.0
	mini_panel.offset_bottom = 172.0
	mini_panel.add_theme_stylebox_override("panel", _make_box(Color(0.15, 0.1, 0.07, 0.94), Color(0.83, 0.63, 0.09), 2, 8))
	root.add_child(mini_panel)

	var mini_vbox: VBoxContainer = VBoxContainer.new()
	mini_vbox.add_theme_constant_override("separation", 3)
	mini_panel.add_child(mini_vbox)

	var mini_title: Label = Label.new()
	mini_title.text = "PETA DESA GIRAH (U↑)"
	mini_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mini_title.add_theme_font_size_override("font_size", 11)
	mini_title.add_theme_color_override("font_color", Color(0.98, 0.88, 0.52))
	mini_vbox.add_child(mini_title)

	_minimap_control = MinimapControlScript.new()
	_minimap_control.custom_minimum_size = Vector2(170, 118)
	_minimap_control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_minimap_control.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mini_vbox.add_child(_minimap_control)

	var mini_legend: Label = Label.new()
	mini_legend.text = "H:Tabib  M:Bahula  K:Warga  ◆:Gate"
	mini_legend.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mini_legend.add_theme_font_size_override("font_size", 9)
	mini_legend.add_theme_color_override("font_color", Color(0.88, 0.84, 0.72))
	mini_vbox.add_child(mini_legend)

	# ===================== PANEL CATATAN DIAGNOSA (DI BAWAH MINIMAP) =====================
	var diag_panel: PanelContainer = PanelContainer.new()
	diag_panel.anchor_left = 1.0
	diag_panel.anchor_right = 1.0
	diag_panel.offset_left = -266.0
	diag_panel.offset_top = 180.0
	diag_panel.offset_right = -10.0
	diag_panel.offset_bottom = 410.0
	diag_panel.add_theme_stylebox_override("panel", _make_box(Color(0.16, 0.1, 0.07, 0.86), Color(0.68, 0.5, 0.22), 2, 8))
	root.add_child(diag_panel)

	var diag_root: VBoxContainer = VBoxContainer.new()
	diag_root.add_theme_constant_override("separation", 4)
	diag_panel.add_child(diag_root)

	var diag_hdr: Label = Label.new()
	diag_hdr.text = "CATATAN DIAGNOSA WARGA"
	diag_hdr.add_theme_font_size_override("font_size", 11)
	diag_hdr.add_theme_color_override("font_color", Color(0.96, 0.84, 0.48))
	diag_root.add_child(diag_hdr)

	var diag_scroll: ScrollContainer = ScrollContainer.new()
	diag_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	diag_root.add_child(diag_scroll)

	_diag_list_vbox = VBoxContainer.new()
	_diag_list_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_diag_list_vbox.add_theme_constant_override("separation", 5)
	diag_scroll.add_child(_diag_list_vbox)

	# ===================== PROMPT INTERAKSI =====================
	_prompt_panel = PanelContainer.new()
	_prompt_panel.anchor_left = 0.5
	_prompt_panel.anchor_right = 0.5
	_prompt_panel.anchor_top = 1.0
	_prompt_panel.anchor_bottom = 1.0
	_prompt_panel.offset_left = -290.0
	_prompt_panel.offset_right = 290.0
	_prompt_panel.offset_top = -152.0
	_prompt_panel.offset_bottom = -114.0
	_prompt_panel.visible = false
	_prompt_panel.add_theme_stylebox_override("panel", _make_box(Color(0.14, 0.09, 0.05, 0.92), Color(0.92, 0.74, 0.22), 2, 8))
	root.add_child(_prompt_panel)

	_prompt_label = Label.new()
	_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_prompt_label.add_theme_font_size_override("font_size", 13)
	_prompt_label.add_theme_color_override("font_color", Color(1.0, 0.96, 0.82))
	_prompt_panel.add_child(_prompt_label)

	# ===================== POPUP UMPAN BALIK INSTAN =====================
	_feedback_panel = PanelContainer.new()
	_feedback_panel.anchor_left = 0.5
	_feedback_panel.anchor_right = 0.5
	_feedback_panel.anchor_top = 1.0
	_feedback_panel.anchor_bottom = 1.0
	_feedback_panel.offset_left = -395.0
	_feedback_panel.offset_right = 395.0
	_feedback_panel.offset_top = -246.0
	_feedback_panel.offset_bottom = -158.0
	_feedback_panel.visible = false
	root.add_child(_feedback_panel)

	var fb_hbox: HBoxContainer = HBoxContainer.new()
	fb_hbox.add_theme_constant_override("separation", 8)
	_feedback_panel.add_child(fb_hbox)

	var fb_vbox: VBoxContainer = VBoxContainer.new()
	fb_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fb_vbox.add_theme_constant_override("separation", 2)
	fb_hbox.add_child(fb_vbox)

	_feedback_title_label = Label.new()
	_feedback_title_label.add_theme_font_size_override("font_size", 14)
	fb_vbox.add_child(_feedback_title_label)

	_feedback_msg_label = Label.new()
	_feedback_msg_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_feedback_msg_label.add_theme_font_size_override("font_size", 12)
	fb_vbox.add_child(_feedback_msg_label)

	var fb_close: Button = Button.new()
	fb_close.text = "x"
	fb_close.custom_minimum_size = Vector2(28, 28)
	fb_close.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	fb_close.focus_mode = Control.FOCUS_NONE
	fb_close.pressed.connect(func() -> void: _feedback_panel.visible = false)
	fb_hbox.add_child(fb_close)

	# ===================== PANEL BAWAH: INVENTORY (LONTAR + KUALI PORTABEL + HERBAL + RAMUAN) =====================
	var bottom_panel: PanelContainer = PanelContainer.new()
	bottom_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_panel.offset_left = 12.0
	bottom_panel.offset_right = -12.0
	bottom_panel.offset_top = -106.0
	bottom_panel.offset_bottom = -10.0
	bottom_panel.add_theme_stylebox_override("panel", _make_box(Color(0.16, 0.1, 0.06, 0.94), Color(0.83, 0.63, 0.09), 2, 8))
	root.add_child(bottom_panel)

	var bot_hbox: HBoxContainer = HBoxContainer.new()
	bot_hbox.add_theme_constant_override("separation", 8)
	bottom_panel.add_child(bot_hbox)

	# Item Permanen 1: Buku Lontar Usada (L)
	var lontar_item_btn: Button = Button.new()
	lontar_item_btn.custom_minimum_size = Vector2(152, 0)
	lontar_item_btn.focus_mode = Control.FOCUS_NONE
	lontar_item_btn.text = "BUKU LONTAR\nUSADA (L)\n40 Herbal & Resep"
	lontar_item_btn.add_theme_font_size_override("font_size", 11)
	lontar_item_btn.add_theme_stylebox_override("normal", _make_box(Color(0.36, 0.24, 0.11), Color(0.95, 0.78, 0.22), 2, 7))
	lontar_item_btn.add_theme_color_override("font_color", Color(1.0, 0.94, 0.72))
	lontar_item_btn.pressed.connect(func() -> void: lontar_button_pressed.emit())
	bot_hbox.add_child(lontar_item_btn)

	# Item Permanen 2: Kuali Portabel Tabib Wira (R)
	var cauldron_item_btn: Button = Button.new()
	cauldron_item_btn.custom_minimum_size = Vector2(152, 0)
	cauldron_item_btn.focus_mode = Control.FOCUS_NONE
	cauldron_item_btn.text = "KUALI RACIK (R)\n[Portabel • Kapan Saja]\nRacik 2–3 Herbal"
	cauldron_item_btn.add_theme_font_size_override("font_size", 11)
	cauldron_item_btn.add_theme_stylebox_override("normal", _make_box(Color(0.16, 0.36, 0.32), Color(0.45, 0.9, 0.72), 2, 7))
	cauldron_item_btn.add_theme_color_override("font_color", Color(0.88, 1.0, 0.95))
	cauldron_item_btn.pressed.connect(func() -> void: cauldron_button_pressed.emit())
	bot_hbox.add_child(cauldron_item_btn)

	# Kantong Herbal Bersama
	var herbs_vbox: VBoxContainer = VBoxContainer.new()
	herbs_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	herbs_vbox.add_theme_constant_override("separation", 3)
	bot_hbox.add_child(herbs_vbox)

	var herbs_hdr: Label = Label.new()
	herbs_hdr.text = "KANTONG HERBAL BERSAMA (Starter Pack + Panen Ekosistem):"
	herbs_hdr.add_theme_font_size_override("font_size", 11)
	herbs_hdr.add_theme_color_override("font_color", Color(0.92, 0.85, 0.65))
	herbs_vbox.add_child(herbs_hdr)

	var herbs_scroll: ScrollContainer = ScrollContainer.new()
	herbs_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	herbs_vbox.add_child(herbs_scroll)

	_herbs_flow = HFlowContainer.new()
	_herbs_flow.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_herbs_flow.add_theme_constant_override("h_separation", 6)
	_herbs_flow.add_theme_constant_override("v_separation", 4)
	herbs_scroll.add_child(_herbs_flow)

	# Slot Ramuan Siap Pakai (Maks 3)
	var pot_vbox: VBoxContainer = VBoxContainer.new()
	pot_vbox.custom_minimum_size = Vector2(288, 0)
	pot_vbox.add_theme_constant_override("separation", 3)
	bot_hbox.add_child(pot_vbox)

	var pot_hdr: Label = Label.new()
	pot_hdr.text = "RAMUAN SIAP PAKAI (Maks 3 • Beri [E]):"
	pot_hdr.add_theme_font_size_override("font_size", 11)
	pot_hdr.add_theme_color_override("font_color", Color(0.76, 0.96, 0.8))
	pot_vbox.add_child(pot_hdr)

	_potions_hbox = HBoxContainer.new()
	_potions_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_potions_hbox.add_theme_constant_override("separation", 5)
	pot_vbox.add_child(_potions_hbox)

	# ===================== OVERLAY JEDA (PAUSE) & MENANG / KALAH =====================
	_build_pause_overlay(root)
	_build_end_overlay(root)


func _build_pause_overlay(parent: Control) -> void:
	_pause_overlay = ColorRect.new()
	_pause_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pause_overlay.color = Color(0.05, 0.03, 0.02, 0.72)
	_pause_overlay.visible = false
	parent.add_child(_pause_overlay)

	var box: PanelContainer = PanelContainer.new()
	box.anchor_left = 0.5
	box.anchor_right = 0.5
	box.anchor_top = 0.5
	box.anchor_bottom = 0.5
	box.offset_left = -210.0
	box.offset_right = 210.0
	box.offset_top = -155.0
	box.offset_bottom = 155.0
	box.add_theme_stylebox_override("panel", _make_box(Color(0.2, 0.13, 0.08, 0.98), Color(0.83, 0.63, 0.09), 3, 12))
	_pause_overlay.add_child(box)

	var v: VBoxContainer = VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	box.add_child(v)

	var lbl: Label = Label.new()
	lbl.text = "PERMAINAN DIJEDA"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 22)
	lbl.add_theme_color_override("font_color", Color(0.98, 0.88, 0.52))
	v.add_child(lbl)

	var sub: Label = Label.new()
	sub.text = "Wabah Meter dihentikan sementara."
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 13)
	sub.add_theme_color_override("font_color", Color(0.86, 0.82, 0.72))
	v.add_child(sub)

	var btn_resume: Button = Button.new()
	btn_resume.text = "Lanjutkan Permainan (Esc)"
	btn_resume.custom_minimum_size = Vector2(0, 44)
	btn_resume.focus_mode = Control.FOCUS_NONE
	btn_resume.add_theme_stylebox_override("normal", _make_box(Color(0.2, 0.5, 0.26), Color(0.85, 0.75, 0.25), 2, 6))
	btn_resume.pressed.connect(func() -> void: pause_button_pressed.emit())
	v.add_child(btn_resume)

	var btn_lontar: Button = Button.new()
	btn_lontar.text = "Buka Buku Lontar Usada (L)"
	btn_lontar.custom_minimum_size = Vector2(0, 42)
	btn_lontar.focus_mode = Control.FOCUS_NONE
	btn_lontar.add_theme_stylebox_override("normal", _make_box(Color(0.35, 0.24, 0.12), Color(0.83, 0.63, 0.09), 2, 6))
	btn_lontar.pressed.connect(func() -> void: lontar_button_pressed.emit())
	v.add_child(btn_lontar)

	var btn_retry: Button = Button.new()
	btn_retry.text = "Ulangi Stage 1 dari Awal"
	btn_retry.custom_minimum_size = Vector2(0, 42)
	btn_retry.focus_mode = Control.FOCUS_NONE
	btn_retry.add_theme_stylebox_override("normal", _make_box(Color(0.5, 0.2, 0.16), Color(0.88, 0.55, 0.42), 2, 6))
	btn_retry.pressed.connect(func() -> void: retry_stage_requested.emit())
	v.add_child(btn_retry)


func _build_end_overlay(parent: Control) -> void:
	_end_overlay = ColorRect.new()
	_end_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_end_overlay.color = Color(0.05, 0.03, 0.03, 0.8)
	_end_overlay.visible = false
	parent.add_child(_end_overlay)

	var box: PanelContainer = PanelContainer.new()
	box.anchor_left = 0.5
	box.anchor_right = 0.5
	box.anchor_top = 0.5
	box.anchor_bottom = 0.5
	box.offset_left = -295.0
	box.offset_right = 295.0
	box.offset_top = -225.0
	box.offset_bottom = 225.0
	box.add_theme_stylebox_override("panel", _make_box(Color(0.2, 0.13, 0.08, 0.98), Color(0.88, 0.68, 0.14), 3, 12))
	_end_overlay.add_child(box)

	var v: VBoxContainer = VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	box.add_child(v)

	_end_title_label = Label.new()
	_end_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_end_title_label.add_theme_font_size_override("font_size", 22)
	_end_title_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.45))
	v.add_child(_end_title_label)

	_end_stars_label = Label.new()
	_end_stars_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_end_stars_label.add_theme_font_size_override("font_size", 20)
	_end_stars_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.2))
	v.add_child(_end_stars_label)

	_end_body_label = Label.new()
	_end_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_end_body_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_end_body_label.add_theme_font_size_override("font_size", 14)
	_end_body_label.add_theme_color_override("font_color", Color(0.95, 0.92, 0.84))
	v.add_child(_end_body_label)

	var btn_retry: Button = Button.new()
	btn_retry.text = "Main Lagi Stage 1 (Desa Girah)"
	btn_retry.custom_minimum_size = Vector2(0, 48)
	btn_retry.focus_mode = Control.FOCUS_NONE
	btn_retry.add_theme_font_size_override("font_size", 16)
	btn_retry.add_theme_stylebox_override("normal", _make_box(Color(0.2, 0.54, 0.28), Color(0.95, 0.8, 0.25), 2, 8))
	btn_retry.pressed.connect(func() -> void: retry_stage_requested.emit())
	v.add_child(btn_retry)


## --- Signal Handlers ---

func _on_character_changed(character_id: int) -> void:
	if character_id == GameManager.ActiveCharacter.TABIB:
		_char_panel.add_theme_stylebox_override("panel", _make_box(Color(0.14, 0.29, 0.17, 0.94), Color(0.42, 0.82, 0.48), 2, 8))
		_char_name_label.text = "TABIB WIRA (Mode Penyembuh)"
		_char_controls_label.text = "WASD: Gerak | E: Diagnosa/Panen | R: Kuali Racik | L: Lontar"
	else:
		_char_panel.add_theme_stylebox_override("panel", _make_box(Color(0.36, 0.13, 0.11, 0.94), Color(0.92, 0.45, 0.28), 2, 8))
		_char_name_label.text = "MPU BAHULA (Mode Lini Serang)"
		_char_controls_label.text = "WASD: Gerak | Spasi: Tebas | Shift: Dash | E: Panen Kabut"


func _on_plague_updated(value: float, is_paused: bool) -> void:
	if _plague_bar == null or _plague_label == null:
		return
	_plague_bar.value = value
	var status_tag: String = ""
	if GameManager.north_gate_unlocked:
		status_tag = "  [REDA • KE GERBANG UTARA]"
	elif is_paused:
		status_tag = "  [DIJEDA]"
	_plague_label.text = "WABAH METER: %.0f%%%s" % [value, status_tag]

	if value >= 75.0:
		_plague_bar_fill_style.bg_color = Color(0.84, 0.2, 0.2)
	elif value >= 45.0:
		_plague_bar_fill_style.bg_color = Color(0.88, 0.56, 0.16)
	else:
		_plague_bar_fill_style.bg_color = Color(0.24, 0.66, 0.36)


func _on_score_updated(total_score: int, _delta: int, streak: int, _reason: String) -> void:
	if _score_label != null:
		_score_label.text = "SKOR: %d" % total_score
	if _streak_label != null:
		_streak_label.text = "Streak: %dx" % streak


func _on_bahula_hp_changed(current_hp: int, max_hp: int) -> void:
	if _bahula_hp_bar != null:
		_bahula_hp_bar.max_value = float(max_hp)
		_bahula_hp_bar.value = float(current_hp)
	if _bahula_hp_label != null:
		_bahula_hp_label.text = "HP Bahula: %d/%d" % [current_hp, max_hp]


func _on_dash_cd_updated(remaining: float, _duration: float) -> void:
	if _dash_status_label == null:
		return
	if remaining <= 0.02:
		_dash_status_label.text = "Dash: Siap"
		_dash_status_label.add_theme_color_override("font_color", Color(0.98, 0.88, 0.45))
	else:
		_dash_status_label.text = "Dash: %.1fs" % remaining
		_dash_status_label.add_theme_color_override("font_color", Color(0.8, 0.72, 0.65))


func _on_retreat_cd_updated(remaining: float) -> void:
	if _dash_status_label == null:
		return
	if remaining > 0.0:
		_dash_status_label.text = "Pulih: %.0fs" % ceilf(remaining)
		_dash_status_label.add_theme_color_override("font_color", Color(1.0, 0.48, 0.45))
	else:
		_dash_status_label.text = "Dash: Siap"
		_dash_status_label.add_theme_color_override("font_color", Color(0.98, 0.88, 0.45))


func _on_patient_diagnosed(_patient_data: Dictionary) -> void:
	_refresh_diagnosis_panel()


func _on_patient_cured(_patient_id: String, cured_count: int, total_count: int) -> void:
	if _patient_counter_label != null:
		if GameManager.north_gate_unlocked:
			_patient_counter_label.text = "Warga: %d/%d ✓ → GERBANG UTARA!" % [cured_count, total_count]
			_patient_counter_label.add_theme_color_override("font_color", Color(0.45, 1.0, 0.62))
		else:
			_patient_counter_label.text = "Warga Sembuh: %d / %d" % [cured_count, total_count]
			_patient_counter_label.add_theme_color_override("font_color", Color(0.68, 0.96, 0.72))
	_refresh_diagnosis_panel()


func _on_all_patients_cured() -> void:
	_on_patient_cured("", GameManager.cured_patients, GameManager.total_patients)


func _on_prompt_changed(prompt_text: String) -> void:
	if _prompt_panel == null or _prompt_label == null:
		return
	if prompt_text.is_empty():
		_prompt_panel.visible = false
	else:
		_prompt_label.text = prompt_text
		_prompt_panel.visible = true


func _on_feedback_requested(status: String, title: String, message: String) -> void:
	if _feedback_panel == null:
		return
	var bg: Color = Color(0.2, 0.14, 0.09, 0.96)
	var border: Color = Color(0.85, 0.68, 0.22)
	var title_col: Color = Color(1.0, 0.92, 0.56)

	match status:
		"PERFECT":
			bg = Color(0.14, 0.34, 0.18, 0.96)
			border = Color(0.96, 0.82, 0.2)
			title_col = Color(1.0, 0.94, 0.45)
		"GOOD":
			bg = Color(0.14, 0.3, 0.22, 0.96)
			border = Color(0.4, 0.86, 0.52)
			title_col = Color(0.75, 1.0, 0.78)
		"PARTIAL":
			bg = Color(0.36, 0.26, 0.08, 0.96)
			border = Color(0.96, 0.72, 0.2)
			title_col = Color(1.0, 0.88, 0.45)
		"FAIL":
			bg = Color(0.36, 0.14, 0.14, 0.96)
			border = Color(0.9, 0.38, 0.34)
			title_col = Color(1.0, 0.72, 0.68)
		"TOXIC":
			bg = Color(0.32, 0.09, 0.36, 0.96)
			border = Color(0.98, 0.32, 0.55)
			title_col = Color(1.0, 0.68, 0.85)

	_feedback_panel.add_theme_stylebox_override("panel", _make_box(bg, border, 2, 8))
	_feedback_title_label.text = title
	_feedback_title_label.add_theme_color_override("font_color", title_col)
	_feedback_msg_label.text = message
	_feedback_msg_label.add_theme_color_override("font_color", Color(0.98, 0.96, 0.92))
	_feedback_panel.visible = true
	_feedback_timer = 7.5


func _refresh_inventory() -> void:
	if _herbs_flow == null:
		return
	for child in _herbs_flow.get_children():
		child.queue_free()

	var avail: Dictionary = GameManager.get_available_herbs()
	if avail.is_empty():
		var lbl: Label = Label.new()
		lbl.text = "(Stok herbal habis — petik di kebun desa, tepi sungai, atau hutan kabut!)"
		lbl.add_theme_font_size_override("font_size", 11)
		lbl.add_theme_color_override("font_color", Color(0.95, 0.7, 0.55))
		_herbs_flow.add_child(lbl)
		return

	var sorted_ids: Array = avail.keys()
	sorted_ids.sort()
	for raw_id in sorted_ids:
		var hid: String = String(raw_id)
		var count: int = int(avail[hid])
		var herb: Dictionary = AlchemyDatabase.get_herb(hid)
		var tags: Array = herb.get("effect_tags", [])
		var is_toxic: bool = tags.has("toksik")

		var chip: PanelContainer = PanelContainer.new()
		var bg: Color = Color(0.36, 0.12, 0.4) if is_toxic else Color(0.24, 0.17, 0.1)
		var border: Color = Color(0.86, 0.38, 0.95) if is_toxic else AlchemyDatabase.get_herb_color(hid)
		chip.add_theme_stylebox_override("panel", _make_box(bg, border, 2, 5))
		var clbl: Label = Label.new()
		clbl.text = "%s x%d%s" % [AlchemyDatabase.get_herb_name(hid), count, " [!]" if is_toxic else ""]
		clbl.add_theme_font_size_override("font_size", 11)
		clbl.add_theme_color_override("font_color", Color(1.0, 0.85, 1.0) if is_toxic else Color(0.98, 0.95, 0.86))
		chip.add_child(clbl)
		_herbs_flow.add_child(chip)


func _refresh_potions() -> void:
	if _potions_hbox == null:
		return
	for child in _potions_hbox.get_children():
		child.queue_free()

	if GameManager.ready_potions.is_empty():
		var empty_lbl: Label = Label.new()
		empty_lbl.text = "(Kosong — Tekan [R] buka Kuali Racik)"
		empty_lbl.add_theme_font_size_override("font_size", 11)
		empty_lbl.add_theme_color_override("font_color", Color(0.76, 0.72, 0.65))
		_potions_hbox.add_child(empty_lbl)
		return

	for i in range(GameManager.ready_potions.size()):
		var p: Dictionary = GameManager.ready_potions[i]
		var is_sel: bool = (i == GameManager.selected_potion_index)

		var btn: Button = Button.new()
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.focus_mode = Control.FOCUS_NONE
		btn.clip_text = true
		btn.text = "%s#%d %s" % ["▶ " if is_sel else "", i + 1, String(p.get("label", "Ramuan"))]
		btn.tooltip_text = "Ramuan #%d: %s\nTag: %s\nKlik untuk jadikan ramuan aktif." % [
			i + 1,
			String(p.get("label", "")),
			AlchemyDatabase.format_tag_list(p.get("tags", []))
		]
		btn.add_theme_font_size_override("font_size", 11)
		btn.add_theme_stylebox_override("normal", _make_box(Color(0.2, 0.5, 0.28) if is_sel else Color(0.22, 0.16, 0.12), Color(0.95, 0.82, 0.25) if is_sel else Color(0.5, 0.4, 0.3), 2 if is_sel else 1, 5))
		btn.pressed.connect(GameManager.select_potion.bind(i))
		_potions_hbox.add_child(btn)


func _refresh_diagnosis_panel() -> void:
	if _diag_list_vbox == null:
		return
	for child in _diag_list_vbox.get_children():
		child.queue_free()

	if GameManager.diagnosed_patients.is_empty():
		var hint: Label = Label.new()
		hint.text = "Ikuti panah kuning & titik berkedip di Minimap untuk mendiagnosa warga sakit [E].\nTekan [R] kapan saja untuk meracik di Kuali Portabel!"
		hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		hint.add_theme_font_size_override("font_size", 11)
		hint.add_theme_color_override("font_color", Color(0.84, 0.78, 0.68))
		_diag_list_vbox.add_child(hint)
		return

	for pid in GameManager.diagnosed_patients.keys():
		var entry: Dictionary = GameManager.diagnosed_patients[pid]
		var is_cured: bool = bool(entry.get("cured", false))
		var card: PanelContainer = PanelContainer.new()
		card.add_theme_stylebox_override("panel", _make_box(Color(0.14, 0.3, 0.18) if is_cured else Color(0.26, 0.16, 0.1), Color(0.42, 0.84, 0.48) if is_cured else Color(0.82, 0.52, 0.24), 1, 5))
		_diag_list_vbox.add_child(card)

		var lbl: Label = Label.new()
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl.add_theme_font_size_override("font_size", 11)
		if is_cured:
			lbl.text = "[✓] %s — SEMBUH!" % String(entry["name"])
			lbl.add_theme_color_override("font_color", Color(0.75, 1.0, 0.78))
		else:
			var syms: Array = entry.get("symptoms", [])
			var req_tags: Array[String] = AlchemyDatabase.get_required_tags_for_symptoms(syms)
			var snames: PackedStringArray = PackedStringArray()
			for s in syms:
				snames.append(AlchemyDatabase.get_symptom_name(String(s)))
			lbl.text = "%s:\n• %s\nButuh: %s" % [
				String(entry["name"]),
				", ".join(snames),
				AlchemyDatabase.format_tag_list(req_tags)
			]
			lbl.add_theme_color_override("font_color", Color(0.98, 0.92, 0.8))
		card.add_child(lbl)


func _on_stage_won(summary: Dictionary) -> void:
	_end_overlay.visible = true
	_end_title_label.text = "STAGE 1 SELESAI — GERBANG STAGE 2 TERBUKA!"
	_end_stars_label.text = String(summary.get("rank_title", "LULUS (★☆☆)"))
	_end_body_label.text = (
		"Seluruh warga (%d / %d) sembuh & perjalanan menuju Stage 2 (Hutan Bambu & Sendang Girah) siap dimulai!\n\n"
		+ "• Poin Penyembuhan Warga : +%d\n"
		+ "• Bonus Akurasi Usada    : +%d\n"
		+ "• Bonus Streak Akurasi   : +%d\n"
		+ "• Bonus Penemuan Herbal  : +%d\n"
		+ "• Bonus Efisiensi Wabah  : +%d (Wabah akhir %.0f%%)\n"
		+ "• Penalti Gagal/Toksik   : -%d (%d kali)\n"
		+ "-----------------------------------------\n"
		+ "TOTAL SKOR STAGE 1       : %d Poin\n\n"
		+ "Fakta Sejarah: Desa Girah pada masa Kerajaan Kahuripan (abad ke-11, Prabu Airlangga) kini dikenal sebagai wilayah Kecamatan Gurah, Kabupaten Kediri, Jawa Timur."
	) % [
		int(summary.get("cured_patients", 0)),
		int(summary.get("total_patients", 0)),
		int(summary.get("cure_points", 0)),
		int(summary.get("accuracy_bonus_points", 0)),
		int(summary.get("streak_bonus_points", 0)),
		int(summary.get("discovery_points", 0)),
		int(summary.get("plague_efficiency_points", 0)),
		float(summary.get("plague_meter", 0.0)),
		int(summary.get("penalty_points", 0)),
		int(summary.get("wrong_brew_count", 0)),
		int(summary.get("total_score", 0)),
	]


func _on_stage_lost(summary: Dictionary) -> void:
	_end_overlay.visible = true
	_end_title_label.text = "KABUT TELUH MELUAS (WABAH 100%)"
	_end_stars_label.text = "Desa Girah Terpaksa Ditinggalkan Sementara"
	_end_body_label.text = (
		"Warga yang berhasil disembuhkan: %d / %d\n"
		+ "Skor sementara: %d poin (Gagal racik: %d kali, Gagal toksik: %d kali)\n\n"
		+ "Tips Usada:\n"
		+ "• Tekan [L] membuka Buku Lontar Usada (Wabah Meter DIJEDA!) untuk melihat 40 herbal & resep valid tiap gejala.\n"
		+ "• Tekan [R] kapan saja membuka Kuali Portabel tanpa perlu kembali ke posko.\n"
		+ "• Selalu netralkan Kecubung Gunung dengan herbal [Penawar Racun / detoks] seperti Temulawak atau Sambiloto!"
	) % [
		int(summary.get("cured_patients", 0)),
		int(summary.get("total_patients", 0)),
		int(summary.get("total_score", 0)),
		int(summary.get("wrong_brew_count", 0)),
		int(summary.get("toxic_fail_count", 0)),
	]


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
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 5
	sb.content_margin_bottom = 5
	return sb
