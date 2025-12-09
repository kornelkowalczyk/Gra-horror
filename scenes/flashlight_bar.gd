extends TextureProgressBar

func _process(_delta: float):
	# Ensure min_value and max_value are set correctly
	if max_value == 0:
		return  # Avoid division by zero
	
	# Calculate ratio (value normalized between 0 and 1)
	var fill_ratio = float(value) / float(max_value)
	
	# Interpolate vibrant colors based on ratio
	var color = Color(0, 1, 0)  # Green
	if ratio > 0.5:
		color = lerp(Color(1, 1, 0), Color(0, 1, 0), (fill_ratio - 0.5) / 0.5)  # Yellow to Green
	else:
		color = lerp(Color(1, 0, 0), Color(1, 1, 0), (fill_ratio-0.3) / 0.2)  # Red to Yellow
	
	# Apply tint only to progress (fill texture)
	tint_progress = color
