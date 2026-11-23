extends Area2D
## AlchemyStation — Meja Alkimia (Lumpang & Pipisan) di Posko Tabib.
## Tekan E oleh Tabib Wira untuk membuka modal Meja Alkimia.


func can_interact(_actor: Node) -> bool:
	return true


func get_interaction_prompt(actor: Node) -> String:
	if actor.name == "PlayerBahula":
		return "[Tab] Beralih ke Tabib Wira untuk meracik di Meja Alkimia"
	return "[E] Buka Meja Alkimia (Lumpang & Pipisan)"


func interact(actor: Node) -> void:
	if actor.name == "PlayerBahula":
		EventBus.feedback_requested.emit(
			"INFO",
			"MEJA ALKIMIA TABIB",
			"Meja Alkimia digunakan oleh Tabib Wira untuk meracik obat. Tekan [Tab] untuk kembali ke Tabib."
		)
		return
	EventBus.alchemy_table_requested.emit()
