extends Timer

func _on_timeout() -> void:
	get_parent().choose_random_mode()
