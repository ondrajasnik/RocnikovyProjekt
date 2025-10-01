extends Node2D

@onready var inventory_panel: Panel = $UI/InventoryPanel
@onready var shop_panel: Panel = $UI/ShopPanel
@onready var gold_label: Label = $UI/GoldLabel
@onready var wave_label: Label = $UI/WaveLabel
@onready var player_hp_label: Label = $UI/PlayerHPLabel
@onready var inventory_button: Button = $UI/Buttons/InventoryButton
@onready var shop_button: Button = $UI/Buttons/ShopButton
@onready var upgrades_button: Button = $UI/Buttons/UpgradesButton
@onready var spawner: Node = $Spawner
@onready var inventory_list: ItemList = $UI/InventoryPanel/VBox/InventoryList
@onready var equip_button: Button = $UI/InventoryPanel/VBox/EquipButton
@onready var shop_list: ItemList = $UI/ShopPanel/VBox/ShopList
@onready var buy_button: Button = $UI/ShopPanel/VBox/BuyButton
@onready var boss_bar: TextureProgressBar = $UI/BossHealthBar
@onready var upgrade_attack_btn: Button = $UI/UpgradesPanel/VBox/UpgradeAttack
@onready var upgrade_as_btn: Button = $UI/UpgradesPanel/VBox/UpgradeAttackSpeed
@onready var upgrade_hp_btn: Button = $UI/UpgradesPanel/VBox/UpgradeHealth
@onready var stats_label: Label = $UI/UpgradesPanel/VBox/StatsLabel

func _ready() -> void:
	inventory_button.pressed.connect(_on_inventory_pressed)
	shop_button.pressed.connect(_on_shop_pressed)
	upgrades_button.pressed.connect(_on_upgrades_pressed)
	equip_button.pressed.connect(_on_equip_pressed)
	buy_button.pressed.connect(_on_buy_pressed)
	upgrade_attack_btn.pressed.connect(_on_upgrade_attack)
	upgrade_as_btn.pressed.connect(_on_upgrade_attack_speed)
	upgrade_hp_btn.pressed.connect(_on_upgrade_health)
	Game.connect("gold_changed", Callable(self, "update_gold_label"))
	Game.connect("wave_changed", Callable(self, "update_wave_label"))
	Game.connect("player_stats_changed", Callable(self, "update_player_hp_label"))
	Game.connect("player_stats_changed", Callable(self, "_refresh_stats_label"))
	Game.connect("player_died", Callable(self, "_on_player_died"))
	update_gold_label(Game.gold)
	update_wave_label(Game.current_wave)
	update_player_hp_label(Game.player_current_hp, Game.get_player_max_hp(), Game.get_player_attack())
	_refresh_inventory_ui()
	_refresh_shop_ui()
	_refresh_upgrade_buttons()
	_refresh_stats_label()
	_start_wave()

func _start_wave() -> void:
	var info: Dictionary = WaveManager.start_wave()
	Game.heal_player_to_full()
	spawner.spawn_wave(info.count, info.is_boss)
	boss_bar.visible = info.is_boss
	if not info.is_boss:
		boss_bar.value = 0

func _on_inventory_pressed() -> void:
	inventory_panel.visible = not inventory_panel.visible

func _on_shop_pressed() -> void:
	shop_panel.visible = not shop_panel.visible

func _on_upgrades_pressed() -> void:
	$UI/UpgradesPanel.visible = not $UI/UpgradesPanel.visible

func _on_upgrade_attack() -> void:
	if Game.upgrade_attack():
		_refresh_upgrade_buttons()
		_refresh_stats_label()

func _on_upgrade_attack_speed() -> void:
	if Game.upgrade_attack_speed():
		_refresh_upgrade_buttons()
		_refresh_stats_label()

func _on_upgrade_health() -> void:
	if Game.upgrade_health():
		update_player_hp_label(Game.player_current_hp, Game.get_player_max_hp(), Game.get_player_attack())
		_refresh_upgrade_buttons()
		_refresh_stats_label()

func _on_equip_pressed() -> void:
	var idx: PackedInt32Array = inventory_list.get_selected_items()
	if idx.size() == 0:
		return
	Game.equip_item(idx[0])
	_refresh_inventory_ui()

func _on_buy_pressed() -> void:
	var idx: PackedInt32Array = shop_list.get_selected_items()
	if idx.size() == 0:
		return
	if Game.buy_from_shop(idx[0]):
		_refresh_inventory_ui()
		_refresh_shop_ui()

func update_gold_label(amount: int) -> void:
	gold_label.text = "Gold: %d" % amount

func update_wave_label(wave: int) -> void:
	wave_label.text = "Wave: %d%s" % [wave, (" (Boss)" if Game.is_boss_wave() else "")]

func update_player_hp_label(hp: int, max_hp: int, _atk: int) -> void:
	player_hp_label.text = "HP: %d/%d" % [hp, max_hp]

func on_enemy_health_changed(current: int, max: int) -> void:
	if boss_bar.visible:
		boss_bar.max_value = max
		boss_bar.value = clamp(current, 0, max)

func on_boss_spawned(enemy: Node) -> void:
	# Optionally connect per-boss health update if needed
	if enemy.has_signal("health_changed"):
		enemy.health_changed.connect(Callable(self, "on_enemy_health_changed"))

func _on_player_died() -> void:
	# clear remaining enemies and restart current wave
	var enemies_container: Node = $Spawner/Enemies
	for e in enemies_container.get_children():
		e.queue_free()
	await get_tree().create_timer(1.0).timeout
	_start_wave()

func _refresh_inventory_ui() -> void:
	inventory_list.clear()
	for item in Game.inventory:
		var line: String = "%s [%s] +ATK %d +HP %d" % [
			item.get("name", "Item"),
			item.get("rarity", "common"),
			int(item.get("bonus_attack", 0)),
			int(item.get("bonus_hp", 0))
		]
		inventory_list.add_item(line)

func _refresh_shop_ui() -> void:
	shop_list.clear()
	for item in Game.shop_offers:
		var line: String = "%s [%s] %dG" % [
			item.get("name", "Item"),
			item.get("rarity", "common"),
			int(item.get("price", 0))
		]
		shop_list.add_item(line)

func _refresh_upgrade_buttons() -> void:
	upgrade_attack_btn.text = "Upgrade Attack (%dG)" % Game.upgrade_cost_attack
	upgrade_as_btn.text = "Upgrade Attack Speed (%dG)" % Game.upgrade_cost_attack_speed
	upgrade_hp_btn.text = "Upgrade Health (%dG)" % Game.upgrade_cost_health

func _refresh_stats_label(_hp := 0, _max_hp := 0, _atk := 0) -> void:
	stats_label.text = "ATK: %d  HP: %d  AS: %.1f/s" % [
		Game.get_player_attack(),
		Game.get_player_max_hp(),
		Game.player_attack_speed
	]
