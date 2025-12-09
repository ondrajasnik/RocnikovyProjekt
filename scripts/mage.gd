extends RigidBody2D

# --- Statistiky ---
var max_hp: int = 100
var current_hp: int = 100
var hp_regen: float = 2.0
var damage: int = 10
var projectile_count: int = 1
var projectile_size: float = 1.0
var attack_speed: float = 1.0
var move_speed: float = 250.0
var defense: float = 0.2
var lifesteal: float = 0.1
var attack_range: float = 300.0

# Critical hit system
var critical_chance: float = 0.15
var critical_multiplier: float = 2.0

# --- Level systém ---
var level: int = 1
var current_exp: int = 95
var exp_to_next_level: int = 100
var exp_multiplier: float = 1.5

# --- Gold a Kills systém ---
var gold: int = 0
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

func _physics_process(delta):
	if is_dead:
		return
	
	_handle_movement(delta)
	_handle_attack(delta)
	_regenerate_hp(delta)
	
	if not is_dead:
		survival_time += delta
	
	# Debug output
	debug_counter += 1
	if debug_counter % 60 == 0:
		print("Level: ", level, " | EXP: ", current_exp, "/", exp_to_next_level, " | Gold: ", gold, " | Kills: ", kills)
		print("HP_REGEN: ", hp_regen, " | Current HP: ", current_hp, "/", max_hp)

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
		
		_handle_footsteps(delta)
		
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
			print("Regenerated +", int(hp_regen), " HP | Current: ", current_hp, "/", max_hp)
			regen_timer = 0.0

func add_exp(amount: int):
	current_exp += amount
	print("Gained ", amount, " EXP! Total: ", current_exp, "/", exp_to_next_level)
	
	if current_exp >= exp_to_next_level:
		level_up()

func level_up():
	level += 1
	current_exp -= exp_to_next_level
	exp_to_next_level = int(exp_to_next_level * exp_multiplier)
	
	print("LEVEL UP! Level ", level)
	
	if level_up_menu:
		level_up_menu.show_level_up(self, luck)

func add_gold(amount: int):
	gold += amount
	print("Gained ", amount, " gold! Total: ", gold)

func add_kill():
	kills += 1
	print("Kill! Total kills: ", kills)

func take_damage(amount: int):
	if is_dead:
		return
	
	var reduced = amount * (1.0 - defense)
	current_hp -= reduced
	print("Player took ", reduced, " damage! HP: ", current_hp, "/", max_hp)
	if current_hp <= 0:
		die()

func heal(amount: int):
	current_hp = min(current_hp + amount, max_hp)

func die():
	if is_dead:
		return
	
	is_dead = true
	current_hp = 0
	print("Player died!")
	
	var player_name = PlayerProfile.get_player_name()
	var score = kills * 100 + level * 50 + gold
	SupabaseManager.submit_score(player_name, score, kills, survival_time)
	
	await get_tree().process_frame
	
	if game_over_menu and is_instance_valid(game_over_menu):
		game_over_menu.show_game_over(self, survival_time)
	else:
		print("ERROR: Game Over menu not found!")
		get_tree().paused = true

func _handle_footsteps(delta):
	footstep_timer += delta
	
	if footstep_timer >= footstep_interval:
		footstep_timer = 0.0
		_play_random_footstep()

func _play_random_footstep():
	var random_sound = footstep_sounds[randi() % footstep_sounds.size()]
	footstep_player.stream = random_sound
	footstep_player.play()
