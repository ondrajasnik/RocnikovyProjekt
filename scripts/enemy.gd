extends RigidBody2D

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
var attack_range: float = 80.0  # Zvětšeno z 50.0 na 80.0
var detection_range: float = 200.0
var difficulty_multiplier: float = 1.0  # Zvyšuje se s časem/vlnami

var player = null
var attack_timer: float = 0.0
var is_attacking: bool = false

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

func _apply_difficulty():
	# Aplikuje difficulty multiplier na statistiky
	max_hp = int(base_max_hp * difficulty_multiplier)
	current_hp = max_hp
	damage = int(base_damage * difficulty_multiplier)
	move_speed = base_move_speed * difficulty_multiplier
	attack_speed = base_attack_speed * difficulty_multiplier

func _physics_process(delta):
	# Pokus najít hráče, pokud není nastaven
	if not player:
		player = get_tree().root.find_child("PlayerMage", true, false)
	
	if player and is_instance_valid(player):
		_follow_player(delta)
		_update_attack(delta)
	else:
		linear_velocity = Vector2.ZERO

func _follow_player(delta):
	var direction = (player.global_position - global_position).normalized()
	var distance = global_position.distance_to(player.global_position)
	
	# Pohyb k hráči, ale zastaví se v attack_range
	if distance > attack_range:
		linear_velocity = direction * move_speed
		_play_walk_animation(direction)
		is_attacking = false
	else:
		linear_velocity = Vector2.ZERO
		is_attacking = true

func _update_attack(delta):
	# Aktualizuje attack timer a útočí podle attack_speed
	if not is_attacking:
		attack_timer = 0.0
		return
	
	attack_timer += delta
	var attack_interval = 1.0 / attack_speed  # Převod útoků/s na sekundy mezi útoky
	
	if attack_timer >= attack_interval:
		_attack_player()
		attack_timer = 0.0

func _play_walk_animation(direction: Vector2):
	if not anim_player:
		return
	
	# Určení směru a přehrání správné animace
	if abs(direction.x) > abs(direction.y):
		# Pohyb vlevo/vpravo
		if direction.x > 0:
			anim_player.play("walk_right")
		else:
			anim_player.play("walk_left")
	else:
		# Pohyb nahoru/dolů
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
			print("Enemy dealt ", damage, " damage! Player HP: ", player.current_hp)

func _on_detection_area_body_entered(body):
	if body.name == "PlayerMage":
		player = body

func _on_detection_area_body_exited(body):
	if body == player:
		player = null
		is_attacking = false

func take_damage(amount):
	current_hp -= amount
	_update_health_bar()
	
	# Flash efekt při zásahu
	sprite.modulate = Color.WHITE
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1, 1, 1, 1)
	
	if current_hp <= 0:
		die()

func _update_health_bar():
	health_bar.max_value = max_hp
	health_bar.value = current_hp

func increase_difficulty(multiplier: float):
	# Zvýší obtížnost nepřítele (volej při spawnu nových vln)
	difficulty_multiplier = multiplier
	_apply_difficulty()

func die():
	print("Enemy died!")
	queue_free()
