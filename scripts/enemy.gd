extends CharacterBody2D

@onready var sprite = $Sprite2D
@onready var health_bar = $HealthBar
@onready var animation_player = $AnimationPlayer
@onready var nav_agent = $NavigationAgent2D

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

# === PŘIDEJ FROST RESISTANCE ===
var is_frozen: bool = false
var frozen_slow_multiplier: float = 1.0

# Scenes
var orb_scene = preload("res://scenes/orb.tscn")
var chest_scene = preload("res://scenes/chest.tscn")
var chest_drop_chance: float = 1.0  # 100% for testing

func _ready():
	add_to_group("enemies")
	_apply_difficulty()
	_update_health_bar()
	
	collision_layer = 2
	collision_mask = 7
	
	if nav_agent:
		nav_agent.path_desired_distance = 4.0
		nav_agent.target_desired_distance = 4.0
		call_deferred("_setup_navigation")

func _setup_navigation():
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
	if nav_agent and player:
		nav_agent.target_position = player.global_position
	
	var direction = Vector2.ZERO
	
	if nav_agent and not nav_agent.is_navigation_finished():
		direction = (nav_agent.get_next_path_position() - global_position).normalized()
	elif player:
		direction = (player.global_position - global_position).normalized()
	
	var distance = global_position.distance_to(player.global_position)
	
	var current_speed = move_speed * frozen_slow_multiplier
	
	if distance > 20.0:
		velocity = direction * current_speed
		_play_walk_animation(direction)
	else:
		velocity = direction * current_speed * 0.3

func _update_attack(delta):
	if not player or not is_instance_valid(player):
		return
	
	var distance = global_position.distance_to(player.global_position)
	
	# ← NASTAV is_attacking TADY místo v _follow_player!
	is_attacking = distance <= 80.0
	
	if not is_attacking:
		attack_timer = 0.0
		return
	
	attack_timer += delta
	var attack_interval = 1.0 / attack_speed
	
	if attack_timer >= attack_interval:
		_attack_player()
		attack_timer = 0.0
		print("✅ ATTACK FIRED! Timer reset.")

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
		print("❌ Player not found or invalid!")
		return
	
	var distance = global_position.distance_to(player.global_position)
	print("🎯 Attack check! Distance: ", distance)
	
	if distance <= 80.0:
		if player.has_method("take_damage"):
			print("👊 Enemy attacking player! Damage: ", damage)
			player.take_damage(damage)
		else:
			print("❌ Player doesn't have take_damage method!")
	else:
		print("⚠️ Too far to attack! Distance: ", distance)

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
	_try_drop_chest()
	
	queue_free()

func _drop_orbs():
	# Drop EXP orb
	var exp_orb = orb_scene.instantiate()
	exp_orb.position = global_position
	exp_orb.set_orb_type(exp_orb.OrbType.EXP, experience_drop)
	get_parent().call_deferred("add_child", exp_orb)
	
	# Drop GOLD orb
	var gold_orb = orb_scene.instantiate()
	gold_orb.position = global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
	gold_orb.set_orb_type(gold_orb.OrbType.GOLD, gold_drop)
	get_parent().call_deferred("add_child", gold_orb)

func _try_drop_chest():
	print("=== TRY DROP CHEST ===")
	print("Chest drop chance: ", chest_drop_chance)
	var roll = randf()
	print("Rolled: ", roll)
	
	if roll < chest_drop_chance:
		print("💎 Spawning chest!")
		
		if not chest_scene:
			print("ERROR: chest_scene is null!")
			return
		
		var chest = chest_scene.instantiate()
		chest.position = global_position
		
		print("Chest position: ", chest.position)
		print("Chest parent: ", get_parent())
		
		get_parent().call_deferred("add_child", chest)
		print("✅ Chest added to scene!")
	else:
		print("❌ No chest (rolled ", roll, " vs ", chest_drop_chance, ")")
