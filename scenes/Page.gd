extends StaticBody3D

@export var photo_ui_path: NodePath
var photo_ui: Control
var interactable = true

func _ready():
	photo_ui = get_node(photo_ui_path)
	photo_ui.visible = false

func _unhandled_input(event):
	if interactable and event.is_action_pressed("interact") and photo_ui.visible:
		interact()  # Hide the photo if it's visible and interact key is pressed

func interact():
	if interactable:
		interactable = false
		photo_ui.visible = !photo_ui.visible
		await get_tree().create_timer(0.1, false).timeout
		interactable = true
