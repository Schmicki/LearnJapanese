extends Node

enum {
	HIRAGANA,
	KATAKANA,
	RADICAL,
	KANJI,
	VOCABULARY,
	GRAMMAR,
}

var hiragana
var katakana
var radicals
var kanji
var vocabulary
var grammar = []
var all

var card_styles = [
	[
		preload("res://Styles/Lime/StyleLimeNormal.tres"),
		preload("res://Styles/Lime/StyleLimeHover.tres"),
		preload("res://Styles/Lime/StyleLimePressed.tres"),
		preload("res://Styles/Lime/StyleLimeDisabled.tres"),
		preload("res://Styles/Lime/StyleLimeFocused.tres")
	],
	[
		preload("res://Styles/Orange/StyleOrangeNormal.tres"),
		preload("res://Styles/Orange/StyleOrangeHover.tres"),
		preload("res://Styles/Orange/StyleOrangePressed.tres"),
		preload("res://Styles/Orange/StyleOrangeDisabled.tres"),
		preload("res://Styles/Orange/StyleOrangeFocused.tres")
	],
	[
		preload("res://Styles/LightBlue/StyleLightBlueNormal.tres"),
		preload("res://Styles/LightBlue/StyleLightBlueHover.tres"),
		preload("res://Styles/LightBlue/StyleLightBluePressed.tres"),
		preload("res://Styles/LightBlue/StyleLightBlueDisabled.tres"),
		preload("res://Styles/LightBlue/StyleLightBlueFocused.tres")
	],
	[
		preload("res://Styles/Magenta/StyleMagentaNormal.tres"),
		preload("res://Styles/Magenta/StyleMagentaHover.tres"),
		preload("res://Styles/Magenta/StyleMagentaPressed.tres"),
		preload("res://Styles/Magenta/StyleMagentaDisabled.tres"),
		preload("res://Styles/Magenta/StyleMagentaFocused.tres")
	],
	[
		preload("res://Styles/Purple/StylePurpleNormal.tres"),
		preload("res://Styles/Purple/StylePurpleHover.tres"),
		preload("res://Styles/Purple/StylePurplePressed.tres"),
		preload("res://Styles/Purple/StylePurpleDisabled.tres"),
		preload("res://Styles/Purple/StylePurpleFocused.tres")
	]
]

func load_json_file(path : String):
	var file = FileAccess.open(path, FileAccess.READ)
	var json : Array = JSON.parse_string(file.get_as_text())
	print(len(json))
	file.close()
	return json


func _ready():
	hiragana = load_json_file("res://Databases/Japanese/hiragana.json")
	katakana = load_json_file("res://Databases/Japanese/katakana.json")
	radicals = load_json_file("res://Databases/Japanese/radicals.json")
	kanji = load_json_file("res://Databases/Japanese/kanji.json")
	vocabulary = load_json_file("res://Databases/Japanese/vocabulary.json")
	
	var char_dict : Dictionary = {}
	var radical_dict : Dictionary = {}
	
	for i in len(radicals):
		var r : Dictionary = radicals[i]
		radical_dict[r["reading"]] = i
		r["kanji"] = []
		
		if r["text"].begins_with("i"):
			var name = r["reading"].to_lower()
			r["text"] = load("res://Textures/Radicals/" + name + ".png")
	
	for i in len(hiragana):
		var h : Dictionary = hiragana[i]
		char_dict[h["text"]] = [HIRAGANA, i]
		h["vocabulary"] = []
	
	for i in len(katakana):
		var k : Dictionary = katakana[i]
		char_dict[k["text"]] = [KATAKANA, i]
		k["vocabulary"] = []
	
	for i in len(kanji):
		var k : Dictionary = kanji[i]
		char_dict[k["text"]] = [KANJI, i]
		k["vocabulary"] = []
		
		var k_radicals : Array = k["radicals"]
		for x in len(k_radicals):
			var idx = radical_dict[k_radicals[x]]
			radicals[idx]["kanji"].append(i)
			k_radicals[x] = idx
	
	for i in len(vocabulary):
		var v : Dictionary = vocabulary[i]
		var characters = []
		
		for c in v["text"]:
			var char = char_dict.get(c)
			
			if char == null:
				char = char_dict.get(String.chr(c.unicode_at(0) + 1))
			
			if char == null:
				continue
			
			characters.append(char)
			
			match char[0]:
				HIRAGANA:
					hiragana[char[1]]["vocabulary"].append(i)
				KATAKANA:
					katakana[char[1]]["vocabulary"].append(i)
				KANJI:
					kanji[char[1]]["vocabulary"].append(i)
		
		v["characters"] = characters
		all = [hiragana, katakana, radicals, kanji, vocabulary, grammar]


func search(text : String, modifiers):
	var results : Array = []
	
	results.append(search_hiragana(text, modifiers.get(HIRAGANA), modifiers.size() > 0))
	results.append(search_katakana(text, modifiers.get(KATAKANA), modifiers.size() > 0))
	results.append(search_radicals(text, modifiers.get(RADICAL), modifiers.size() > 0))
	results.append(search_kanji(text, modifiers.get(KANJI), modifiers.size() > 0))
	results.append(search_vocabulary(text, modifiers.get(VOCABULARY), modifiers.size() > 0))
	
	return results


func search_hiragana(text, ranges, filter):
	var results = []
	
	if ranges == null:
		if filter == true:
			return ["Hiragana", results]
		else:
			ranges = [[0, hiragana.size()]]
	
	var empty = text == ""
	
	for i in len(hiragana):
		var h : Dictionary = hiragana[i]
		
		if not is_in_ranges(h["level"], ranges):
			pass
		elif empty:
			results.append([0, i])
		elif h["text"].findn(text) != -1 or h["reading"].findn(text) != -1:
			results.append([0, i])
	
	return ["Hiragana", results]


func search_katakana(text, ranges, filter):
	var results = []
	
	if ranges == null:
		if filter == true:
			return ["Katakana", results]
		else:
			ranges = [[0, katakana.size()]]
	
	var empty = text == ""
	
	for i in len(katakana):
		var k : Dictionary = katakana[i]
		
		if not is_in_ranges(k["level"], ranges):
			pass
		elif empty:
			results.append([1, i])
		elif k["text"].findn(text) != -1 or k["reading"].findn(text) != -1:
			results.append([1, i])
	
	return ["Katakana", results]


func search_radicals(text, ranges, filter):
	var results = []
	
	if ranges == null:
		if filter == true:
			return ["Radicals", results]
		else:
			ranges = [[0, radicals.size()]]
	
	var empty = text == ""
	
	for i in len(radicals):
		var r : Dictionary = radicals[i]
		
		if not is_in_ranges(r["level"], ranges):
			pass
		elif empty:
			results.append([2, i])
		elif r["text"] is String and r["text"].findn(text) != -1:
			results.append([2, i])
		elif r["reading"].findn(text) != -1:
			results.append([2, i])
	
	return ["Radicals", results]


func search_kanji(text, ranges, filter):
	var results = []
	
	if ranges == null:
		if filter == true:
			return ["Kanji", results]
		else:
			ranges = [[0, kanji.size()]]
	
	var empty = text == ""
	
	for i in len(kanji):		
		var k : Dictionary = kanji[i]
		var added : bool = false
		
		if not is_in_ranges(k["level"], ranges):
			continue
		elif empty:
			results.append([3, i])
			continue
		elif k["text"].findn(text) != -1:
			results.append([3, i])
			continue
		
		for m in k["meanings"]:
			if m.findn(text) != -1:
				results.append([3, i])
				added = true
				break
		
		if added:
			continue
		
		for r in k["radicals"]:
			if radicals[r]["reading"].findn(text) != -1:
				results.append([3, i])
				break
	
	return ["Kanji", results]


func search_vocabulary(text, ranges, filter):
	var results = []
	
	if ranges == null:
		if filter == true:
			return ["Vocabulary", results]
		else:
			ranges = [[0, vocabulary.size()]]
	
	var empty = text == ""
	
	for i in len(vocabulary):
		var v : Dictionary = vocabulary[i]
		
		if not is_in_ranges(v["level"], ranges):
			continue
		elif empty:
			results.append([4, i])
			continue
		elif v["text"].findn(text) != -1:
			results.append([4, i])
			continue
		
		for m in v["meanings"]:
			if m.findn(text) != -1:
				results.append([4, i])
				break
	
	return ["Vocabulary", results]


func is_in_ranges(num, ranges):
	for r in ranges:
		if num > r[0] and num <= r[1]:
			return true
	return false


func setup_info_card(card : InfoCard, index):
	var type = index[0]
	var info : Dictionary = all[index[0]][index[1]]
	
	match type:
		HIRAGANA, KATAKANA, RADICAL:
			card.add_text(info["text"], 32)
			card.add_text(info["reading"], 16)
		KANJI:
			card.add_text(info["text"], 32)
			card.add_text(info["readings"][info["primary_reading"]][0], 16)
			card.add_text(info["meanings"][0], 16)
		VOCABULARY:
			card.add_text(info["text"], 32)
			card.add_text(info["reading"], 16)
			card.add_text(info["meanings"][0], 16)
	
	var styles = card_styles[type]
	card.set_style(styles[0], styles[1], styles[2], styles[3], styles[4])


func setup_info_popup(popup : InfoPopup, item):
	var type = item[0]
	var info : Dictionary = all[item[0]][item[1]]
	
	var style_type = card_styles[type][0]
	const style_grey = preload("res://Styles/Grey/StyleGreyNormal.tres")
	const style_empty = preload("res://Styles/General/StyleEmpty.tres")
	
	popup.add_title_text(str(info["level"]), style_grey)
	popup.add_title_text(info["text"], style_type)
	
	match type:
		HIRAGANA, KATAKANA, RADICAL:
			popup.add_title_text(" " + info["reading"] + " ", style_empty)
		KANJI, VOCABULARY:
			popup.add_title_text(" " + info["meanings"][0] + " ", style_empty)
	
	match type:
		HIRAGANA, KATAKANA:
			var hk_vocabulary = []
			
			for v in info["vocabulary"]:
				hk_vocabulary.append([VOCABULARY, v])
			
			popup.add_paragraph("Found In Vocabulary")
			popup.add_info_cards(hk_vocabulary, 0, hk_vocabulary.size())
			
		RADICAL:
			var r_kanji = []
			
			for k in info["kanji"]:
				r_kanji.append([KANJI, k])
			
			popup.add_paragraph("Found In Kanji")
			popup.add_info_cards(r_kanji, 0, r_kanji.size())
			
		KANJI:
			var readings = info["readings"]
			
			var on_color = Color(0.4, 0.4, 0.4)
			var kun_color = Color(on_color)
			var nan_color = Color(on_color)
			
			var k_radicals = []
			var k_vocabulary = []
			
			for r in info["radicals"]:
				k_radicals.append([RADICAL, r])
			
			for v in info["vocabulary"]:
				k_vocabulary.append([VOCABULARY, v])
			
			if info["primary_reading"] == "on":
				on_color = Color(1.0, 1.0, 1.0)
			elif info["primary_reading"] == "kun":
				kun_color = Color(1.0, 1.0, 1.0)
			elif info["primary_reading"] == "nan":
				nan_color = Color(1.0, 1.0, 1.0)
			
			popup.add_paragraph("Meanings")
			popup.add_table([[[", ".join(info["meanings"]), Color.WHITE]]])
			popup.add_seperator()
			popup.add_paragraph("Readings")
			popup.add_table([
				[
					["On`yumi", on_color],
					[", ".join(readings["on"]), on_color]
				],
				[
					["Kun`yumi", kun_color],
					[", ".join(readings["kun"]), kun_color]
				],
				[
					["Nanori", nan_color],
					[", ".join(readings["nan"]), nan_color]
				]
			])
			popup.add_seperator()
			popup.add_paragraph("Radicals")
			popup.add_info_cards(k_radicals, 0, k_radicals.size())
			popup.add_seperator()
			popup.add_paragraph("Found In Vocabulary")
			popup.add_info_cards(k_vocabulary, 0, k_vocabulary.size())
			
		VOCABULARY:
			popup.add_paragraph("Meanings")
			popup.add_table([[[", ".join(info["meanings"]), Color.WHITE]]])
			popup.add_seperator()
			popup.add_paragraph("Reading")
			popup.add_table([[[info["reading"], Color.WHITE]]])
			popup.add_seperator()
			popup.add_paragraph("Word Type")
			popup.add_table([[[", ".join(info["types"]), Color.WHITE]]])
			popup.add_seperator()
			popup.add_paragraph("Composition")
			popup.add_info_cards(info["characters"], 0, info["characters"].size())


func setup_quiz_card(card : QuizCard, item):
	var type = item[0]
	var info = all[type][item[1]]
	
	card.set_style(card_styles[type][0])
	
	if type == HIRAGANA or type == KATAKANA or type == RADICAL:
		card.add_text(info["text"], 32)
		card.add_input(info["reading"])
	elif type == KANJI or type == VOCABULARY:
		card.add_text(info["text"], 32)
		card.add_input(info["meanings"][0])


func get_categories():
	return [
		"Hiragana",
		"Katakana",
		"Radicals",
		"Kanji",
		"Vocabulary",
		"Grammar",
	]


func get_levels(category):
	var entries = all[category]
	var levels = []
	
	for i in entries.size():
		var e = entries[i]
		var level = e["level"]
		var level_index = level - 1
		
		if level > levels.size():
			levels.resize(level)
		
		if levels[level_index] == null:
			levels[level_index] = []
		
		levels[level_index].append([category, i])
	
	return levels
