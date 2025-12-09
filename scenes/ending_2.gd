extends Area3D

@export var video_player_path: NodePath  # Assign VideoStreamPlayer in editor

var played = false
var video_player: VideoStreamPlayer = null

# List of videos to play in sequence
var video_paths = [
	"res://scenes/1ending1.ogv",
	"res://scenes/2ending1.ogv",
	"res://scenes/3ending1.ogv"
]

var current_index = 0

func _on_body_entered(body):
	if played or body.name != "character":
		return

	played = true
	video_player = get_node(video_player_path)
	if video_player == null:
		push_error("Video player path not assigned or invalid.")
		return

	$"../Music/BGM_player".stop()
	$"../Music/potwormp3".play()

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
