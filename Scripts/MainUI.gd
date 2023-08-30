extends Control

@onready var container : Control = $VBoxContainer/HBoxContainer2/Control


func _init():
	visibility_changed.connect(_on_visibility_changed)


# Called when the node enters the scene tree for the first time.
func _ready():
	show_menu()


func set_content(node : Node):
	container.remove_child(container.get_child(0))
	container.add_child(node)


func show_menu():
	var menu_ui = (load("res://Scenes/main_menu.tscn") as PackedScene).instantiate()
	menu_ui.get_node("SearchBar/LineEdit").connect("text_submitted", show_search)
	menu_ui.get_node("HBox/VBox/Hiragana/Button").connect("pressed", Callable(show_levels).bind(JapaneseDb.HIRAGANA))
	menu_ui.get_node("HBox/VBox/Katakana/Button").connect("pressed", Callable(show_levels).bind(JapaneseDb.KATAKANA))
	menu_ui.get_node("HBox/VBox2/Radicals/Button").connect("pressed", Callable(show_levels).bind(JapaneseDb.RADICAL))
	menu_ui.get_node("HBox/VBox2/Kanji/Button").connect("pressed", Callable(show_levels).bind(JapaneseDb.KANJI))
	menu_ui.get_node("HBox/VBox2/Vocabulary/Button").connect("pressed", Callable(show_levels).bind(JapaneseDb.VOCABULARY))
	menu_ui.get_node("HBox/VBox2/Grammar/Button").connect("pressed", Callable(show_levels).bind(JapaneseDb.GRAMMAR))
	menu_ui.get_node("HBox/VBox2/Quiz/Button").connect("pressed", Callable(show_quiz))
	menu_ui.get_node("Buttons/Settings").connect("pressed", show_settings)
	menu_ui.get_node("Buttons/Quit").connect("pressed", on_quit)
	set_content(menu_ui)


func show_search(text : String):
	var ui_search = (load("res://Scenes/main_search.tscn") as PackedScene).instantiate()
	ui_search.get_node("Buttons/Back").pressed.connect(show_menu)
	ui_search.get_node("SearchBar/LineEdit").text_submitted.connect(show_search)
	ui_search.setup(text)
	set_content(ui_search)


func show_levels(category):
	var ui_levels = (load("res://Scenes/main_levels.tscn") as PackedScene).instantiate()
	ui_levels.get_node("Buttons/Back").pressed.connect(show_menu)
	ui_levels.setup(category)
	set_content(ui_levels)


func show_quiz():
	pass


func show_settings():
	var ui_settings = load("res://Scenes/main_settings.tscn").instantiate()
	ui_settings.get_node("Buttons/Back").connect("pressed", show_menu)
	set_content(ui_settings)


func on_quit():
	get_tree().quit()


func _on_visibility_changed():
	
	if is_visible_in_tree():
		print("menu visible")
	else:
		print("menu invisible")
