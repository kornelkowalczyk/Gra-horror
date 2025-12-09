extends ProgressBar

func _process(delta: float) -> void:
	var current_value = value	
	var ratio = current_value / max_value
	
	# Interpolate between red, yellow, and green based on the ratio
	var color = Color(1, 0, 0)  # Red
	if ratio > 0.5:
		color = lerp(Color(1, 1, 0), Color(0, 1, 0), (ratio - 0.5) / 0.5)  # Yellow to Green
	else:
		color = lerp(Color(1, 0, 0), Color(1, 1, 0), ratio / 0.5)  # Red to Yellow
	
	# Update the style box color
	var styleBox = get("custom_styles/fill")
	if styleBox:
		styleBox.bg_color = color
	else:
		var newStyleBox = StyleBoxFlat.new()
		newStyleBox.bg_color = color
		add_theme_stylebox_override("fill", newStyleBox)
