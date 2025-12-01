extends Node

const SAVE_PATH = "user://game_settings.json"

# Audio settings
var master_volume: float = 1.0
var music_volume: float = 1.0
var sfx_volume: float = 1.0

func _ready():
    load_settings()
    apply_audio_settings()

func apply_audio_settings():
    # Nastav audio bus volumes
    var master_idx = AudioServer.get_bus_index("Master")
    var music_idx = AudioServer.get_bus_index("Music")
    var sfx_idx = AudioServer.get_bus_index("SFX")
    
    if master_idx >= 0:
        AudioServer.set_bus_volume_db(master_idx, linear_to_db(master_volume))
    
    if music_idx >= 0:
        AudioServer.set_bus_volume_db(music_idx, linear_to_db(music_volume))
    
    if sfx_idx >= 0:
        AudioServer.set_bus_volume_db(sfx_idx, linear_to_db(sfx_volume))

func save_settings():
    var data = {
        "master_volume": master_volume,
        "music_volume": music_volume,
        "sfx_volume": sfx_volume
    }
    
    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(data))
        file.close()
        print("Settings saved!")

func load_settings():
    if not FileAccess.file_exists(SAVE_PATH):
        print("No settings file found, using defaults")
        return
    
    var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file:
        var json_string = file.get_as_text()
        file.close()
        
        var json = JSON.new()
        var error = json.parse(json_string)
        
        if error == OK:
            var data = json.data
            master_volume = data.get("master_volume", 1.0)
            music_volume = data.get("music_volume", 1.0)
            sfx_volume = data.get("sfx_volume", 1.0)
            print("Settings loaded!")