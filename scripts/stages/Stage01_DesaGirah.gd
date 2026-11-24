extends Node2D
## Stage01_DesaGirah — Peta Luas Stage 1 (3200x4220): Desa Pinggiran Girah (Zona Aman) + Hutan Girah 4x Luas.
## 4 Landmark Hutan terhubung jalan setapak:
##   (a) Tepi Sungai & Jembatan Kayu, (b) Rumpun Bambu Lebat, (c) Reruntuhan Batu Tua, (d) Sarang Babi Hutan.
## Musuh Stage 1: Hewan buas (Babi Hutan Liar & Ular Berbisa). Wabah Meter diperlambat 35% (+0.1625%/dtk).

const MAP_WIDTH: int = 3200
const MAP_HEIGHT: int = 4220
const FOREST_BARRIER_Y: float = 2700.0
const STAGE1_PLAGUE_RATE: float = 0.1625 # 0.25 * 0.65 (diperlambat 35% untuk eksplorasi hutan 4x luas)

@onready var player_tabib: CharacterBody2D = $Entities/PlayerTabib
@onready var player_bahula: CharacterBody2D = $Entities/PlayerBahula
@onready var proxy_camera: Camera2D = $ProxyCamera2D
@onready var quest_pointer: Node2D = $QuestPointer
@onready var patients_container: Node2D = $Patients
@onready var herbs_container: Node2D = $Herbs
@onready var enemies_container: Node2D = $Enemies
@onready var north_gate: Area2D = $NorthGate

@onready var fog_barrier: StaticBody2D = $FogBarrier
@onready var fog_warning_zone: Area2D = $FogBarrier/FogWarningZone

@onready var game_hud: CanvasLayer = $GameHUD
@onready var alchemy_ui: CanvasLayer = $AlchemyTableUI
@onready var lontar_ui: CanvasLayer = $LontarUsadaUI

var _barrier_warn_cooldown: float = 0.0


func _ready() -> void:
	var patient_count: int = patients_container.get_child_count()
	GameManager.reset_for_stage(1, 10.0, STAGE1_PLAGUE_RATE, patient_count)
	GameManager.register_players(player_tabib, player_bahula)

	proxy_camera.set_map_limits(MAP_WIDTH, MAP_HEIGHT)
	proxy_camera.setup_targets(player_tabib, player_bahula)

	if player_bahula.has_method("setup_companion"):
		player_bahula.setup_companion(player_tabib, FOREST_BARRIER_Y)

	if quest_pointer.has_method("setup"):
		quest_pointer.setup(player_tabib, player_bahula, patients_container, north_gate)

	for enemy in enemies_container.get_children():
		if enemy.has_method("set_target_bahula"):
			enemy.set_target_bahula(player_bahula)

	var house_rects: Array = [
		Rect2(440, 3150, 180, 110),
		Rect2(1140, 3140, 180, 110),
		Rect2(1860, 3150, 180, 110),
		Rect2(440, 3780, 180, 110),
		Rect2(1140, 3780, 210, 120),
		Rect2(1860, 3780, 180, 110),
	]
	var road_rects: Array = [
		Rect2(1524, 150, 152, 3910),
		Rect2(360, 980, 2520, 80),
		Rect2(360, 2050, 2520, 80),
		Rect2(740, 1060, 76, 990),
		Rect2(2710, 1060, 76, 990),
		Rect2(2260, 1520, 520, 80),
		Rect2(420, 3020, 2360, 80),
		Rect2(420, 3640, 2360, 80),
		Rect2(640, 3100, 76, 540),
	]
	var bridge_rects: Array = [
		Rect2(2385, 1505, 200, 110),
		Rect2(2385, 2035, 200, 110),
	]
	var landmark_rects: Array = [
		{"rect": Rect2(160, 240, 1120, 960), "color": Color(0.32, 0.36, 0.34, 0.9)},
		{"rect": Rect2(1900, 240, 1140, 960), "color": Color(0.32, 0.22, 0.14, 0.9)},
		{"rect": Rect2(160, 1420, 1120, 1120), "color": Color(0.2, 0.42, 0.2, 0.9)},
		{"rect": Rect2(1900, 1280, 1180, 1380), "color": Color(0.18, 0.4, 0.32, 0.9)},
	]
	game_hud.setup_minimap({
		"map_size": Vector2(MAP_WIDTH, MAP_HEIGHT),
		"fog_barrier_y": FOREST_BARRIER_Y,
		"river_rect": Rect2(2420, 1280, 130, 1400),
		"bridge_rects": bridge_rects,
		"road_rects": road_rects,
		"house_rects": house_rects,
		"landmark_rects": landmark_rects,
		"tabib": player_tabib,
		"bahula": player_bahula,
		"patients": patients_container,
		"herbs": herbs_container,
		"enemies": enemies_container,
		"north_gate": north_gate,
		"camera": proxy_camera,
	})

	fog_warning_zone.body_entered.connect(_on_forest_barrier_warning)
	EventBus.alchemy_table_requested.connect(_on_cauldron_requested)
	EventBus.stage_won.connect(_on_stage_ended)
	EventBus.stage_lost.connect(_on_stage_ended)

	alchemy_ui.open_lontar_requested.connect(func() -> void: lontar_ui.open_lontar(0))
	game_hud.lontar_button_pressed.connect(func() -> void: lontar_ui.toggle_lontar())
	game_hud.cauldron_button_pressed.connect(_on_cauldron_requested)
	game_hud.switch_button_pressed.connect(func() -> void: GameManager.request_switch_character())
	game_hud.pause_button_pressed.connect(_toggle_pause)
	game_hud.retry_stage_requested.connect(_on_retry_stage)

	EventBus.feedback_requested.emit(
		"INFO",
		"STAGE 1: DESA PINGGIRAN & HUTAN GIRAH (WABAH 10%)",
		"Starter Pack (Kunyit x2, Asam Jawa x2) cukup untuk 2 dosis obat Pak Kartono! Untuk pasien lain, tekan [Tab] mengutus Mpu Bahula ke hutan 4x luas (tahan [Shift] Sprint, [E] petik ke Kantong Bahula, lalu pulang setor ke Desa/Tabib)!"
	)


func _process(delta: float) -> void:
	if _barrier_warn_cooldown > 0.0:
		_barrier_warn_cooldown = maxf(0.0, _barrier_warn_cooldown - delta)


func _input(event: InputEvent) -> void:
	if GameManager.stage_ended:
		return

	if event.is_action_pressed("open_lontar"):
		lontar_ui.toggle_lontar()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("open_cauldron"):
		_on_cauldron_requested()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("pause"):
		if lontar_ui.visible:
			lontar_ui.close_lontar()
		elif alchemy_ui.visible:
			alchemy_ui.close_alchemy()
		else:
			_toggle_pause()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("switch_character"):
		if not GameManager.is_gameplay_blocked():
			GameManager.request_switch_character()
		get_viewport().set_input_as_handled()
		return


func _on_cauldron_requested() -> void:
	if GameManager.stage_ended or game_hud.is_pause_overlay_visible():
		return
	if alchemy_ui.visible:
		alchemy_ui.close_alchemy()
		return
	if GameManager.active_character != GameManager.ActiveCharacter.TABIB:
		EventBus.feedback_requested.emit(
			"INFO",
			"KUALI PORTABEL TABIB WIRA",
			"Kuali Portabel dibawa oleh Tabib Wira. Tekan [Tab] untuk kembali ke Tabib lalu tekan [R] untuk meracik!"
		)
		return
	if lontar_ui.visible:
		lontar_ui.close_lontar()
	alchemy_ui.open_alchemy()


func _toggle_pause() -> void:
	if GameManager.stage_ended:
		return
	var next_paused: bool = not game_hud.is_pause_overlay_visible()
	game_hud.set_pause_overlay_visible(next_paused)
	GameManager.set_plague_paused("pause_menu", next_paused)
	GameManager.set_modal_open("pause_menu", next_paused)
	EventBus.pause_toggled.emit(next_paused)


func _on_retry_stage() -> void:
	get_tree().reload_current_scene()


func _on_stage_ended(_summary: Dictionary) -> void:
	if lontar_ui.visible:
		lontar_ui.close_lontar()
	if alchemy_ui.visible:
		alchemy_ui.close_alchemy()
	game_hud.set_pause_overlay_visible(false)


func _on_forest_barrier_warning(body: Node2D) -> void:
	if body == player_tabib and _barrier_warn_cooldown <= 0.0:
		_barrier_warn_cooldown = 3.0
		EventBus.feedback_requested.emit(
			"FAIL",
			"TEPI KORIDOR AMAN!",
			"Hutan liar di luar jalan setapak terlalu berbahaya! Tekan [Tab] untuk mengutus Mpu Bahula."
		)
