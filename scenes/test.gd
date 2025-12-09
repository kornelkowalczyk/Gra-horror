extends Node3D

var interacted := false

@export var jumpscare_picture_path: NodePath
@export var jumpscare_sound_path: NodePath

func interact():
	if interacted:
		return

	interacted = true  # Block future interactions

	# Get nodes
	var jumpscare_pic = get_node_or_null(jumpscare_picture_path)
	var jumpscare_sound = get_node_or_null(jumpscare_sound_path)
	print("g")
	# Show picture and play sound
	if is_instance_valid(jumpscare_pic):
		jumpscare_pic.visible = true
	if is_instance_valid(jumpscare_sound):
		jumpscare_sound.play()

	# Wait 0.5s, then hide picture
	await get_tree().create_timer(0.5).timeout
	if is_instance_valid(jumpscare_pic):
		jumpscare_pic.visible = false
