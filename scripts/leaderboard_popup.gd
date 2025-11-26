extends CanvasLayer

@onready var close_button = $CenterContainer/Panel/VBoxContainer/HeaderContainer/CloseButton
@onready var refresh_button = $CenterContainer/Panel/VBoxContainer/RefreshButton
@onready var loading_label = $CenterContainer/Panel/VBoxContainer/LoadingLabel
@onready var leaderboard_list = $CenterContainer/Panel/VBoxContainer/ScrollContainer/LeaderboardList

func _ready():
    close_button.pressed.connect(_on_close_pressed)
    refresh_button.pressed.connect(_on_refresh_pressed)
    
    # Připoj se na Supabase signál
    SupabaseManager.leaderboard_loaded.connect(_on_leaderboard_loaded)
    
    # Načti data
    _load_leaderboard()

func _load_leaderboard():
    loading_label.visible = true
    refresh_button.disabled = true
    
    # Smaž staré záznamy
    for child in leaderboard_list.get_children():
        child.queue_free()
    
    # Načti z Supabase
    SupabaseManager.fetch_leaderboard()

func _on_leaderboard_loaded(data):
    loading_label.visible = false
    refresh_button.disabled = false
    
    # Smaž staré záznamy
    for child in leaderboard_list.get_children():
        child.queue_free()
    
    if data.size() == 0:
        var empty_label = Label.new()
        empty_label.text = "No scores yet. Be the first!"
        empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        empty_label.add_theme_font_size_override("font_size", 18)
        leaderboard_list.add_child(empty_label)
        return
    
    # Přidej header
    _add_header()
    
    # Přidej každý záznam
    for i in range(data.size()):
        var entry = data[i]
        _add_leaderboard_entry(i + 1, entry)

func _add_header():
    var header = HBoxContainer.new()
    header.add_theme_constant_override("separation", 20)
    
    var rank_label = Label.new()
    rank_label.text = "Rank"
    rank_label.custom_minimum_size = Vector2(60, 0)
    rank_label.add_theme_font_size_override("font_size", 16)
    rank_label.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
    
    var name_label = Label.new()
    name_label.text = "Player"
    name_label.custom_minimum_size = Vector2(200, 0)
    name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    name_label.add_theme_font_size_override("font_size", 16)
    name_label.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
    
    var score_label = Label.new()
    score_label.text = "Score"
    score_label.custom_minimum_size = Vector2(100, 0)
    score_label.add_theme_font_size_override("font_size", 16)
    score_label.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
    score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    
    var kills_label = Label.new()
    kills_label.text = "Kills"
    kills_label.custom_minimum_size = Vector2(70, 0)
    kills_label.add_theme_font_size_override("font_size", 16)
    kills_label.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
    kills_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    
    header.add_child(rank_label)
    header.add_child(name_label)
    header.add_child(score_label)
    header.add_child(kills_label)
    
    leaderboard_list.add_child(header)
    
    # Separator
    var separator = ColorRect.new()
    separator.custom_minimum_size = Vector2(0, 2)
    separator.color = Color(0.5, 0.5, 0.5, 0.5)
    leaderboard_list.add_child(separator)

func _add_leaderboard_entry(rank: int, entry: Dictionary):
    var row = HBoxContainer.new()
    row.add_theme_constant_override("separation", 20)
    
    # Medal pro top 3
    var rank_text = str(rank)
    if rank == 1:
        rank_text = "🥇"
    elif rank == 2:
        rank_text = "🥈"
    elif rank == 3:
        rank_text = "🥉"
    
    var rank_label = Label.new()
    rank_label.text = rank_text
    rank_label.custom_minimum_size = Vector2(60, 0)
    rank_label.add_theme_font_size_override("font_size", 20)
    rank_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    
    var name_label = Label.new()
    name_label.text = entry.get("player_name", "Unknown")
    name_label.custom_minimum_size = Vector2(200, 0)
    name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    name_label.add_theme_font_size_override("font_size", 18)
    
    # Zvýrazni aktuálního hráče
    if PlayerProfile.is_player_registered() and entry.get("player_name") == PlayerProfile.get_player_name():
        name_label.add_theme_color_override("font_color", Color(0.2, 1, 0.3))
        name_label.text += " (You)"
    
    var score_label = Label.new()
    score_label.text = str(int(entry.get("score", 0)))
    score_label.custom_minimum_size = Vector2(100, 0)
    score_label.add_theme_font_size_override("font_size", 18)
    score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    
    var kills_label = Label.new()
    kills_label.text = str(int(entry.get("kills", 0)))
    kills_label.custom_minimum_size = Vector2(70, 0)
    kills_label.add_theme_font_size_override("font_size", 18)
    kills_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    
    row.add_child(rank_label)
    row.add_child(name_label)
    row.add_child(score_label)
    row.add_child(kills_label)
    
    leaderboard_list.add_child(row)

func _on_refresh_pressed():
    _load_leaderboard()

func _on_close_pressed():
    # Odpoj signál
    if SupabaseManager.leaderboard_loaded.is_connected(_on_leaderboard_loaded):
        SupabaseManager.leaderboard_loaded.disconnect(_on_leaderboard_loaded)
    
    queue_free()