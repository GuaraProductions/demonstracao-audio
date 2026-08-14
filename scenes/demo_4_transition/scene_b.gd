extends Control

@onready var btn_seamless: Button = %BtnSeamless
@onready var btn_crossfade: Button = %BtnCrossfade
@onready var btn_sfx: Button = %BtnSFX
@onready var slider_volume: HSlider = %SliderVolume
@onready var lbl_volume_val: Label = %LblVolumeVal
@onready var lbl_status: Label = %LblStatus
@onready var btn_back: Button = %BtnBack

var track_1: AudioStreamWAV
var track_2: AudioStreamWAV
var sfx_sound: AudioStreamWAV

func _ready() -> void:
	track_1 = load("res://audio/bgm_track_1.wav") as AudioStreamWAV
	track_2 = load("res://audio/bgm_track_2.wav") as AudioStreamWAV
	sfx_sound = load("res://audio/sfx_sample_3d.wav") as AudioStreamWAV

	var current_vol = AudioManager.get_bus_volume("Master")
	slider_volume.value = current_vol
	_update_volume_label(current_vol)

	slider_volume.value_changed.connect(_on_volume_changed)
	btn_seamless.pressed.connect(_on_seamless_transition)
	btn_crossfade.pressed.connect(_on_crossfade_transition)
	btn_sfx.pressed.connect(func(): AudioManager.play_sfx(sfx_sound, randf_range(0.8, 1.3)))
	btn_back.pressed.connect(func():
		AudioManager.stop_bgm(0.3)
		get_tree().change_scene_to_file("res://scenes/main_launcher.tscn")
	)

func _on_volume_changed(val: float) -> void:
	AudioManager.set_bus_volume("Master", val)
	_update_volume_label(val)

func _update_volume_label(val: float) -> void:
	var db_val = linear_to_db(clampf(val, 0.0001, 1.0))
	lbl_volume_val.text = "%d%% (%.1f dB)" % [int(val * 100), db_val]

func _process(_delta: float) -> void:
	lbl_status.text = "Active BGM: %s | Playback Position: %.2f s" % [
		AudioManager.get_active_bgm_name(),
		AudioManager.get_bgm_playback_position()
	]

func _on_seamless_transition() -> void:
	# Simply transition scene: AudioManager keeps whatever track is currently playing uninterrupted!
	get_tree().change_scene_to_file("res://scenes/demo_4_transition/scene_a.tscn")

func _on_crossfade_transition() -> void:
	# Crossfade back to Track 1 while returning to Scene A
	AudioManager.play_bgm(track_1, AudioManager.BGMMode.CROSSFADE, 1.5)
	get_tree().change_scene_to_file("res://scenes/demo_4_transition/scene_a.tscn")
