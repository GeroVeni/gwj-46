extends Camera2D


@export var decay = 0.8  # How quickly the shaking stops [0, 1].
@export var max_offset = Vector2(10, 7.5)  # Maximum hor/ver shake in pixels.
@export var max_roll = 0.1  # Maximum rotation in radians (use sparingly).
@export var target: NodePath  # Assign the node this camera will follow.

var trauma = 0.0  # Current shake strength.
var trauma_power = 2  # Trauma exponent. Use [2, 3].


func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)


func shake():
	var amount = pow(trauma, trauma_power)
	rotation = max_roll * amount * randf_range(-1, 1)
	offset.x = max_offset.x * amount * randf_range(-1, 1)
	offset.y = max_offset.y * amount * randf_range(-1, 1)


func _ready():
	randomize()


func _process(delta):
	if Input.is_action_just_pressed("low_trauma"):
		add_trauma(0.4)
	if Input.is_action_just_pressed("high_trauma"):
		add_trauma(0.8)
	if target:
		global_position = get_node(target).global_position
	if trauma:
		print(trauma)
		trauma = max(trauma - decay * delta, 0)
		shake()
