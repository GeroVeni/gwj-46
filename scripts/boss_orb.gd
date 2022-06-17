extends Area2D

@export var explosion_indicator_radius = 350.0

var explosion_indicator_visible = false:
	set(value):
		explosion_indicator_visible = value
		explosion_indicator_mesh.visible = value
		explosion_indicator_background.visible = value

var explosion_indicator_progress: = 0.0:
	set(value):
		explosion_indicator_progress = clamp(value, 0, 1)
		var radius = explosion_indicator_radius * explosion_indicator_progress
		explosion_indicator_mesh.scale = Vector2(radius, radius)

@onready var explosion_indicator_mesh = $ExplosionIndicator
@onready var explosion_indicator_background = $ExplosionIndicatorBackground

func _ready():
	explosion_indicator_background.scale = Vector2(explosion_indicator_radius, explosion_indicator_radius)
	explosion_indicator_progress = 1
	explosion_indicator_visible = false
