extends Book


var hflow
var items_per_page = 300
var items


func setup(items):
	self.items = items.duplicate()
	self.items.shuffle()
	switch_page(0)


func get_page_count():
	return (items.size() - 1) / items_per_page + 1


func build_page(page):
	hflow = HFlowContainer.new()
	hflow.alignment = FlowContainer.ALIGNMENT_CENTER
	hflow.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hflow.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(hflow)
	
	var quiz_card_scene = preload("res://Scenes/quiz_card_text.tscn")
	
	var start = current_page * items_per_page
	var end = start + clampi(items.size() - start, 0, items_per_page)
	var page_items = items.slice(start, end)
	
	var i = start
	for item in page_items:
		var card = quiz_card_scene.instantiate()
		card.setup(self, i)
		hflow.add_child(card)
		i += 1
	
	hflow.get_child(0).inputs[0][0].grab_focus()


func _on_back_pressed():
	var root = get_tree().get_root()
	root.remove_child(self)
	root.get_child(root.get_children().size() - 1).set_visible(true)
	queue_free()
