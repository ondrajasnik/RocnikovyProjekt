extends CanvasLayer

@onready var progress_bar = $CenterContainer/VBoxContainer/ProgressBar
@onready var label = $CenterContainer/VBoxContainer/Label
@onready var particles = $Particles
@onready var rune = $CenterContainer/VBoxContainer/RuneIcon
@onready var fade_overlay = $FadeOverlay  # ← NOVÉ pro fade efekt

var progress = 0.0
var loading_speed = 50.0
var glow_time = 0.0
var text_pulse = 0.0

func _ready():
	if not progress_bar or not label:
		print("ERROR: Nodes not found!")
		return
	
	progress_bar.value = 0
	label.text = "Loading..."
	
	# Spusť částice pokud existují
	if particles:
		particles.emitting = true
	
	# Animuj fade-in pomocí overlay
	if fade_overlay:
		fade_overlay.modulate = Color(0, 0, 0, 1)  # Černá neprůhledná
		var tween = create_tween()
		tween.tween_property(fade_overlay, "modulate", Color(0, 0, 0, 0), 0.5)  # Fade to transparent

func _process(delta):
	if not progress_bar or not label:
		return
	
	# Animuj progress
	if progress < 100:
		progress += loading_speed * delta
		progress = min(progress, 100)
		progress_bar.value = progress
	else:
		# Fade-out před přechodem
		if fade_overlay:
			var tween = create_tween()
			tween.tween_property(fade_overlay, "modulate", Color(0, 0, 0, 1), 0.5)
			await tween.finished
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		return
	
	# Pulzující glow na progress baru
	glow_time += delta * 3.0
	var glow_intensity = (sin(glow_time) + 1.0) / 2.0
	
	var fill_style = progress_bar.get_theme_stylebox("fill")
	if fill_style:
		var base_color = Color(1, 0.3, 0.15)
		var glow_color = Color(1, 0.5, 0.3)
		fill_style.bg_color = base_color.lerp(glow_color, glow_intensity * 0.3)
		fill_style.shadow_color = Color(1, 0.3, 0.1, 0.5 + glow_intensity * 0.5)
	
	# Pulzující text
	text_pulse += delta * 2.0
	var text_scale = 1.0 + sin(text_pulse) * 0.05
	label.scale = Vector2(text_scale, text_scale)
	
	# Rotující runa (pokud existuje)
	if rune:
		rune.rotation += delta * 0.5

func _exit_tree():
	if particles:
		particles.emitting = false
