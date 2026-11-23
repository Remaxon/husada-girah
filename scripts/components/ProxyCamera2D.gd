extends Camera2D
## ProxyCamera2D — Kamera utama dengan transisi Tween mulus 0.55 detik saat berganti
## antara Tabib Wira dan Mpu Bahula, serta efek getar ringan (screen shake) saat gagal/toksik.

const SWITCH_DURATION: float = 0.55

var tabib_node: Node2D = null
var bahula_node: Node2D = null
var _active_target: Node2D = null
var _is_tweening: bool = false
var _switch_tween: Tween = null
var _shake_intensity: float = 0.0
var _shake_timer: float = 0.0


func _ready() -> void:
	EventBus.camera_switch_started.connect(_on_camera_switch_started)
	EventBus.feedback_requested.connect(_on_feedback_requested)


func setup_targets(tabib: Node2D, bahula: Node2D) -> void:
	tabib_node = tabib
	bahula_node = bahula
	_active_target = tabib_node
	if _active_target != null:
		global_position = _active_target.global_position


func set_map_limits(map_width: int, map_height: int) -> void:
	limit_left = 0
	limit_top = 0
	limit_right = map_width
	limit_bottom = map_height


func _process(delta: float) -> void:
	if not _is_tweening and _active_target != null and is_instance_valid(_active_target):
		global_position = global_position.lerp(_active_target.global_position, minf(1.0, delta * 10.0))

	if _shake_timer > 0.0:
		_shake_timer = maxf(0.0, _shake_timer - delta)
		offset = Vector2(
			randf_range(-_shake_intensity, _shake_intensity),
			randf_range(-_shake_intensity, _shake_intensity)
		)
		if _shake_timer <= 0.0:
			offset = Vector2.ZERO


func trigger_shake(intensity: float = 7.0, duration: float = 0.25) -> void:
	_shake_intensity = intensity
	_shake_timer = duration


func _on_camera_switch_started(target_character_id: int) -> void:
	var dest_node: Node2D = bahula_node if target_character_id == GameManager.ActiveCharacter.BAHULA else tabib_node
	if dest_node == null or not is_instance_valid(dest_node):
		GameManager.complete_switch_character(target_character_id)
		return

	_is_tweening = true
	if _switch_tween != null and _switch_tween.is_running():
		_switch_tween.kill()

	_switch_tween = create_tween()
	_switch_tween.set_trans(Tween.TRANS_CUBIC)
	_switch_tween.set_ease(Tween.EASE_IN_OUT)
	_switch_tween.tween_property(self, "global_position", dest_node.global_position, SWITCH_DURATION)
	_switch_tween.tween_callback(func() -> void:
		_active_target = dest_node
		_is_tweening = false
		GameManager.complete_switch_character(target_character_id)
	)


func _on_feedback_requested(status: String, _title: String, _message: String) -> void:
	if status == "TOXIC":
		trigger_shake(9.0, 0.32)
	elif status == "FAIL":
		trigger_shake(5.5, 0.22)
