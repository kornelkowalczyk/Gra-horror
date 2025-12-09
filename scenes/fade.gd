extends Control

signal transitioned

func _ready() -> void:
	transition() 
# Called when the node enters the scene tree for the first time.
func transition():
	$AnimationPlayer.play("fade_to_normal")


func _on_animation_player_current_animation_finished(scene_name: String) -> void:
	if scene_name == "fade_to_normal":
		emit_signal("transitioned")
