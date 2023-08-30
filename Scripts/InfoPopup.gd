class_name InfoPopup extends Book


@export var title_box : HBoxContainer
var items


func setup(items, index):
	self.items = items
	switch_page(index)


func build_page(page):
	JapaneseDb.setup_info_popup(self, items[page])


func get_page_count():
	return items.size()


func clear():
	super()
	
	for c in title_box.get_children():
		title_box.remove_child(c)
		c.queue_free()


func add_title_text(text, style : StyleBox):
	if text is String:
		var label = Label.new()
		label.add_theme_stylebox_override("normal", style)
		label.add_theme_font_size_override("font_size", 32)
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.size_flags_vertical = Control.SIZE_FILL
		label.custom_minimum_size.x = 54
		label.text = text
		title_box.add_child(label)
	
	elif text is Texture2D:
		var panel = PanelContainer.new()
		panel.add_theme_stylebox_override("panel", style)
		title_box.add_child(panel)
		
		var margin = 8
		var margin_container = MarginContainer.new()
		margin_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
		margin_container.add_theme_constant_override("margin_top", margin)
		margin_container.add_theme_constant_override("margin_bottom", margin)
		panel.add_child(margin_container)
		
		var texture_rect = TextureRect.new()
		texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		texture_rect.custom_minimum_size.y = 32
		texture_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		texture_rect.texture = text
		margin_container.add_child(texture_rect)


func _on_quiz_pressed():
	var quiz = load("res://Scenes/quiz.tscn").instantiate()
	var root = get_tree().get_root()
	quiz.setup(items)
	root.get_child(root.get_children().size() - 1).set_visible(false)
	root.add_child(quiz)
	quiz.hflow.get_child(0).inputs[0][0].grab_focus()


func _on_exit_pressed():
	var root = get_tree().get_root()
	root.remove_child(self)
	root.get_child(root.get_children().size() - 1).set_visible(true)
	queue_free()
