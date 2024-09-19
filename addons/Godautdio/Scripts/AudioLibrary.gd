@tool
extends Resource
class_name AudioLibrary


@export var audio_clips:Array[AudioClip]
@export var audio_bus:AudioBusLayout
@export var audio_files_format:Array[String] = ["mp3","wav","ogg","tres"]


#TODO use static typed Dictionary[Sting,AudioClip] when this is implemented 
#pull request https://github.com/godotengine/godot/pull/78656
#proposal https://github.com/godotengine/godot-proposals/issues/56
@export var clips_dict:Dictionary

@export var log:bool = false
