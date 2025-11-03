extends Area2D

enum OrbType { EXP, GOLD }

var orb_type: OrbType = OrbType.EXP
var value: int = 10
var move_speed: float = 200.0
var attraction_range: float = 50.0  # Zmenšeno ze 150.0 na 50.0
var player = null

@onready var sprite = $Sprite2D

# Textury pro různé typy orbů
var texture_exp = preload("res://assets/PlayerMageTexture/orb_exp.png")
var texture_gold = preload("res://assets/PlayerMageTexture/orb_gold.png")

func _ready():
	body_entered.connect(_on_body_entered)
	player = get_tree().root.find_child("PlayerMage", true, false)
	
	# Nastav texturu podle typu
	match orb_type:
		OrbType.EXP:
			sprite.texture = texture_exp
		OrbType.GOLD:
			sprite.texture = texture_gold

func _physics_process(delta):
	if player and is_instance_valid(player):
		var distance = global_position.distance_to(player.global_position)
		
		# Pokud je hráč blízko, přitahuj orb
		if distance < attraction_range:
			var direction = (player.global_position - global_position).normalized()
			global_position += direction * move_speed * delta
			
			# Zvyš rychlost čím blíž je hráč
			move_speed = min(move_speed + 300.0 * delta, 800.0)

func _on_body_entered(body):
	if body.name == "PlayerMage":
		match orb_type:
			OrbType.EXP:
				if body.has_method("add_exp"):
					body.add_exp(value)
			OrbType.GOLD:
				if body.has_method("add_gold"):
					body.add_gold(value)
		queue_free()

func set_orb_type(type: OrbType, amount: int):
	orb_type = type
	value = amount
