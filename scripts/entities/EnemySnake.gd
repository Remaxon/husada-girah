extends CharacterBody2D
## EnemySnake — Hewan Buas Stage 1: Ular Berbisa.
## Ukuran lebih kecil, gerak melata lincah (weaving), menjaga area Tepi Sungai dan Reruntuhan Batu Tua
## di dekat tanaman herbal kunci.

@export var enemy_name: String = "Ular Berbisa"
@export var max_hp: int = 28
@export var patrol_speed: float = 95.0
@export var chase_speed: float = 172.0
@export var aggro_radius: float = 310.0
@export var patrol_distance: float = 95.0
@export var contact_damage: int = 10
@export var danger_zone_max_y: float = 2665.0

@onready var visual_root: Node2D = $VisualRoot
@onready var body_visual: Polygon2D = $VisualRoot/CoilBody
@onready var name_label: Label = $NameLabel
@onready var hp_bar_fill: ColorRect = $HpBarBg/HpBarFill
@onready var hitbox_area: Area2D = $HitboxArea

var current_hp: int = 28
var _spawn_pos: Vector2 = Vector2.ZERO
var _patrol_angle: float = 0.0
var _slither_time: float = 0.0
var _attack_cd: float = 0.0
var _knockback_vel: Vector2 = Vector2.ZERO
var _bahula_ref: Node2D = null
var _base_color: Color = Color(0.16, 0.44, 0.18)


func _ready() -> void:
	current_hp = max_hp
	_spawn_pos = global_position
	_patrol_angle = randf() * TAU
	if name_label != null:
		name_label.text = enemy_name
	if body_visual != null:
		_base_color = body_visual.color
	_update_hp_bar()


func set_target_bahula(bahula_node: Node2D) -> void:
	_bahula_ref = bahula_node


func _physics_process(delta: float) -> void:
	if GameManager.is_gameplay_blocked():
		velocity = Vector2.ZERO
		return

	_slither_time += delta
	if _attack_cd > 0.0:
		_attack_cd = maxf(0.0, _attack_cd - delta)

	_knockback_vel = _knockback_vel.move_toward(Vector2.ZERO, 820.0 * delta)

	var desired_vel: Vector2 = Vector2.ZERO
	var chasing: bool = false

	if (
		_bahula_ref != null
		and is_instance_valid(_bahula_ref)
		and GameManager.active_character == GameManager.ActiveCharacter.BAHULA
		and _bahula_ref.global_position.y < danger_zone_max_y
		and not GameManager.is_position_in_safe_zone(_bahula_ref.global_position)
	):
		var dist: float = global_position.distance_to(_bahula_ref.global_position)
		if dist <= aggro_radius:
			chasing = true
			var to_player: Vector2 = (_bahula_ref.global_position - global_position).normalized()
			var perp: Vector2 = Vector2(-to_player.y, to_player.x)
			# Gerakan melata lincah berliku saat mengejar, lalu menerjang lurus saat dekat
			var weave: float = sin(_slither_time * 9.5) * (0.15 if dist < 90.0 else 0.42)
			var move_dir: Vector2 = (to_player + perp * weave).normalized()
			var spd: float = chase_speed * (1.28 if dist < 95.0 else 1.0)
			desired_vel = move_dir * spd

	if not chasing:
		# Kembali ke wilayah patroli (return to home) jika sempat mengejar jauh
		var dist_home: float = global_position.distance_to(_spawn_pos)
		if dist_home > patrol_distance + 24.0:
			desired_vel = (_spawn_pos - global_position).normalized() * (chase_speed * 0.85)
		else:
			_patrol_angle += delta * 1.35
			var orbit_target: Vector2 = _spawn_pos + Vector2(cos(_patrol_angle) * patrol_distance, sin(_patrol_angle) * patrol_distance * 0.65)
			var to_orbit: Vector2 = orbit_target - global_position
			if to_orbit.length() > 6.0:
				desired_vel = to_orbit.normalized() * patrol_speed

	if absf(desired_vel.x) > 4.0 and visual_root != null:
		visual_root.scale.x = 1.0 if desired_vel.x >= 0.0 else -1.0
		visual_root.rotation = sin(_slither_time * 10.0) * 0.1

	velocity = desired_vel + _knockback_vel
	move_and_slide()

	if _attack_cd <= 0.0 and hitbox_area != null:
		for body in hitbox_area.get_overlapping_bodies():
			if body != null and body.name == "PlayerBahula" and body.has_method("take_damage"):
				body.take_damage(contact_damage, global_position)
				_attack_cd = 0.85
				break


func take_damage(amount: int, knockback_dir: Vector2) -> void:
	current_hp = maxi(0, current_hp - amount)
	_knockback_vel = knockback_dir * 310.0
	_update_hp_bar()
	_spawn_floating_text("-%d" % amount, Color(1.0, 0.92, 0.3))

	if body_visual != null:
		body_visual.color = Color(1.0, 1.0, 1.0)
		var tw: Tween = create_tween()
		tw.tween_property(body_visual, "color", _base_color, 0.15)

	if current_hp <= 0:
		EventBus.enemy_defeated.emit(enemy_name)
		EventBus.feedback_requested.emit(
			"GOOD",
			"%s DIKALAHKAN!" % enemy_name.to_upper(),
			"Ular berbisa berhasil disingkirkan! Herbal kunci di sekitar sini kini aman dipetik."
		)
		queue_free()


func _update_hp_bar() -> void:
	if hp_bar_fill == null:
		return
	var ratio: float = clampf(float(current_hp) / float(maxi(1, max_hp)), 0.0, 1.0)
	hp_bar_fill.size.x = 42.0 * ratio


func _spawn_floating_text(text: String, color: Color) -> void:
	var lbl: Label = Label.new()
	lbl.text = text
	lbl.modulate = color
	lbl.position = Vector2(-14, -48)
	lbl.z_index = 25
	add_child(lbl)
	var tw: Tween = create_tween()
	tw.set_parallel(true)
	tw.tween_property(lbl, "position:y", lbl.position.y - 24.0, 0.5)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.5)
	tw.chain().tween_callback(lbl.queue_free)
