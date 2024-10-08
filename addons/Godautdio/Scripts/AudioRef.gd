extends Resource
class_name AudioRef

@export var clip_path:String 


var last_play:Godautdio.RefResult
var instance_id:String


func play(free_on_finish:bool = true)->Godautdio.RefResult:
	return Godautdio.play(self,null,free_on_finish)
	
func play_attached(parent:Node,free_on_finish:bool = true)->Godautdio.RefResult:
	return Godautdio.play(self,parent,free_on_finish)

func stop()->void:
	return Godautdio.stop(self)

func stop_all()->void:
	return Godautdio.stop_all_clips_of_path(self)
	
func play_at_location(position:Vector3)->Godautdio.RefResult:
	return Godautdio.play_at_location(self,position)
	
func play_one_shot(parent:Node = null)->Godautdio.RefResult:
	return Godautdio.play_one_shot(self,parent)

func play_one_shot_at_loc(position:Vector3)->Godautdio.RefResult:
	return Godautdio.play_one_shot(self,null,position)

func is_playing()->bool:
	return Godautdio.is_playing(self)

func clear():
	Godautdio.erase_ref(self)


func _init(path:String = ""):
	clip_path = path
	
static func create(path:String)->AudioRef:
	var ref:AudioRef = AudioRef.new()
	ref.clip_path = path
	return ref
