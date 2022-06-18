extends Node2D

@export_node_path(CharacterBody2D) var player_body_path
@onready var player_body = get_node(player_body_path)
@export var respawn_time = 5.0
@onready var respawn_timer: Timer = $Respawn_timer
@export var healing_value = 50.0
var rng = RandomNumberGenerator.new()
var my_random_x = 0.0
var my_random_y = 0.0
func _ready():
	rng.randomize()
	my_random_x = rng.randf_range(-500, 500)
	my_random_y = rng.randf_range(-500, 500)	



func _on_respawn_timer_timeout():
	global_position += Vector2(my_random_x, my_random_y)
	$AnimatedSprite2D.show()


func _on_healing_artifact_body_entered(body):
	print(body)
	print(player_body)
	if body==player_body: ### ASK veni
		
		GameData.life_force += healing_value
		if GameData.life_force > 100:
			GameData.life_force = 100
		respawn_timer.start(respawn_time)
		$AnimatedSprite2D.hide()
	else: global_position += Vector2(my_random_x, my_random_y)
		
