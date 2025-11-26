extends CanvasLayer

@onready var name_input = $CenterContainer/Panel/VBoxContainer/NameInput
@onready var confirm_button = $CenterContainer/Panel/VBoxContainer/ConfirmButton
@onready var error_label = $CenterContainer/Panel/VBoxContainer/ErrorLabel

var is_checking = false

signal name_confirmed(player_name: String)

func _ready():
    confirm_button.pressed.connect(_on_confirm_pressed)
    name_input.text_changed.connect(_on_name_changed)
    name_input.text_submitted.connect(_on_name_submitted)
    error_label.text = ""
    
    # Focus na input
    name_input.grab_focus()

func _on_name_changed(new_text: String):
    error_label.text = ""
    confirm_button.disabled = new_text.strip_edges().length() < 3

func _on_name_submitted(text: String):
    if not confirm_button.disabled:
        _on_confirm_pressed()

func _on_confirm_pressed():
    var player_name = name_input.text.strip_edges()
    
    if player_name.length() < 3:
        _show_error("Name must be at least 3 characters!")
        return
    
    if is_checking:
        return
    
    is_checking = true
    confirm_button.disabled = true
    confirm_button.text = "Checking..."
    
    _check_name_availability(player_name)

func _check_name_availability(player_name: String):
    var headers = [
        "apikey: " + SupabaseManager.SUPABASE_KEY,
        "Authorization: Bearer " + SupabaseManager.SUPABASE_KEY
    ]
    
    var url = SupabaseManager.SUPABASE_URL + "/rest/v1/leaderboard?player_name=eq." + player_name.uri_encode()
    
    var http = HTTPRequest.new()
    add_child(http)
    http.request_completed.connect(
        func(result, response_code, headers_resp, body):
            _on_name_check_completed(result, response_code, body, player_name)
            http.queue_free()
    )
    http.request(url, headers, HTTPClient.METHOD_GET)

func _on_name_check_completed(result, response_code, body, player_name: String):
    is_checking = false
    confirm_button.text = "Confirm"
    confirm_button.disabled = false
    
    if response_code == 200:
        var json = JSON.new()
        json.parse(body.get_string_from_utf8())
        var data = json.data
        
        if data.size() > 0:
            # Jméno už existuje
            _show_error("This name is already taken!")
            name_input.modulate = Color(1, 0.5, 0.5, 1)
            await get_tree().create_timer(2.0).timeout
            name_input.modulate = Color.WHITE
        else:
            # Jméno je volné!
            PlayerProfile.set_player_name(player_name)
            emit_signal("name_confirmed", player_name)
            queue_free()
    else:
        _show_error("Connection error. Please try again.")

func _show_error(message: String):
    error_label.text = message