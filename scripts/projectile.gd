extends Area2D

var speed: float = 400.0
var direction: Vector2 = Vector2.RIGHT
var damage: int = 10
var lifesteal_percent: float = 0.0
var owner_mage = null

@onready var sprite = $Sprite2D
@onready var lifetime_timer = $Lifetime

func _ready():
    body_entered.connect(_on_body_entered)
    lifetime_timer.timeout.connect(_on_lifetime_timeout)
    
    # Rotace fireballu podle směru letu
    rotation = direction.angle()

func _physics_process(delta):
    position += direction * speed * delta

func _on_body_entered(body):
    # Kontrola, zda zasáhl nepřítele
    if body.is_in_group("enemies"):
        if body.has_method("take_damage"):
            body.take_damage(damage)
            
            # Lifesteal - vrať HP vlastníkovi
            if owner_mage and owner_mage.has_method("heal"):
                var heal_amount = damage * lifesteal_percent
                owner_mage.heal(heal_amount)
            
            queue_free()  # Zničí projektil po zásahu

func _on_lifetime_timeout():
    queue_free()  # Zničí projektil po 3 sekundách