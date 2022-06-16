extends TextureProgressBar


# Called when the node enters the scene tree for the first time.
func _ready():
	value = GameData.life_force
	GameData.life_force_changed.connect(on_life_force_changed)

func on_life_force_changed(p_value):
	value = p_value
