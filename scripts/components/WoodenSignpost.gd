extends Area2D
## WoodenSignpost — Papan petunjuk kayu di persimpangan peta Desa Girah.

@export var sign_title: String = "Papan Petunjuk Desa Girah"
@export_multiline var short_label: String = "↑ Hutan Kabut\n→ Sungai"
@export_multiline var detail_text: String = "Ikuti jalan setapak menuju rumah warga atau jembatan sungai."

@onready var board_label: Label = $BoardLabel


func _ready() -> void:
	if board_label != null:
		board_label.text = short_label


func can_interact(_actor: Node) -> bool:
	return true


func get_interaction_prompt(_actor: Node) -> String:
	return "[E] Baca %s" % sign_title


func interact(_actor: Node) -> void:
	EventBus.feedback_requested.emit("INFO", sign_title.to_upper(), detail_text)
