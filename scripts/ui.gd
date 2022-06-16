extends Control

@onready var boss_health_bar: = $Bossbar

func update_ui():
	var boss = GameData.current_boss
	boss_health_bar.visible = boss != null
	if boss and boss.has_method("get_health"):
		boss_health_bar.value = boss.get_health()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	update_ui()
