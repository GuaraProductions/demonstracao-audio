extends Node2D

@onready var audio_player_2d: AudioStreamPlayer2D = $Speaker/AudioStreamPlayer2D
@onready var speaker: Node2D = $Speaker
@onready var listener: AudioListener2D = $Listener
@onready var listener_marker: Node2D = $ListenerMarker

@onready var btn_play: Button = %BtnPlay
@onready var btn_sfx: Button = %BtnSFX
@onready var slider_max_dist: HSlider = %SliderMaxDist
@onready var lbl_max_dist_val: Label = %LblMaxDistVal
@onready var lbl_metrics: Label = %LblMetrics
@onready var btn_back: Button = %BtnBack

var is_dragging: bool = false
var audio_stream: AudioStreamWAV

func _ready() -> void:
	listener.make_current()
	
	audio_stream = load("res://audio/sfx_sample_2d.wav") as AudioStreamWAV
	if audio_stream:
		audio_player_2d.stream = audio_stream
	
	audio_player_2d.finished.connect(func(): if btn_play.text.begins_with("⏹"): audio_player_2d.play())
	
	btn_play.pressed.connect(_on_play_toggle)
	btn_sfx.pressed.connect(_on_play_one_shot)
	slider_max_dist.value_changed.connect(_on_max_dist_changed)
	btn_back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_launcher.tscn"))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var mouse_pos = get_global_mouse_position()
			if mouse_pos.distance_to(speaker.global_position) < 50.0:
				is_dragging = true
		else:
			is_dragging = false
			
	elif event is InputEventMouseMotion and is_dragging:
		speaker.global_position = get_global_mouse_position()
		queue_redraw()

func _process(_delta: float) -> void:
	var dist = speaker.global_position.distance_to(listener_marker.global_position)
	var max_d = audio_player_2d.max_distance
	var dx = speaker.global_position.x - listener_marker.global_position.x
	var pan = clampf(dx / (max_d if max_d > 0 else 1.0), -1.0, 1.0)
	
	lbl_metrics.text = "Distance to Listener: %.1f px | Max Dist: %.0f px | Est. Panning: %.2f" % [
		dist,
		max_d,
		pan
	]

func _draw() -> void:
	# Draw Listener visual marker
	var listener_pos = listener_marker.position
	draw_circle(listener_pos, 12.0, Color(0.2, 0.8, 1.0, 0.9))
	draw_string(ThemeDB.fallback_font, listener_pos + Vector2(-30, 30), "Listener2D", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.CYAN)
	
	# Draw Speaker attenuation range ring & vector line
	var speaker_pos = speaker.position
	var max_d = audio_player_2d.max_distance
	draw_arc(speaker_pos, max_d, 0, TAU, 64, Color(1.0, 0.4, 0.4, 0.4), 2.0)
	draw_line(speaker_pos, listener_pos, Color(1.0, 1.0, 0.4, 0.5), 1.5)

func _on_play_toggle() -> void:
	if audio_player_2d.playing and btn_play.text.begins_with("⏹"):
		audio_player_2d.stop()
		btn_play.text = "▶ Play Continuous 2D Loop"
	else:
		if audio_stream:
			audio_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			if audio_stream.loop_end <= audio_stream.loop_begin:
				var total_samples = int(audio_stream.get_length() * audio_stream.mix_rate)
				if total_samples > 0:
					audio_stream.loop_end = total_samples
		audio_player_2d.play()
		btn_play.text = "⏹ Stop 2D Loop"

func _on_play_one_shot() -> void:
	audio_player_2d.stop()
	btn_play.text = "▶ Play Continuous 2D Loop"
	if audio_stream:
		audio_stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	audio_player_2d.play()

func _on_max_dist_changed(val: float) -> void:
	audio_player_2d.max_distance = val
	lbl_max_dist_val.text = "%.0f px" % val
	queue_redraw()
