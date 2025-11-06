extends Control

@onready var play_button = $CenterContainer/VBoxContainer/PlayButton
@onready var settings_button = $CenterContainer/VBoxContainer/SettingsButton
@onready var leaderboard_button = $CenterContainer/VBoxContainer/LeaderboardButton
@onready var exit_button = $CenterContainer/VBoxContainer/ExitButton

func _ready():
    # Připoj signály tlačítek
    play_button.pressed.connect(_on_play_pressed)
    settings_button.pressed.connect(_on_settings_pressed)
    leaderboard_button.pressed.connect(_on_leaderboard_pressed)
    exit_button.pressed.connect(_on_exit_pressed)

func _on_play_pressed():
    print("Starting game...")
    # Načti hlavní herní scénu
    get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_settings_pressed():
    print("Opening settings...")
    # TODO: Otevři settings menu
    pass

func _on_leaderboard_pressed():
    print("Opening leaderboard...")
    # TODO: Otevři leaderboard
    pass

func _on_exit_pressed():
    print("Exiting game...")
    get_tree().quit()