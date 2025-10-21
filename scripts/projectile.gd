extends Area2D

var speed: float = 400.0
var direction: Vector2 = Vector2.RIGHT
var damage: int = 10
var lifesteal_percent: float = 0.1
var owner_mage = null

func _ready():
    body_entered.connect(_on_body_entered)

func _physics_process(delta):
    position += direction * speed * delta

func _on_body_entered(body):
    if body.is_in_group("enemies"):
        # Způsob damage nepříteli
        if body.has_method("take_damage"):
            body.take_damage(damage)
        
        # Vrátí HP hráči (lifesteal)
        if owner_mage and owner_mage.has_method("heal"):
            var heal_amount = damage * lifesteal_percent
            owner_mage.heal(heal_amount)
        
        queue_free() # Zničí projektil po zásahu
    elif body != owner_mage:
        queue_free() # Zničí projektil při kolizi s jiným objektem