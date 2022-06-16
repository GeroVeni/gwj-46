extends AnimatableBody2D

enum FlyingMode {
	IDLE,
	GOING,
	RETURNING
}

enum AttackMode {
	IDLE,
	ATTACK_1,
	ATTACK_2
}

signal attack_finished

@export var travel_curve: Curve
@export var orb_speed: = 1000.0
@export var travel_duration: = 0.4

@export var mini_orb_scene: PackedScene = preload("res://scenes/mini_orb.tscn")

var player: Node2D

var flying: = FlyingMode.IDLE

var target_position: Vector2
var start_position: Vector2
var start_timer: = 0.0

var attack_mode: = AttackMode.IDLE

var attack_2_mini_orb_count: = 0
var attack_2_mini_orbs: Array[Node] = []
var attack_2_launching = false
var mini_orb_launch_cooldown: = 0.05

var idle_position: Position2D

func _ready():
	$MiniOrbLaunchTimer.timeout.connect(on_mini_orb_launch_ready)

func attack_1(p_target_position: Vector2):
	print(p_target_position)
	flying = FlyingMode.GOING
	target_position = p_target_position
	start_position = global_position
	start_timer = 0

func generate_orb():
	var mini_orb = mini_orb_scene.instantiate()
	print(mini_orb)
	attack_2_mini_orbs.append(mini_orb)
	if player:
		player.add_child(mini_orb)

func start_attack_2():
	attack_mode = AttackMode.ATTACK_2
	attack_2_mini_orb_count = 1
	generate_orb()

func update_attack_2(orb_count: int) -> bool:
	var extra_mini_orbs = orb_count - attack_2_mini_orb_count
	attack_2_mini_orb_count = orb_count
	if !extra_mini_orbs:
		return false
	print("Generating %d orbs" % extra_mini_orbs)
	print(mini_orb_scene)
	for i in extra_mini_orbs:
		generate_orb()
	return true

func on_mini_orb_launch_ready():
	$MiniOrbLaunchTimer.stop()
	launch_mini_orb()

func send_attack_2(p_target_position):
	target_position = p_target_position
	launch_mini_orb()

func launch_mini_orb():
	# Launch orb
	var orb_to_launch = attack_2_mini_orbs.pop_back()
	orb_to_launch.launch(target_position)
	if attack_2_mini_orbs.size() > 0:
		$MiniOrbLaunchTimer.start(mini_orb_launch_cooldown)

func _process(delta):
	if flying == FlyingMode.GOING:
		start_timer += delta
		start_timer = clamp(start_timer, 0, travel_duration)
		var travel_progress = start_timer
		var progress = travel_curve.interpolate(travel_progress / travel_duration)
		global_position = start_position + progress * (target_position - start_position)
		if start_timer == travel_duration:
			flying = FlyingMode.RETURNING
	else:
		global_position = global_position.lerp(idle_position.global_position, 4 * delta)
		if flying == FlyingMode.RETURNING && (global_position - idle_position.global_position).length() < 80:
			# global_position = idle_position.global_position
			flying = FlyingMode.IDLE
			attack_finished.emit()
