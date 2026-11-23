extends Node
## ScoreManager — Menghitung skor per tindakan, streak akurasi, efisiensi Wabah Meter,
## serta peringkat Bintang 1–3 sesuai GDD Bagian 5.

const BASE_CURE_PER_SYMPTOM: int = 200
const PERFECT_ACCURACY_BONUS: int = 150
const STREAK_UNIT_BONUS: int = 50
const STREAK_MAX_BONUS: int = 250
const FIRST_DISCOVERY_BONUS: int = 100
const FAIL_PENALTY: int = 50

var current_stage: int = 1
var total_score: int = 0
var cure_points: int = 0
var accuracy_bonus_points: int = 0
var streak_bonus_points: int = 0
var discovery_points: int = 0
var plague_efficiency_points: int = 0
var penalty_points: int = 0

var current_streak: int = 0
var wrong_brew_count: int = 0
var toxic_fail_count: int = 0


func reset_stage_score(stage_number: int) -> void:
	current_stage = stage_number
	total_score = 0
	cure_points = 0
	accuracy_bonus_points = 0
	streak_bonus_points = 0
	discovery_points = 0
	plague_efficiency_points = 0
	penalty_points = 0
	current_streak = 0
	wrong_brew_count = 0
	toxic_fail_count = 0
	EventBus.score_updated.emit(total_score, 0, current_streak, "Stage dimulai")


func record_patient_cured(symptom_count: int, is_perfect: bool) -> int:
	var base_pts: int = BASE_CURE_PER_SYMPTOM * maxi(1, symptom_count)
	var acc_pts: int = PERFECT_ACCURACY_BONUS if is_perfect else 0
	current_streak += 1
	var str_pts: int = mini(STREAK_MAX_BONUS, current_streak * STREAK_UNIT_BONUS)

	cure_points += base_pts
	accuracy_bonus_points += acc_pts
	streak_bonus_points += str_pts

	var delta: int = base_pts + acc_pts + str_pts
	total_score += delta
	var reason: String = "Usada Utama! +%d (+%d akurasi, +%d streak)" % [base_pts, acc_pts, str_pts] if is_perfect else "Warga Sembuh +%d (+%d streak)" % [base_pts, str_pts]
	EventBus.score_updated.emit(total_score, delta, current_streak, reason)
	return delta


func record_new_herb_discovery(herb_id: String) -> int:
	discovery_points += FIRST_DISCOVERY_BONUS
	total_score += FIRST_DISCOVERY_BONUS
	var herb_name: String = AlchemyDatabase.get_herb_name(herb_id)
	EventBus.score_updated.emit(total_score, FIRST_DISCOVERY_BONUS, current_streak, "Penemuan herbal: %s (+%d)" % [herb_name, FIRST_DISCOVERY_BONUS])
	return FIRST_DISCOVERY_BONUS


func record_brew_failure(is_toxic: bool) -> int:
	wrong_brew_count += 1
	if is_toxic:
		toxic_fail_count += 1
	current_streak = 0
	var old_score: int = total_score
	total_score = maxi(0, total_score - FAIL_PENALTY)
	var actual_loss: int = total_score - old_score
	penalty_points += abs(actual_loss)
	var label: String = "Gagal Toksik (-%d)" % FAIL_PENALTY if is_toxic else "Racikan Salah (-%d)" % FAIL_PENALTY
	EventBus.score_updated.emit(total_score, actual_loss, current_streak, label)
	return actual_loss


func finalize_stage(final_plague_percent: float, bahula_retreats: int = 0) -> Dictionary:
	plague_efficiency_points = int(round(maxf(0.0, 100.0 - final_plague_percent) * 10.0))
	total_score += plague_efficiency_points
	EventBus.score_updated.emit(total_score, plague_efficiency_points, current_streak, "Bonus Efisiensi Wabah (+%d)" % plague_efficiency_points)

	var stars: int = _calculate_stars(current_stage, total_score, bahula_retreats)
	var breakdown: Dictionary = get_current_breakdown(final_plague_percent)
	breakdown["stars"] = stars
	breakdown["rank_title"] = _get_rank_title(stars)
	return breakdown


func get_current_breakdown(final_plague_percent: float) -> Dictionary:
	return {
		"stage": current_stage,
		"total_score": total_score,
		"cure_points": cure_points,
		"accuracy_bonus_points": accuracy_bonus_points,
		"streak_bonus_points": streak_bonus_points,
		"discovery_points": discovery_points,
		"plague_efficiency_points": plague_efficiency_points,
		"penalty_points": penalty_points,
		"wrong_brew_count": wrong_brew_count,
		"toxic_fail_count": toxic_fail_count,
		"plague_percent": final_plague_percent,
		"stars": 0,
		"rank_title": "Belum Selesai",
	}


func _calculate_stars(stage_num: int, score: int, bahula_retreats: int) -> int:
	match stage_num:
		1:
			if score >= 2400 and wrong_brew_count <= 1:
				return 3
			elif score >= 1800:
				return 2
			return 1
		2:
			if score >= 3600 and toxic_fail_count == 0:
				return 3
			elif score >= 2800:
				return 2
			return 1
		3:
			if score >= 4900 and wrong_brew_count <= 1:
				return 3
			elif score >= 3900:
				return 2
			return 1
		4:
			if score >= 4800 and bahula_retreats == 0:
				return 3
			elif score >= 3800:
				return 2
			return 1
		_:
			return 1


func _get_rank_title(stars: int) -> String:
	match stars:
		3:
			return "EMPU USADA (★★★)"
		2:
			return "TABIB MAHIR (★★☆)"
		_:
			return "LULUS (★☆☆)"
