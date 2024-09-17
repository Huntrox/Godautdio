extends Button

@export var ui_click:AudioRef
@export var ui_enter:AudioRef
@export var ui_exit:AudioRef


func _on_pressed() -> void:
	ui_click.play()

func _on_mouse_entered() -> void:
	ui_enter.play()

func _on_mouse_exited() -> void:
	ui_exit.play()
