extends Node

signal wave_started(wave: int, enemy_count: int, is_boss: bool)
signal wave_cleared(wave: int)

@export var base_enemies_per_wave: int = 3

var enemies_remaining: int = 0

func start_wave() -> Dictionary:
    var is_boss := Game.is_boss_wave()
    var count := base_enemies_per_wave + (Game.current_wave - 1)
    if is_boss:
        count = max(1, count - 1) # One boss instead of adding
    enemies_remaining = count
    emit_signal("wave_started", Game.current_wave, enemies_remaining, is_boss)
    return {"count": enemies_remaining, "is_boss": is_boss}

func on_enemy_killed(is_boss: bool) -> void:
    enemies_remaining = max(0, enemies_remaining - 1)
    if enemies_remaining == 0:
        if is_boss:
            Game.roll_boss_chest_and_add()
        emit_signal("wave_cleared", Game.current_wave)
        Game.advance_wave()
        # start next wave automatically after short delay
        await get_tree().create_timer(1.0).timeout
        var main := get_tree().current_scene
        if main and main.has_method("_start_wave"):
            main._start_wave()

func set_expected_enemies(total: int) -> void:
    enemies_remaining = max(0, total)


