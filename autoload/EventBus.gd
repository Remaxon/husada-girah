extends Node
## EventBus — Penghubung sinyal global (Observer Pattern) untuk memisahkan logika gameplay dan UI.

signal active_character_changed(character_id: int)
signal camera_switch_started(target_character_id: int)
signal camera_switch_finished(target_character_id: int)

signal herb_collected(herb_id: String, amount: int, is_first_discovery: bool)
signal herb_inventory_changed()
signal bahula_pouch_changed(total_count: int, pouch_dict: Dictionary)
signal bahula_pouch_transferred(total_count: int, summary_text: String)
signal ready_potions_changed()

signal patient_diagnosed(patient_data: Dictionary)
signal patient_treated(patient_id: String, eval_result: Dictionary)
signal patient_cured(patient_id: String, cured_count: int, total_count: int)
signal all_patients_cured()

signal plague_meter_updated(value: float, is_paused: bool)
signal plague_paused_changed(is_paused: bool)

signal score_updated(total_score: int, delta: int, streak: int, reason: String)
signal feedback_requested(status: String, title: String, message: String)

signal alchemy_table_requested()
signal cauldron_toggled(is_open: bool)
signal lontar_toggled(is_open: bool)
signal pause_toggled(is_paused: bool)

signal bahula_hp_changed(current_hp: int, max_hp: int)
signal bahula_dash_cooldown_updated(remaining: float, duration: float)
signal bahula_retreated(cooldown_sec: float)
signal bahula_retreat_cooldown_updated(remaining: float)

signal enemy_defeated(enemy_name: String)
signal interaction_prompt_changed(prompt_text: String)

signal stage_won(summary: Dictionary)
signal stage_lost(summary: Dictionary)
