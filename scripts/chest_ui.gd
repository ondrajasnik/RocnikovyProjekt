extends CanvasLayer

var chest = null
var player = null
var chest_cost: int = 50
var rolled_item_type = null
var rolled_item_data = null

@onready var cost_label = $CenterContainer/PanelContainer/VBoxContainer/CostLabel
@onready var player_gold_label = $CenterContainer/PanelContainer/VBoxContainer/PlayerGoldLabel
@onready var open_button = $CenterContainer/PanelContainer/VBoxContainer/ButtonsContainer/OpenButton
@onready var take_button = $CenterContainer/PanelContainer/VBoxContainer/ButtonsContainer/TakeButton
@onready var leave_button = $CenterContainer/PanelContainer/VBoxContainer/ButtonsContainer/LeaveButton
@onready var close_button = $CenterContainer/PanelContainer/VBoxContainer/ButtonsContainer/CloseButton

@onready var item_sprite = $CenterContainer/PanelContainer/VBoxContainer/ItemDisplay/ItemPanel/VBox/ItemSprite
@onready var item_name_label = $CenterContainer/PanelContainer/VBoxContainer/ItemDisplay/ItemPanel/VBox/ItemName
@onready var item_desc_label = $CenterContainer/PanelContainer/VBoxContainer/ItemDisplay/ItemPanel/VBox/ItemDescription

# Item pool
enum ItemType {
	LUCKY_DICE, RED_APPLE, BLUE_POTION, LIGHTNING_BOLT,
	IRON_SHIELD, RUBY, SHARP_DAGGER, BOOTS,
	FIREBOOTS, LIGHTNING_AURA, FROST_RING, SHADOW_CLOAK, STAR_CROWN
}

enum ItemRarity { COMMON, RARE, LEGENDARY }

var rarity_colors = {
	ItemRarity.COMMON: Color(0.8, 0.8, 0.8),
	ItemRarity.RARE: Color(0.3, 0.5, 1.0),
	ItemRarity.LEGENDARY: Color(1.0, 0.6, 0.0)
}

var item_data = {
	ItemType.LUCKY_DICE: { "name": "🎲 Lucky Dice", "description": "+0.2 Luck", "rarity": ItemRarity.COMMON },
	ItemType.RED_APPLE: { "name": "🍎 Red Apple", "description": "+20 Max HP", "rarity": ItemRarity.COMMON },
	ItemType.BLUE_POTION: { "name": "💙 Blue Potion", "description": "+1 HP Regen", "rarity": ItemRarity.RARE },
	ItemType.LIGHTNING_BOLT: { "name": "⚡ Lightning Bolt", "description": "x1.1 Attack Speed", "rarity": ItemRarity.RARE },
	ItemType.IRON_SHIELD: { "name": "🛡️ Iron Shield", "description": "+5% Defense", "rarity": ItemRarity.COMMON },
	ItemType.RUBY: { "name": "💎 Ruby", "description": "+10% Crit Chance", "rarity": ItemRarity.RARE },
	ItemType.SHARP_DAGGER: { "name": "🗡️ Sharp Dagger", "description": "x1.15 Damage", "rarity": ItemRarity.RARE },
	ItemType.BOOTS: { "name": "👟 Boots", "description": "x1.1 Move Speed", "rarity": ItemRarity.COMMON },
	ItemType.FIREBOOTS: { "name": "🔥 Fireboots", "description": "Fire trail damage", "rarity": ItemRarity.LEGENDARY },
	ItemType.LIGHTNING_AURA: { "name": "⚡ Lightning Aura", "description": "Auto zap enemies", "rarity": ItemRarity.LEGENDARY },
	ItemType.FROST_RING: { "name": "❄️ Frost Ring", "description": "Slow enemies", "rarity": ItemRarity.LEGENDARY },
	ItemType.SHADOW_CLOAK: { "name": "💀 Shadow Cloak", "description": "20% dodge", "rarity": ItemRarity.LEGENDARY },
	ItemType.STAR_CROWN: { "name": "🌟 Star Crown", "description": "Auto-shoot", "rarity": ItemRarity.LEGENDARY }
}

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Null checks pro všechny node reference
	if not cost_label:
		cost_label = get_node_or_null("CenterContainer/PanelContainer/VBoxContainer/CostLabel")
		if not cost_label:
			print("ERROR: CostLabel not found!")
	
	if not player_gold_label:
		player_gold_label = get_node_or_null("CenterContainer/PanelContainer/VBoxContainer/PlayerGoldLabel")
		if not player_gold_label:
			print("ERROR: PlayerGoldLabel not found!")
	
	if not item_sprite:
		item_sprite = get_node_or_null("CenterContainer/PanelContainer/VBoxContainer/ItemDisplay/ItemPanel/VBox/ItemSprite")
		if not item_sprite:
			print("ERROR: ItemSprite not found!")
	
	if not item_name_label:
		item_name_label = get_node_or_null("CenterContainer/PanelContainer/VBoxContainer/ItemDisplay/ItemPanel/VBox/ItemName")
		if not item_name_label:
			print("ERROR: ItemName not found!")
	
	if not item_desc_label:
		item_desc_label = get_node_or_null("CenterContainer/PanelContainer/VBoxContainer/ItemDisplay/ItemPanel/VBox/ItemDescription")
		if not item_desc_label:
			print("ERROR: ItemDescription not found!")
	
	# Connect buttons
	if open_button:
		open_button.pressed.connect(_on_open_pressed)
	if take_button:
		take_button.pressed.connect(_on_take_pressed)
	if leave_button:
		leave_button.pressed.connect(_on_leave_pressed)
	if close_button:
		close_button.pressed.connect(_on_close_pressed)

func _input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		if take_button.visible:
			_on_leave_pressed()  # ESC = leave
		else:
			_on_close_pressed()
		get_viewport().set_input_as_handled()

func show_chest(chest_ref, player_ref, cost: int):
	chest = chest_ref
	player = player_ref
	chest_cost = cost
	
	# Update labels s null check
	if cost_label:
		cost_label.text = "Cost: %d 💰" % chest_cost
	if player_gold_label:
		player_gold_label.text = "Your gold: %d 💰" % player.gold
	
	# Reset display
	if item_sprite:
		item_sprite.visible = false
	if item_name_label:
		item_name_label.text = "???"
	if item_desc_label:
		item_desc_label.text = "Press OPEN to reveal"
	
	# Show/hide buttons
	if open_button:
		open_button.visible = true
	if take_button:
		take_button.visible = false
	if leave_button:
		leave_button.visible = false
	if close_button:
		close_button.visible = true
	
	# Check if can afford
	var can_afford = player.gold >= chest_cost
	
	if open_button:
		if can_afford:
			open_button.disabled = false
			open_button.text = "OPEN"
			if player_gold_label:
				player_gold_label.add_theme_color_override("font_color", Color(1, 0.84, 0))
		else:
			open_button.disabled = true
			open_button.text = "Not enough gold"
			if player_gold_label:
				player_gold_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	
	visible = true
	get_tree().paused = true

func _on_open_pressed():
	if player.gold < chest_cost:
		return
	
	# Deduct gold
	player.gold -= chest_cost
	player_gold_label.text = "Your gold: %d 💰" % player.gold
	print("💰 Spent ", chest_cost, " gold. Remaining: ", player.gold)
	
	# Hide open button
	open_button.visible = false
	close_button.visible = false
	
	# Start shuffle animation
	await _play_shuffle_animation()
	
	# Show Take/Leave buttons
	take_button.visible = true
	leave_button.visible = true

func _play_shuffle_animation():
	if item_name_label:
		item_name_label.text = "🎰 Shuffling..."
	if item_desc_label:
		item_desc_label.text = "Rolling..."
	
	# Shuffle effect - flash random items
	for i in range(15):
		var random_type = randi() % ItemType.size()
		var random_item = item_data[random_type]
		
		# Load and show random texture
		var texture_path = _get_item_texture_path(random_type)
		if ResourceLoader.exists(texture_path):
			var texture = load(texture_path)
			if item_sprite:
				item_sprite.texture = texture
				item_sprite.visible = true
				_normalize_sprite_size(texture)
		
		if item_name_label:
			item_name_label.text = random_item.name
		
		var delay = 0.05 + (i * 0.02)
		await get_tree().create_timer(delay).timeout
	
	# Final roll
	rolled_item_type = _get_random_item()
	rolled_item_data = item_data[rolled_item_type]
	
	# Show final item
	var final_texture = load(_get_item_texture_path(rolled_item_type))
	if item_sprite:
		item_sprite.texture = final_texture
		item_sprite.visible = true
		_normalize_sprite_size(final_texture)
	
	var rarity_color = rarity_colors[rolled_item_data.rarity]
	if item_name_label:
		item_name_label.text = rolled_item_data.name
		item_name_label.add_theme_color_override("font_color", rarity_color)
	if item_desc_label:
		item_desc_label.text = rolled_item_data.description
	
	# Scale up effect
	if item_sprite:
		var tween = get_tree().create_tween()
		tween.tween_property(item_sprite, "scale", item_sprite.scale * 1.2, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	print("🎁 Rolled: ", rolled_item_data.name)

func _on_take_pressed():
	print("✅ Taking item: ", rolled_item_data.name)
	
	# Apply item to player
	_apply_item(rolled_item_type)
	
	# Show notification
	_show_notification("🎁 Received: " + rolled_item_data.name, rarity_colors[rolled_item_data.rarity])
	
	# Close and open chest
	_finish_chest_interaction(true)

func _on_leave_pressed():
	print("❌ Left item: ", rolled_item_data.name)
	
	# Show notification
	_show_notification("💔 Left: " + rolled_item_data.name, Color(0.8, 0.3, 0.3))
	
	# Close without taking
	_finish_chest_interaction(false)

func _on_close_pressed():
	get_tree().paused = false
	visible = false
	queue_free()

func _finish_chest_interaction(took_item: bool):
	# Close UI
	get_tree().paused = false
	visible = false
	
	# Tell chest to open
	if chest and is_instance_valid(chest):
		chest.open_chest()
	
	queue_free()

func _apply_item(type):
	match type:
		ItemType.LUCKY_DICE: player.luck += 0.2
		ItemType.RED_APPLE: player.base_max_hp += 20; player._update_stats()
		ItemType.BLUE_POTION: player.base_hp_regen += 1.0; player._update_stats()
		ItemType.LIGHTNING_BOLT: player.attack_speed_multiplier *= 1.1; player._update_stats()
		ItemType.IRON_SHIELD: player.defense += 0.05
		ItemType.RUBY: player.critical_chance += 0.10
		ItemType.SHARP_DAGGER: player.damage_multiplier *= 1.15; player._update_stats()
		ItemType.BOOTS: player.speed_multiplier *= 1.1; player._update_stats()
		ItemType.FIREBOOTS: player.has_fireboots = true
		ItemType.LIGHTNING_AURA: player.has_lightning_aura = true
		ItemType.FROST_RING: player.has_frost_ring = true
		ItemType.SHADOW_CLOAK: player.has_shadow_cloak = true; player.dodge_chance = 0.20
		ItemType.STAR_CROWN: player.has_star_crown = true

func _show_notification(text: String, color: Color):
	var notif = Label.new()
	notif.text = text
	notif.add_theme_font_size_override("font_size", 32)
	notif.add_theme_color_override("font_color", color)
	notif.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	notif.add_theme_constant_override("outline_size", 3)
	notif.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notif.position = Vector2(400, 200)
	notif.z_index = 10000
	
	get_tree().current_scene.add_child(notif)
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(notif, "position:y", 150, 2.0)
	tween.tween_property(notif, "modulate:a", 0.0, 2.0)
	
	await tween.finished
	notif.queue_free()

func _get_random_item() -> ItemType:
	var roll = randf() * 100.0
	
	# 5% legendary, 25% rare, 70% common
	if roll < 5.0:
		var legendaries = [ItemType.FIREBOOTS, ItemType.LIGHTNING_AURA, ItemType.FROST_RING, ItemType.SHADOW_CLOAK, ItemType.STAR_CROWN]
		return legendaries[randi() % legendaries.size()]
	elif roll < 30.0:
		var rares = [ItemType.BLUE_POTION, ItemType.LIGHTNING_BOLT, ItemType.RUBY, ItemType.SHARP_DAGGER]
		return rares[randi() % rares.size()]
	else:
		var commons = [ItemType.LUCKY_DICE, ItemType.RED_APPLE, ItemType.IRON_SHIELD, ItemType.BOOTS]
		return commons[randi() % commons.size()]

func _get_item_texture_path(type) -> String:
	match type:
		ItemType.LUCKY_DICE: return "res://assets/items/lucky_dice.png"
		ItemType.RED_APPLE: return "res://assets/items/red_apple.png"
		ItemType.BLUE_POTION: return "res://assets/items/blue_potion.png"
		ItemType.LIGHTNING_BOLT: return "res://assets/items/lightning_bolt.png"
		ItemType.IRON_SHIELD: return "res://assets/items/iron_shield.png"
		ItemType.RUBY: return "res://assets/items/ruby.png"
		ItemType.SHARP_DAGGER: return "res://assets/items/sharp_dagger.png"
		ItemType.BOOTS: return "res://assets/items/boots.png"
		ItemType.FIREBOOTS: return "res://assets/items/fireboots.png"
		ItemType.LIGHTNING_AURA: return "res://assets/items/lightning_aura.png"
		ItemType.FROST_RING: return "res://assets/items/frost_ring.png"
		ItemType.SHADOW_CLOAK: return "res://assets/items/shadow_cloak.png"
		ItemType.STAR_CROWN: return "res://assets/items/star_crown.png"
		_: return "res://icon.svg"

# NOVÁ FUNKCE - normalizuje velikost všech sprite na stejnou
func _normalize_sprite_size(texture: Texture2D):
	if not texture or not item_sprite:
		return
	
	# Cílová velikost v pixelech (upravitelné!)
	var target_size = 64.0  # Můžeš změnit na 48, 80, atd.
	
	# Získej původní rozměry textury
	var texture_size = texture.get_size()
	var max_dimension = max(texture_size.x, texture_size.y)
	
	# Vypočítej scale aby největší strana byla = target_size
	var scale_factor = target_size / max_dimension
	
	# Aplikuj scale
	item_sprite.scale = Vector2(scale_factor, scale_factor)
	
	# Debug
	# print("Texture: ", texture_size, " → Scale: ", scale_factor, " → Final: ", texture_size * scale_factor)
