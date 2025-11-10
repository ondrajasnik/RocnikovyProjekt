extends CanvasLayer

var player = null

@onready var hp_label = $CenterContainer/PanelContainer/HBoxContainer/RightSide/StatsContainer/HPLabel
@onready var hp_regen_label = $CenterContainer/PanelContainer/HBoxContainer/RightSide/StatsContainer/HPRegenLabel
@onready var damage_label = $CenterContainer/PanelContainer/HBoxContainer/RightSide/StatsContainer/DamageLabel
@onready var projectiles_label = $CenterContainer/PanelContainer/HBoxContainer/RightSide/StatsContainer/ProjectilesLabel
@onready var attack_speed_label = $CenterContainer/PanelContainer/HBoxContainer/RightSide/StatsContainer/AttackSpeedLabel
@onready var move_speed_label = $CenterContainer/PanelContainer/HBoxContainer/RightSide/StatsContainer/MoveSpeedLabel
@onready var defense_label = $CenterContainer/PanelContainer/HBoxContainer/RightSide/StatsContainer/DefenseLabel
@onready var lifesteal_label = $CenterContainer/PanelContainer/HBoxContainer/RightSide/StatsContainer/LifestealLabel
@onready var luck_label = $CenterContainer/PanelContainer/HBoxContainer/RightSide/StatsContainer/LuckLabel

@onready var resume_button = $CenterContainer/PanelContainer/HBoxContainer/LeftSide/ResumeButton
@onready var settings_button = $CenterContainer/PanelContainer/HBoxContainer/LeftSide/SettingsButton
@onready var exit_button = $CenterContainer/PanelContainer/HBoxContainer/LeftSide/ExitButton

func _ready():
    player = get_tree().root.find_child("PlayerMage", true, false)
    
    resume_button.pressed.connect(_on_resume_pressed)
    settings_button.pressed.connect(_on_settings_pressed)
    exit_button.pressed.connect(_on_exit_pressed)

func _input(event):
    if event.is_action_pressed("ui_cancel"):  # ESC key
        if visible:
            hide_pause_menu()
        else:
            show_pause_menu()

func show_pause_menu():
    visible = true
    Engine.time_scale = 0.0
    update_stats()

func hide_pause_menu():
    visible = false
    Engine.time_scale = 1.0

func update_stats():
    if not player or not is_instance_valid(player):
        return
    
    hp_label.text = "Max HP: " + str(player.max_hp)
    hp_regen_label.text = "HP Regen: " + str(player.hp_regen) + "/s"
    damage_label.text = "Damage: " + str(player.damage)
    projectiles_label.text = "Projectiles: " + str(player.projectile_count)
    attack_speed_label.text = "Attack Speed: " + str(player.attack_speed) + "/s"
    move_speed_label.text = "Move Speed: " + str(player.move_speed)
    defense_label.text = "Defense: " + str(int(player.defense * 100)) + "%"
    lifesteal_label.text = "Lifesteal: " + str(int(player.lifesteal * 100)) + "%"
    luck_label.text = "Luck: " + str(player.luck) + "x"

func _on_resume_pressed():
    hide_pause_menu()

func _on_settings_pressed():
    print("Settings button pressed - not implemented yet")

func _on_exit_pressed():
    # Obnov time scale před změnou scény
    Engine.time_scale = 1.0
    # Vrať se do main menu
    get_tree().change_scene_to_file("res://scenes/main_menu.tscn")