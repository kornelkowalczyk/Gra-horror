class_name Interactable
extends StaticBody3D

signal interacted(body)

@export var prompt_message = "Interact"
@export var prompt_action = "interact"

@onready var audio_sample = $AudioStreamPlayer3D

func get_prompt():
	var key_name = ""
	for action in InputMap.action_get_events(prompt_action):
		if action is InputEventKey:
			key_name = action.as_text()  # FIXED: Properly gets the key name
	return prompt_message + "\n[" + key_name + "]"

func interact(body):
	emit_signal("interacted", body)  # FIXED: Corrected signal emission



func _on_interacted(_body):
	audio_sample.play()
