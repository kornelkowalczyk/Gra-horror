extends Node3D

@export var video_player_path: NodePath  # Assign VideoStreamPlayer in editor

var interactable = true
var video_player: VideoStreamPlayer = null
var player  # To store reference to player node

var played = false
var video_paths = [
	"res://scenes/1ending1.ogv",
	"res://scenes/2ending1.ogv",
	"res://scenes/3ending1.ogv",
	"res://scenes/creditsy2.ogv"
]
var current_index = 0

func _ready():
	player = get_tree().root.get_node("Level/character")  # Adjust to match your scene
	video_player = get_node(video_player_path)
	video_player.visible = false  # Hide initially

func interact():
	if played or not player.has_key:
		return

	played = true
	var bgm = get_node_or_null("../Music/BGM_player")
	if bgm:
		bgm.stop()

	var potwor = get_node_or_null("Music/potwormp3")
	if potwor:
		potwor.play()

	_play_video(video_paths[current_index])

func _play_video(path: String) -> void:
	var stream = load(path)
	if stream:
		video_player.stream = stream
		video_player.visible = true
		video_player.play()
	else:
		push_error("Failed to load video: " + path)

func _process(_delta):
	if played and Input.is_action_just_pressed("ui_accept"):
		if video_player != null and video_player.is_playing():
			video_player.stop()

		current_index += 1

		if current_index < video_paths.size():
			_play_video(video_paths[current_index])
		else:
			get_tree().quit()
