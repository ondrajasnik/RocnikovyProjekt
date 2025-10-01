extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_radius_pixels: float = 320.0
@export var player_path: NodePath

var _player: Node2D

func _ready() -> void:
	if player_path != NodePath(""):
		_player = get_node_or_null(player_path)

func spawn_wave(count: int, is_boss: bool) -> void:
	if is_boss:
		# Spawn a slightly weaker boss plus some minions so players can farm
		_spawn_enemy(true, 0)
		var minions: int = max(2, int(round(float(count) * 0.6)))
		for i in range(minions):
			_spawn_enemy(false, i + 1)
		if WaveManager and WaveManager.has_method("set_expected_enemies"):
			WaveManager.set_expected_enemies(1 + minions)
		return
	for i in range(count):
		_spawn_enemy(false, i)
	if WaveManager and WaveManager.has_method("set_expected_enemies"):
		WaveManager.set_expected_enemies(count)

func _spawn_enemy(boss: bool, index: int = 0) -> void:
	var enemy = enemy_scene.instantiate()
	if not enemy:
		return
	enemy.is_boss = boss
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var vp := get_viewport()
	var rect := vp.get_visible_rect()
	var margin: float = 64.0
	var spacing_x: float = 48.0
	var lane_spread: int = 24
	var base: Vector2 = _player.global_position if _player else global_position
	var spawn_x: float = base.x + rect.size.x * 0.5 + margin + float(index) * spacing_x
	var spawn_y: float = base.y + float(rng.randi_range(-lane_spread, lane_spread))
	enemy.global_position = Vector2(spawn_x, spawn_y)
	get_node("Enemies").add_child(enemy)
	if enemy.has_signal("died"):
		enemy.died.connect(Callable(self, "_on_enemy_died"))
	if enemy.has_signal("health_changed"):
		var main := get_tree().current_scene
		if main and main.has_method("on_enemy_health_changed"):
			enemy.health_changed.connect(Callable(main, "on_enemy_health_changed"))

func _on_enemy_died(is_boss: bool) -> void:
	if WaveManager and WaveManager.has_method("on_enemy_killed"):
		WaveManager.on_enemy_killed(is_boss)
