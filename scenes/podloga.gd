extends Area3D

var has_played: bool = false

@export var void_sound_path: NodePath
@export var picture_node_path: NodePath
@export var swiatlo64_path: NodePath

func _ready() -> void:
	var audio_path := NodePath(name)
	if has_node(audio_path):
		get_node(audio_path).stop()
	
	var void_sound = get_node_or_null(void_sound_path)
	if is_instance_valid(void_sound):
		void_sound.stop()
	
	var picture_node = get_node_or_null(picture_node_path)
	if is_instance_valid(picture_node):
		picture_node.visible = false

func _on_body_entered(body: Node3D) -> void:
	if body.name != "character":
		return
	
	var audio_path := NodePath(name)
	if not has_node(audio_path):
		return
	
	if name == "upadek" and has_played:
		return
	has_played = true
	
	# Play main sound
	get_node(audio_path).play()
	
	# Play void sound
	var void_sound = get_node_or_null(void_sound_path)
	if is_instance_valid(void_sound):
		void_sound.play()
	
	# Show picture
	var picture_node = get_node_or_null(picture_node_path)
	if is_instance_valid(picture_node):
		picture_node.visible = true
	
	# If this area is "void", teleport and hide picture after 2 seconds
	if name == "void":
		var swiatlo64 = get_node_or_null(swiatlo64_path)
		if is_instance_valid(swiatlo64):
			var target_pos = swiatlo64.global_transform.origin - Vector3(0, 3, 0)
			var new_transform = body.global_transform
			new_transform.origin = target_pos
			body.global_transform = new_transform
		else:
			print("swiatlo64 node not found at:", swiatlo64_path)
		
		# Wait 2 seconds, then hide the jumpscare picture
		await get_tree().create_timer(0.7).timeout
		if is_instance_valid(picture_node):
			picture_node.visible = false
