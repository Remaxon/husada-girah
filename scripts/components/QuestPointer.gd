extends Node2D
## QuestPointer — Panah penunjuk arah dinamis di sekitar karakter aktif.
## Mengarah ke warga sakit terdekat (warna kuning emas) atau ke Gerbang Utara menuju Stage 2 (hijau zamrud)
## setelah seluruh warga Desa Girah sembuh.

@export var orbit_radius: float = 68.0
@export var hide_distance: float = 125.0

@onready var arrow_pivot: Node2D = $ArrowPivot
@onready var arrow_poly: Polygon2D = $ArrowPivot/ArrowPoly
@onready var target_label: Label = $TargetLabel

var tabib_node: Node2D = null
var bahula_node: Node2D = null
var patients_container: Node2D = null
var north_gate_node: Node2D = null
var _pulse: float = 0.0


func setup(tabib: Node2D, bahula: Node2D, patients: Node2D, gate: Node2D) -> void:
	tabib_node = tabib
	bahula_node = bahula
	patients_container = patients
	north_gate_node = gate


func _process(delta: float) -> void:
	_pulse += delta
	if GameManager.stage_ended:
		visible = false
		return

	var active_actor: Node2D = tabib_node if GameManager.active_character == GameManager.ActiveCharacter.TABIB else bahula_node
	if active_actor == null or not is_instance_valid(active_actor):
		visible = false
		return

	var target_pos: Vector2 = Vector2.ZERO
	var target_text: String = ""
	var is_gate_target: bool = false
	var has_target: bool = false

	if GameManager.north_gate_unlocked and north_gate_node != null and is_instance_valid(north_gate_node):
		target_pos = north_gate_node.global_position
		target_text = "★ Gerbang Stage 2"
		is_gate_target = true
		has_target = true
	elif patients_container != null:
		var best_patient: Node2D = _find_priority_patient(active_actor.global_position)
		if best_patient != null:
			target_pos = best_patient.global_position
			var pname: String = String(best_patient.patient_name) if "patient_name" in best_patient else "Warga Sakit"
			target_text = pname
			has_target = true

	if not has_target:
		visible = false
		return

	var diff: Vector2 = target_pos - active_actor.global_position
	var dist: float = diff.length()
	if dist <= hide_distance:
		visible = false
		return

	visible = true
	var dir: Vector2 = diff / dist
	var bob: float = sin(_pulse * 5.5) * 4.0
	global_position = active_actor.global_position + dir * (orbit_radius + bob)

	if arrow_pivot != null:
		arrow_pivot.rotation = dir.angle()
	if arrow_poly != null:
		arrow_poly.color = Color(0.28, 0.96, 0.54, 0.95) if is_gate_target else Color(0.98, 0.82, 0.22, 0.95)
	if target_label != null:
		var meters: int = maxi(1, int(round(dist / 32.0)))
		target_label.text = "%s (%dm)" % [target_text, meters]
		target_label.modulate = Color(0.68, 1.0, 0.78) if is_gate_target else Color(1.0, 0.95, 0.65)


func _find_priority_patient(origin: Vector2) -> Node2D:
	var nearest_any: Node2D = null
	var nearest_any_dist: float = INF
	var nearest_diag: Node2D = null
	var nearest_diag_dist: float = INF
	var carrying_potion: bool = (
		GameManager.active_character == GameManager.ActiveCharacter.TABIB
		and not GameManager.ready_potions.is_empty()
	)

	for child in patients_container.get_children():
		if not (child is Node2D):
			continue
		if "is_cured" in child and bool(child.is_cured):
			continue
		var d: float = origin.distance_squared_to(child.global_position)
		if d < nearest_any_dist:
			nearest_any_dist = d
			nearest_any = child
		if carrying_potion and "is_diagnosed" in child and bool(child.is_diagnosed):
			if d < nearest_diag_dist:
				nearest_diag_dist = d
				nearest_diag = child

	if carrying_potion and nearest_diag != null:
		return nearest_diag
	return nearest_any
