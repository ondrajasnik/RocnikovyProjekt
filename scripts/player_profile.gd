extends Node

const SAVE_PATH = "user://player_profile.json"

var player_name: String = ""
var is_registered: bool = false

func _ready():
    load_profile()

func set_player_name(name: String):
    player_name = name
    is_registered = true
    save_profile()
    print("Player name saved: ", player_name)

func get_player_name() -> String:
    return player_name

func is_player_registered() -> bool:
    return is_registered and player_name != ""

func save_profile():
    var data = {
        "player_name": player_name,
        "is_registered": is_registered
    }
    
    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(data))
        file.close()

func load_profile():
    if not FileAccess.file_exists(SAVE_PATH):
        print("No profile found")
        return
    
    var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file:
        var json_string = file.get_as_text()
        file.close()
        
        var json = JSON.new()
        var error = json.parse(json_string)
        
        if error == OK:
            var data = json.data
            player_name = data.get("player_name", "")
            is_registered = data.get("is_registered", false)
            print("Profile loaded: ", player_name)

func clear_profile():
    player_name = ""
    is_registered = false
    save_profile()
    print("Profile cleared")