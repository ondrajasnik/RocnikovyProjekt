extends CanvasLayer

@onready var health_bar_full = $HealthBarContainer/HealthBarFull
@onready var health_bar_empty = $HealthBarContainer/HealthBarEmpty
@onready var health_text = $HealthBarContainer/HealthText
@onready var level_label = $LevelContainer/LevelLabel
@onready var gold_label = $GoldContainer/GoldLabel
@onready var kills_label = $KillsContainer/KillsLabel

var player = null
var max_bar_width = 164.0  # Šířka baru: 23 - (-141) = 164

func _ready():
    player = get_tree().root.find_child("PlayerMage", true, false)

func _process(delta):
    if player:
        _update_health_bar()
        _update_level_display()
        _update_gold_display()
        _update_kills_display()

func _update_health_bar():
    # Procento chybějícího HP
    var missing_health_percent = 1.0 - (float(player.current_hp) / float(player.max_hp))
    
    # Tmavý bar překrývá zprava doleva podle chybějícího HP
    var empty_width = max_bar_width * missing_health_percent
    health_bar_empty.size.x = empty_width
    # Posun tmavý bar doprava - NOVÉ offsety: začíná na -141.0
    health_bar_empty.position.x = -141.0 + (max_bar_width - empty_width)
    
    health_text.text = str(player.current_hp) + " / " + str(player.max_hp)

func _update_level_display():
    level_label.text = "LVL " + str(player.level)

func _update_gold_display():
    gold_label.text = str(player.gold)

func _update_kills_display():
    kills_label.text = "KILLS: " + str(player.kills)
