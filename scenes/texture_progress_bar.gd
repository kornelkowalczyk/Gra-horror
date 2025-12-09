extends TextureProgressBar

func _process(delta: float):
	

	# Calculate ratio (value normalized between 0 and 1)
	var ratio = float(value) / float(max_value)
	
	# Interpolate colors based on ratio
	var color = Color(0, 1, 0)  # Green
	if ratio > 0.5:
		color = lerp(Color(1, 1, 0), Color(0, 1, 0), (ratio - 0.5) / 0.5)  # Yellow to Green
	else:
		color = lerp(Color(1, 0, 0), Color(1, 1, 0),  0.5)  # Red to Yellow
	
	# Apply the interpolated color as a tint to the progress (fill) texture
	tint_progress = color 
