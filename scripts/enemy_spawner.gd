extends Node2D

# Načti scénu nepřítele
var enemy_scene = preload("res://scenes/enemy.tscn")

# Reference na hráče
var player = null

# Nastavení spawnování
var max_enemies: int = 8
var spawn_radius: float = 500.0
var difficulty_multiplier: float = 1.0

var check_timer: float = 0.0
var difficulty_timer: float = 0.0
var difficulty_increase_interval: float = 30.0

var spawn_timer: float = 0.0
var spawn_interval: float = 2.0
var spawn_distance: float = 600

# LIMITY MAPY
var map_min = Vector2(-2540, -3484)
var map_max = Vector2(2347, 172)

# Physics pro kontrolu kolizí ← NOVÉ!
var space_state: PhysicsDirectSpaceState2D
var max_spawn_attempts = 10

func _ready():
	process_mode = Node.PROCESS_MODE_PAUSABLE
	
	# Získej physics space ← NOVÉ!
	space_state = get_world_2d().direct_space_state
	
	player = get_tree().root.find_child("PlayerMage", true, false)
	await get_tree().process_frame
	
	for i in range(max_enemies):
		spawn_enemy()

func _process(delta):
	if Engine.time_scale == 0.0:
		return
	
	check_timer += delta
	if check_timer >= 1.0:
		check_timer = 0.0
		maintain_enemy_count()
	
	difficulty_timer += delta
	if difficulty_timer >= difficulty_increase_interval:
		difficulty_timer = 0.0
		increase_difficulty()

func maintain_enemy_count():
	var enemies = get_tree().get_nodes_in_group("enemies")
	var alive_count = enemies.size()
	
	var to_spawn = max_enemies - alive_count
	if to_spawn > 0:
		for i in range(to_spawn):
			spawn_enemy()

func spawn_enemy():
	if not player or not is_instance_valid(player):
		return
	
	var spawn_pos = Vector2.ZERO
	var valid_position_found = false
	
	# Zkus najít volnou pozici ← UPRAVENO!
	for attempt in range(max_spawn_attempts):
		var angle = randf() * TAU
		spawn_pos = player.global_position + Vector2(cos(angle), sin(angle)) * spawn_radius
		
		# Omeź na mapu
		spawn_pos.x = clamp(spawn_pos.x, map_min.x, map_max.x)
		spawn_pos.y = clamp(spawn_pos.y, map_min.y, map_max.y)
		
		# Zkontroluj kolizi ← NOVÉ!
		if not _is_position_blocked(spawn_pos):
			valid_position_found = true
			break
	
	# Pokud nenašel volné místo, spawni dál
	if not valid_position_found:
		var angle = randf() * TAU
		spawn_pos = player.global_position + Vector2(cos(angle), sin(angle)) * (spawn_radius + 200)
		spawn_pos.x = clamp(spawn_pos.x, map_min.x, map_max.x)
		spawn_pos.y = clamp(spawn_pos.y, map_min.y, map_max.y)
	
	var enemy = enemy_scene.instantiate()
	enemy.position = spawn_pos
	enemy.increase_difficulty(difficulty_multiplier)
	get_parent().call_deferred("add_child", enemy)

# Zkontroluj jestli je pozice blokovaná ← NOVÁ FUNKCE!
func _is_position_blocked(pos: Vector2) -> bool:
	if not space_state:
		return false
	
	var query = PhysicsShapeQueryParameters2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 25  # Kontroluj 25px okolo
	query.shape = shape
	query.transform = Transform2D(0, pos)
	query.collision_mask = 1  # Layer 1 (obstacles)
	
	var result = space_state.intersect_shape(query, 1)
	
	for collision in result:
		var collider = collision.collider
		if collider.is_in_group("player") or collider.is_in_group("enemies"):
			continue
		return true  # Našli jsme obstacle!
	
	return false

func increase_difficulty():
	difficulty_multiplier += 0.15
	max_enemies += 1
	print("Difficulty increased! Multiplier: ", difficulty_multiplier, " / Max enemies: ", max_enemies)
