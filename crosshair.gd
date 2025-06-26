extends Control

@onready var hitmarker = $Hitmarker
@onready var timer = $HitmarkerTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if timer.time_left > 0:
		var alpha = timer.time_left / timer.wait_time
		var c = hitmarker.modulate
		c.a = alpha
		hitmarker.modulate = c
	else:
		hitmarker.visible = false
