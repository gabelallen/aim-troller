extends Node3D

@onready var camera = $Camera3D
@onready var ray = $Camera3D/RayCast3D
@onready var crosshair = $Camera3D/Crosshair
@onready var timer = $Camera3D/Crosshair/HitmarkerTimer
@onready var fire_rate_timer = $FireRateTimer
@onready var hit_sound = $Camera3D/AudioStreamPlayer3D

var mouse_sensitivity := 0.002
var rotation_x := 0.0
var is_firing := false

var mouse_cache = {} #time, dir
var cache_duration = 0.5 #how many seconds we store inputs for
var cache_average = Vector2.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	fire_rate_timer.wait_time = 1.0 / 20.0
	fire_rate_timer.one_shot = false

	fire_rate_timer.connect("timeout", Callable(self, "_on_fire_rate_timeout"))

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)

		rotation_x = clamp(rotation_x - event.relative.y * mouse_sensitivity, deg_to_rad(-90), deg_to_rad(90))
		camera.rotation.x = rotation_x
		
		store_input(Vector2(event.relative.x * mouse_sensitivity, -event.relative.y * mouse_sensitivity))
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_firing = true
			if not fire_rate_timer.is_stopped():
				fire_rate_timer.stop()
			fire_rate_timer.start()
		else:
			is_firing = false
			fire_rate_timer.stop()

func _on_fire_rate_timeout():
	if is_firing:
		shoot()

func shoot():
	ray.force_raycast_update()
	if ray.is_colliding():
		var hit = ray.get_collider()
		crosshair.hitmarker.visible = true
		timer.start()
		hit_sound.play()

func store_input(direction: Vector2) -> void:
	if direction == null: direction = Vector2.ZERO
	var timestamp = Time.get_ticks_msec() / 1000.0
	mouse_cache[timestamp] = direction

	var cutoff = timestamp - cache_duration
	for key in mouse_cache.keys():
		if key < cutoff:
			mouse_cache.erase(key)
	get_cache_average()
	
func get_cache_average():
	var sum_x = 0.0
	var sum_y = 0.0
	var count = 0

	for dir in mouse_cache.values():
		sum_x += dir.x
		sum_y += dir.y
		count += 1

	if count > 0:
		var avg_x = sum_x / count
		var avg_y = sum_y / count
		cache_average = Vector2(avg_x, avg_y)
	else:
		print("DEBUG: cache is empty")
		cache_average = Vector2.ZERO

	
