extends CharacterBody2D

@export var walk_speed: = 300.0
@export var dash_cooldown: = 4.0
@export var dash_speed: = 1000.0
@export var dash_duration: = 0.2

@export var attack_orb_path: NodePath

@onready var dash_timer: Timer = $DashTimer
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer

var attack_orb: Node2D

var speed_modifier: = 1.0
var dash_direction: = Vector2.UP
var dashing: = false
var dashing_ready: = true

var global_cooldown: = 1.0

var attack_1_cooldown: = 5.0
var attack_1: = false
var attack_1_range: = 300.0

var attack_2: = false
var attack_2_shards: = {
	1: 1.5,
	2: 2.5,
	5: 7200.0
}
var attack_2_hold_duration: = 0.0

func attacking() -> bool:
	return attack_1 || attack_2

func on_attack_finish():
	print("attack finished")
	attack_1 = false

func _ready():
		dash_timer.timeout.connect(on_dash_ended)
		dash_cooldown_timer.timeout.connect(on_dash_cooldown_ended)

		# $IdleOrb.position = $OrbPosition.position
		attack_orb = get_node(attack_orb_path)
		attack_orb.global_position = $OrbPosition.global_position
		attack_orb.idle_position = $OrbPosition
		attack_orb.attack_finished.connect(on_attack_finish)

func on_dash_ended():
	dash_timer.stop()
	dashing = false
	print("dash cd started")
	dash_cooldown_timer.start(dash_cooldown)

func on_dash_cooldown_ended():
	dash_cooldown_timer.stop()
	dashing_ready = true
	print("dash ready")

func get_attack_2_orb_count(elapsed_time: float) -> int:
	for shard_count in attack_2_shards:
		if attack_2_shards[shard_count] > elapsed_time:
			return shard_count
	return 5

func _process(delta):
	if attack_2:
		attack_2_hold_duration += delta

	if !attacking() && Input.is_action_just_pressed("attack_1"):
		attack_1 = true
		var direction = (get_global_mouse_position() - global_position).normalized()
		attack_orb.attack_1(global_position + direction * attack_1_range)
	elif !attacking() && Input.is_action_just_pressed("attack_2"):
		attack_2 = true
		attack_2_hold_duration = 0
		speed_modifier = 0.35
		attack_orb.start_attack_2()
	elif attack_2 && Input.is_action_just_released("attack_2"):
		speed_modifier = 1
		attack_2 = false
		attack_orb.send_attack_2(get_global_mouse_position())

	if attack_2:
		attack_orb.update_attack_2(get_attack_2_orb_count(attack_2_hold_duration))

func _physics_process(_delta):
	var dash_pressed = Input.is_action_just_pressed("dash")

	rotation = fmod((get_global_mouse_position() - global_position).angle() + PI / 2, 360)

	if dashing_ready && dash_pressed:
		dashing_ready = false
		dashing = true
		dash_timer.start(dash_duration)

	var direction = dash_direction
	var speed = dash_speed
	if !dashing:
		direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		speed = walk_speed

	if direction:
		dash_direction = direction
		velocity = speed_modifier * direction * speed
	else:
		velocity = velocity.move_toward(Vector2(), speed)

	move_and_slide()
