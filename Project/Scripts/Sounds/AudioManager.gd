extends Node

@onready var bgm: AudioStreamWAV = preload("res://Sounds/Bgm_Main.wav")

var bgm_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer


func _init() -> void:
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = AudioServer.get_bus_name(1)
	add_child(bgm_player)
	
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = AudioServer.get_bus_name(2)
	add_child(sfx_player)
	

func _ready() -> void:
	bgm_player.stream = bgm
	bgm_player.play()
	

func play_sfx(audio: AudioStream, volume: float = -1.0) -> void:
	sfx_player.stream = audio
	sfx_player.volume_db = volume if volume >= 0.0 else 1.0
	sfx_player.play()
	
