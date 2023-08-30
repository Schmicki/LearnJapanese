class_name Book extends Control


@export var scroll : ScrollContainer
@export var vbox : Control
@export var prev : Button
@export var next : Button

var current_page = -1


func _init():
	visibility_changed.connect(_on_visibility_changed)


func get_page_count():
	return 0


func build_page(page):
	pass


func switch_page(page):
	clear()
	current_page = clampi(page, 0, get_page_count() - 1)
	update_button_state()
	build_page(current_page)
	scroll.scroll_vertical = 0


func update_button_state():
	if get_page_count() == 0:
		prev.disabled = true
		next.disabled = true
	else:
		prev.disabled = current_page == 0
		next.disabled = current_page == get_page_count() - 1


func _on_prev_pressed():
	switch_page(current_page - 1)


func _on_next_pressed():
	switch_page(current_page + 1)


func clear():
	for c in vbox.get_children():
		vbox.remove_child(c)
		c.queue_free()


func add_paragraph(name : String):
	var label = Label.new()
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.add_theme_font_size_override("font_size", 24)
	label.text = name
	vbox.add_child(label)
	
	var spacer = HSeparator.new()
	spacer.add_theme_constant_override("separation", 8)
	spacer.add_theme_stylebox_override("separator", preload("res://Styles/General/StyleLineGrey.tres"))
	vbox.add_child(spacer)


func add_seperator():
	var spacer = HSeparator.new()
	spacer.add_theme_constant_override("separation", 32)
	spacer.add_theme_stylebox_override("separator", preload("res://Styles/General/StyleEmpty.tres"))
	vbox.add_child(spacer)


func add_info_cards(items : Array, start, end, centered = false):
	var ref_box = HFlowContainer.new()
	ref_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	if centered:
		ref_box.alignment = FlowContainer.ALIGNMENT_CENTER
	else:
		ref_box.alignment = FlowContainer.ALIGNMENT_BEGIN
		
	vbox.add_child(ref_box)
	
	var info_card_scene : PackedScene = preload("res://Scenes/info_card.tscn")
	var i = start
	
	while i < end:
		var info_card : InfoCard = info_card_scene.instantiate()
		info_card.setup(items, i)
		ref_box.add_child(info_card)
		i += 1


func add_table(table : Array):
	var table_box = HBoxContainer.new()
	table_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(table_box)
	
	for column in table:
		var column_box = VBoxContainer.new()
		column_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		table_box.add_child(column_box)
		
		for field in column:
			var label = Label.new()
			label.text = field[0]
			label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			label.add_theme_color_override("font_color", field[1])
			column_box.add_child(label)


func _on_visibility_changed():
	if is_visible_in_tree():
		print("book visible")
		switch_page(current_page)
	else:
		print("book invisible")
		clear()
