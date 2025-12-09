extends StaticBody3D

@export var animation_player: AnimationPlayer
@export var opened := false
var cards_needed := 3
var cards_collected := 0
var interactable := true

@onready var vault_menu = get_node("../../../VaultMenu")
@onready var input_field = vault_menu.get_node("Password") # LineEdit node
@onready var confirm_button = vault_menu.get_node("Button")

func _ready():
	add_to_group("vaults")
	confirm_button.pressed.connect(_on_confirm_pressed)

func register_card():
	cards_collected += 1
	if cards_collected >= cards_needed:
		interactable = true # allow interaction

func _unhandled_input(event):
	if interactable and event.is_action_pressed("interact") and vault_menu.visible:
		await interact()  # toggle menu like your photo_ui example

func interact():
	if not interactable:
		return
	
	interactable = false
	
	vault_menu.visible = !vault_menu.visible
	
	# Lock/unlock mouse mode accordingly
	if vault_menu.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Cooldown to prevent immediate toggling
	await get_tree().create_timer(0.1).timeout
	
	interactable = true

func _on_confirm_pressed():
	var code = input_field.text.strip_edges()
	if code == "256413":
		vault_menu.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		open_vault()
		$"../../../vault_sound".play()
	else:
		print("Incorrect code.")

func open_vault():
	if opened:
		return
	opened = true
	interactable = false
	animation_player.play("sejf_open")
