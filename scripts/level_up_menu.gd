extends CanvasLayer

var upgrades_container = null
var player = null
var upgrade_options = []

enum UpgradeType { DAMAGE, PROJECTILE_COUNT, MAX_HP, HP_REGEN, ATTACK_SPEED, MOVE_SPEED, LIFESTEAL, DEFENSE }
enum UpgradeRarity { COMMON, RARE, EPIC, LEGENDARY }

var base_rarity_chances = {
	UpgradeRarity.COMMON: 60.0,
	UpgradeRarity.RARE: 30.0,
	UpgradeRarity.EPIC: 8.0,
	UpgradeRarity.LEGENDARY: 2.0
}

var rarity_colors = {
	UpgradeRarity.COMMON: Color(0.6, 0.6, 0.6),
	UpgradeRarity.RARE: Color(0.2, 0.5, 1.0),
	UpgradeRarity.EPIC: Color(0.7, 0.3, 1.0),
	UpgradeRarity.LEGENDARY: Color(1.0, 0.84, 0.0)
}

var upgrade_values = {
	UpgradeType.DAMAGE: { UpgradeRarity.COMMON: 2, UpgradeRarity.RARE: 5, UpgradeRarity.EPIC: 10, UpgradeRarity.LEGENDARY: 20 },
	UpgradeType.PROJECTILE_COUNT: { UpgradeRarity.COMMON: 1, UpgradeRarity.RARE: 1, UpgradeRarity.EPIC: 2, UpgradeRarity.LEGENDARY: 3 },
	UpgradeType.MAX_HP: { UpgradeRarity.COMMON: 10, UpgradeRarity.RARE: 25, UpgradeRarity.EPIC: 50, UpgradeRarity.LEGENDARY: 100 },
	UpgradeType.HP_REGEN: { UpgradeRarity.COMMON: 2.0, UpgradeRarity.RARE: 5.0, UpgradeRarity.EPIC: 10.0, UpgradeRarity.LEGENDARY: 20.0 }, # ZVÝŠENO
	UpgradeType.ATTACK_SPEED: { UpgradeRarity.COMMON: 0.1, UpgradeRarity.RARE: 0.25, UpgradeRarity.EPIC: 0.5, UpgradeRarity.LEGENDARY: 1.0 },
	UpgradeType.MOVE_SPEED: { UpgradeRarity.COMMON: 10, UpgradeRarity.RARE: 25, UpgradeRarity.EPIC: 50, UpgradeRarity.LEGENDARY: 100 },
	UpgradeType.LIFESTEAL: { UpgradeRarity.COMMON: 0.05, UpgradeRarity.RARE: 0.1, UpgradeRarity.EPIC: 0.2, UpgradeRarity.LEGENDARY: 0.4 },
	UpgradeType.DEFENSE: { UpgradeRarity.COMMON: 0.05, UpgradeRarity.RARE: 0.1, UpgradeRarity.EPIC: 0.15, UpgradeRarity.LEGENDARY: 0.3 }
}

var upgrade_names = {
	UpgradeType.DAMAGE: "Damage",
	UpgradeType.PROJECTILE_COUNT: "Projectiles",
	UpgradeType.MAX_HP: "Max Health",
	UpgradeType.HP_REGEN: "Health Regen",
	UpgradeType.ATTACK_SPEED: "Attack Speed",
	UpgradeType.MOVE_SPEED: "Move Speed",
	UpgradeType.LIFESTEAL: "Lifesteal",
	UpgradeType.DEFENSE: "Defense"
}

var upgrade_icons = {
	UpgradeType.DAMAGE: "res://assets/upgrades/damage_book.png",
	UpgradeType.PROJECTILE_COUNT: "res://assets/upgrades/projectile_multiplayer_book.png",
	UpgradeType.MAX_HP: "res://assets/upgrades/health.png",
	UpgradeType.HP_REGEN: "res://assets/upgrades/health_regen.png",
	UpgradeType.ATTACK_SPEED: "res://assets/upgrades/attack_speed_book.png",
	UpgradeType.MOVE_SPEED: "res://assets/upgrades/movement_speed.png",
	UpgradeType.LIFESTEAL: "res://assets/upgrades/lifesteal.png",
	UpgradeType.DEFENSE: "res://assets/upgrades/defence.png"
}

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Nastav layer aby bylo menu nahoře
	layer = 100
	
	# Najdi container - OPRAVENO s novou cestou
	upgrades_container = get_node_or_null("CenterContainer/PanelContainer/VBoxContainer/MarginContainer/Content/UpgradesContainer")
	
	if not upgrades_container:
		print("ERROR: UpgradesContainer not found!")
	else:
		print("UpgradesContainer found successfully")

func show_level_up(player_ref, luck: float = 1.0):
	print("=== LEVEL UP CALLED ===")
	
	if not upgrades_container:
		print("ERROR: upgrades_container is null!")
		upgrades_container = get_node_or_null("CenterContainer/PanelContainer/VBoxContainer/MarginContainer/Content/UpgradesContainer")
		if not upgrades_container:
			print("ERROR: Still can't find UpgradesContainer!")
			return
	
	player = player_ref
	
	# Vygeneruj 3 náhodné upgrady
	upgrade_options = generate_upgrade_options(3, luck)
	print("Generated ", upgrade_options.size(), " upgrades")
	
	# Vyčisti předchozí upgrady
	var children = upgrades_container.get_children()
	for child in children:
		child.queue_free()
	
	# Vytvoř UI pro každý upgrade
	for i in range(upgrade_options.size()):
		var option = upgrade_options[i]
		create_upgrade_button(option, i)
	
	# Zobraz menu a pauza
	visible = true
	Engine.time_scale = 0.0
	print("Menu shown, game paused")

func generate_upgrade_options(count: int, luck: float = 1.0) -> Array:
	var options = []
	var available_types = UpgradeType.values()
	
	for i in range(count):
		var type = available_types[randi() % available_types.size()]
		var rarity = generate_random_rarity(luck)
		var value = upgrade_values[type][rarity]
		
		var desc = ""
		match type:
			UpgradeType.DAMAGE: desc = "+%d Damage" % value
			UpgradeType.PROJECTILE_COUNT: desc = "+%d Projectiles" % value
			UpgradeType.MAX_HP: desc = "+%d Max HP" % value
			UpgradeType.HP_REGEN: desc = "+%.1f HP/s" % value
			UpgradeType.ATTACK_SPEED: desc = "+%.1f Attacks/s" % value
			UpgradeType.MOVE_SPEED: desc = "+%d Speed" % value
			UpgradeType.LIFESTEAL: desc = "+%.0f%% Lifesteal" % (value * 100)
			UpgradeType.DEFENSE: desc = "+%.0f%% Defense" % (value * 100)
		
		options.append({
			"type": type,
			"rarity": rarity,
			"value": value,
			"name": upgrade_names[type],
			"description": desc,
			"color": rarity_colors[rarity]
		})
	
	return options

func generate_random_rarity(luck: float = 1.0) -> UpgradeRarity:
	var adjusted_chances = {}
	var total = 0.0
	
	for rarity in base_rarity_chances:
		var chance = base_rarity_chances[rarity]
		if rarity == UpgradeRarity.LEGENDARY:
			chance *= luck * luck
		elif rarity == UpgradeRarity.EPIC:
			chance *= luck * 1.5
		elif rarity == UpgradeRarity.RARE:
			chance *= luck
		
		adjusted_chances[rarity] = chance
		total += chance
	
	for rarity in adjusted_chances:
		adjusted_chances[rarity] = (adjusted_chances[rarity] / total) * 100.0
	
	var roll = randf() * 100.0
	var cumulative = 0.0
	
	for rarity in [UpgradeRarity.LEGENDARY, UpgradeRarity.EPIC, UpgradeRarity.RARE, UpgradeRarity.COMMON]:
		cumulative += adjusted_chances[rarity]
		if roll <= cumulative:
			return rarity
	
	return UpgradeRarity.COMMON

func get_rarity_name(rarity: UpgradeRarity) -> String:
	match rarity:
		UpgradeRarity.COMMON: return "Common"
		UpgradeRarity.RARE: return "Rare"
		UpgradeRarity.EPIC: return "Epic"
		UpgradeRarity.LEGENDARY: return "Legendary"
	return "Unknown"

func create_upgrade_button(option: Dictionary, index: int):
	print("Creating button ", index, " for ", option.name)
	
	var button = Button.new()
	button.custom_minimum_size = Vector2(220, 280)
	
	# VBox pro obsah
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 10)
	
	# Ikona upgradu - UPRAVENO pro jednotnou velikost
	var icon = TextureRect.new()
	icon.custom_minimum_size = Vector2(120, 120)  # Fixní velikost
	icon.texture = load(upgrade_icons[option.type])
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	var icon_center = CenterContainer.new()
	icon_center.add_child(icon)
	
	# Kvalita (rarity)
	var rarity_label = Label.new()
	rarity_label.text = get_rarity_name(option.rarity)
	rarity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rarity_label.add_theme_color_override("font_color", option.color)
	rarity_label.add_theme_color_override("font_outline_color", Color.BLACK)
	rarity_label.add_theme_constant_override("outline_size", 2)
	rarity_label.add_theme_font_size_override("font_size", 18)
	
	# Název upgradu
	var name_label = Label.new()
	name_label.text = option.name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_color_override("font_color", Color.WHITE)
	name_label.add_theme_color_override("font_outline_color", Color.BLACK)
	name_label.add_theme_constant_override("outline_size", 2)
	name_label.add_theme_font_size_override("font_size", 16)
	
	# Popis
	var desc_label = Label.new()
	desc_label.text = option.description
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1))
	desc_label.add_theme_color_override("font_outline_color", Color.BLACK)
	desc_label.add_theme_constant_override("outline_size", 1)
	desc_label.add_theme_font_size_override("font_size", 14)
	
	vbox.add_child(icon_center)
	vbox.add_child(rarity_label)
	vbox.add_child(name_label)
	vbox.add_child(desc_label)
	
	button.add_child(vbox)
	
	# ČISTĚ PRŮHLEDNÉ pozadí s barevným okrajem
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0, 0, 0, 0)
	style_normal.border_color = option.color
	style_normal.border_width_left = 4
	style_normal.border_width_right = 4
	style_normal.border_width_top = 4
	style_normal.border_width_bottom = 4
	style_normal.corner_radius_top_left = 12
	style_normal.corner_radius_top_right = 12
	style_normal.corner_radius_bottom_left = 12
	style_normal.corner_radius_bottom_right = 12
	
	# Hover efekt - stále průhledné, jen širší okraj
	var style_hover = StyleBoxFlat.new()
	style_hover.bg_color = Color(0, 0, 0, 0)
	style_hover.border_color = option.color
	style_hover.border_width_left = 6
	style_hover.border_width_right = 6
	style_hover.border_width_top = 6
	style_hover.border_width_bottom = 6
	style_hover.corner_radius_top_left = 12
	style_hover.corner_radius_top_right = 12
	style_hover.corner_radius_bottom_left = 12
	style_hover.corner_radius_bottom_right = 12
	
	button.add_theme_stylebox_override("normal", style_normal)
	button.add_theme_stylebox_override("hover", style_hover)
	button.add_theme_stylebox_override("pressed", style_hover)
	
	button.pressed.connect(_on_upgrade_selected.bind(index))
	upgrades_container.add_child(button)
	print("Button added with icon: ", upgrade_icons[option.type])

func _on_upgrade_selected(index: int):
	print("=== UPGRADE SELECTED: ", index, " ===")
	
	if index >= upgrade_options.size() or not player or not is_instance_valid(player):
		print("ERROR: Invalid selection")
		Engine.time_scale = 1.0
		visible = false
		return
	
	var option = upgrade_options[index]
	
	match option.type:
		UpgradeType.DAMAGE: 
			player.damage += option.value
			print("Damage: ", player.damage)
		UpgradeType.PROJECTILE_COUNT: 
			player.projectile_count += option.value
			print("Projectile count: ", player.projectile_count)
		UpgradeType.MAX_HP: 
			player.max_hp += option.value
			player.current_hp += option.value
			print("Max HP: ", player.max_hp)
		UpgradeType.HP_REGEN: 
			player.hp_regen += option.value
			print("HP REGEN: ", player.hp_regen, " HP/s")
		UpgradeType.ATTACK_SPEED: 
			player.attack_speed += option.value
			print("Attack speed: ", player.attack_speed)
		UpgradeType.MOVE_SPEED: 
			player.move_speed += option.value
			print("Move speed: ", player.move_speed)
		UpgradeType.LIFESTEAL: 
			player.lifesteal += option.value
			print("Lifesteal: ", player.lifesteal)
		UpgradeType.DEFENSE: 
			player.defense += option.value
			print("Defense: ", player.defense)
	
	print("Applied: ", option.name, " +", option.value)
	
	# Unpauza hry a zavři menu
	Engine.time_scale = 1.0
	visible = false
	print("Game resumed")
