extends Node2D
## Stage01_DesaGirah — Peta Luas Terhubung (3200x2200) Parameter Terluar Wilayah Girah, Kerajaan Kahuripan.
## Ekosistem: Pemukiman Desa Pinggiran (6 rumah + 7 herbal dapur), Sungai & Tepi Lembap (2 jembatan + 4 herbal lembap),
## Pinggiran Hutan Berkabut Utara (3 Bayangan Kabut + Sambiloto & Kecubung), serta Gerbang Utara menuju Stage 2.

const MAP_WIDTH: int = 3200
const MAP_HEIGHT: int = 2200
const FOG_BARRIER_Y: float = 682.0

@onready var player_tabib: CharacterBody2D = $Entities/PlayerTabib
@onready var player_bahula: CharacterBody2D = $Entities/PlayerBahula
@onready var proxy_camera: Camera2D = $ProxyCamera2D
@onready var quest_pointer: Node2D = $QuestPointer
@onready var patients_container: Node2D = $Patients
@onready var enemies_container: Node2D = $Enemies
@onready var north_gate: Area2D = $NorthGate

@onready var fog_barrier: StaticBody2D = $FogBarrier
@onready var fog_strip_outer: ColorRect = $FogBarrier/FogStripOuter
@onready var fog_strip_core: ColorRect = $FogBarrier/FogStripCore
@onready var fog_label: Label = $FogBarrier/FogLabel
@onready var fog_warning_zone: Area2D = $FogBarrier/FogWarningZone

@onready var game_hud: CanvasLayer = $GameHUD
@onready var alchemy_ui: CanvasLayer = $AlchemyTableUI
@onready var lontar_ui: CanvasLayer = $LontarUsadaUI

var _fog_warn_cooldown: float = 0.0
var _fog_cleared: bool = false


func _ready() -> void:
	var patient_count: int = patients_container.get_child_count()
	# Stage 1 (Parameter Terluar Wilayah Girah): Wabah awal 10%, laju rendah +0.25%/detik
	GameManager.reset_for_stage(1, 10.0, 0.25, patient_count)

	proxy_camera.set_map_limits(MAP_WIDTH, MAP_HEIGHT)
	proxy_camera.setup_targets(player_tabib, player_bahula)

	if player_bahula.has_method("setup_companion"):
		player_bahula.setup_companion(player_tabib, FOG_BARRIER_Y)

	if quest_pointer.has_method("setup"):
		quest_pointer.setup(player_tabib, player_bahula, patients_container, north_gate)

	for enemy in enemies_container.get_children():
		if enemy.has_method("set_target_bahula"):
			enemy.set_target_bahula(player_bahula)

	var house_rects: Array = [
		Rect2(440, 1130, 180, 110),
		Rect2(1140, 1120, 180, 110),
		Rect2(1860, 1130, 180, 110),
		Rect2(440, 1760, 180, 110),
		Rect2(1140, 1760, 210, 120),
		Rect2(1860, 1760, 180, 110),
	]
	game_hud.setup_minimap({
		"map_size": Vector2(MAP_WIDTH, MAP_HEIGHT),
		"fog_barrier_y": FOG_BARRIER_Y,
		"house_rects": house_rects,
		"tabib": player_tabib,
		"bahula": player_bahula,
		"patients": patients_container,
		"north_gate": north_gate,
		"camera": proxy_camera,
	})

	fog_warning_zone.body_entered.connect(_on_fog_warning_entered)
	EventBus.alchemy_table_requested.connect(_on_cauldron_requested)
	EventBus.all_patients_cured.connect(_on_all_patients_cured)
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
		"STAGE 1: PARAMETER TERLUAR DESA GIRAH (WABAH 10%)",
		"Mpu Bahula mengikuti di belakang Tabib! Ikuti panah kuning & Minimap untuk diagnosa 4 warga [E], tekan [R] buka Kuali Portabel di mana saja, [L] Buku Lontar, atau [Tab] tugaskan Mpu Bahula ke hutan utara."
	)


func _process(delta: float) -> void:
	if _fog_warn_cooldown > 0.0:
		_fog_warn_cooldown = maxf(0.0, _fog_warn_cooldown - delta)


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


func _on_all_patients_cured() -> void:
	_fog_cleared = true
	if fog_barrier != null:
		fog_barrier.set_deferred("collision_layer", 0)
	if fog_strip_outer != null:
		fog_strip_outer.color = Color(0.24, 0.62, 0.36, 0.32)
	if fog_strip_core != null:
		fog_strip_core.color = Color(0.45, 0.94, 0.58, 0.48)
	if fog_label != null:
		fog_label.text = "~~~~~  KABUT TELUH MEREDA — JALAN MENUJU GERBANG UTARA (STAGE 2) TERBUKA!  ~~~~~"
		fog_label.modulate = Color(0.82, 1.0, 0.85)


func _on_retry_stage() -> void:
	get_tree().reload_current_scene()


func _on_stage_ended(_summary: Dictionary) -> void:
	if lontar_ui.visible:
		lontar_ui.close_lontar()
	if alchemy_ui.visible:
		alchemy_ui.close_alchemy()
	game_hud.set_pause_overlay_visible(false)


func _on_fog_warning_entered(body: Node2D) -> void:
	if _fog_cleared:
		return
	if body == player_tabib and _fog_warn_cooldown <= 0.0:
		_fog_warn_cooldown = 3.5
		EventBus.feedback_requested.emit(
			"FAIL",
			"BATAS KABUT TELUH!",
			"Kabut teluh terlalu pekat bagi Tabib Wira! Tekan [Tab] untuk menugaskan Mpu Bahula menerobos hutan utara."
		)
