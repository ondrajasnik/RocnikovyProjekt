extends Node

# Main game controller script
var mage_scene = preload("res://scenes/mage.tscn")
var ui_scene = preload("res://scenes/ui.tscn")

func _ready():
    # Initialize the game by loading the main scenes
    load_main_scene()

func load_main_scene():
    # Load the Mage character scene
    var mage_instance = mage_scene.instantiate()
    add_child(mage_instance)

    # Load the UI scene
    var ui_instance = ui_scene.instantiate()
    add_child(ui_instance)

    # Additional game initialization logic can go here
    print("Game initialized. Mage and UI loaded.")