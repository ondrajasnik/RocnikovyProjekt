extends CharacterBody2D  # ZMĚNĚNO z RigidBody2D

# --- Základní statistiky nepřítele ---
var base_max_hp: int = 50
var base_damage: int = 5
var base_move_speed: float = 150.0
var base_attack_speed: float = 1.0  # útoky za sekundu

# --- Aktuální statistiky (upravitelné během hry) ---
var max_hp: int = 50
var current_hp: int = 50
var damage: int = 5
var move_speed: float = 150.0
var attack_speed: float = 1.0

# --- Ostatní nastavení ---
var attack_range: float = 80.0
var detection_range: float = 200.0
var difficulty_multiplier: float = 1.0  # Zvyšuje se s časem/vlnami
var min_distance_to_player: float = 20.0  # Minimální vzdálenost od hráče

var player = null
var attack_timer: float = 0.0
var is_attacking: bool = false
var is_dead: bool = false

# NOVÉ - Pathfinding
@onready var nav_agent = $NavigationAgent2D
var nav_update_timer: float = 0.0
var nav_update_interval: float = 0.3  # aktualizace cesty každých 0.3s

# Načti scénu orbu
var orb_scene = preload("res://scenes/orb.tscn")

@onready var sprite = $Sprite2D
@onready var health_bar = $HealthBar
@onready var detection_area = $DetectionArea
@onready var anim_player = $AnimationPlayer

func _ready():
	add_to_group("enemies")
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)
	_apply_difficulty()
	_update_health_bar()
	
	# DŮLEŽITÉ - enemy kolidují se zdmi
	collision_layer = 2  # enemy layer
	collision_mask = 7   # ZMĚNĚNO - koliduje s layer 1 (player), 2 (enemy), 4 (walls)
	
	# NOVÉ - Nastavení NavigationAgent2D
	if nav_agent:
		nav_agent.path_desired_distance = 4.0
		nav_agent.target_desired_distance = 4.0
		nav_agent.avoidance_enabled = true
		nav_agent.radius = 16.0
		
		# Počkej na první physics frame než nastavíš cíl
		call_deferred("_setup_navigation")

func _setup_navigation():
	await get_tree().physics_frame
	if player and is_instance_valid(player):
		nav_agent.target_position = player.global_position

func _apply_difficulty():
	max_hp = int(base_max_hp * difficulty_multiplier)
	current_hp = max_hp
	damage = int(base_damage * difficulty_multiplier)
	move_speed = base_move_speed * difficulty_multiplier
	attack_speed = base_attack_speed * difficulty_multiplier

func _physics_process(delta):
	if is_dead:
		return
	
	if Engine.time_scale == 0.0:
		return
	
	if not player:
		player = get_tree().root.find_child("PlayerMage", true, false)
	
	if player and is_instance_valid(player):
		_follow_player_with_navigation(delta)
		_update_attack(delta)
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

func _follow_player_with_navigation(delta):
	if not nav_agent:
		# Fallback na přímý pohyb pokud není NavigationAgent2D
		_follow_player_direct(delta)
		return
	
	# Pravidelně aktualizuj cíl (pohybující se hráč)
	nav_update_timer += delta
	if nav_update_timer >= nav_update_interval:
		nav_update_timer = 0.0
		nav_agent.target_position = player.global_position
	
	var distance = global_position.distance_to(player.global_position)
	
	# Pokud je cesta dokončena
	if nav_agent.is_navigation_finished():
		if distance > min_distance_to_player:
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * move_speed
		else:
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * move_speed * 0.3
		is_attacking = distance <= attack_range
	else:
		# Následuj cestu
		var next_position = nav_agent.get_next_path_position()
		var direction = (next_position - global_position).normalized()
		velocity = direction * move_speed
		
		is_attacking = distance <= attack_range
	
	_play_walk_animation(velocity.normalized() if velocity.length() > 0 else Vector2.ZERO)

func _follow_player_direct(delta):
	# Původní přímočará logika (bez pathfindingu)
	var direction = (player.global_position - global_position).normalized()
	var distance = global_position.distance_to(player.global_position)
	
	if distance > min_distance_to_player:
		velocity = direction * move_speed
		_play_walk_animation(direction)
	else:
		velocity = direction * move_speed * 0.3
	
	is_attacking = distance <= attack_range

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
	if not anim_player:
		return
	
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			anim_player.play("walk_right")
		else:
			anim_player.play("walk_left")
	else:
		if direction.y > 0:
			anim_player.play("walk_down")
		else:
			anim_player.play("walk_up")

func _attack_player():
	if not player or not is_instance_valid(player):
		return
	
	var distance = global_position.distance_to(player.global_position)
	
	if distance <= attack_range:
		if player.has_method("take_damage"):
			player.take_damage(damage)

func _on_detection_area_body_entered(body):
	if body.name == "PlayerMage":
		player = body

func _on_detection_area_body_exited(body):
	if body == player:
		player = null
		is_attacking = false

func take_damage(amount):
	if is_dead:
		return
	
	current_hp -= amount
	_update_health_bar()
	
	sprite.modulate = Color.WHITE
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1, 1, 1, 1)
	
	if current_hp <= 0:
		die()

func _update_health_bar():
	health_bar.max_value = max_hp
	health_bar.value = current_hp

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
