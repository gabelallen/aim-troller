extends Node3D

@export var player: Node3D
@onready var mode_timer = $Mode_Timer
@onready var direction_timer = $Direction_Timer

var mode_weights = {
	"long_strafes": 5,
	"short_strafes": 5,
	"giga_long_strafes": 1,
	"giga_short_strafes": 1,
	"short_dash": 1,
	"long_dash": 1,
	"short_stop": 1,
	"anti_aim": 50,
}
var current_mode = ""
var orbit_direction_target = 1.0
var orbit_direction_current = 1.0
var orbit_speed = 1.0 # radians/sec
var orbit_radius = 5.0
var prev_speed = -1 #for super fast movements, so when it's done we can go back to this to get the old speed and set it back to -1

var vertical_direction_target = 1.0
var vertical_direction_current = 1.0
var vertical_speed = 0.5
var orbit_angle = 0.0
var vertical_angle = 0.0
const MAX_VERTICAL_ANGLE = deg_to_rad(70)
const SHARPNESS = 10 #how sharp the turns are, lower number = smoother turns

func _ready():
	randomize()
	choose_random_mode()
	direction_timer.timeout.connect(_on_direction_timer_timeout)

func choose_random_mode():
	if prev_speed == -1:
		orbit_speed = prev_speed
		prev_speed = -1
		
	current_mode = weighted_random_choice(mode_weights)
	mode_timer.wait_time = randf_range(0.2, 2)
	mode_timer.start()

	match current_mode:
		"long_strafes":
			direction_timer.wait_time = 0.5
			direction_timer.start()
			print("long strafes")
		"short_strafes":
			direction_timer.wait_time = 0.25
			direction_timer.start()
			print("short strafes")
		"giga_long_strafes":
			direction_timer.wait_time = 1.0
			direction_timer.start()
			print("giga long strafes")
		"giga_short_strafes":
			direction_timer.wait_time = 0.1
			direction_timer.start()
			print("giga short strafes")
		"short_dash":
			mode_timer.wait_time = 0.05
			direction_timer.wait_time = 0.05
			direction_timer.start()
			prev_speed = orbit_speed
			orbit_speed = prev_speed * 3
			print("short dash")
		"long_dash":
			mode_timer.wait_time = 0.1
			direction_timer.wait_time = 0.1
			direction_timer.start()
			prev_speed = orbit_speed
			orbit_speed = prev_speed * 3
			print("long dash")
		"short_stop":
			mode_timer.wait_time = 0.1
			direction_timer.wait_time = 0.1
			direction_timer.start()
			prev_speed = orbit_speed
			orbit_speed = 0
			print("short stop")
		"anti_aim":
			print("anti-aim")
			
func _process(delta: float) -> void:
	if current_mode == "anti_aim":
		update_anti_aim(delta)
	else:	
		#interpolate to avoid super sharp turns
		orbit_direction_current = lerp(orbit_direction_current, orbit_direction_target, delta * SHARPNESS)
		vertical_direction_current = lerp(vertical_direction_current, vertical_direction_target, delta * SHARPNESS)

		orbit_angle += orbit_direction_current * orbit_speed * delta
		vertical_angle += vertical_direction_current * vertical_speed * delta
		vertical_angle = clamp(vertical_angle, -MAX_VERTICAL_ANGLE, MAX_VERTICAL_ANGLE)

		if abs(vertical_angle) >= MAX_VERTICAL_ANGLE:
			vertical_direction_target *= -1

		var x = orbit_radius * sin(orbit_angle) * cos(vertical_angle)
		var y = orbit_radius * sin(vertical_angle)
		var z = orbit_radius * cos(orbit_angle) * cos(vertical_angle)

		global_position = player.global_position + Vector3(x, y, z)

func _on_direction_timer_timeout():
	if randf() < 0.5:
		orbit_direction_target = -1.0
	else:
		orbit_direction_target = 1.0

	#vertical change tries to avoid getting stuck above or below player
	var bias_threshold = 1.0 #radians, 60 deg = about 1rad
	var bias_strength = 0.7 #probability to push away from limit
	
	#print(vertical_angle)
	
	if vertical_angle > MAX_VERTICAL_ANGLE - bias_threshold: #near upper limit, pulling down
		#print("NEAR UPPER LIMIT")	
		if randf() < bias_strength:
			vertical_direction_target = -1.0
		else:
			vertical_direction_target = 1.0
	elif vertical_angle < -MAX_VERTICAL_ANGLE + bias_threshold:  #near lower limit, pulling down
		#print("NEAR LOWER LIMIT")	
		if randf() < bias_strength:
			vertical_direction_target = 1.0
		else:
			vertical_direction_target = -1.0
	else: #normal 50/50 direction change
		if randf() < 0.5:
			vertical_direction_target = 1.0
		else:
			vertical_direction_target = -1.0

func update_anti_aim(delta: float) -> void:
	var mouse_dir: Vector2 = player.cache_average
	var opposite: Vector2 = -mouse_dir.normalized()
	
	orbit_direction_target = opposite.x
	vertical_direction_target = opposite.y

	orbit_direction_current = lerp(orbit_direction_current, orbit_direction_target, delta * SHARPNESS)
	vertical_direction_current = lerp(vertical_direction_current, vertical_direction_target, delta * SHARPNESS)

	orbit_angle += orbit_direction_current * orbit_speed * delta * 2
	vertical_angle += vertical_direction_current * vertical_speed * delta * 2
	vertical_angle = clamp(vertical_angle, -MAX_VERTICAL_ANGLE, MAX_VERTICAL_ANGLE)

	update_position()
	
func update_position():
	var x = orbit_radius * sin(orbit_angle) * cos(vertical_angle)
	var y = orbit_radius * sin(vertical_angle)
	var z = orbit_radius * cos(orbit_angle) * cos(vertical_angle)

	global_position = player.global_position + Vector3(x, y, z)

func weighted_random_choice(weights: Dictionary) -> String:
	var total_weight = 0.0
	for weight in weights.values():
		total_weight += weight

	var r = randf() * total_weight
	var cumulative = 0.0
	for key in weights.keys():
		cumulative += weights[key]
		if r <= cumulative:
			return key
	return weights.keys()[0] # fallback
