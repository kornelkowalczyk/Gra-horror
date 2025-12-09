extends Control

@onready var prolog_player := $prolog
@onready var menu := $menu
@onready var wyjdz := $Wyjdz
@onready var rozpocznij := $Rozpocznij
@onready var transition := TransitionScreen

var video_files = [
	"res://scenes/1.ogv",
	"res://scenes/2.ogv",
	"res://scenes/3.ogv",
	"res://scenes/4.ogv",
	"res://scenes/5.ogv",
	"res://scenes/6.ogv",
	"res://scenes/7.ogv"
]

var current_video_index = 0
var current_level = "res://scenes/level.tscn"
var videos_playing = false

func _ready() -> void:
	# Menu is now shown first
	menu.visible = true
	wyjdz.visible = true
	rozpocznij.visible = true
	
	prolog_player.visible = false
	prolog_player.connect("finished", Callable(self, "_on_video_finished"))

	# Connect menu buttons
	rozpocznij.connect("pressed", Callable(self, "_on_rozpocznij_pressed"))
	wyjdz.connect("pressed", Callable(self, "_on_exit_button_pressed"))

func _unhandled_input(_event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

	if videos_playing and Input.is_action_just_pressed("next_video"):
		_next_video()

func _on_rozpocznij_pressed() -> void:
	# Start transition first
	var transition_promise = transition.transition()
	
	# Simultaneously start volume fade-out (but don't await it)
	var bgm := $MenuBGM
	var tween := create_tween()
	tween.tween_property(bgm, "volume_db", -80, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(func():
		bgm.stop()
		bgm.volume_db = 0  # Reset for future playback
	)

	# Now await the transition (independently)
	await transition_promise
	await transition.on_transition_finished

	# After transition, hide menu and start prolog video sequence
	menu.visible = false
	wyjdz.visible = false
	rozpocznij.visible = false

	current_video_index = 0
	videos_playing = true
	_play_current_video()

func _play_current_video():
	if current_video_index < video_files.size():
		var stream = load(video_files[current_video_index])
		if stream:
			prolog_player.stream = stream
			prolog_player.visible = true
			prolog_player.play()
	else:
		_finish_prolog()

func _on_video_finished():
	_next_video()

func _next_video():
	current_video_index += 1
	_play_current_video()

func _finish_prolog():
	await transition.transition()
	await transition.on_transition_finished
	
	prolog_player.visible = false
	videos_playing = false
	
	# Load the actual game
	get_tree().change_scene_to_file(current_level)

func _on_exit_button_pressed() -> void:
	get_tree().quit()
