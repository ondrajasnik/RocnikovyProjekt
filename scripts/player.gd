extends CharacterBody2D

@export var attack_interval_seconds: float = 0.8
var _attack_timer: float = 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	name = "Player"
	Game.player_stats_changed.connect(_on_stats_changed)
	Game.player_died.connect(_on_player_died)

	# zmenšení postavy na polovinu
	self.scale = Vector2(0.4, 0.4)

	# spustíme idle animaci na start
	if sprite and sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")

func _physics_process(delta: float) -> void:
	_attack_timer += delta
	var interval: float = float(max(0.1, 1.0 / max(0.1, Game.player_attack_speed)))
	if _attack_timer >= interval:
		_attack_timer = 0.0
		_auto_attack()

func _auto_attack() -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return
	# pick the closest enemy
	var target: Node2D = null
	var best_dist: float = 1.0e20
	for e: Node in enemies:
		var e2: Node2D = e as Node2D
		if e2 == null or not is_instance_valid(e2):
			continue
		var d: float = global_position.distance_to(e2.global_position)
		if d < best_dist:
			best_dist = d
			target = e2

	if target != null and target.has_method("take_damage"):
		target.take_damage(Game.get_player_attack())

func _on_stats_changed(_hp: int, _max_hp: int, _attack: int) -> void:
	# Placeholder to react to stat changes if needed later
	pass

func _on_player_died() -> void:
	# Zastavíme idle animaci při smrti
	if sprite:
		sprite.stop()

func add_gold(amount: int) -> void:
	Game.add_gold(amount)
