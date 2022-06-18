extends Area2D

@export_node_path(StaticBody2D) var exit_wall_path
var exit_wall : StaticBody2D

func _ready():
	$AnimatedSprite2D.show()
	if exit_wall_path:
		exit_wall = get_node(exit_wall_path)

func _on_artifact_body_entered(body):
	$AnimatedSprite2D.hide()
	#if exit_wall:
		#if body.is_in_group("player"):
	print(exit_wall.global_position)
	exit_wall.global_position += Vector2(100, 0)
	print(exit_wall.global_position)
			#Play text exit is open
		
