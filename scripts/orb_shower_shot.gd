extends Node2D

@export var fall_indicator_radius = 200.0
@export var fall_distance: = 1000.0

@onready var fall_indicator_mesh = $FallIndicator
@onready var fall_indicator_background = $FallIndicatorBackground
@onready var fall_direction_position: Position2D = $FallDirection
@onready var fall_sprite: Node2D = $OrbShot

@export var fall_indicator_visible = false:
	set(value):
		fall_indicator_visible = value
		if fall_indicator_mesh:
			fall_indicator_mesh.visible = value
			fall_indicator_background.visible = value
			fall_sprite.visible = value

@export var fall_indicator_progress: = 0.0:
	set(value):
		fall_indicator_progress = clamp(value, 0, 1)
		if fall_indicator_mesh:
			var radius = fall_indicator_radius * fall_indicator_progress
			fall_indicator_mesh.scale = Vector2(radius, radius)
			fall_sprite.position = fall_direction * fall_distance * (1.0 - fall_indicator_progress)

var fall_direction: Vector2
var fall_duration: float
var active = false

func _ready():
	fall_indicator_background.scale = Vector2(fall_indicator_radius, fall_indicator_radius)
	fall_indicator_progress = 0
	fall_indicator_visible = false
	fall_direction = fall_direction_position.position.normalized()
	activate(1.0)

func _process(delta):
	if active:
		fall_indicator_progress += delta / fall_duration

func explode():
	active = false
	fall_indicator_visible = false
	queue_free()

func activate(p_fall_duration: float):
	if active:
		return
	active = true
	fall_duration = p_fall_duration
	fall_indicator_visible = true
	fall_indicator_progress = 0
	get_tree().create_timer(fall_duration).timeout.connect(explode)
