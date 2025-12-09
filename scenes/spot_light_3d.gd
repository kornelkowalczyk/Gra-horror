extends SpotLight3D

@onready var flashlight_bar = $"../../../../FlashlightBar"
@onready var battery = $"../../../../../battery"

var toggle = false
var drain_interval = 0.1
var drain_rate = 1.5
var time_accumulator = 0.0

# Dimming parameters
var max_energy := 8
var dim_start_threshold := 300.0
var min_energy := 0.0
var critical_battery_level := 46.0

func _ready():
	if battery and battery.has_signal("picked_up"):
		battery.picked_up.connect(_on_battery_picked_up)

func _on_battery_picked_up():
	flashlight_bar.value += 100
	flashlight_bar.value = min(flashlight_bar.value, 450)
	update_light_state()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Flashlight"):
		if flashlight_bar.value > 0:
			toggle = !toggle
		else:
			toggle = false
		update_light_state()

func _physics_process(delta: float) -> void:
	flashlight_bar.value = min(flashlight_bar.value, 450)
	
	if toggle:
		handle_battery_drain(delta)
		update_light_state()
		
		if flashlight_bar.value <= critical_battery_level:
			emergency_shutdown()

func handle_battery_drain(delta):
	time_accumulator += delta
	if time_accumulator >= drain_interval:
		time_accumulator = 0.0
		flashlight_bar.value = max(flashlight_bar.value - drain_rate, 0)

func update_light_state():
	if toggle:
		if flashlight_bar.value > dim_start_threshold:
			light_energy = max_energy
		else:
			var energy_range = max_energy - min_energy
			var battery_range = dim_start_threshold - 0.0
			var t = (flashlight_bar.value - 0.0) / battery_range
			light_energy = clamp(t * max_energy, min_energy, max_energy)
	else:
		light_energy = 0.0

func emergency_shutdown():
	toggle = false
	light_energy = 0.0
