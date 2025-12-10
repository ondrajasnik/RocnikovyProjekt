extends Area2D

@onready var sprite = $Sprite2D
@onready var anim_player = $AnimationPlayer

var is_opened = false
var player = null
var chest_cost: int = 50  # První truhla stojí 50 gold

# Global counter pro zvyšování ceny
static var chests_opened: int = 0
static var base_chest_cost: int = 50

# Chest UI scene
var chest_ui_scene = preload("res://scenes/chest_ui.tscn")

func _ready():
	add_to_group("chests")
	
	# Calculate cost based on how many chests were opened
	chest_cost = base_chest_cost + (chests_opened * 25)  # +25 gold za každou otevřenou
	print("Chest spawned! Cost: ", chest_cost, " gold (", chests_opened, " chests opened)")
	
	collision_layer = 8
	collision_mask = 1
	
	if anim_player and anim_player.has_animation("idle"):
		anim_player.play("idle")
	
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not is_opened:
			show_chest_ui()

func _on_mouse_entered():
	if not is_opened:
		if sprite:
			sprite.modulate = Color(1.3, 1.3, 1.3)

func _on_mouse_exited():
	if sprite:
		sprite.modulate = Color(1, 1, 1)

func show_chest_ui():
	if is_opened:
		return
	
	print("💎 Showing chest UI...")
	
	# Find player
	player = get_tree().root.find_child("PlayerMage", true, false)
	if not player:
		print("ERROR: Player not found!")
		return
	
	# Create UI
	var chest_ui = chest_ui_scene.instantiate()
	get_tree().current_scene.add_child(chest_ui)
	
	await get_tree().process_frame
	
	if chest_ui and chest_ui.has_method("show_chest"):
		chest_ui.show_chest(self, player, chest_cost)
	else:
		print("ERROR: chest_ui invalid!")

func open_chest():
	if is_opened:
		return
	
	is_opened = true
	chests_opened += 1  # Increment global counter
	
	print("💎 Chest opened! Total chests opened: ", chests_opened)
	
	# Play OPEN animation
	if anim_player and anim_player.has_animation("open"):
		anim_player.play("open")
		await anim_player.animation_finished
	
	# Wait a bit
	await get_tree().create_timer(0.5).timeout
	
	# Play EMPTY animation
	if anim_player and anim_player.has_animation("empty"):
		anim_player.play("empty")
		await anim_player.animation_finished
	
	# Remove chest
	queue_free()
