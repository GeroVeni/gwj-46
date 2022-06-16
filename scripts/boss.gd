extends CharacterBody2D


enum AttackType {
	SIMPLE_ATTACK,
	EXPLODING_ATTACK,
	REVIVE_MUMMIES,
	ORB_SHOWER,
	BEAM
}

enum State {
	INACTIVE,
	IDLE,
	CASTING
}

@export var walk_speed: = 100.0
@export var orb_follow_factor: = 4.0

@export var max_health: = 1000.0

# random bag

# internal ability cooldown reduced by health of boss
# boss moves slowly towards player - stops while casting abiltities
# simple attack: projectile - high speed straight line
# abilities have cast time

@export var ability_cooldown: = 3
@export var min_ability_cooldown: = 1

@export_node_path var target_path

@onready var health: = max_health
@onready var orb_position = $OrbPosition
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var casting_timer: Timer = $CastingTimer

@onready var target = get_node(target_path)

var ability_target: Vector2

var simple_attack_state: = 0
var simple_attack_range: = 800.0
var simple_attack_speed: = 400.0

var state: State = State.INACTIVE:
	set(value):
		if state != value:
			print("Changing state %s" % state)
		state = value

var phase_transitions = {
	3: 0.333,
	2: 0.666,
	1: 1.0
}

var current_ability: AttackType
var random_abilities_bag: Array = []
var default_bag_counts = {
	AttackType.SIMPLE_ATTACK: 7,
	AttackType.EXPLODING_ATTACK: 4,
	AttackType.REVIVE_MUMMIES: 2,
	AttackType.ORB_SHOWER: 3,
	AttackType.BEAM: 4
}

func get_random_ability():
	if random_abilities_bag.size() == 0:
		for type in default_bag_counts:
			for i in default_bag_counts[type]:
				random_abilities_bag.push_back(type)
		random_abilities_bag.shuffle()
	return random_abilities_bag.pop_back()


var orb: Node2D

func get_phase():
	for p in phase_transitions:
		if health <= phase_transitions[p] * max_health:
			return p

func update_ability_cooldown():
	ability_cooldown = 4 - get_phase()

func _ready():
	orb = get_node("../BossOrb")
	orb.global_position = orb_position.global_position
	cooldown_timer.timeout.connect(on_cooldown_timer_timeout)
	casting_timer.timeout.connect(on_casting_timer_timeout)

func on_cooldown_timer_timeout():
	print("cooldown timeout")
	cooldown_timer.stop()
	# current_ability = get_random_ability()
	current_ability = AttackType.SIMPLE_ATTACK
	start_casting_ability()
	print("Casting %s" % current_ability)
	state = State.CASTING

func on_casting_timer_timeout():
	print("cast timeout")
	casting_timer.stop()

func get_health() -> float:
	return health

func start_fight():
	state = State.IDLE
	cooldown_timer.start(ability_cooldown)

func _process(_delta):
	pass

func get_target_direction() -> Vector2:
		return (target.global_position - global_position).normalized()

func start_casting_ability():
	print("starting casting %s" % current_ability)
	if current_ability == AttackType.SIMPLE_ATTACK:
		simple_attack_state = 0
		ability_target = get_target_direction() * simple_attack_range

func update_ability_cast(delta: float):
	if current_ability == AttackType.SIMPLE_ATTACK:
		if simple_attack_state == 0:
			orb.global_position = orb.global_position.move_toward(ability_target, simple_attack_speed * delta)
			if orb.global_position.distance_to(ability_target) < 1:
				print("orb returning")
				simple_attack_state = 1
		else:
			orb.global_position = orb.global_position.move_toward(orb_position.global_position, simple_attack_speed * delta)
			print(orb.global_position)
			print(orb_position.global_position)
			if orb.global_position.distance_to(orb_position.global_position) < 1:
				print("orb returned")
				simple_attack_state = 0
				state = State.IDLE

func _physics_process(delta):
	print("State %s" % state)
	if state == State.IDLE:
		orb.global_position = orb.global_position.lerp(orb_position.global_position, orb_follow_factor * delta)
		velocity = get_target_direction() * walk_speed
		move_and_slide()
	elif state == State.CASTING:
		update_ability_cast(delta)
