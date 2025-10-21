extends Node

# Ability class to define different spells and their effects
class Ability:
    var name: String
    var mana_cost: int
    var cooldown: float
    var last_cast_time: float = 0.0

    func _init(name: String, mana_cost: int, cooldown: float):
        self.name = name
        self.mana_cost = mana_cost
        self.cooldown = cooldown

    func can_cast(current_time: float, current_mana: int) -> bool:
        return (current_time - last_cast_time >= cooldown) and (current_mana >= mana_cost)

    func cast() -> void:
        last_cast_time = OS.get_ticks_msec() / 1000.0

# Define Mage abilities
var abilities: Dictionary = {
    "fireball": Ability.new("Fireball", 10, 2.0),
    "ice_shard": Ability.new("Ice Shard", 8, 1.5),
    "lightning_strike": Ability.new("Lightning Strike", 12, 3.0)
}

func get_ability(name: String) -> Ability:
    return abilities.get(name, null)

func cast_ability(name: String, current_time: float, current_mana: int) -> bool:
    var ability = get_ability(name)
    if ability and ability.can_cast(current_time, current_mana):
        ability.cast()
        return true
    return false