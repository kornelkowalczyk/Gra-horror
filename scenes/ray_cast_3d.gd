extends RayCast3D

@onready var prompt = $Prompt

func _process(_delta: float) -> void:
	prompt.text = ""
	if is_colliding():
		var hitObj = get_collider()
		if hitObj != null:
			#prompt.text = hitObj.name
			if hitObj.has_method("interact") && Input.is_action_just_pressed("interact"):
				hitObj.interact()
			if hitObj.name == "lustro" && Input.is_action_just_pressed("interact"):
				var lustro = get_node("../../../../swiatlo4/swiatlo2/swiatlo40").position
				lustro.y += -0.9 
				$"../../..".position = lustro
