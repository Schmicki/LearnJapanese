@tool
class_name LODContainer extends Container

@export var debug_lod = -1:
	
	set(val):
		debug_lod = val
		select_lod()


@export var lod_min_width : Array[int]:
	
	set(val):
		val.resize(get_children().size())
		lod_min_width = val
		select_lod()


func _notification(what):
	if what == NOTIFICATION_SORT_CHILDREN:
		lod_min_width.resize(get_children().size())
		select_lod()
	elif what == NOTIFICATION_RESIZED:
		select_lod()


func select_lod():
	var lods = lod_min_width
	var last = lods.size() - 1
	var selected = -1
	
	if Engine.is_editor_hint() and debug_lod != -1:
		for i in lods.size():
			var child = get_child(i)
			child.visible = i == debug_lod
			
			if i == debug_lod:
				fit_child_in_rect(child, Rect2(Vector2(), size))
			
		return
	
	for i in lods.size():
		var child = get_child(i)
		var min_size = child.get_combined_minimum_size()
		
		if selected != -1:
			child.visible = false
			
		elif lods[i] < size.x and size.x > min_size.x or i == last:
			selected = i
			child.visible = true
			fit_child_in_rect(child, Rect2(Vector2(), size))
			
		else:
			child.visible = false
