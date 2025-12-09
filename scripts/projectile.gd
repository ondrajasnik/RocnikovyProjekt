extends Area2D

var speed = 300.0
var direction = Vector2.ZERO
var damage: int = 10
var is_critical: bool = false  # ← PŘIDEJ!
var target_enemy = null
var lifesteal_percent = 0.0
var owner_mage = null

func _ready():
    body_entered.connect(_on_body_entered)

func _process(delta):
    if target_enemy and is_instance_valid(target_enemy):
        direction = (target_enemy.global_position - global_position).normalized()
    
    position += direction * speed * delta

func _on_body_entered(body):
    if body.is_in_group("enemies"):
        body.take_damage(damage, is_critical)  # ← PŘEDEJ is_critical!
        
        if lifesteal_percent > 0 and owner_mage and is_instance_valid(owner_mage):
            var heal_amount = int(damage * lifesteal_percent)
            owner_mage.heal(heal_amount)
        
        queue_free()