extends Node

signal life_force_changed(life_force: float)

@export var max_life_force: = 100.0

var life_force: float:
	set(value):
		life_force = clamp(value, 0, max_life_force)
		life_force_changed.emit(life_force)
		var test = Node2D.new()
		test.is_in_group("player")

var tmp: = 1.0
func _process(delta):
	print('test')
	life_force += tmp * delta * 50
	if life_force == max_life_force:
		tmp = -1
	elif life_force == 0:
		tmp = 1