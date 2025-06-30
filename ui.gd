extends Control

signal update_sens(sens)

@onready var acc_label = $Accuracy
var shots = 0
var hits = 0

func _on_player_on_shot_fired(hit: bool) -> void:
	shots += 1
	if hit:
		hits += 1
	var misses = shots - hits
	acc_label.text = "Hits: %d | Misses: %d | Shots: %d | Accuracy: %.2f%%" % [hits, misses, shots, float(hits) / shots * 100.0]


func _on_sens_edit_sens_changed(sens: float) -> void:
	emit_signal("update_sens", sens)

func restart_self():
	shots = 0
	hits = 0
	var misses = shots - hits
	acc_label.text = "Hits: %d | Misses: %d | Shots: %d | Accuracy: 0%%" % [hits, misses, shots]
