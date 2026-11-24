extends CharacterBody2D
## EnemyBoar — Hewan Buas Stage 1: Babi Hutan Liar.
## HP sedang (50), berpatroli di Rumpun Bambu & Sarang Babi Hutan,
## dan melakukan serangan seruduk (charge) singkat saat Mpu Bahula masuk radius aggro.

enum State {
	PATROL,
	CHASE,
	TELEGRAPH,
	CHARGE,
	RECOVER,
}

@export var enemy_name: String = "Babi Hutan Liar"
@export var max_hp: int = 50
@export var patrol_speed: float = 65.0
@export var chase_speed: float = 115.0
@export var charge_speed: float = 355.0
@export var aggro_radius: float = 340.0
@export var charge_trigger_radius: float = 245.0
@export var patrol_distance: float = 115.0
@export var contact_damage: int = 14
@export var danger_zone_max_y: float = 2665.0

@onready var visual_root: Node2D = $VisualRoot
@onready var body_visual: Polygon2D = $VisualRoot/BodyVisual
@onready var name_label: Label = $NameLabel
@onready var charge_alert: Label = $ChargeAlert
@onready var hp_bar_fill: ColorRect = $HpBarBg/HpBarFill
@onready var hitbox_area: Area2D = $HitboxArea

var current_hp: int = 50
var _state: int = State.PATROL
var _state_timer: float = 0.0
var _charge_cd: float = 0.0
var _charge_dir: Vector2 = Vector2.RIGHT
var _spawn_pos: Vector2 = Vector2.ZERO
var _patrol_dir: float = 1.0
var _attack_cd: float = 0.0
var _knockback_vel: Vector2 = Vector2.ZERO
var _bahula_ref: Node2D = null
var _base_color: Color = Color(0.36, 0.21, 0.12)


func _ready() -> void:
	current_hp = max_hp
	_spawn_pos = global_position
	if name_label != null:
		name_label.text = enemy_name
	if body_visual != null:
		_base_color = body_visual.color
	if charge_alert != null:
		charge_alert.visible = false
	_update_hp_bar()


func set_target_bahula(bahula_node: Node2D) -> void:
	_bahula_ref = bahula_node


func _physics_process(delta: float) -> void:
	if GameManager.is_gameplay_blocked():
		velocity = Vector2.ZERO
		return

	if _attack_cd > 0.0:
		_attack_cd = maxf(0.0, _attack_cd - delta)
	if _charge_cd > 0.0:
		_charge_cd = maxf(0.0, _charge_cd - delta)

	_knockback_vel = _knockback_vel.move_toward(Vector2.ZERO, 760.0 * delta)

	var bahula_in_forest: bool = (
		_bahula_ref != null
		and is_instance_valid(_bahula_ref)
		and GameManager.active_character == GameManager.ActiveCharacter.BAHULA
		and _bahula_ref.global_position.y < danger_zone_max_y
		and not GameManager.is_position_in_safe_zone(_bahula_ref.global_position)
	)
	var dist_to_bahula: float = INF
	if bahula_in_forest:
		dist_to_bahula = global_position.distance_to(_bahula_ref.global_position)

	var desired_vel: Vector2 = Vector2.ZERO

	match _state:
		State.PATROL:
			if bahula_in_forest and dist_to_bahula <= aggro_radius:
				_state = State.CHASE
			else:
				var to_home: Vector2 = _spawn_pos - global_position
				if to_home.length() > patrol_distance + 18.0:
					desired_vel = to_home.normalized() * (chase_speed * 0.9)
				else:
					var offset_x: float = global_position.x - _spawn_pos.x
					if offset_x >= patrol_distance:
						_patrol_dir = -1.0
					elif offset_x <= -patrol_distance:
						_patrol_dir = 1.0
					desired_vel = Vector2(_patrol_dir * patrol_speed, 0.0)

		State.CHASE:
			if not bahula_in_forest or dist_to_bahula > aggro_radius * 1.45:
				_state = State.PATROL
			else:
				var dir: Vector2 = (_bahula_ref.global_position - global_position).normalized()
				desired_vel = dir * chase_speed
				if dist_to_bahula <= charge_trigger_radius and _charge_cd <= 0.0:
					_charge_dir = dir
					_state = State.TELEGRAPH
					_state_timer = 0.42
					if charge_alert != null:
						charge_alert.visible = true
					if body_visual != null:
						body_visual.color = Color(0.86, 0.34, 0.16)

		State.TELEGRAPH:
			if not bahula_in_forest:
				_cancel_charge_to_patrol()
			else:
				_state_timer -= delta
				desired_vel = Vector2.ZERO
				_charge_dir = (_bahula_ref.global_position - global_position).normalized()
				if _state_timer <= 0.0:
					_state = State.CHARGE
					_state_timer = 0.48
					if body_visual != null:
						body_visual.color = Color(0.96, 0.25, 0.14)

		State.CHARGE:
			if not bahula_in_forest:
				_cancel_charge_to_patrol()
			else:
				_state_timer -= delta
				desired_vel = _charge_dir * charge_speed
				if _state_timer <= 0.0 or is_on_wall():
					_state = State.RECOVER
					_state_timer = 0.9
					_charge_cd = 2.4
					if charge_alert != null:
						charge_alert.visible = false
					if body_visual != null:
						body_visual.color = _base_color

		State.RECOVER:
			_state_timer -= delta
			desired_vel = Vector2.ZERO
			if _state_timer <= 0.0:
				_state = State.CHASE if (bahula_in_forest and dist_to_bahula <= aggro_radius * 1.2) else State.PATROL

	if absf(desired_vel.x) > 4.0 and visual_root != null:
		visual_root.scale.x = 1.0 if desired_vel.x >= 0.0 else -1.0
	elif _state == State.TELEGRAPH and visual_root != null:
		visual_root.scale.x = 1.0 if _charge_dir.x >= 0.0 else -1.0

	velocity = desired_vel + _knockback_vel
	move_and_slide()

	if _attack_cd <= 0.0 and hitbox_area != null:
		for body in hitbox_area.get_overlapping_bodies():
			if body != null and body.name == "PlayerBahula" and body.has_method("take_damage"):
				var dmg: int = contact_damage + (4 if _state == State.CHARGE else 0)
				body.take_damage(dmg, global_position)
				_attack_cd = 0.95
				if _state == State.CHARGE:
					_state = State.RECOVER
					_state_timer = 0.85
					_charge_cd = 2.4
					if charge_alert != null:
						charge_alert.visible = false
					if body_visual != null:
						body_visual.color = _base_color
				break


func _cancel_charge_to_patrol() -> void:
	_state = State.PATROL
	_state_timer = 0.0
	if charge_alert != null:
		charge_alert.visible = false
	if body_visual != null:
		body_visual.color = _base_color


func take_damage(amount: int, knockback_dir: Vector2) -> void:
	current_hp = maxi(0, current_hp - amount)
	_knockback_vel = knockback_dir * 250.0
	_update_hp_bar()
	_spawn_floating_text("-%d" % amount, Color(1.0, 0.85, 0.35))

	if body_visual != null:
		body_visual.color = Color(1.0, 1.0, 1.0)
		var tw: Tween = create_tween()
		tw.tween_property(body_visual, "color", _base_color, 0.16)

	if current_hp <= 0:
		EventBus.enemy_defeated.emit(enemy_name)
		EventBus.feedback_requested.emit(
			"GOOD",
			"%s DIKALAHKAN!" % enemy_name.to_upper(),
			"Babi hutan berhasil dihalau! Mpu Bahula kini lebih leluasa memanen herbal di area ini."
		)
		queue_free()


func _update_hp_bar() -> void:
	if hp_bar_fill == null:
		return
	var ratio: float = clampf(float(current_hp) / float(maxi(1, max_hp)), 0.0, 1.0)
	hp_bar_fill.size.x = 50.0 * ratio


func _spawn_floating_text(text: String, color: Color) -> void:
	var lbl: Label = Label.new()
	lbl.text = text
	lbl.modulate = color
	lbl.position = Vector2(-14, -56)
	lbl.z_index = 25
	add_child(lbl)
	var tw: Tween = create_tween()
	tw.set_parallel(true)
	tw.tween_property(lbl, "position:y", lbl.position.y - 26.0, 0.5)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.5)
	tw.chain().tween_callback(lbl.queue_free)
