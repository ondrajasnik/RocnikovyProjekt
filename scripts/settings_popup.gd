extends CanvasLayer

@onready var close_button = $CenterContainer/Panel/VBoxContainer/HeaderContainer/CloseButton
@onready var save_button = $CenterContainer/Panel/VBoxContainer/SaveButton
@onready var privacy_button = $CenterContainer/Panel/VBoxContainer/PrivacyButton

@onready var master_slider = $CenterContainer/Panel/VBoxContainer/AudioSection/MasterVolumeContainer/MasterSlider
@onready var music_slider = $CenterContainer/Panel/VBoxContainer/AudioSection/MusicContainer/MusicSlider
@onready var sfx_slider = $CenterContainer/Panel/VBoxContainer/AudioSection/SFXContainer/SFXSlider

@onready var master_label = $CenterContainer/Panel/VBoxContainer/AudioSection/MasterVolumeContainer/MasterLabel
@onready var music_label = $CenterContainer/Panel/VBoxContainer/AudioSection/MusicContainer/MusicLabel
@onready var sfx_label = $CenterContainer/Panel/VBoxContainer/AudioSection/SFXContainer/SFXLabel

func _ready():
    close_button.pressed.connect(_on_close_pressed)
    save_button.pressed.connect(_on_save_pressed)
    privacy_button.pressed.connect(_on_privacy_pressed)
    
    # Připoj slidery
    master_slider.value_changed.connect(_on_master_changed)
    music_slider.value_changed.connect(_on_music_changed)
    sfx_slider.value_changed.connect(_on_sfx_changed)
    
    # Načti uložené hodnoty
    _load_settings()

func _load_settings():
    # Načti z GameSettings (vytvoříme v dalším kroku)
    if GameSettings:
        master_slider.value = GameSettings.master_volume * 100
        music_slider.value = GameSettings.music_volume * 100
        sfx_slider.value = GameSettings.sfx_volume * 100
        
        _update_labels()

func _on_master_changed(value: float):
    master_label.text = "Master Volume: %d%%" % int(value)
    if GameSettings:
        GameSettings.master_volume = value / 100.0
        GameSettings.apply_audio_settings()

func _on_music_changed(value: float):
    music_label.text = "Music Volume: %d%%" % int(value)
    if GameSettings:
        GameSettings.music_volume = value / 100.0
        GameSettings.apply_audio_settings()

func _on_sfx_changed(value: float):
    sfx_label.text = "Sound Effects: %d%%" % int(value)
    if GameSettings:
        GameSettings.sfx_volume = value / 100.0
        GameSettings.apply_audio_settings()

func _update_labels():
    master_label.text = "Master Volume: %d%%" % int(master_slider.value)
    music_label.text = "Music Volume: %d%%" % int(music_slider.value)
    sfx_label.text = "Sound Effects: %d%%" % int(sfx_slider.value)

func _on_save_pressed():
    if GameSettings:
        GameSettings.save_settings()
    _on_close_pressed()

func _on_privacy_pressed():
    # Otevři Privacy Policy popup
    var privacy_popup = load("res://scenes/privacy_popup.tscn").instantiate()
    get_parent().add_child(privacy_popup)

func _on_close_pressed():
    queue_free()