extends Node3D

var interactable = true
var toggle = false
@export var animation_player:AnimationPlayer
var player  # This will store the reference to the player node

func _ready():
	# Update this path to reflect your scene structure
	player = get_tree().root.get_node("Level/character")  # Correct path to the player node

func interact():
	if player.has_key:
		if interactable == true:
			interactable = false
			toggle = !toggle  # Check if the player has the key
			if toggle == false:
				animation_player.play("door_close")
				animation_player.play("door_close")
				$"../../../Door/Door_sound".play()
			if toggle == true:
				animation_player.play("door_rotation")  # Open the door
				$"../../../Door/Door_sound".play()
			await get_tree().create_timer(0.3, false).timeout
			interactable = true
