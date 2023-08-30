class_name HierarchyButton extends Button


@export var parent_button : HierarchyButton
var button_children : Array[HierarchyButton]


func _ready():
	if parent_button != null:
		parent_button.button_children.append(self)


func _pressed():
	print("pressed")


func update_state():
	for child in button_children:
		if not child.button_pressed:
			button_pressed = false
			return
	button_pressed = true
