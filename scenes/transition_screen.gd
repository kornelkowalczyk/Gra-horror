extends CanvasLayer

signal on_transition_finished 

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer
func _ready():
	color_rect.modulate.a = 0.0  # Initialize as transparent
	color_rect.visible = false
	animation_player.animation_finished.connect(_on_animation_finished)

func _unhandled_input(_event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _on_animation_finished(anim_name):
	if anim_name == "fade_to_b":
		animation_player.play("fade_to_n")  # Start fade-out animation
		on_transition_finished.emit()

	elif anim_name == "fade_to_n":
		color_rect.visible = false  # Hide only after fade-out completes

func transition():
	animation_player.play("fade_to_b") 
	color_rect.visible = true
