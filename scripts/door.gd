extends Node3D

var interactable = true
var toggle = false
@export var  animation_player: AnimationPlayer

func interact():
	if interactable == true:
		interactable = false
		toggle = !toggle
		if toggle == false:
			animation_player.play("door_close")
			$"../../Door_sound".play()
			
		if toggle == true:
			animation_player.play("door_rotation")
			$"../../Door_sound".play()	
		await get_tree().create_timer(0.3, false).timeout
		interactable = true
	
