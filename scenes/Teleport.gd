extends Area3D

@export var connect_portal: Area3D
@export var transition_path: NodePath  # Drag the TransitionScreen node in the editor
@export var jumpscare_picture_path: NodePath
@export var jumpscare_sound_path: NodePath

var transition: Node = null
var is_teleporting := false
var player
func _ready() -> void:
	player = get_tree().root.get_node("Level/character") 
	if transition_path != null:
		transition = get_node(transition_path)

func _on_body_entered(body: Node3D) -> void:
	if is_teleporting:
		return  # Prevent double triggering
	if body.is_in_group("player") and transition:
		is_teleporting = true
		player.set("has_key", false)  # Set the player’s 'has_key' variable to true
		$"../../character/Klucz".visible = false


		var jumpscare_pic = get_node_or_null(jumpscare_picture_path)
		var jumpscare_sound = get_node_or_null(jumpscare_sound_path)

		# Show jumpscare + play sound
		if is_instance_valid(jumpscare_pic):
			jumpscare_pic.visible = true
		if is_instance_valid(jumpscare_sound):
			jumpscare_sound.play()

		# Start fade IMMEDIATELY with jumpscare
		transition.transition()

		# Wait 0.7s for jumpscare and fade to complete
		await get_tree().create_timer(0.6).timeout

		# Hide jumpscare after fade finishes
		if is_instance_valid(jumpscare_pic):
			jumpscare_pic.visible = false

		# Then teleport
		teleport_player(body)
		is_teleporting = false

func teleport_player(body: Node3D) -> void:
	var destination = connect_portal.global_transform.origin
	var new_transform = body.global_transform
	new_transform.origin = destination
	body.global_transform = new_transform
