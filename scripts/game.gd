extends Node

signal gold_changed(amount: int)
signal wave_changed(wave: int)
signal player_stats_changed(hp: int, max_hp: int, attack: int)
signal player_died()

var player_level: int = 1
var player_max_hp: int = 100
var player_attack: int = 10
var player_current_hp: int = player_max_hp
var gold: int = 0
var current_wave: int = 1

# Upgrades
var player_attack_speed: float = 1.0 # attacks per second
var upgrade_cost_attack: int = 50
var upgrade_cost_attack_speed: int = 50
var upgrade_cost_health: int = 50

var inventory: Array = [] # Array of dictionaries: {name, type, rarity, bonus_hp, bonus_attack}
var equipped: Dictionary = {"weapon": null, "armor": null, "tool": null}

var shop_offers: Array = []

const SAVE_PATH := "user://save.json"

func _ready() -> void:
	load_game()
	_recompute_stats()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		save_game()

func add_gold(amount: int) -> void:
	gold = max(0, gold + amount)
	emit_signal("gold_changed", gold)

func spend_gold(amount: int) -> bool:
	if gold >= amount:
		gold -= amount
		emit_signal("gold_changed", gold)
		return true
	return false

func advance_wave() -> void:
	current_wave += 1
	emit_signal("wave_changed", current_wave)

func is_boss_wave() -> bool:
	return current_wave % 5 == 0

func get_enemy_scale_multiplier() -> float:
	# 5% per wave, starting at wave 1 → 1.0
	return pow(1.05, float(current_wave - 1))

func on_player_damaged(amount: int) -> void:
	player_current_hp = clamp(player_current_hp - amount, 0, player_max_hp)
	emit_signal("player_stats_changed", player_current_hp, player_max_hp, get_player_attack())
	if player_current_hp <= 0:
		emit_signal("player_died")

func heal_player_to_full() -> void:
	player_current_hp = player_max_hp
	emit_signal("player_stats_changed", player_current_hp, player_max_hp, get_player_attack())

func get_player_attack() -> int:
	var bonus := 0
	for slot in ["weapon", "armor", "tool"]:
		var it = equipped.get(slot)
		if it:
			bonus += int(it.get("bonus_attack", 0))
	return player_attack + bonus

func get_player_max_hp() -> int:
	var bonus := 0
	for slot in ["weapon", "armor", "tool"]:
		var it = equipped.get(slot)
		if it:
			bonus += int(it.get("bonus_hp", 0))
	return player_max_hp + bonus

func _recompute_stats() -> void:
	player_max_hp = get_player_max_hp()
	player_current_hp = clamp(player_current_hp, 0, player_max_hp)
	emit_signal("player_stats_changed", player_current_hp, player_max_hp, get_player_attack())

func upgrade_attack() -> bool:
	if spend_gold(upgrade_cost_attack):
		player_attack += 2
		upgrade_cost_attack += 25
		_recompute_stats()
		return true
	return false

func upgrade_attack_speed() -> bool:
	if spend_gold(upgrade_cost_attack_speed):
		player_attack_speed = clamp(player_attack_speed + 0.1, 0.1, 10.0)
		upgrade_cost_attack_speed += 25
		emit_signal("player_stats_changed", player_current_hp, player_max_hp, get_player_attack())
		return true
	return false

func upgrade_health() -> bool:
	if spend_gold(upgrade_cost_health):
		player_max_hp += 10
		upgrade_cost_health += 25
		heal_player_to_full()
		_recompute_stats()
		return true
	return false

func equip_item(index: int) -> void:
	if index < 0 or index >= inventory.size():
		return
	var item = inventory[index]
	var slot: String = item.get("type", "weapon")
	equipped[slot] = item
	_recompute_stats()

func add_item(item: Dictionary) -> void:
	inventory.append(item)

func generate_random_item(seed: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var types: Array[String] = ["weapon", "armor", "tool"]
	var rarities: Array[String] = ["common", "rare", "epic"]
	var item_type: String = types[rng.randi_range(0, types.size()-1)]
	var rarity_index: int = rng.randi_range(0, rarities.size()-1)
	var rarity: String = rarities[rarity_index]
	var base_attack := 2 + rarity_index * 3
	var base_hp := 5 + rarity_index * 10
	return {
		"name": "%s %s" % [rarity.capitalize(), item_type.capitalize()],
		"type": item_type,
		"rarity": rarity,
		"bonus_attack": base_attack,
		"bonus_hp": base_hp,
		"price": 25 + rarity_index * 50
	}

func roll_boss_chest_and_add() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	if rng.randf() <= 0.4:
		var item := generate_random_item(rng.randi())
		add_item(item)

func get_gold_multiplier_for_wave() -> float:
	# Mild growth, ~+10% per 5 waves
	return 1.0 * pow(1.02, float(current_wave - 1))

func build_daily_shop_offers() -> void:
	var date := Time.get_date_dict_from_system()
	var seed := int(date.year * 10000 + date.month * 100 + date.day)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	shop_offers.clear()
	for i in range(3):
		shop_offers.append(generate_random_item(rng.randi()))

func buy_from_shop(index: int) -> bool:
	if index < 0 or index >= shop_offers.size():
		return false
	var item: Dictionary = shop_offers[index]
	var price: int = int(item.get("price", 0))
	if spend_gold(price):
		add_item(item)
		return true
	return false

func save_game() -> void:
	var data := {
		"player_level": player_level,
		"player_max_hp": player_max_hp,
		"player_attack": player_attack,
		"player_attack_speed": player_attack_speed,
		"player_current_hp": player_current_hp,
		"gold": gold,
		"current_wave": current_wave,
		"inventory": inventory,
		"equipped": equipped,
		"upgrade_cost_attack": upgrade_cost_attack,
		"upgrade_cost_attack_speed": upgrade_cost_attack_speed,
		"upgrade_cost_health": upgrade_cost_health,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		build_daily_shop_offers()
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		build_daily_shop_offers()
		return
	var content := file.get_as_text()
	var parsed = JSON.parse_string(content)
	if typeof(parsed) == TYPE_DICTIONARY:
		var data: Dictionary = parsed
		player_level = int(data.get("player_level", player_level))
		player_max_hp = int(data.get("player_max_hp", player_max_hp))
		player_attack = int(data.get("player_attack", player_attack))
		player_attack_speed = float(data.get("player_attack_speed", player_attack_speed))
		player_current_hp = int(data.get("player_current_hp", player_current_hp))
		gold = int(data.get("gold", gold))
		current_wave = int(data.get("current_wave", current_wave))
		inventory = data.get("inventory", inventory)
		equipped = data.get("equipped", equipped)
		upgrade_cost_attack = int(data.get("upgrade_cost_attack", upgrade_cost_attack))
		upgrade_cost_attack_speed = int(data.get("upgrade_cost_attack_speed", upgrade_cost_attack_speed))
		upgrade_cost_health = int(data.get("upgrade_cost_health", upgrade_cost_health))
	build_daily_shop_offers()
