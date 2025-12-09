extends Area3D

func _ready():
	add_to_group("batteries")

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		var flashlight_bar_path = NodePath("FlashlightBar")
		#$"../character/Template_item1".visible = true
		if body.has_node(flashlight_bar_path):
			var flashlight_bar = body.get_node(flashlight_bar_path)
			flashlight_bar.value += 450
			flashlight_bar.value = min(flashlight_bar.value, 450)
		
		queue_free()
