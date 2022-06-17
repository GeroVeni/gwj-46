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

var exploding_attack_state: = 0
var exploding_attack_travel_speed: = 400.0
var exploding_attack_explosion_range: = 800.0
var exploding_attack_charge_time: = 1.0

var revive_mummies_state: = 0
var revive_mummies_casttime: = 1.5

@export var orb_shower_total_shots: = 20
@export var orb_shower_shots_per_round: = 5
@export var orb_shower_round_duration: = 0.5
@export var orb_shower_fall_duration: = 1.0
var orb_shower_state: = 0
var orb_shower_round: = 0


var state: State = State.INACTIVE:
	set(value):
		if state != value:
			print("Changing state %s" % value)
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
	print("Casting %s" % current_ability)
	cooldown_timer.stop()
	# current_ability = get_random_ability()
	current_ability = AttackType.ORB_SHOWER
	start_casting_ability()
	state = State.CASTING

func on_casting_timer_timeout():
	print("cast timeout")
	casting_timer.stop()
	if current_ability == AttackType.EXPLODING_ATTACK:
		if exploding_attack_state == 1:
			exploding_attack_state = 2
			orb.explosion_indicator_visible = false
			orb.explosion_indicator_progress = 0
	if current_ability == AttackType.REVIVE_MUMMIES:
		if revive_mummies_state == 1:
			print("mummies revived")
			revive_mummies_state = 2

func get_health() -> float:
	return health

func start_fight():
	state = State.IDLE
	cooldown_timer.start(ability_cooldown)

func _process(_delta):
	update_ability_cooldown()

func get_target_direction() -> Vector2:
		return (target.global_position - global_position).normalized()

func get_target_distance() -> float:
		return (target.global_position - global_position).length()

func start_casting_ability():
	print("starting casting %s" % current_ability)
	if current_ability == AttackType.SIMPLE_ATTACK:
		simple_attack_state = 0
		ability_target = orb.global_position + simple_attack_range * (target.global_position - orb.global_position).normalized()
	elif current_ability == AttackType.EXPLODING_ATTACK:
		exploding_attack_state = 0
		ability_target = target.global_position
	elif current_ability == AttackType.REVIVE_MUMMIES:
		revive_mummies_state = 0

func update_ability_cast(delta: float):
	if current_ability == AttackType.SIMPLE_ATTACK:
		if simple_attack_state == 0:
			orb.global_position = orb.global_position.move_toward(ability_target, simple_attack_speed * delta)
			if orb.global_position.distance_to(ability_target) < 1:
				print("orb returning")
				simple_attack_state = 1
		else:
			orb.global_position = orb.global_position.move_toward(orb_position.global_position, simple_attack_speed * delta)
			if orb.global_position.distance_to(orb_position.global_position) < 1:
				print("orb returned")
				simple_attack_state = 0
				state = State.IDLE
				cooldown_timer.start(ability_cooldown)
	elif current_ability == AttackType.EXPLODING_ATTACK:
		if exploding_attack_state == 0:
			orb.global_position = orb.global_position.move_toward(ability_target, simple_attack_speed * delta)
			if orb.global_position.distance_to(ability_target) < 1:
				print("orb reached explosion point")
				exploding_attack_state = 1
				orb.explosion_indicator_progress = 0.0
				orb.explosion_indicator_visible = true
				casting_timer.start(exploding_attack_charge_time)
		elif exploding_attack_state == 1:
			orb.explosion_indicator_progress = (exploding_attack_charge_time - casting_timer.time_left) / exploding_attack_charge_time
		elif exploding_attack_state == 2:
			# TODO: Blow up
			exploding_attack_state = 3
		else:
			orb.global_position = orb.global_position.move_toward(orb_position.global_position, simple_attack_speed * delta)
			if orb.global_position.distance_to(orb_position.global_position) < 1:
				print("orb returned")
				exploding_attack_state = 0
				state = State.IDLE
				cooldown_timer.start(ability_cooldown)
	elif current_ability == AttackType.REVIVE_MUMMIES:
		if revive_mummies_state == 0:
			print("mummies reviving...")
			casting_timer.start(revive_mummies_casttime)
			revive_mummies_state = 1
		elif revive_mummies_state == 1:
			pass # casting
		elif revive_mummies_state == 2:
			revive_mummies_state = 0
			state = State.IDLE
			cooldown_timer.start(ability_cooldown)


func _physics_process(delta):
	if state == State.IDLE:
		orb.global_position = orb.global_position.lerp(orb_position.global_position, orb_follow_factor * delta)
		if get_target_distance() > 10:
			velocity = get_target_direction() * walk_speed
			move_and_slide()
	elif state == State.CASTING:
		update_ability_cast(delta)
