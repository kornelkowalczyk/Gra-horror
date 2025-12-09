extends Area3D

var player  # This will store the reference to the player node
var key_node

func _ready():
	add_to_group("keys")  # Optional: Adds this key to a group (for easier detection)
	# Update this path to reflect your scene structure
	player = get_tree().root.get_node("Level/character")  # Correct path to the player node
	key_node = get_node("../hinge/Drzwisejfu/StaticBody3D")
func _on_body_entered(body: Node3D) -> void:
	# Check if the player enters the key's area
	if body.is_in_group("player") and key_node.opened:
		player.set("has_key", true)  # Set the player’s 'has_key' variable to true
		$"../../character/Klucz".visible = true
		queue_free()  # Remove the key from the scene (it disappears after pickup)
