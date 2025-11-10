extends CanvasLayer

@onready var health_bar_full = $HealthBarContainer/HealthBarFull
@onready var health_bar_empty = $HealthBarContainer/HealthBarEmpty
@onready var health_text = $HealthBarContainer/HealthText
@onready var level_label = $LevelContainer/LevelLabel
@onready var gold_label = $GoldContainer/GoldLabel
@onready var kills_label = $KillsContainer/KillsLabel
@onready var time_label = $TimeLabel
@onready var pause_button = $PauseButton

var player = null
var max_bar_width = 164.0
var pause_menu = null

func _ready():
	player = get_tree().root.find_child("PlayerMage", true, false)
	pause_menu = get_tree().root.find_child("PauseMenu", true, false)
	
	# Připoj tlačítko pauzy
	pause_button.pressed.connect(_on_pause_button_pressed)

func _process(delta):
	if player and is_instance_valid(player):
		_update_health_bar()
		_update_level_display()
		_update_gold_display()
		_update_kills_display()
		_update_time_display()

func _update_health_bar():
	if not player or not is_instance_valid(player):
		return
	
	var display_hp = player.current_hp
	if display_hp < 0:
		display_hp = 0
	
	var missing_health_percent = 1.0 - (float(display_hp) / float(player.max_hp))
	
	var empty_width = max_bar_width * missing_health_percent
	health_bar_empty.size.x = empty_width
	health_bar_empty.position.x = -141.0 + (max_bar_width - empty_width)
	
	health_text.text = str(display_hp) + " / " + str(player.max_hp)

func _update_level_display():
	level_label.text = "LVL " + str(player.level)

func _update_gold_display():
	gold_label.text = str(player.gold)

func _update_kills_display():
	kills_label.text = "KILLS: " + str(player.kills)

func _update_time_display():
	var time = player.survival_time
	var minutes = int(time / 60)
	var seconds = int(time) % 60
	time_label.text = "TIME: %02d:%02d" % [minutes, seconds]

func _on_pause_button_pressed():
	if pause_menu:
		pause_menu.show_pause_menu()
