extends Area2D

@onready var my_animation = $Sprite2D
@onready var trap_timer: Timer = $TrapTimer
@export var activation_time := 0.5
@export var trap_cooldown_time := 3.0
@export var default_color = Color(0, 0, 0) 
@export var warning_color = Color(1, 0.6, 0)
@export var activation_color = Color(1, 0, 0)
@export var damage = 10.0
var trap_active = 0


func _ready():
	my_animation.play("spikes_down")
	
func _on_spikes_body_entered(body):
	if !trap_active:
		trap_timer.start(activation_time)
		my_animation.play("spikes_mid")
		trap_active = 1

func _on_trap_timer_timeout():
	if trap_active:
		#trap_timer.stop()
		my_animation.play("spikes_up")
		GameData.life_force -= damage
		trap_timer.start(trap_cooldown_time)
		#trap_timer.stop()
		trap_active = 0
	else:
		my_animation.play("spikes_down") 
		trap_timer.stop()




