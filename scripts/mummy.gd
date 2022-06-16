extends CharacterBody2D


@export var speed: = 200.0
@export var speed_modifier: = 1.0
@export var charge_multiplier: = 7.0
@export var charge_cooldown: = 2.0
@export var charge_duration: = 0.2
@export var charge_windup: = 1
@export var attack_cooldown: = 1.0
#@export var attack_damage: = 5.0
@export_node_path(CharacterBody2D) var player_path
@onready var player = get_node(player_path) 
var direction: = Vector2()
var charging = 0
var attacking = 0
var active = 0
var distance_from_player = 0.0
var preparing = 0
var off_cooldown = 1

func windup():
	$MeshInstance2D.modulate = Color(0, 0, 0)
	off_cooldown = 0
	preparing = 1
	speed_modifier = 0
	$charge_windup_timer.start(charge_windup)
	direction = (player.global_position - global_position).normalized()
	velocity = speed_modifier * speed * direction

	
func charge():
	$MeshInstance2D.modulate = Color(0, 0 , 1)
	charging = 1
	preparing = 0
	$charge_windup_timer.stop()
	$charge_duration_timer.start(charge_duration)
	speed_modifier = charge_multiplier
	velocity = speed_modifier * speed * direction
	
	
func just_charged():
	charging = 0
	$charge_duration_timer.stop()
	$charge_cooldown_timer.start(charge_cooldown)
	speed_modifier = 1
	velocity = speed_modifier * speed * direction
	
func _ready():
	$charge_windup_timer.timeout.connect(charge)
	$charge_duration_timer.timeout.connect(just_charged)
	$charge_cooldown_timer.timeout.connect(func():
		off_cooldown = 1
		$charge_cooldown_timer.stop())
	
func _physics_process(_delta):
	if !charging and !preparing:
		$MeshInstance2D.modulate = Color(1, 0 , 0)		
		direction = (player.global_position - global_position).normalized()
		velocity = speed_modifier * speed * direction
	distance_from_player = (player.global_position - global_position).length()
	if (distance_from_player <= charge_multiplier * speed * charge_duration) and off_cooldown:
		windup()
	move_and_slide()
	
