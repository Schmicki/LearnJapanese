extends Book


var items = []
var items_per_page = 300


func setup(text : String):
	get_node("SearchBar/LineEdit").text = text
	
	var tokens = text.split(" ", false)
	var modifiers = {}
	var string = ""
	
	for t in tokens:
		t = t.split(":")
		
		# Is modifier
		if t.size() > 1 and t[0] != "":
			try_add_modifier(modifiers, t)
		else:
			if string.length() > 0:
				string += " "
			string += t[0]
		
	var result = JapaneseDb.search(string, modifiers)
	
	for category in result:
		items.append_array(category[1])


func try_add_modifier(modifiers, token):
	var type = get_mod_type(token[0])
	var range = get_mod_range(token[1])
	
	if type == null:
		return false
	
	var ranges = modifiers.get(type)
	
	if ranges == null:
		modifiers[type] = [range]
		return true
	
	var i = 0
	var start = -1
	var end = 0
	
	while i < ranges.size():
		var r = ranges[i]
		
		if range[1] < r[0]:
			ranges.insert(i, range)
			return true
		
		# Overlap
		if range[0] <= r[1]:
			r = ranges.pop_at(i)
			range[0] = mini(range[0], r[0])
			range[1] = maxi(range[1], r[1])
			continue
		
		i += 1
	
	ranges.append(range)
	return true


func get_mod_type(type):
	var i = 0
	for c in JapaneseDb.get_categories():
		if c.nocasecmp_to(type) == 0:
			return i
		i += 1
	return null


func get_mod_range(range):
	range = range.split("-", false)
	var x = 0
	var y = 0x7FFFFFFF
	
	if range.size() > 0 and range[0].is_valid_int():
		x = clampi(int(range[0]) - 1, 0, 0x7FFFFFFF)
		
		if range.size() > 1 and range[1].is_valid_int():
			y = clampi(int(range[1]), 0, 0x7FFFFFFF)
		else:
			y = x + 1
	
	return [x, y]


func build_page(page):
	var start = current_page * items_per_page
	var end = start + clampi(items.size() - start, 0, items_per_page)
	add_info_cards(items, start, end, true)


func get_page_count():
	return (items.size() - 1) / items_per_page + 1
