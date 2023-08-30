extends Book


var levels : Array
var levels_per_page = 5


func setup(category):
	levels = JapaneseDb.get_levels(category)
	switch_page(0)

func build_page(page):
	var start = current_page * levels_per_page
	var end = start + clampi(levels.size() - start, 0, levels_per_page)
	var page_levels = levels.slice(start, end)
	var i = start
	
	for level in page_levels:
		i += 1
		add_paragraph("Level " + str(i))
		
		if level != null:
			add_info_cards(level, 0, level.size())
		
		if i < end:
			add_seperator()


func get_page_count():
	return (levels.size() - 1) / levels_per_page + 1
