extends AnimatableBody2D

@export var omega: = PI * 2
@export var rotation_radius: = 15.0
@export var flight_speed = 1200.0

var angle_offset: = 0.0
var time: float
var mult: float

var quat: Quaternion

var launched: = false
var direction: Vector2 = Vector2.UP

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	time = 0
	angle_offset = randf_range(0, 2 * PI)
	quat = Quaternion(
		randf_range(-1, 1),
		randf_range(-1, 1),
		randf_range(-1, 1),
		randf_range(0, 1)
	)
	quat = quat.normalized()
	mult = randf_range(-1, 1)
	if (mult < 0):
		mult = -1
	else:
		mult = 1


func launch(target_position: Vector2):
	launched = true
	direction = (target_position - global_position).normalized()


func _physics_process(delta):
	if !launched:
		time += delta
		var lat = mult * omega * time + angle_offset
		var position_3d = quat * Vector3(cos(lat), sin(lat), 0)
		position = rotation_radius * Vector2(position_3d.x, position_3d.y)
		z_index = int(sign(position_3d.z))
	else:
		global_position += flight_speed * delta * direction
