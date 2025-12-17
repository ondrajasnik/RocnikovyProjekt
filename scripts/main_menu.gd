extends Control

const ChestScript = preload("res://scripts/chest.gd")

@onready var play_button = $CenterContainer/VBoxContainer/PlayButton
@onready var settings_button = $CenterContainer/VBoxContainer/SettingsButton
@onready var leaderboard_button = $CenterContainer/VBoxContainer/LeaderboardButton
@onready var exit_button = $CenterContainer/VBoxContainer/ExitButton
@onready var player_name_label = $ProfileContainer/PlayerNameLabel
@onready var log_off_button = $ProfileContainer/LogOffButton

var name_popup_scene = preload("res://scenes/name_input_popup.tscn")
var leaderboard_popup_scene = preload("res://scenes/leaderboard_popup.tscn")
var settings_popup_scene = preload("res://scenes/settings_popup.tscn")

var background_music: AudioStreamPlayer

func _ready():
	# Reset chest counter při návratu
	if has_node("/root/Chest"):  # Pokud existuje Chest autoload
		get_node("/root/Chest").reset_global_counter()
	
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	leaderboard_button.pressed.connect(_on_leaderboard_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	log_off_button.pressed.connect(_on_log_off_pressed)
	
	_update_profile_display()
	_setup_background_music()

func _setup_background_music():
	background_music = AudioStreamPlayer.new()
	background_music.name = "BackgroundMusic"
	add_child(background_music)
	
	# Načti MP3 a nastav loop
	var audio_stream = load("res://audio/music/main_menu_music.mp3")
	
	# Pro MP3 musíš nastavit loop přes AudioStreamMP3
	if audio_stream is AudioStreamMP3:
		audio_stream.loop = true  # ← TADY!
	
	background_music.stream = audio_stream
	background_music.bus = "Music"
	background_music.volume_db = 0
	background_music.play()
	
	print("Background music playing on loop!")

func _update_profile_display():
	if PlayerProfile.is_player_registered():
		player_name_label.text = PlayerProfile.get_player_name()
		log_off_button.visible = true
	else:
		player_name_label.text = "Guest"
		log_off_button.visible = false

func _on_play_pressed():
	# Reset chest pricing - SPRÁVNĚ!
	ChestScript.chests_opened = 0  # ← Přímo nastav static var!
	
	print("🔄 New game - chest counter reset to 0")
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _show_name_input_popup():
	var popup = name_popup_scene.instantiate()
	add_child(popup)
	popup.name_confirmed.connect(_on_name_confirmed)

func _on_name_confirmed(player_name: String):
	print("Name confirmed: ", player_name)
	_update_profile_display()
	await get_tree().create_timer(0.5).timeout
	_start_game()

func _on_log_off_pressed():
	var confirm_dialog = ConfirmationDialog.new()
	confirm_dialog.dialog_text = "Are you sure you want to log off?"
	confirm_dialog.title = "Log Off"
	confirm_dialog.ok_button_text = "Yes"
	confirm_dialog.cancel_button_text = "No"
	
	add_child(confirm_dialog)
	confirm_dialog.confirmed.connect(_confirm_log_off)
	confirm_dialog.popup_centered()

func _confirm_log_off():
	PlayerProfile.clear_profile()
	_update_profile_display()
	print("Logged off successfully")

func _start_game():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_settings_pressed():
	var popup = settings_popup_scene.instantiate()
	add_child(popup)

func _on_leaderboard_pressed():
	var popup = leaderboard_popup_scene.instantiate()
	add_child(popup)

func _on_exit_pressed():
	get_tree().quit()
