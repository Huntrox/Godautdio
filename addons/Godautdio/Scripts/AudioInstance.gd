extends Node
class_name AudioInstance

var instance_id:String

	
func on_finish()->void:
	Godautdio.on_instance_finish(self)
	queue_free()
