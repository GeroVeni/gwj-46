extends Node2D


func _on_boss_entry_body_entered(_body: Node2D):
	if not GameData.current_boss:
		GameData.current_boss = $Boss
		$Boss.start_fight()
