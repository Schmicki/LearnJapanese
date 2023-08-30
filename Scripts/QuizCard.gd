class_name QuizCard extends Control


var inputs = []
var vbox : Control
var quiz
var index


func setup(quiz, index):
	self.quiz = quiz
	self.index = index
	JapaneseDb.setup_quiz_card(self, quiz.items[index])
	restore_inputs()
	save_inputs()


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


func add_input(solution):
	var edit = LineEdit.new()
	inputs.append([edit, solution])
	edit.size_flags_horizontal = Control.SIZE_FILL
	edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	edit.caret_blink = true
	
	if 8 < solution.length():
		edit.max_length = solution.length()
	else:
		edit.max_length = 8
	
	edit.text_submitted.connect(Callable(submit_input).bind(edit, inputs.size() - 1))
	edit.focus_exited.connect(Callable(on_focus_exited))
	vbox.add_child(edit)


func on_focus_exited():
	save_inputs()


func submit_input(text, edit, index):
	var input = inputs[index]
	
	if text == input[1]:
		edit.editable = false
		
		if index < inputs.size() - 1:
			inputs[index + 1][0].grab_focus()
		elif self.index < quiz.hflow.get_children().size() - 1:
			var next = quiz.hflow.get_child(self.index + 1)
			if next.inputs.size() > 0:
				next.inputs[0][0].grab_focus()
		elif quiz.current_page < quiz.get_page_count() - 1:
			quiz.switch_page(quiz.current_page + 1)


func save_inputs():
	var data = []
	
	for i in inputs:
		data.append([i[0].text, i[1]])
	
	var item = quiz.items[index]
	
	if item.size() == 2:
		item.append(data)
	else:
		item[2] = data


func restore_inputs():
	var item = quiz.items[index]
	
	if item.size() == 2:
		return
	
	var i = 0
	for text in item[2]:
		inputs[i][0].text = text[0]
		i += 1


func check_answer():
	for i in inputs:
		if i[0].text != i[1]:
			return false
	return true


static func get_line_end(string : String, line_width : float, font : Font, font_size : int = 16, wrap_mode : int = TextServer.AUTOWRAP_ARBITRARY):
	if string.length() == 0:
		return -1
	
	var i = 0
	var end = 0
	var size = 0.0
	
	for c in string:
		size += font.get_char_size(c.unicode_at(0), font_size).x
		
		if size > line_width:
			if wrap_mode == TextServer.AUTOWRAP_WORD_SMART and end == 0:
				end = i
			break
		
		if (wrap_mode == TextServer.AUTOWRAP_WORD or
			wrap_mode == TextServer.AUTOWRAP_WORD_SMART):
			if c == " ":
				end = i
		else:
			end = i
		
		i += 1
	
	if end == 0:
		return -1
	elif i == string.length() and size < line_width:
		return string.length()
	else:
		return end


func set_style(style):
	get_node("Panel").add_theme_stylebox_override("panel", style)


func _notification(what):
	if what == NOTIFICATION_SCENE_INSTANTIATED:
		vbox = get_node("MarginContainer/VBoxContainer")
