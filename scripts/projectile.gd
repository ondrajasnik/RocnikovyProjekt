extends Area2D

var direction = Vector2.RIGHT
var speed = 350.0
var damage = 10
var lifetime = 3.0
var lifesteal_percent = 0.0
var owner_mage = null

# NOVÉ - tracking systém
var target_enemy = null
var homing_strength = 5.0  # Síla navádění (vyšší = ostřejší zatáčky)

func _ready():
    body_entered.connect(_on_body_entered)

func _process(delta):
    # Pokud máme cíl a je stále platný, sleduj ho
    if target_enemy and is_instance_valid(target_enemy):
        var desired_direction = (target_enemy.global_position - global_position).normalized()
        direction = direction.lerp(desired_direction, homing_strength * delta).normalized()
    
    position += direction * speed * delta
    
    lifetime -= delta
    if lifetime <= 0:
        queue_free()

func _on_body_entered(body):
    if body.is_in_group("enemies"):
        body.take_damage(damage)
        
        # Lifesteal - vrať HP hráči
        if owner_mage and lifesteal_percent > 0:
            var heal_amount = damage * lifesteal_percent
            owner_mage.heal(heal_amount)
        
        queue_free()