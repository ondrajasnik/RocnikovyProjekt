extends Node2D

var enemy_scene = preload("res://scenes/enemy.tscn")
var player = null

# Nastavení spawnování
var max_enemies: int = 8
var spawn_radius: float = 500.0  # Vzdálenost od hráče kde se spawnují
var difficulty_multiplier: float = 1.0

var check_timer: float = 0.0
var difficulty_timer: float = 0.0
var difficulty_increase_interval: float = 30.0  # Zvýší obtížnost každých 30 sekund

func _ready():
	# Najdi hráče
	player = get_tree().root.find_child("PlayerMage", true, false)
	
	# Spawn počátečních nepřátel
	for i in range(max_enemies):
		spawn_enemy()

func _process(delta):
	# Každou sekundu kontroluj počet nepřátel
	check_timer += delta
	if check_timer >= 1.0:
		check_timer = 0.0
		maintain_enemy_count()
	
	# Zvyšuj obtížnost po čase
	difficulty_timer += delta
	if difficulty_timer >= difficulty_increase_interval:
		difficulty_timer = 0.0
		increase_difficulty()

func maintain_enemy_count():
	# Spočítej živé nepřátele
	var enemies = get_tree().get_nodes_in_group("enemies")
	var alive_count = enemies.size()
	
	# Doplň chybějící nepřátele do maxima
	var to_spawn = max_enemies - alive_count
	if to_spawn > 0:
		for i in range(to_spawn):
			spawn_enemy()

func spawn_enemy():
	if not player or not is_instance_valid(player):
		return
	
	var enemy = enemy_scene.instantiate()
	
	# Náhodná pozice kolem hráče
	var angle = randf() * TAU  # Náhodný úhel (0-360°)
	var spawn_pos = player.global_position + Vector2(cos(angle), sin(angle)) * spawn_radius
	
	enemy.position = spawn_pos
	enemy.increase_difficulty(difficulty_multiplier)
	
	get_parent().add_child(enemy)

func increase_difficulty():
	# Zvyš obtížnost (nepřátelé budou silnější)
	difficulty_multiplier += 0.15
	max_enemies += 1  # Přidej 1 nepřítele navíc
	print("Difficulty increased! Multiplier: ", difficulty_multiplier, " / Max enemies: ", max_enemies)
