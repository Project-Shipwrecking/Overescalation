class_name Magazine extends Control


@onready var bullet_icon = preload("res://Scenes/bullet_icon.tscn")
var row_len = 4
var curr_mag = 8
var curr_max_mag = 8

func _ready() -> void:
	update_mag_size(8)

func get_mag_size():
	return curr_max_mag

func update_mag_size(mag_size : int):
	if curr_max_mag != mag_size:
		_recalculate_layout(mag_size)
		curr_max_mag = mag_size
		curr_mag = mag_size
	update_mag_display()

func update_mag_display():
	for child in get_children():
		child.queue_free()
	for i in range(curr_mag):
		var icon_instance = bullet_icon.instantiate()
		add_child(icon_instance)

func _recalculate_layout(new_mag_size : int):
	print(new_mag_size)
	if new_mag_size > 8:
		self.columns = 3
		row_len = 4
	else:
		self.columns = 2
		row_len = 4
	#if not is_inside_tree():
		#return # Cannot get size if not in tree
#
	## Get the actual available width for the GridContainer
	## This depends on where your Magazine Control node is placed.
	## If Magazine is meant to fill its parent horizontally, use get_parent().size.x
	## If Magazine has a fixed size, use size.x
	#var available_width = size.x # Assuming the Magazine Control is laid out to its desired width
#
	#if available_width <= 0:
		#available_width = 100 # Fallback for safety, or push_error("Magazine has no width!")
#
	#var best_columns = 1
	#var best_scale_factor = 1.0
#
	#if max_mag_capacity == 0:
		#grid.columns = 1 # Avoid division by zero, show nothing or single column
		#return
#
	## Try to find the maximum number of columns that would fit
	## without shrinking if possible, or minimizing shrink.
	#for test_columns in range(1, max_mag_capacity + 1):
		#var total_width_for_columns = (base_icon_size.x * test_columns) + (padding_x * (test_columns - 1))
		#if total_width_for_columns <= available_width:
			#best_columns = test_columns
			#best_scale_factor = 1.0 # No shrinking needed yet
		#else:
			## We've exceeded the width. The previous test_columns was the best without shrinking.
			## Now calculate the scale needed for the current test_columns.
			#var required_width = (base_icon_size.x * test_columns) + (padding_x * (test_columns - 1))
			#best_scale_factor = available_width / required_width
			## If the scale factor is too small, maybe stick to previous best_columns
			## You can refine this logic to prefer fewer columns over very small icons
			#if best_scale_factor < 0.5: # Example: Don't let icons get smaller than 50%
				#break # Use the previous 'best_columns'
			#else:
				#best_columns = test_columns # This set of columns requires shrinking, but might be desired
				#break # Found a valid column count, even if it requires shrinking
#
	## If no ideal best_columns was found (e.g., very narrow space),
	## just use enough columns to fit all items in one row if they were shrunk sufficiently.
	#if best_columns == 1 and max_mag_capacity > 0:
		## If even 1 column requires shrinking, then we'll shrink
		#var required_width_for_one_column = base_icon_size.x
		#if required_width_for_one_column > available_width:
			#best_scale_factor = available_width / required_width_for_one_column
		#else:
			#best_scale_factor = 1.0
#
	#grid.columns = best_columns
	## Store the calculated scale factor to apply when instantiating icons
	#grid.set_meta("icon_scale", Vector2(best_scale_factor, best_scale_factor))


func use_bullet() -> bool:
	if curr_mag > 0:
		curr_mag -= 1
		get_child(0).queue_free()
		return true
	return false
	
func reload() -> bool:
	if curr_mag != get_mag_size():
		curr_mag = get_mag_size()
		update_mag_display()
		return true
	return false
	
func can_add() -> bool:
	if curr_mag + 1 <= get_mag_size():
		return true
	else:
		return false
	
