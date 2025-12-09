extends Control
var password = ""
var confirmed = false


func _on_button_button_down() -> void:
	if confirmed:
		password=$Password.text
