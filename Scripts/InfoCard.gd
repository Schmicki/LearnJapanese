class_name InfoCard extends PanelContainer


var vbox : Control
var button : Button
var index : int
var items


func setup(items, index : int):
	self.items = items
	self.index = index
	JapaneseDb.setup_info_card(self, items[index])


func _notification(what):
	if what == NOTIFICATION_SCENE_INSTANTIATED:
		vbox = get_node("MarginContainer/VBoxContainer")
		button = get_node("Button")


func set_style(normal, hover, pressed, disabled, focus):
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_stylebox_override("focus", focus)

func add_text(text, font_size : int = 16):
	if text is String:
		var label = Label.new()
		label.add_theme_font_size_override("font_size", font_size)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.text = text
		vbox.add_child(label)
	
	elif text is Texture2D:
		var margin = font_size / 4
		var margin_container = MarginContainer.new()
		margin_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
		margin_container.add_theme_constant_override("margin_top", margin)
		margin_container.add_theme_constant_override("margin_bottom", margin)
		
		var texture_rect = TextureRect.new()
		texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		texture_rect.custom_minimum_size.y = font_size
		texture_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		texture_rect.texture = text
		
		margin_container.add_child(texture_rect)
		vbox.add_child(margin_container)


func _on_button_pressed():
	var info_screen = load("res://Scenes/info_popup.tscn").instantiate()	
	var root = get_tree().get_root()
	root.get_child(root.get_children().size() - 1).visible = false
	info_screen.setup(items, index)
	root.add_child(info_screen)
