extends Button

@export var ui_click:AudioRef
@export var ui_enter:AudioRef
@export var ui_exit:AudioRef

func _on_pressed():
	ui_click.play()
	await get_tree().create_timer(0.5).timeout
	queue_free()



func _on_mouse_entered():
#	ui_enter.play() # Replace with function body.
	pass


func _on_mouse_exited():
#	ui_exit.play() # Replace with function body.
	pass
