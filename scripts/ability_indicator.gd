extends TextureProgressBar

@export var cooldown_timer_path: NodePath
@export var ability_name: String
@export var cooldown_duration: = 1.0

@onready var cooldown_timer: Timer = get_node(cooldown_timer_path)

func _ready():
	$AbilityName.text = ability_name

func _process(_delta):
	$RemainingTime.text = "%.1f" % cooldown_timer.time_left
	value = max_value * (cooldown_duration - cooldown_timer.time_left) / cooldown_duration
