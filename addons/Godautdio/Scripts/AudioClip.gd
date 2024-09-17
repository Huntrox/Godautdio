extends Resource
class_name AudioClip


enum ClipSpaceType  { NonePositional = 0,Is2DSpace = 1,Is3DSpace = 2}
enum StreamType{Single=0,RandomStream =1}

#TODO use id lookup 
#@export var clip_id:String
@export var clip_path:String 
@export var clip_stream:AudioStreamRandomizer
@export var stream_type:StreamType
@export var bus_index:int 
@export var clip_space_type:ClipSpaceType
@export var params:ClipParams = ClipParams.new()



func _init() -> void:
	clip_stream = AudioStreamRandomizer.new()
	clip_stream.random_volume_offset_db = 0.0
	clip_stream.random_pitch = 1.0
	params = ClipParams.new()
	bus_index = 0
	clip_space_type = ClipSpaceType.NonePositional
