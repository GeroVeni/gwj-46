extends Node

signal life_force_changed(life_force: float)

@export var max_life_force: = 100.0

var life_force: float:
	set(value):
		life_force = clamp(value, 0, max_life_force)
		life_force_changed.emit(life_force)

func _ready():
	self.life_force = 100
