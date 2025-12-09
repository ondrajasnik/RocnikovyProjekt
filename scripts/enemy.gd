extends CharacterBody2D

@onready var sprite = $Sprite2D
@onready var health_bar = $HealthBar
@onready var animation_player = $AnimationPlayer
@onready var nav_agent = $NavigationAgent2D  # ← PŘIDEJ ZPĚT!

# Stats
var max_health: int = 50
var current_health: int = 50
var move_speed: float = 100.0
var damage: int = 10
var experience_drop: int = 10
var gold_drop: int = 5

# Combat
var is_attacking: bool = false
var attack_timer: float = 0.0
var attack_speed: float = 1.0

# State
var is_dead: bool = false

# References
var player = null
var knockback_force: float = 0.0
var knockback_direction: Vector2 = Vector2.ZERO

# Difficulty scaling
var difficulty_multiplier: float = 1.0

# Scenes
var orb_scene = preload("res://scenes/orb.tscn")

func _ready():
	add_to_group("enemies")
	_apply_difficulty()
	_update_health_bar()
	
	collision_layer = 2
	collision_mask = 7
	
	# Nastav NavigationAgent2D ← PŘIDEJ!
	if nav_agent:
		nav_agent.path_desired_distance = 4.0
		nav_agent.target_desired_distance = 4.0
		
		# Počkej na NavigationServer
		call_deferred("_setup_navigation")

func _setup_navigation():  # ← NOVÁ FUNKCE!
	await get_tree().physics_frame
	if player:
		nav_agent.target_position = player.global_position

func _apply_difficulty():
	max_health = int(50 * difficulty_multiplier)
	current_health = max_health
	damage = int(10 * difficulty_multiplier)
	move_speed = 100.0 * difficulty_multiplier
	experience_drop = int(10 * difficulty_multiplier)
	gold_drop = int(5 * difficulty_multiplier)

func _physics_process(delta):
	if not player:
		player = get_tree().root.find_child("PlayerMage", true, false)
	
	if player and is_instance_valid(player):
		_follow_player(delta)
		_update_attack(delta)
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

func _follow_player(delta):
	# Update navigation target ← PŘIDEJ!
	if nav_agent and player:
		nav_agent.target_position = player.global_position
	
	var direction = Vector2.ZERO
	
	# Použij NavigationAgent pokud existuje ← ZMĚNĚNO!
	if nav_agent and not nav_agent.is_navigation_finished():
		direction = (nav_agent.get_next_path_position() - global_position).normalized()
	elif player:
		# Fallback - přímá cesta k hráči
		direction = (player.global_position - global_position).normalized()
	
	var distance = global_position.distance_to(player.global_position)
	
	if distance > 20.0:
		velocity = direction * move_speed
		_play_walk_animation(direction)
	else:
		velocity = direction * move_speed * 0.3
	
	is_attacking = distance <= 80.0

func _update_attack(delta):
	if not is_attacking:
		attack_timer = 0.0
		return
	
	attack_timer += delta
	var attack_interval = 1.0 / attack_speed
	
	if attack_timer >= attack_interval:
		_attack_player()
		attack_timer = 0.0

func _play_walk_animation(direction: Vector2):
	if not animation_player:
		return
	
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			animation_player.play("walk_right")
		else:
			animation_player.play("walk_left")
	else:
		if direction.y > 0:
			animation_player.play("walk_down")
		else:
			animation_player.play("walk_up")

func _attack_player():
	if not player or not is_instance_valid(player):
		return
	
	var distance = global_position.distance_to(player.global_position)
	
	if distance <= 80.0:
		if player.has_method("take_damage"):
			player.take_damage(damage)

func take_damage(amount: int, is_critical: bool = false):
	current_health -= amount
	
	_spawn_damage_number(amount, is_critical)
	_update_health_bar()
	
	print("Enemy took ", amount, " damage! HP: ", current_health, "/", max_health)
	
	if sprite:
		sprite.modulate = Color(1, 0.5, 0.5)
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color(1, 1, 1)
	
	if current_health <= 0:
		die()

func _spawn_damage_number(damage: int, is_critical: bool):
	var label = Label.new()
	label.text = str(damage)
	label.z_index = 100
	
	if is_critical:
		label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0))
		label.add_theme_font_size_override("font_size", 28)
		label.add_theme_constant_override("outline_size", 4)
		label.add_theme_color_override("font_outline_color", Color(0.8, 0.2, 0.0))
	else:
		label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
		label.add_theme_font_size_override("font_size", 20)
		label.add_theme_constant_override("outline_size", 2)
		label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	
	var spawn_pos = global_position + Vector2(-15, -40)
	get_tree().current_scene.add_child(label)
	label.global_position = spawn_pos
	
	get_tree().create_timer(0.8).timeout.connect(func():
		if is_instance_valid(label):
			label.queue_free()
	)
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	
	var fly_distance = 80 if is_critical else 60
	var target_y = spawn_pos.y - fly_distance
	var random_x = spawn_pos.x + randf_range(-20, 20)
	
	tween.tween_property(label, "global_position", Vector2(random_x, target_y), 0.7)
	tween.tween_property(label, "modulate:a", 0.0, 0.7)

func _update_health_bar():
	health_bar.max_value = max_health
	health_bar.value = current_health

func increase_difficulty(multiplier: float):
	difficulty_multiplier = multiplier
	_apply_difficulty()

func die():
	if is_dead:
		return
	
	is_dead = true
	
	print("Enemy died!")
	
	if player and is_instance_valid(player) and player.has_method("add_kill"):
		player.add_kill()
	
	_drop_orbs()
	queue_free()

func _drop_orbs():
	var exp_orb = orb_scene.instantiate()
	exp_orb.position = global_position
	exp_orb.set_orb_type(exp_orb.OrbType.EXP, int(10 * difficulty_multiplier))
	get_parent().call_deferred("add_child", exp_orb)
	
	var gold_orb = orb_scene.instantiate()
	gold_orb.position = global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
	gold_orb.set_orb_type(gold_orb.OrbType.GOLD, int(5 * difficulty_multiplier))
	get_parent().call_deferred("add_child", gold_orb)
