extends CharacterBody2D
## PlayerBahula — Mpu Bahula (Karakter Pendamping & Lini Serang / Combat).
## Perilaku Follow-Then-Dispatch:
## - Saat Tabib Wira aktif: otomatis mengikuti di belakang Tabib (~70 px), tidak mendorong Tabib,
##   berhenti sopan sebelum garis Batas Kabut Teluh, dan melintasi jembatan sungai dengan cerdas.
## - Saat tekan Tab: dikendalikan langsung menembus Zona Berbahaya, menebas (Spasi), Dash (Shift), dan panen (E).
## - Saat tekan Tab kembali ke Tabib: otomatis menyusul kembali ke belakang Tabib.

@export var move_speed: float = 275.0
@export var dash_speed: float = 660.0
@export var dash_duration: float = 0.18
@export var dash_cooldown: float = 1.2
@export var attack_damage: int = 18
@export var attack_cooldown: float = 0.35
@export var safe_zone_y_threshold: float = 715.0
@export var follow_distance: float = 70.0
@export var follow_speed: float = 265.0
@export var catchup_speed: float = 365.0
@export var fog_stop_y: float = 728.0
@export var river_x_left: float = 2445.0
@export var river_x_right: float = 2645.0
@export var bridge_north_y: float = 1040.0
@export var bridge_south_y: float = 1660.0

@onready var body_visual: Polygon2D = $BodyVisual
@onready var active_ring: Polygon2D = $ActiveRing
@onready var status_label: Label = $StatusLabel
@onready var interact_area: Area2D = $InteractArea
@onready var attack_pivot: Node2D = $AttackPivot
@onready var attack_area: Area2D = $AttackPivot/AttackArea
@onready var slash_visual: Polygon2D = $AttackPivot/SlashVisual

var tabib_ref: Node2D = null
var home_position: Vector2 = Vector2.ZERO
var facing_dir: Vector2 = Vector2.UP
var fog_cleared: bool = false

var _dash_timer: float = 0.0
var _dash_cd_timer: float = 0.0
var _dash_dir: Vector2 = Vector2.UP
var _attack_cd_timer: float = 0.0
var _invuln_timer: float = 0.0
var _knockback_vel: Vector2 = Vector2.ZERO
var _safe_regen_accum: float = 0.0
var _is_moving_follow: bool = false
var _stuck_timer: float = 0.0
var _last_follow_pos: Vector2 = Vector2.ZERO
var _avoid_sign: float = 1.0

var _current_target: Node = null
var _last_prompt: String = ""
var _base_body_color: Color = Color(0.69, 0.23, 0.18)


func _ready() -> void:
	home_position = global_position
	_last_follow_pos = global_position
	if slash_visual != null:
		slash_visual.visible = false
	if body_visual != null:
		_base_body_color = body_visual.color
	EventBus.active_character_changed.connect(_on_active_character_changed)
	EventBus.bahula_retreated.connect(_on_bahula_retreated)
	EventBus.bahula_retreat_cooldown_updated.connect(_on_retreat_cd_updated)
	EventBus.all_patients_cured.connect(_on_all_patients_cured)
	_refresh_visual_state()


func setup_companion(tabib: Node2D, barrier_y: float) -> void:
	tabib_ref = tabib
	safe_zone_y_threshold = barrier_y + 32.0
	fog_stop_y = barrier_y + 46.0


func _physics_process(delta: float) -> void:
	if GameManager.is_gameplay_blocked():
		velocity = Vector2.ZERO
		return

	if _attack_cd_timer > 0.0:
		_attack_cd_timer = maxf(0.0, _attack_cd_timer - delta)

	if _dash_cd_timer > 0.0:
		_dash_cd_timer = maxf(0.0, _dash_cd_timer - delta)
		EventBus.bahula_dash_cooldown_updated.emit(_dash_cd_timer, dash_cooldown)

	if _invuln_timer > 0.0:
		_invuln_timer = maxf(0.0, _invuln_timer - delta)
		if body_visual != null:
			body_visual.modulate.a = 0.55 if int(_invuln_timer * 18.0) % 2 == 0 else 1.0
	elif body_visual != null:
		body_visual.modulate.a = 1.0

	# Pemulihan HP pelan & setor otomatis ketika Mpu Bahula berada di Zona Aman
	if global_position.y >= safe_zone_y_threshold:
		if not GameManager.unbanked_danger_herbs.is_empty():
			GameManager.clear_unbanked_danger_herbs()
		if GameManager.bahula_hp < GameManager.bahula_max_hp:
			_safe_regen_accum += delta
			if _safe_regen_accum >= 0.5:
				_safe_regen_accum = 0.0
				GameManager.heal_bahula(6)

	if _is_controlled():
		_process_player_control(delta)
	elif GameManager.active_character == GameManager.ActiveCharacter.TABIB and not GameManager.is_switching_camera:
		_process_follow_companion(delta)
	else:
		velocity = Vector2.ZERO


func _process_player_control(delta: float) -> void:
	var input_vec: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_vec.length_squared() > 0.01:
		facing_dir = input_vec.normalized()
		if attack_pivot != null:
			attack_pivot.rotation = facing_dir.angle()

	if _dash_timer > 0.0:
		_dash_timer = maxf(0.0, _dash_timer - delta)
		velocity = _dash_dir * dash_speed
		if _dash_timer <= 0.0 and body_visual != null:
			body_visual.color = _base_body_color
	else:
		_knockback_vel = _knockback_vel.move_toward(Vector2.ZERO, 900.0 * delta)
		velocity = input_vec * move_speed + _knockback_vel

	move_and_slide()
	_update_nearest_interactable()


func _process_follow_companion(delta: float) -> void:
	if tabib_ref == null or not is_instance_valid(tabib_ref):
		velocity = Vector2.ZERO
		return

	if GameManager.bahula_retreat_cooldown > 0.0:
		velocity = Vector2.ZERO
		return

	var tabib_pos: Vector2 = tabib_ref.global_position
	var behind_dir: Vector2 = Vector2.DOWN
	if "last_move_dir" in tabib_ref:
		var d: Vector2 = tabib_ref.last_move_dir
		if d.length_squared() > 0.01:
			behind_dir = -d.normalized()

	var desired_pos: Vector2 = tabib_pos + behind_dir * follow_distance

	# Berhenti otomatis sebelum Batas Kabut Teluh jika Mpu Bahula sudah di Zona Aman
	if not fog_cleared and global_position.y >= fog_stop_y - 4.0:
		desired_pos.y = maxf(desired_pos.y, fog_stop_y)

	var dist_to_tabib: float = global_position.distance_to(tabib_pos)
	var dist_to_desired: float = global_position.distance_to(desired_pos)

	# Jika terlalu rapat dengan Tabib (< 44 px), bergeser lembut ke belakang agar tidak berdempetan
	if dist_to_tabib < 44.0:
		var away: Vector2 = (global_position - tabib_pos).normalized()
		if away.length_squared() < 0.01:
			away = behind_dir
		if not fog_cleared and global_position.y <= fog_stop_y + 4.0 and away.y < 0.0:
			away.y = 0.25
			away = away.normalized()
		velocity = away * 135.0
		move_and_slide()
		return

	# Histeresis jarak nyaman ~70 px agar tidak bergetar
	if not _is_moving_follow:
		if dist_to_tabib > follow_distance + 14.0 or (dist_to_desired > 28.0 and dist_to_tabib > follow_distance - 4.0):
			_is_moving_follow = true
	else:
		if dist_to_tabib <= follow_distance + 4.0 and dist_to_desired <= 18.0:
			_is_moving_follow = false

	if not _is_moving_follow:
		velocity = Vector2.ZERO
		_stuck_timer = 0.0
		_update_follow_label(false)
		return

	# Navigasi cerdas melewati jembatan kayu jika terpisah aliran sungai timur
	var nav_target: Vector2 = _resolve_bridge_waypoint(desired_pos)
	var to_target: Vector2 = nav_target - global_position
	var dist_nav: float = to_target.length()
	if dist_nav <= 6.0:
		velocity = Vector2.ZERO
		_update_follow_label(false)
		return

	var move_dir: Vector2 = to_target / dist_nav

	# Anti-nyangkut ringan di sudut rumah desa
	if global_position.distance_to(_last_follow_pos) < 12.0 * delta:
		_stuck_timer += delta
		if _stuck_timer > 0.35:
			var perp: Vector2 = Vector2(-move_dir.y, move_dir.x) * _avoid_sign
			move_dir = (move_dir * 0.45 + perp * 0.85).normalized()
		if _stuck_timer > 1.3:
			_avoid_sign = -_avoid_sign
			_stuck_timer = 0.36
	else:
		_stuck_timer = 0.0
	_last_follow_pos = global_position

	var speed: float = catchup_speed if dist_to_tabib > 240.0 else follow_speed
	if dist_nav < 50.0:
		speed = lerpf(110.0, follow_speed, dist_nav / 50.0)

	velocity = move_dir * speed
	# Pastikan Bahula tidak melintasi Batas Kabut saat mengikuti Tabib dari sisi Zona Aman
	if not fog_cleared and global_position.y >= fog_stop_y - 2.0 and velocity.y < 0.0 and global_position.y + velocity.y * delta < fog_stop_y:
		velocity.y = 0.0

	facing_dir = move_dir
	if attack_pivot != null:
		attack_pivot.rotation = facing_dir.angle()

	move_and_slide()
	_update_follow_label(dist_to_tabib > 150.0)


func _resolve_bridge_waypoint(target_pos: Vector2) -> Vector2:
	# Hanya diperlukan saat keduanya berada di zona sungai (selatan Batas Kabut)
	if global_position.y < safe_zone_y_threshold or target_pos.y < safe_zone_y_threshold:
		return target_pos

	var my_west: bool = global_position.x < river_x_left
	var my_east: bool = global_position.x > river_x_right
	var tgt_west: bool = target_pos.x < river_x_left
	var tgt_east: bool = target_pos.x > river_x_right

	if (my_west and tgt_east) or (my_east and tgt_west):
		var d_north: float = absf(global_position.y - bridge_north_y) + absf(target_pos.y - bridge_north_y)
		var d_south: float = absf(global_position.y - bridge_south_y) + absf(target_pos.y - bridge_south_y)
		var bridge_y: float = bridge_north_y if d_north <= d_south else bridge_south_y
		if absf(global_position.y - bridge_y) > 36.0:
			var approach_x: float = river_x_left - 24.0 if my_west else river_x_right + 24.0
			return Vector2(approach_x, bridge_y)
		else:
			var exit_x: float = river_x_right + 30.0 if my_west else river_x_left - 30.0
			return Vector2(exit_x, bridge_y)

	return target_pos


func _update_follow_label(is_catching_up: bool) -> void:
	if status_label == null or GameManager.active_character == GameManager.ActiveCharacter.BAHULA:
		return
	if GameManager.bahula_retreat_cooldown > 0.0:
		return
	status_label.text = "[MENYUSUL TABIB]" if is_catching_up else "[MENGIKUTI • Tab]"
	status_label.modulate = Color(0.95, 0.85, 0.62)


func _unhandled_input(event: InputEvent) -> void:
	if not _is_controlled():
		return

	if event.is_action_pressed("attack"):
		_perform_attack()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("dash"):
		_perform_dash()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("interact"):
		if _current_target != null and is_instance_valid(_current_target) and _current_target.has_method("interact"):
			_current_target.interact(self)
			get_viewport().set_input_as_handled()


func _is_controlled() -> bool:
	return (
		GameManager.active_character == GameManager.ActiveCharacter.BAHULA
		and not GameManager.is_switching_camera
		and not GameManager.is_gameplay_blocked()
	)


func _perform_dash() -> void:
	if _dash_cd_timer > 0.0 or _dash_timer > 0.0:
		return
	var input_vec: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	_dash_dir = input_vec.normalized() if input_vec.length_squared() > 0.01 else facing_dir
	_dash_timer = dash_duration
	_dash_cd_timer = dash_cooldown
	_invuln_timer = maxf(_invuln_timer, dash_duration + 0.08)
	if body_visual != null:
		body_visual.color = Color(0.95, 0.78, 0.25)
	EventBus.bahula_dash_cooldown_updated.emit(_dash_cd_timer, dash_cooldown)


func _perform_attack() -> void:
	if _attack_cd_timer > 0.0:
		return
	_attack_cd_timer = attack_cooldown

	if attack_pivot != null:
		attack_pivot.rotation = facing_dir.angle()

	if slash_visual != null:
		slash_visual.visible = true
		slash_visual.modulate = Color(1.0, 0.88, 0.35, 0.95)
		slash_visual.scale = Vector2(0.75, 0.75)
		var tw: Tween = create_tween()
		tw.set_parallel(true)
		tw.tween_property(slash_visual, "scale", Vector2(1.25, 1.25), 0.14)
		tw.tween_property(slash_visual, "modulate:a", 0.0, 0.16)
		tw.chain().tween_callback(func() -> void: slash_visual.visible = false)

	var hit_any: bool = false
	for body in attack_area.get_overlapping_bodies():
		if body != null and body.has_method("take_damage"):
			var kb_dir: Vector2 = (body.global_position - global_position).normalized()
			if kb_dir.length_squared() < 0.01:
				kb_dir = facing_dir
			body.take_damage(attack_damage, kb_dir)
			hit_any = true

	if hit_any:
		_spawn_floating_text("TEBAS!", Color(1.0, 0.88, 0.28))


func take_damage(amount: int, from_pos: Vector2) -> void:
	if _dash_timer > 0.0 or _invuln_timer > 0.0 or GameManager.stage_ended:
		return
	if GameManager.active_character != GameManager.ActiveCharacter.BAHULA:
		return

	_invuln_timer = 0.75
	var push: Vector2 = (global_position - from_pos).normalized()
	_knockback_vel = push * 260.0
	_spawn_floating_text("-%d HP" % amount, Color(1.0, 0.35, 0.35))

	if body_visual != null:
		body_visual.color = Color(1.0, 0.3, 0.3)
		var tw: Tween = create_tween()
		tw.tween_property(body_visual, "color", _base_body_color, 0.22)

	GameManager.damage_bahula(amount)


func _on_bahula_retreated(_cooldown_sec: float) -> void:
	_dash_timer = 0.0
	_knockback_vel = Vector2.ZERO
	if tabib_ref != null and is_instance_valid(tabib_ref):
		var safe_retreat: Vector2 = tabib_ref.global_position + Vector2(-64.0, 24.0)
		safe_retreat.y = maxf(safe_retreat.y, fog_stop_y + 12.0)
		global_position = safe_retreat
	else:
		global_position = home_position
	_refresh_visual_state()
	if GameManager.active_character == GameManager.ActiveCharacter.BAHULA and not GameManager.is_switching_camera:
		GameManager.is_switching_camera = true
		EventBus.camera_switch_started.emit(GameManager.ActiveCharacter.TABIB)


func _on_retreat_cd_updated(_remaining: float) -> void:
	_refresh_visual_state()


func _on_all_patients_cured() -> void:
	fog_cleared = true


func _on_active_character_changed(_character_id: int) -> void:
	_refresh_visual_state()
	if GameManager.active_character != GameManager.ActiveCharacter.BAHULA:
		_current_target = null
		_last_prompt = ""
		_stuck_timer = 0.0


func _refresh_visual_state() -> void:
	var is_active: bool = GameManager.active_character == GameManager.ActiveCharacter.BAHULA
	if active_ring != null:
		active_ring.visible = is_active
	if status_label != null:
		if GameManager.bahula_retreat_cooldown > 0.0:
			status_label.text = "[PULIH %.0f dtk]" % ceilf(GameManager.bahula_retreat_cooldown)
			status_label.modulate = Color(1.0, 0.55, 0.45)
		elif is_active:
			status_label.text = "[AKTIF — TEMPUR]"
			status_label.modulate = Color(1.0, 0.85, 0.45)
		else:
			status_label.text = "[MENGIKUTI • Tab]"
			status_label.modulate = Color(0.95, 0.85, 0.62)


func _update_nearest_interactable() -> void:
	var best: Node = null
	var best_dist: float = INF

	for area in interact_area.get_overlapping_areas():
		var candidate: Node = area
		if not candidate.has_method("interact") and area.get_parent() != null and area.get_parent().has_method("interact"):
			candidate = area.get_parent()
		if candidate.has_method("can_interact") and not candidate.can_interact(self):
			continue
		if candidate.has_method("interact"):
			var dist: float = global_position.distance_squared_to(area.global_position)
			if dist < best_dist:
				best_dist = dist
				best = candidate

	_current_target = best
	var prompt: String = ""
	if _current_target != null and _current_target.has_method("get_interaction_prompt"):
		prompt = String(_current_target.get_interaction_prompt(self))

	if prompt != _last_prompt:
		_last_prompt = prompt
		EventBus.interaction_prompt_changed.emit(prompt)


func _spawn_floating_text(text: String, color: Color) -> void:
	var lbl: Label = Label.new()
	lbl.text = text
	lbl.modulate = color
	lbl.position = Vector2(-28, -52)
	lbl.z_index = 20
	add_child(lbl)
	var tw: Tween = create_tween()
	tw.set_parallel(true)
	tw.tween_property(lbl, "position:y", lbl.position.y - 28.0, 0.55)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.55)
	tw.chain().tween_callback(lbl.queue_free)
