extends CanvasLayer

@onready var health_bar_full = $HealthBarContainer/HealthBarFull
@onready var health_bar_empty = $HealthBarContainer/HealthBarEmpty
@onready var health_text = $HealthBarContainer/HealthText

var player = null
var max_bar_width = 164.0  # Šířka baru: -56 - (-220) = 164

func _ready():
    player = get_tree().root.find_child("PlayerMage", true, false)

func _process(delta):
    if player:
        _update_health_bar()

func _update_health_bar():
    # Procento chybějícího HP
    var missing_health_percent = 1.0 - (float(player.current_hp) / float(player.max_hp))
    
    # Tmavý bar překrývá zprava doleva podle chybějícího HP
    var empty_width = max_bar_width * missing_health_percent
    health_bar_empty.size.x = empty_width
    # Posun tmavý bar doprava podle tvé pozice
    health_bar_empty.position.x = -220.0 + (max_bar_width - empty_width)
    
    health_text.text = str(player.current_hp) + " / " + str(player.max_hp)
