extends Node3D

@onready var camera = $Camera3D
@onready var ray = $Camera3D/RayCast3D

var mouse_sensitivity := 0.002
var rotation_x := 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)

		rotation_x = clamp(rotation_x - event.relative.y * mouse_sensitivity, deg_to_rad(-90), deg_to_rad(90))
		camera.rotation.x = rotation_x

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		shoot()
		print("shoot")

func shoot():
	ray.force_raycast_update()
	if ray.is_colliding():
		var hit = ray.get_collider()
		print("Hit", hit)
