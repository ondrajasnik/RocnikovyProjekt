extends CanvasLayer

@onready var close_button = $CenterContainer/Panel/VBoxContainer/HeaderContainer/CloseButton
@onready var ok_button = $CenterContainer/Panel/VBoxContainer/OKButton

func _ready():
    close_button.pressed.connect(_on_close_pressed)
    ok_button.pressed.connect(_on_close_pressed)

func _on_close_pressed():
    queue_free()