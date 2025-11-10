extends CanvasLayer

@onready var time_label = $Panel/MarginContainer/VBoxContainer/TimeLabel
@onready var kills_label = $Panel/MarginContainer/VBoxContainer/KillsLabel
@onready var level_label = $Panel/MarginContainer/VBoxContainer/LevelLabel
@onready var exp_label = $Panel/MarginContainer/VBoxContainer/ExpLabel
@onready var gold_label = $Panel/MarginContainer/VBoxContainer/GoldLabel

@onready var damage_value = $Panel/MarginContainer/VBoxContainer/StatsGrid/DamageValue
@onready var attack_speed_value = $Panel/MarginContainer/VBoxContainer/StatsGrid/AttackSpeedValue
@onready var move_speed_value = $Panel/MarginContainer/VBoxContainer/StatsGrid/MoveSpeedValue
@onready var defense_value = $Panel/MarginContainer/VBoxContainer/StatsGrid/DefenseValue
@onready var lifesteal_value = $Panel/MarginContainer/VBoxContainer/StatsGrid/LifestealValue

@onready var restart_button = $Panel/MarginContainer/VBoxContainer/ButtonsContainer/RestartButton
@onready var exit_button = $Panel/MarginContainer/VBoxContainer/ButtonsContainer/ExitButton

var survival_time: float = 0.0

func _ready():
    restart_button.pressed.connect(_on_restart_pressed)
    exit_button.pressed.connect(_on_exit_pressed)

func show_game_over(player, time: float):
    visible = true
    get_tree().paused = true
    
    survival_time = time
    
    # Formátuj čas (minuty:sekundy)
    var minutes = int(time / 60)
    var seconds = int(time) % 60
    time_label.text = "Survival Time: %02d:%02d" % [minutes, seconds]
    
    # Score
    kills_label.text = "Kills: " + str(player.kills)
    
    # Statistics
    level_label.text = "Level: " + str(player.level)
    exp_label.text = "Total EXP: " + str(player.current_exp)
    gold_label.text = "Gold Collected: " + str(player.gold)
    
    # Player Stats
    damage_value.text = str(player.damage)
    attack_speed_value.text = str(player.attack_speed)
    move_speed_value.text = str(player.move_speed)
    defense_value.text = str(int(player.defense * 100)) + "%"
    lifesteal_value.text = str(int(player.lifesteal * 100)) + "%"

func _on_restart_pressed():
    get_tree().paused = false
    get_tree().reload_current_scene()

func _on_exit_pressed():
    get_tree().paused = false
    get_tree().change_scene_to_file("res://scenes/main_menu.tscn")