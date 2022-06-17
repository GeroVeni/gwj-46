@tool

extends Camera2D


@export var decay = 0.8  # How quickly the shaking stops [0, 1].
@export var max_offset = Vector2(100, 75)  # Maximum hor/ver shake in pixels.
@export var max_roll = 0.1  # Maximum rotation in radians (use sparingly).

@export var camera_smoothing: = 0.02
@export var movement_bias: = 30.0
@export var movement_bias_smoothing: = 0.1
@export var target_path: NodePath  # Assign the node this camera will follow.

@export var lookahead_bias: = 50.0

@export var deadzone_size: Vector2
@export var deadzone_offset: Vector2

@export var start_zoom: = 0.7
@export var min_zoom: = 0.4
@export var max_zoom: = 5.0
@export var zoom_factor: = 1.15

@onready var target: Node2D = get_node(target_path)
@onready var noise: FastNoiseLite = FastNoiseLite.new()
var noise_y = 0

var trauma = 0.0  # Current shake strength.
var trauma_power = 2  # Trauma exponent. Use [2, 3].

var movement_offset: = Vector2()


func _ready():
	randomize()
	noise.seed = randi()
	noise.frequency = 0.05
	noise.fractal_octaves = 2
	zoom = Vector2(start_zoom, start_zoom)


func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)

func draw_gizmos():
	if has_node("Line2D"):
		$Line2D.points = PackedVector2Array([
			Vector2(deadzone_offset.x - deadzone_size.x / 2, deadzone_offset.y - deadzone_size.y / 2),
			Vector2(deadzone_offset.x + deadzone_size.x / 2, deadzone_offset.y - deadzone_size.y / 2),
			Vector2(deadzone_offset.x + deadzone_size.x / 2, deadzone_offset.y + deadzone_size.y / 2),
			Vector2(deadzone_offset.x - deadzone_size.x / 2, deadzone_offset.y + deadzone_size.y / 2),
			Vector2(deadzone_offset.x - deadzone_size.x / 2, deadzone_offset.y - deadzone_size.y / 2),
		])
		$Line2D.hide()

func shake():
	var amount = pow(trauma, trauma_power)
	noise_y += 1
	rotation = max_roll * amount * noise.get_noise_2d(noise.seed, noise_y)
	offset.x = max_offset.x * amount * noise.get_noise_2d(noise.seed * 2, noise_y)
	offset.y = max_offset.y * amount * noise.get_noise_2d(noise.seed * 3, noise_y)

func _input(event):
	if event is InputEventMouseButton && event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom *= zoom_factor
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom /= zoom_factor
		zoom = clamp(zoom, Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))

func _process(delta):
	if Engine.is_editor_hint():
		draw_gizmos()
	else:
		if Input.is_action_just_pressed("low_trauma"):
			add_trauma(0.4)
		if Input.is_action_just_pressed("high_trauma"):
			add_trauma(0.8)
		if target_path:
			var target_movement_offset = Vector2()
			if target.velocity:
				target_movement_offset = target.velocity.normalized() * movement_bias
			movement_offset = movement_offset.lerp(target_movement_offset, movement_bias_smoothing)

			var lookahead_offset = lookahead_bias * (get_global_mouse_position() - target.global_position).normalized()
			global_position = global_position.lerp(target.global_position + movement_offset + lookahead_offset, camera_smoothing)
		if trauma:
			trauma = max(trauma - decay * delta, 0)
			shake()
