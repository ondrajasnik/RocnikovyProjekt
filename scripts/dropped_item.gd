extends Area2D

@onready var sprite = $Sprite2D
@onready var anim_player = $AnimationPlayer
@onready var pickup_label = $PickupLabel
@onready var lifetime_timer = $LifetimeTimer

var item_type = null
var item_data = {}
var player_nearby = false

func _ready():
    add_to_group("dropped_items")
    
    collision_layer = 16  # Layer 5
    collision_mask = 1    # Detect player
    
    # Connect signals
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)
    lifetime_timer.timeout.connect(_on_lifetime_timeout)
    
    # Start animations
    if anim_player:
        anim_player.play("spawn")
        await anim_player.animation_finished
        anim_player.play("idle")
    
    # Start lifetime timer
    lifetime_timer.start()
    
    z_index = 100

func setup(type, data: Dictionary, texture: Texture2D):
    item_type = type
    item_data = data
    
    if sprite and texture:
        sprite.texture = texture
    
    print("Dropped item: ", data.name)

func _input(event):
    if player_nearby and visible and event.is_action_pressed("ui_accept"):  # E key
        _pickup()

func _on_body_entered(body):
    if body.name == "PlayerMage":
        player_nearby = true
        if pickup_label:
            pickup_label.visible = true

func _on_body_exited(body):
    if body.name == "PlayerMage":
        player_nearby = false
        if pickup_label:
            pickup_label.visible = false

func _pickup():
    if not item_type or not item_data:
        return
    
    var player = get_tree().root.find_child("PlayerMage", true, false)
    if not player:
        return
    
    print("🎁 Picked up: ", item_data.name)
    
    # Apply item effect
    _apply_item_to_player(player)
    
    # Show notification
    _show_pickup_notification()
    
    # Remove item
    queue_free()

func _apply_item_to_player(player):
    match item_type:
        0: # LUCKY_DICE
            player.luck += 0.2
            print("🎲 Luck: ", player.luck)
        1: # RED_APPLE
            player.base_max_hp += 20
            player._update_stats()
            print("🍎 Max HP: ", player.max_hp)
        2: # BLUE_POTION
            player.base_hp_regen += 1.0
            player._update_stats()
            print("💙 HP Regen: ", player.hp_regen)
        3: # LIGHTNING_BOLT
            player.attack_speed_multiplier *= 1.1
            player._update_stats()
            print("⚡ Attack Speed boosted!")
        4: # IRON_SHIELD
            player.defense += 0.05
            print("🛡️ Defense: ", player.defense)
        5: # RUBY
            player.critical_chance += 0.10
            print("💎 Crit Chance: ", player.critical_chance * 100, "%")
        6: # SHARP_DAGGER
            player.damage_multiplier *= 1.15
            player._update_stats()
            print("🗡️ Damage boosted!")
        7: # BOOTS
            player.speed_multiplier *= 1.1
            player._update_stats()
            print("👟 Speed boosted!")
        8: # FIREBOOTS
            player.has_fireboots = true
            print("🔥 FIREBOOTS EQUIPPED!")
        9: # LIGHTNING_AURA
            player.has_lightning_aura = true
            print("⚡ LIGHTNING AURA ACTIVATED!")
        10: # FROST_RING
            player.has_frost_ring = true
            print("❄️ FROST RING EQUIPPED!")
        11: # SHADOW_CLOAK
            player.has_shadow_cloak = true
            player.dodge_chance = 0.20
            print("💀 SHADOW CLOAK EQUIPPED!")
        12: # STAR_CROWN
            player.has_star_crown = true
            print("🌟 STAR CROWN EQUIPPED!")

func _show_pickup_notification():
    var notif = Label.new()
    notif.text = "🎁 %s" % item_data.name
    notif.add_theme_font_size_override("font_size", 28)
    notif.add_theme_color_override("font_color", item_data.get("color", Color(1, 1, 1)))
    notif.add_theme_color_override("font_outline_color", Color(0, 0, 0))
    notif.add_theme_constant_override("outline_size", 3)
    notif.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    notif.position = global_position + Vector2(-50, -80)
    notif.z_index = 10000
    
    get_tree().current_scene.add_child(notif)
    
    # Animate up and fade
    var tween = get_tree().create_tween()
    tween.set_parallel(true)
    tween.tween_property(notif, "position:y", notif.position.y - 50, 1.5)
    tween.tween_property(notif, "modulate:a", 0.0, 1.5)
    
    await tween.finished
    notif.queue_free()

func _on_lifetime_timeout():
    print("⏱️ Item expired: ", item_data.name)
    
    # Fade out
    var tween = get_tree().create_tween()
    tween.tween_property(self, "modulate:a", 0.0, 0.5)
    await tween.finished
    
    queue_free()