extends CharacterBody2D
## PlayerTabib — Tabib Wira (Karakter Non-Combat, khusus Zona Aman / Desa Pinggiran).
## Bergerak dengan WASD/Panah, tahan Shift untuk Sprint 1.5x, tekan E untuk diagnosa/obati warga & panen herbal desa.
## Secara fisik ditahan oleh barrier hutan (Collision Layer 2).

@export var move_speed: float = 245.0
@export var sprint_multiplier: float = 1.5

@onready var interact_area: Area2D = $InteractArea
@onready var active_ring: Polygon2D = $ActiveRing
@onready var status_label: Label = $StatusLabel

var last_move_dir: Vector2 = Vector2.DOWN
var is_sprinting: bool = false
var _current_target: Node = null
var _last_prompt: String = ""


func _ready() -> void:
	EventBus.active_character_changed.connect(_on_active_character_changed)
	_refresh_visual_state()


func _physics_process(_delta: float) -> void:
	if not _is_controlled():
		velocity = Vector2.ZERO
		if is_sprinting:
			is_sprinting = false
			_refresh_visual_state()
		return

	var input_vec: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var moving: bool = input_vec.length_squared() > 0.01
	if moving:
		last_move_dir = input_vec.normalized()

	var now_sprint: bool = moving and Input.is_action_pressed("sprint")
	if now_sprint != is_sprinting:
		is_sprinting = now_sprint
		_refresh_visual_state()

	var effective_speed: float = move_speed * (sprint_multiplier if is_sprinting else 1.0)
	velocity = input_vec * effective_speed
	move_and_slide()

	_update_nearest_interactable()


func _unhandled_input(event: InputEvent) -> void:
	if not _is_controlled():
		return
	if event.is_action_pressed("interact"):
		if _current_target != null and is_instance_valid(_current_target) and _current_target.has_method("interact"):
			_current_target.interact(self)
			get_viewport().set_input_as_handled()


func _is_controlled() -> bool:
	return (
		GameManager.active_character == GameManager.ActiveCharacter.TABIB
		and not GameManager.is_switching_camera
		and not GameManager.is_gameplay_blocked()
	)


func _on_active_character_changed(_character_id: int) -> void:
	is_sprinting = false
	_refresh_visual_state()
	if GameManager.active_character != GameManager.ActiveCharacter.TABIB:
		_current_target = null
		_last_prompt = ""


func _refresh_visual_state() -> void:
	var is_active: bool = GameManager.active_character == GameManager.ActiveCharacter.TABIB
	if active_ring != null:
		active_ring.visible = is_active
		active_ring.color = Color(1.0, 0.88, 0.25, 0.72) if (is_active and is_sprinting) else Color(0.83, 0.63, 0.09, 0.45)
	if status_label != null:
		if is_active:
			status_label.text = "[SPRINT 1.5x — TABIB]" if is_sprinting else "[AKTIF — TABIB]"
			status_label.modulate = Color(1.0, 0.96, 0.55) if is_sprinting else Color(0.85, 1.0, 0.72)
		else:
			status_label.text = "[SIAGA AMAN]"
			status_label.modulate = Color(0.95, 0.88, 0.62)


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
