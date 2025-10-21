extends RigidBody2D

# --- Statistiky ---
var max_hp: int = 100
var current_hp: int = 100
var hp_regen: float = 2.0
var damage: int = 10
var projectile_count: int = 1
var projectile_size: float = 1.0
var attack_speed: float = 1.0 # útoky za sekundu
var move_speed: float = 250.0
var defense: float = 0.2 # 20% snížení damage
var lifesteal: float = 0.1 # 10% poškození vráceno jako HP

var attack_timer := 0.0

# Přidej načtení scény projektilu na začátek
var projectile_scene = preload("res://scenes/projectile.tscn")
var joystick: Node = null

@onready var sprite = $Sprite2D
@onready var anim_player = $AnimationPlayer

var debug_counter = 0

func _ready():
	# Najdi virtuální joystick ve scéně
	joystick = get_node_or_null("/root/main/UILayer/VirtualJoystick")
	if not joystick:
		joystick = get_tree().root.find_child("VirtualJoystick", true, false)
	
	# Zajisti, že tělo není zmrazené a rotace je zamčená
	lock_rotation = true
	freeze = false
	linear_damp = 5.0

func _physics_process(delta):
	_handle_movement()
	_handle_attack(delta)
	_regenerate_hp(delta)
	
	# Vypis pozice každých 60 framů (cca 1x za sekundu)
	debug_counter += 1
	if debug_counter % 60 == 0:
		print("Pozice hráče: ", global_position)

func _handle_movement():
	var input_vector = Vector2.ZERO
	
	# Pohyb pomocí šipek
	var keyboard_input = Vector2.ZERO
	keyboard_input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	keyboard_input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	if keyboard_input.length() > 0:
		input_vector = keyboard_input
	
	# Pohyb pomocí joysticku (pokud existuje)
	if joystick and "output" in joystick:
		var joystick_output = joystick.output
		if joystick_output.length() > 0.1:  # Dead zone
			input_vector = joystick_output
	
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		linear_velocity = input_vector * move_speed
		
		# Určení směru a přehrání správné animace
		if abs(input_vector.x) > abs(input_vector.y):
			# Pohyb vlevo/vpravo
			if input_vector.x > 0:
				if anim_player and anim_player.has_animation("walk_right"):
					anim_player.play("walk_right")
			else:
				if anim_player and anim_player.has_animation("walk_left"):
					anim_player.play("walk_left")
		else:
			# Pohyb nahoru/dolů
			if input_vector.y > 0:
				if anim_player and anim_player.has_animation("walk_down"):
					anim_player.play("walk_down")
			else:
				if anim_player and anim_player.has_animation("walk_up"):
					anim_player.play("walk_up")
	else:
		linear_velocity = Vector2.ZERO
		
		# Přehrávání animace idle
		if anim_player and anim_player.has_animation("idle"):
			if anim_player.current_animation != "idle":
				anim_player.play("idle")

func _handle_attack(delta):
	attack_timer += delta
	if attack_timer >= 1.0 / attack_speed:
		attack_timer = 0.0
		_shoot_projectiles()

func _shoot_projectiles():
	for i in range(projectile_count):
		var projectile = projectile_scene.instantiate()
		projectile.position = global_position
		projectile.direction = Vector2.RIGHT.rotated(deg_to_rad(i * (360.0 / projectile_count)))
		projectile.damage = damage
		projectile.lifesteal_percent = lifesteal
		projectile.owner_mage = self
		projectile.scale = Vector2(projectile_size, projectile_size)
		get_parent().add_child(projectile)

func _regenerate_hp(delta):
	current_hp = min(current_hp + hp_regen * delta, max_hp)

func take_damage(amount):
	var reduced = amount * (1.0 - defense)
	current_hp -= reduced
	if current_hp <= 0:
		queue_free() # smrt hráče

func heal(amount):
	current_hp = min(current_hp + amount, max_hp)
