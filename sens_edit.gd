extends TextEdit

signal sens_changed(sens)

func _ready() -> void:
	connect("text_changed", Callable(self, "_on_text_changed"))

func _on_text_changed() -> void:
	var filtered_text := ""
	var has_decimal := false

	for c in text:
		if c >= "0" and c <= "9":
			filtered_text += c
		elif c == "." and not has_decimal:
			filtered_text += c
			has_decimal = true

	if filtered_text != text:
		text = filtered_text

	if filtered_text != "" and filtered_text != ".":
		emit_signal("sens_changed", filtered_text.to_float())
