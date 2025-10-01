extends CharacterBody2D

signal health_changed(current: int, max: int)
signal died(is_boss: bool)

@export var move_speed: float = 60.0
@export var base_max_health: int = 20
@export var base_attack: int = 4
@export var is_boss: bool = false
var current_health: int = 0

var player: Node2D = null
var _attack_timer: float = 0.0
@export var attack_interval_seconds: float = 1.2


func _ready() -> void:
	add_to_group("enemies")
	var scale: float = Game.get_enemy_scale_multiplier()
	var boss_mult: float = 1.6 if is_boss else 1.0
	base_max_health = int(round(base_max_health * scale * boss_mult))
	base_attack = int(round(base_attack * scale * (1.3 if is_boss else 1.0)))
	current_health = base_max_health
	var main: Node = get_tree().current_scene
	if main:
		player = main.get_node_or_null("Player") as Node2D
	emit_signal("health_changed", current_health, base_max_health)
	if is_boss:
		attack_interval_seconds *= 1.2
	

func _physics_process(delta: float) -> void:
	if player and is_instance_valid(player):
		var dir_x: float = -1.0
		var desired_y: float = player.global_position.y
		var dy: float = clamp(desired_y - global_position.y, -1.0, 1.0)
		velocity = Vector2(dir_x * move_speed, dy * move_speed * 0.25)
	else:
		velocity = Vector2.ZERO
	move_and_slide()

	_attack_timer += delta
	if _attack_timer >= attack_interval_seconds:
		_attack_timer = 0.0
		_attack_player()

func _attack_player() -> void:
	if Game.player_current_hp > 0:
		Game.on_player_damaged(base_attack)
		# až budeš mít animaci "attack", můžeš ji odkomentovat
		# if anim:
		#	anim.play("attack")

func take_damage(amount: int) -> void:
	current_health -= amount
	emit_signal("health_changed", current_health, base_max_health)
	if current_health <= 0:
		die()
	else:
		_hit_flash()
		# až budeš mít animaci "hit", můžeš ji přidat:
		# if anim:
		#	anim.play("hit")

func die() -> void:
	# až bude animace "death", můžeš přidat:
	# if anim:
	#	anim.play("death")
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	var base_gold: int = rng.randi_range(1, 3) * (3 if is_boss else 1)
	var mult: float = Game.get_gold_multiplier_for_wave()
	Game.add_gold(int(round(float(base_gold) * mult)))
	emit_signal("died", is_boss)
	queue_free()

func _hit_flash() -> void:
	var sprite: Sprite2D = get_node_or_null("Sprite") as Sprite2D
	if not sprite:
		return
	var original: Color = sprite.modulate
	sprite.modulate = Color(1, 1, 1, 1)
	await get_tree().create_timer(0.08).timeout
	if is_instance_valid(sprite):
		sprite.modulate = original
