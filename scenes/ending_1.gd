extends Area3D

@export var video_player_path: NodePath  # Path to the VideoStreamPlayer node
var played = false

# Array of video files for the ending
var videos = [
	"res://scenes/1ending1.ogv",
	"res://scenes/2ending1.ogv",
	"res://scenes/3ending1.ogv"
]

var current_video_index = 0

func _on_body_entered(body):
	if played:
		return
	if body.name != "character":  # Check that the player is the one triggering
		return

	played = true
	var video_player = get_node(video_player_path)  # Get the video player from the path
	if video_player == null:
		push_error("Video player path not assigned or invalid.")
		return

	# Play all videos sequentially
	_play_current_video(video_player)

func _play_current_video(player: VideoStreamPlayer):
	if current_video_index < videos.size():
		var stream = load(videos[current_video_index])
		if stream:
			player.stream = stream
			player.play()
			player.visible = true
	else:
		_finish_ending()

# Called when video finishes, triggered by the "finished" signal of the player
func _on_video_finished():
	_next_video()

# Move to the next video in the array
func _next_video():
	current_video_index += 1
	if current_video_index < videos.size():
		_play_current_video(get_node(video_player_path))
	else:
		_finish_ending()

func _process(_delta):
	var video_player = get_node(video_player_path)
	if video_player.is_playing() and Input.is_action_just_pressed("ui_accept"):  # Check space or enter key
		# Stop the current video and play the next
		video_player.stop()
		_next_video()

# End of video playback, you can switch scenes or do other actions here
func _finish_ending():
	# Handle the transition or any other logic here
	get_tree().quit()
	# Example: Change scene
	# get_tree().change_scene("res://scenes/next_scene.tscn")
