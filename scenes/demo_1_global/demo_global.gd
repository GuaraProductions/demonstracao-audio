extends Control

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var btn_play: Button = %BtnPlay
@onready var btn_stop: Button = %BtnStop
@onready var btn_pause: Button = %BtnPause
@onready var slider_pitch: HSlider = %SliderPitch
@onready var slider_volume: HSlider = %SliderVolume
@onready var check_loop: CheckBox = %CheckLoop
@onready var lbl_status: Label = %LblStatus
@onready var lbl_pitch_val: Label = %LblPitchVal
@onready var lbl_volume_val: Label = %LblVolumeVal
@onready var btn_back: Button = %BtnBack

var audio_stream: AudioStreamWAV

func _ready() -> void:
	audio_stream = load("res://audio/bgm_track_1.wav") as AudioStreamWAV
	if audio_stream:
		audio_player.stream = audio_stream
		_apply_loop_setting(check_loop.button_pressed)
	
	audio_player.finished.connect(_on_audio_finished)
	
	btn_play.pressed.connect(_on_play_pressed)
	btn_stop.pressed.connect(_on_stop_pressed)
	btn_pause.pressed.connect(_on_pause_pressed)
	
	slider_pitch.value_changed.connect(_on_pitch_changed)
	slider_volume.value_changed.connect(_on_volume_changed)
	check_loop.toggled.connect(_on_loop_toggled)
	
	btn_back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_launcher.tscn"))

func _process(_delta: float) -> void:
	if audio_player and audio_player.playing:
		lbl_status.text = "Status: PLAYING | Pos: %.2fs | Pitch: %.2fx | Vol: %.1fdB" % [
			audio_player.get_playback_position(),
			audio_player.pitch_scale,
			audio_player.volume_db
		]
	elif audio_player and audio_player.stream_paused:
		lbl_status.text = "Status: PAUSED"
	else:
		lbl_status.text = "Status: STOPPED"

func _on_play_pressed() -> void:
	if audio_player.stream_paused:
		audio_player.stream_paused = false
	else:
		audio_player.play()

func _on_stop_pressed() -> void:
	audio_player.stop()

func _on_pause_pressed() -> void:
	audio_player.stream_paused = not audio_player.stream_paused

func _on_pitch_changed(val: float) -> void:
	audio_player.pitch_scale = val
	lbl_pitch_val.text = "%.2fx" % val

func _on_volume_changed(val: float) -> void:
	var db_val = linear_to_db(clampf(val, 0.0001, 1.0))
	audio_player.volume_db = db_val
	lbl_volume_val.text = "%.1f dB" % db_val

func _on_loop_toggled(toggled: bool) -> void:
	_apply_loop_setting(toggled)

## Applies looping properties to the AudioStreamWAV resource.
## In Godot 4, AudioStreamWAV requires two conditions to loop properly:
## 1. 'loop_mode' set to LOOP_FORWARD.
## 2. 'loop_end' set to a sample index > 'loop_begin'.
## If 'loop_end' remains 0 (the default for raw runtime WAV files), Godot will not loop the audio.
func _apply_loop_setting(toggled: bool) -> void:
	if audio_stream:
		if toggled:
			# Enable forward looping mode on the WAV stream
			audio_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			
			# If loop_end is invalid or uninitialized (<= 0), calculate total sample count:
			# total_samples = duration_in_seconds * sample_rate (mix_rate in Hz, e.g. 44100)
			if audio_stream.loop_end <= audio_stream.loop_begin:
				var total_samples = int(audio_stream.get_length() * audio_stream.mix_rate)
				if total_samples > 0:
					audio_stream.loop_end = total_samples
		else:
			# Disable looping mode completely
			audio_stream.loop_mode = AudioStreamWAV.LOOP_DISABLED


func _on_audio_finished() -> void:
	if check_loop.button_pressed:
		audio_player.play()
