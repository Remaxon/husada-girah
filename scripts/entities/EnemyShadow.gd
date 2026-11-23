extends CharacterBody2D
## EnemyShadow — Musuh "Bayangan Kabut" di Zona Berbahaya.
## Berpatroli di sekitar herbal langka, mengejar Mpu Bahula, kalah dalam 2 tebasan (35 HP).

@export var enemy_name: String = "Bayangan Kabut"
@export var max_hp: int = 35
@export var move_speed: float = 88.0
@export var aggro_radius: float = 320.0
@export var patrol_distance: float = 110.0
@export var contact_damage: int = 10
@export var danger_zone_max_y: float = 695.0

@onready var body_visual: Polygon2D = $BodyVisual
@onready var name_label: Label = $NameLabel
@onready var hp_bar_fill: ColorRect = $HpBarBg/HpBarFill
@onready var hitbox_area: Area2D = $HitboxArea

var current_hp: int = 35
var _spawn_pos: Vector2 = Vector2.ZERO
var _patrol_dir: float = 1.0
var _attack_cd: float = 0.0
var _knockback_vel: Vector2 = Vector2.ZERO
var _bahula_ref: Node2D = null
var _base_color: Color = Color(0.45, 0.16, 0.56)


func _ready() -> void:
	current_hp = max_hp
	_spawn_pos = global_position
	if name_label != null:
		name_label.text = enemy_name
	if body_visual != null:
		_base_color = body_visual.color
	EventBus.all_patients_cured.connect(_on_all_patients_cured)
	_update_hp_bar()


func _on_all_patients_cured() -> void:
	# Kabut hutan utara mereda saat wabah Desa Girah teratasi
	queue_free()


func set_target_bahula(bahula_node: Node2D) -> void:
	_bahula_ref = bahula_node


func _physics_process(delta: float) -> void:
	if GameManager.is_gameplay_blocked():
		velocity = Vector2.ZERO
		return

	if _attack_cd > 0.0:
		_attack_cd = maxf(0.0, _attack_cd - delta)

	_knockback_vel = _knockback_vel.move_toward(Vector2.ZERO, 750.0 * delta)

	var desired_vel: Vector2 = Vector2.ZERO
	var chasing: bool = false
	if (
		_bahula_ref != null
		and is_instance_valid(_bahula_ref)
		and GameManager.active_character == GameManager.ActiveCharacter.BAHULA
	):
		var dist: float = global_position.distance_to(_bahula_ref.global_position)
		if dist <= aggro_radius and _bahula_ref.global_position.y < danger_zone_max_y:
			chasing = true
			var dir: Vector2 = (_bahula_ref.global_position - global_position).normalized()
			desired_vel = dir * move_speed

	if not chasing:
		# Patroli horizontal lembut di sekitar titik awal
		var offset_x: float = global_position.x - _spawn_pos.x
		if offset_x >= patrol_distance:
			_patrol_dir = -1.0
		elif offset_x <= -patrol_distance:
			_patrol_dir = 1.0
		desired_vel = Vector2(_patrol_dir * move_speed * 0.55, 0.0)

	velocity = desired_vel + _knockback_vel
	move_and_slide()

	# Cek tabrakan serangan dengan Mpu Bahula
	if _attack_cd <= 0.0 and hitbox_area != null:
		for body in hitbox_area.get_overlapping_bodies():
			if body != null and body.name == "PlayerBahula" and body.has_method("take_damage"):
				body.take_damage(contact_damage, global_position)
				_attack_cd = 0.95
				break


func take_damage(amount: int, knockback_dir: Vector2) -> void:
	current_hp = maxi(0, current_hp - amount)
	_knockback_vel = knockback_dir * 290.0
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
			"Jalur menuju herbal langka di Zona Berbahaya makin aman bagi Mpu Bahula!"
		)
		queue_free()


func _update_hp_bar() -> void:
	if hp_bar_fill == null:
		return
	var ratio: float = clampf(float(current_hp) / float(maxi(1, max_hp)), 0.0, 1.0)
	hp_bar_fill.size.x = 48.0 * ratio


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
