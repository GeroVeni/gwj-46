extends Area2D

@onready var trap_timer: Timer = $TrapTimer
@export var activation_time := 0.5
@export var trap_cooldown_time := 3.0
@export var default_color = Color(0, 0, 0)
@export var warning_color = Color(1, 0.6, 0)
@export var activation_color = Color(1, 0, 0)
@export_enum(Enter, Exit) var portalType
var trap_active = 0


func _on_spikes_body_entered(_body):
	if !trap_active:
		trap_timer.start(activation_time)
		$MeshInstance2D.modulate = warning_color
		trap_active = 1


func _on_trap_timer_timeout():
	if trap_active:
		#trap_timer.stop()
		$MeshInstance2D.modulate = activation_color
		trap_timer.start(trap_cooldown_time)
		#trap_timer.stop()
		trap_active = 0
	else:
		$MeshInstance2D.modulate = default_color
		trap_timer.stop()




