extends Button

@export var node : CanvasItem

func _on_pressed():
	node.visible = !node.visible
