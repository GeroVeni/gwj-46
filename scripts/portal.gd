extends Area2D

@onready var portal_timer: Timer = $PortalTimer
@export var activation_time := 0.5
@export var entry_color = Color(0, 0.75, 1)
@export var exit_color = Color(1, 0.5, 0)
@export var activation_color = Color(0.5, 0.7, 0.9)
@export var is_entry = 0
@export_node_path(Area2D) var exit_portal_path
var exit_portal : Area2D
var trap_active = 0
var is_active = 0
var player_body : Node2D

func _process(delta):
	if player_body:
		if portal_timer.is_stopped():
			if player_body.velocity == Vector2() and is_active:
				portal_timer.start(activation_time)
				print("test")
			else:
				portal_timer.stop()



func _ready():
	if exit_portal_path:
		exit_portal = get_node(exit_portal_path)
	if is_entry:
		$MeshInstance2D.modulate = entry_color
	else:
		$MeshInstance2D.modulate = exit_color


func _on_portal_body_entered(body):
	if body.is_in_group("player"):
		player_body = body
		if is_entry:
			is_active = 1
			$MeshInstance2D.modulate = activation_color




func _on_portal_timer_timeout():
	player_body.global_position = exit_portal.global_position
	portal_timer.stop()
	player_body = null



func _on_portal_body_exited(body):
	is_active = 0
