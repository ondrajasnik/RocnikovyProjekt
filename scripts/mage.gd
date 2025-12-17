extends RigidBody2D

# --- Základní statistiky (BASE VALUES) ---
var base_max_hp: int = 100
var base_hp_regen: float = 1.0
var base_damage: int = 10
var base_attack_speed: float = 1.0
var base_move_speed: float = 250.0

# --- Aktuální statistiky (se multiplikátory) ---
var max_hp: int = 100
var current_hp: int = 100
var hp_regen: float = 1.0
var damage: int = 10
var projectile_count: int = 1
var projectile_size: float = 1.0
var attack_speed: float = 1.0
var move_speed: float = 250.0
var defense: float = 0.0
var lifesteal: float = 0.0
var attack_range: float = 300.0

# --- Multiplikátory (x násobky) ---
var hp_multiplier: float = 1.0
var damage_multiplier: float = 1.0
var regen_multiplier: float = 1.0
var speed_multiplier: float = 1.0
var attack_speed_multiplier: float = 1.0

# Critical hit system
var critical_chance: float = 0.10
var critical_multiplier: float = 2.0

# --- LEGENDARY ITEMS ---
var has_fireboots: bool = false
var has_lightning_aura: bool = false
var has_frost_ring: bool = false
var has_shadow_cloak: bool = false
var has_star_crown: bool = false
var dodge_chance: float = 0.0

# Legendary item timers
var lightning_aura_timer: float = 0.0
var star_crown_timer: float = 0.0
var fire_trail_timer: float = 0.0
var frost_ring_timer: float = 0.0
var frozen_enemies: Array = []
var last_fire_position: Vector2 = Vector2.ZERO

# --- Level systém (rychlejší!) ---
var level: int = 1
var current_exp: int = 0
var exp_to_next_level: int = 50
var exp_multiplier: float = 1.3

# --- Gold a K
var gold: int = 500
var kills: int = 0

# --- Luck systém ---
var luck: float = 1.0

# --- Combat ---
var attack_timer: float = 0.0

# --- State ---
var is_dead: bool = false
var survival_time: float = 0.0
var regen_timer: float = 0.0

# --- Scenes ---
var projectile_scene = preload("res://scenes/projectile.tscn")
var level_up_menu_scene = preload("res://scenes/level_up_menu.tscn")

# --- References ---
var joystick: Node = null
var level_up_menu = null
var game_over_menu = null

# --- Nodes ---
@onready var sprite = $Sprite2D
@onready var anim_player = $AnimationPlayer

# --- Debug ---
var debug_counter = 0

# --- Footstep audio ---
var footstep_sounds = [
	preload("res://audio/walk/step_cloth1.ogg"),
	preload("res://audio/walk/step_cloth2.ogg"),
	preload("res://audio/walk/step_cloth3.ogg"),
	preload("res://audio/walk/step_cloth4.ogg")
]
var footstep_player: AudioStreamPlayer2D
var footstep_timer: float = 0.0
var footstep_interval: float = 0.25

func _ready():
	# Najdi virtuální joystick
	joystick = get_node_or_null("/root/main/UILayer/VirtualJoystick")
	if not joystick:
		joystick = get_tree().root.find_child("VirtualJoystick", true, false)
	
	# === PŘIDEJ PLAYER GROUP ===
	add_to_group("player")
	name = "PlayerMage"  # ← Ujisti se že má správné jméno!
	
	# Najdi level up menu
	level_up_menu = get_tree().root.find_child("LevelUpMenu", true, false)
	
	if level_up_menu:
		print("Level up menu found!")
	else:
		print("ERROR: Level up menu not found!")
	
	# Najdi Game Over menu
	await get_tree().process_frame
	game_over_menu = get_parent().get_node_or_null("GameOverMenu")
	if not game_over_menu:
		print("WARNING: GameOverMenu not found in scene tree!")

	# Physics setup
	lock_rotation = true
	freeze = false
	linear_damp = 5.0
	
	# Collision shape setup
	var cs = get_node_or_null("CollisionShape2D")
	if cs and cs is CollisionShape2D:
		cs.shape = RectangleShape2D.new()
		cs.shape.extents = Vector2(12, 20)
		cs.position = Vector2(0, 8)
	
	# Footstep audio setup
	footstep_player = AudioStreamPlayer2D.new()
	footstep_player.name = "FootstepPlayer"
	footstep_player.bus = "SFX"
	footstep_player.volume_db = 2
	footstep_player.max_polyphony = 4
	add_child(footstep_player)
	
	# Aplikuj multiplikátory
	_update_stats()
	
	last_fire_position = global_position  # ← Přidej

func _physics_process(delta):
	if current_hp <= 0:
		return
	
	if is_dead:
		return
	
	_handle_movement(delta)
	_handle_attack(delta)
	_regenerate_hp(delta)
	_update_legendary_items(delta)
	
	if not is_dead:
		survival_time += delta
	
	# Debug output
	debug_counter += 1
	if debug_counter % 60 == 0:
		print("Level: ", level, " | EXP: ", current_exp, "/", exp_to_next_level, " | Gold: ", gold, " | Kills: ", kills)
		print("HP_REGEN: ", hp_regen, " | Current HP: ", current_hp, "/", max_hp)
		print("Damage: ", damage, " | Crit Chance: ", critical_chance * 100, "%")

func _handle_movement(delta):
	var input_vector = Vector2.ZERO
	
	# Keyboard input
	var keyboard_input = Vector2.ZERO
	keyboard_input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	keyboard_input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	if keyboard_input.length() > 0:
		input_vector = keyboard_input
	
	# Joystick input
	if joystick and "output" in joystick:
		var joystick_output = joystick.output
		if joystick_output.length() > 0.1:
			input_vector = joystick_output
	
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		linear_velocity = input_vector * move_speed
		
		_handle_footsteps(delta)  # ← Tady se volá
		_handle_fire_trail(delta)
		
		# Animation
		if abs(input_vector.x) > abs(input_vector.y):
			if input_vector.x > 0:
				if anim_player and anim_player.has_animation("walk_right"):
					anim_player.play("walk_right")
			else:
				if anim_player and anim_player.has_animation("walk_left"):
					anim_player.play("walk_left")
		else:
			if input_vector.y > 0:
				if anim_player and anim_player.has_animation("walk_down"):
					anim_player.play("walk_down")
			else:
				if anim_player and anim_player.has_animation("walk_up"):
					anim_player.play("walk_up")
	else:
		linear_velocity = Vector2.ZERO
		footstep_timer = 0.0
		
		if anim_player and anim_player.has_animation("idle"):
			if anim_player.current_animation != "idle":
				anim_player.play("idle")

func _handle_attack(delta):
	attack_timer += delta
	if attack_timer >= 1.0 / attack_speed:
		attack_timer = 0.0
		_shoot_projectiles()

func _shoot_projectiles():
	var nearest_enemies = _find_nearest_enemies(projectile_count)
	
	if nearest_enemies.size() == 0:
		return
	
	for i in range(projectile_count):
		# Critical hit calculation
		var is_crit = randf() < critical_chance
		var final_damage = damage
		
		if is_crit:
			final_damage = int(damage * critical_multiplier)
			print("CRITICAL HIT! ", final_damage, " damage!")
		
		# Create projectile
		var projectile = projectile_scene.instantiate()
		projectile.position = global_position
		
		var target_enemy = nearest_enemies[i % nearest_enemies.size()]
		var direction_to_enemy = (target_enemy.global_position - global_position).normalized()
		
		projectile.direction = direction_to_enemy
		projectile.target_enemy = target_enemy
		projectile.damage = final_damage
		projectile.is_critical = is_crit
		projectile.lifesteal_percent = lifesteal
		projectile.owner_mage = self
		projectile.scale = Vector2(projectile_size, projectile_size)
		get_parent().add_child(projectile)

func _find_nearest_enemies(count: int) -> Array:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var valid_enemies = []
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		
		var distance = global_position.distance_to(enemy.global_position)
		if distance <= attack_range:
			valid_enemies.append({
				"enemy": enemy,
				"distance": distance
			})
	
	valid_enemies.sort_custom(func(a, b): return a.distance < b.distance)
	
	var result = []
	for i in range(min(count, valid_enemies.size())):
		result.append(valid_enemies[i].enemy)
	
	return result

func _regenerate_hp(delta):
	if current_hp < max_hp:
		regen_timer += delta
		if regen_timer >= 1.0:
			current_hp = min(current_hp + int(hp_regen), max_hp)
			regen_timer = 0.0

# === LEGENDARY ITEMS LOGIC ===

func _update_legendary_items(delta):
	# ⚡ Lightning Aura - zap každé 3s
	if has_lightning_aura:
		lightning_aura_timer += delta
		if lightning_aura_timer >= 3.0:
			lightning_aura_timer = 0.0
			_trigger_lightning_aura()
	
	# 🌟 Star Crown - auto shoot každé 0.5s
	if has_star_crown:
		star_crown_timer += delta
		if star_crown_timer >= 0.5:
			star_crown_timer = 0.0
			_trigger_star_crown()
	
	# ❄️ Frost Ring - slow enemies nearby (každých 0.5s)
	if has_frost_ring:
		frost_ring_timer += delta
		if frost_ring_timer >= 0.5:
			frost_ring_timer = 0.0
			_apply_frost_ring()

func _trigger_lightning_aura():
	print("⚡ Lightning Aura triggered!")  # ← Smaž čárku!
	
	var nearest = _find_nearest_enemies(1)
	if nearest.size() == 0:
		return
	
	var enemy = nearest[0]
	if enemy and is_instance_valid(enemy) and enemy.has_method("take_damage"):
		enemy.take_damage(50, false)
		
		# Visual effect - lightning bolt
		var line = Line2D.new()
		line.add_point(global_position)
		line.add_point(enemy.global_position)
		line.width = 3
		line.default_color = Color(0.8, 0.8, 1.0, 1.0)
		get_parent().add_child(line)
		
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(line):
			line.queue_free()

func _trigger_star_crown():
	var orbit_radius = 60.0  # ← Bez čárky!
	var rotation_speed = 3.0  # ← Bez čárky!
	
	for i in range(3):
		var angle_offset = i * 120.0
		var current_angle = (Time.get_ticks_msec() * 0.001 * rotation_speed * 60.0) + angle_offset
		var angle_rad = deg_to_rad(current_angle)
		
		var offset = Vector2(cos(angle_rad), sin(angle_rad)) * orbit_radius
		
		var projectile = projectile_scene.instantiate()
		projectile.position = global_position + offset  # ← Plus, ne čárka!
		projectile.direction = offset.normalized()
		projectile.damage = damage
		projectile.is_critical = false
		projectile.lifesteal_percent = lifesteal
		projectile.owner_mage = self
		projectile.modulate = Color(1.0, 0.9, 0.3)
		projectile.scale = Vector2(1.2, 1.2)
		
		get_parent().add_child(projectile)

func _apply_frost_ring():
	var enemies = get_tree().get_nodes_in_group("enemies")
	var current_frozen = []
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		
		var distance = global_position.distance_to(enemy.global_position)
		
		if distance <= 120:
			current_frozen.append(enemy)
			
			if "move_speed" in enemy and "difficulty_multiplier" in enemy:
				var base_speed = 100.0 * enemy.difficulty_multiplier
				enemy.move_speed = base_speed * 0.5
				
				if enemy.has_node("Sprite2D"):
					enemy.get_node("Sprite2D").modulate = Color(0.5, 0.7, 1.0)
	
	for enemy in frozen_enemies:
		if is_instance_valid(enemy) and enemy not in current_frozen:
			if "move_speed" in enemy and "difficulty_multiplier" in enemy:
				var base_speed = 100.0 * enemy.difficulty_multiplier
				enemy.move_speed = base_speed
				
				if enemy.has_node("Sprite2D"):
					enemy.get_node("Sprite2D").modulate = Color(1, 1, 1)
	
	frozen_enemies = current_frozen

# === END LEGENDARY ITEMS ===

func _handle_footsteps(delta):
	footstep_timer += delta
	
	if footstep_timer >= footstep_interval:
		footstep_timer = 0.0
		_play_random_footstep()

func _play_random_footstep():
	if footstep_player and footstep_sounds.size() > 0:
		var random_sound = footstep_sounds[randi() % footstep_sounds.size()]
		footstep_player.stream = random_sound
		footstep_player.play()

func _update_stats():
	max_hp = int(base_max_hp * hp_multiplier)
	damage = int(base_damage * damage_multiplier)
	hp_regen = base_hp_regen * regen_multiplier
	move_speed = base_move_speed * speed_multiplier
	attack_speed = base_attack_speed * attack_speed_multiplier
	
	current_hp = min(current_hp, max_hp)
	
	print("Stats updated! HP:", max_hp, " DMG:", damage, " Regen:", hp_regen, " Speed:", move_speed)

func _handle_fire_trail(delta):
	if not has_fireboots:
		return
	
	var distance = global_position.distance_to(last_fire_position)
	
	if distance >= 15.0:  # Každých 15px = hustý trail
		_spawn_fire_trail()
		last_fire_position = global_position

func _spawn_fire_trail():
	var fire = Node2D.new()
	fire.name = "FireTrail"
	fire.position = global_position
	fire.z_index = 5
	
	# Sprite
	var rect = ColorRect.new()
	rect.color = Color(1.0, 0.4, 0.0, 0.8)
	rect.size = Vector2(30, 30)
	rect.position = Vector2(-15, -15)
	fire.add_child(rect)
	
	# Damage area
	var area = Area2D.new()
	area.collision_layer = 0
	area.collision_mask = 2
	
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 20
	collision.shape = shape
	area.add_child(collision)
	fire.add_child(area)
	
	get_parent().add_child(fire)
	
	# Damage timer
	var timer = Timer.new()
	timer.wait_time = 0.2
	timer.one_shot = false
	fire.add_child(timer)
	
	timer.timeout.connect(func():
		for body in area.get_overlapping_bodies():
			if body.is_in_group("enemies") and body.has_method("take_damage"):
				body.take_damage(8, false)
	)
	timer.start()
	
	# Fade out
	await get_tree().create_timer(1.0).timeout
	timer.stop()
	
	var tween = create_tween()
	tween.tween_property(rect, "modulate:a", 0.0, 0.3)
	await tween.finished
	
	if is_instance_valid(fire):
		fire.queue_free()

func take_damage(amount: int):
	if is_dead:
		return
	
	# Shadow Cloak dodge
	if has_shadow_cloak and randf() < dodge_chance:
		print("💀 DODGED!")
		
		if sprite:
			var original_alpha = sprite.modulate.a
			sprite.modulate.a = 0.3
			await get_tree().create_timer(0.1).timeout
			sprite.modulate.a = original_alpha
		
		return
	
	var reduced = int(amount * (1.0 - defense))
	current_hp -= reduced
	print("👤 Player took ", reduced, " damage! HP: ", current_hp, "/", max_hp)
	
	if current_hp <= 0:
		die()

func heal(amount: int):
	current_hp = min(current_hp + amount, max_hp)

func die():
	if is_dead:
		return
	
	is_dead = true
	current_hp = 0
	print("💀 Player died!")
	
	var player_name = PlayerProfile.get_player_name()
	var score = kills * 100 + level * 50 + gold
	SupabaseManager.submit_score(player_name, score, kills, survival_time)
	
	await get_tree().process_frame
	
	if game_over_menu and is_instance_valid(game_over_menu):
		game_over_menu.show_game_over(self, survival_time)
	else:
		print("ERROR: Game Over menu not found!")
		get_tree().paused = true

func add_exp(amount: int):
	current_exp += amount
	print("Gained ", amount, " EXP! Total: ", current_exp, "/", exp_to_next_level)
	
	if current_exp >= exp_to_next_level:
		level_up()

func level_up():
	level += 1
	current_exp -= exp_to_next_level
	exp_to_next_level = int(exp_to_next_level * exp_multiplier)
	
	current_hp = max_hp
	
	print("🎉 LEVEL UP! Level ", level)
	
	if level_up_menu:
		level_up_menu.show_level_up(self, luck)

func add_gold(amount: int):
	gold += amount

func add_kill():
	kills += 1
