extends Node3D

@onready var audio_player_3d: AudioStreamPlayer3D = $SpeakerMesh/AudioStreamPlayer3D
@onready var speaker_mesh: MeshInstance3D = $SpeakerMesh
@onready var camera_3d: Camera3D = $Camera3D

@onready var btn_play: Button = %BtnPlay
@onready var btn_orbit: Button = %BtnOrbit
@onready var option_attenuation: OptionButton = %OptionAttenuation
@onready var option_doppler: OptionButton = %OptionDoppler
@onready var slider_speed: HSlider = %SliderSpeed
@onready var lbl_speed_val: Label = %LblSpeedVal
@onready var slider_unit_size: HSlider = %SliderUnitSize
@onready var lbl_unit_size_val: Label = %LblUnitSizeVal
@onready var lbl_metrics: Label = %LblMetrics
@onready var btn_back: Button = %BtnBack

var is_orbiting: bool = true
var orbit_angle: float = 0.0
var orbit_radius: float = 6.0
var speed_multiplier: float = 1.0
var audio_stream: AudioStreamWAV

func _ready() -> void:
	# Create 3D Mesh and Material procedurally
	var sphere = SphereMesh.new()
	sphere.radius = 0.5
	sphere.height = 1.0
	speaker_mesh.mesh = sphere
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.35, 0.25)
	mat.emission_enabled = true
	mat.emission = Color(0.8, 0.2, 0.1)
	mat.emission_energy_multiplier = 0.8
	speaker_mesh.set_surface_override_material(0, mat)
	
	# Setup Environment procedurally
	var env_node: WorldEnvironment = $WorldEnvironment
	if env_node:
		var env = Environment.new()
		var sky_mat = ProceduralSkyMaterial.new()
		sky_mat.sky_top_color = Color(0.15, 0.18, 0.25)
		sky_mat.sky_horizon_color = Color(0.25, 0.3, 0.4)
		sky_mat.ground_bottom_color = Color(0.08, 0.1, 0.14)
		var sky = Sky.new()
		sky.sky_material = sky_mat
		env.background_mode = Environment.BG_SKY
		env.sky = sky
		env.ambient_light_color = Color(0.6, 0.65, 0.75)
		env_node.environment = env

	audio_stream = load("res://audio/sfx_sample_3d.wav") as AudioStreamWAV
	if audio_stream:
		audio_player_3d.stream = audio_stream
	
	audio_player_3d.finished.connect(func(): if btn_play.text.begins_with("⏹"): audio_player_3d.play())

	btn_play.pressed.connect(_on_play_toggle)
	btn_orbit.pressed.connect(func(): is_orbiting = not is_orbiting)
	
	option_attenuation.add_item("Inverse Distance (Default)")
	option_attenuation.add_item("Logarithmic")
	option_attenuation.add_item("Disabled (No Attenuation)")
	option_attenuation.item_selected.connect(_on_attenuation_model_changed)

	option_doppler.add_item("Disabled")
	option_doppler.add_item("Idle Step")
	option_doppler.add_item("Physics Step")
	option_doppler.item_selected.connect(_on_doppler_mode_changed)
	
	# Match initial player setting
	match audio_player_3d.doppler_tracking:
		AudioStreamPlayer3D.DOPPLER_TRACKING_DISABLED: option_doppler.selected = 0
		AudioStreamPlayer3D.DOPPLER_TRACKING_IDLE_STEP: option_doppler.selected = 1
		AudioStreamPlayer3D.DOPPLER_TRACKING_PHYSICS_STEP: option_doppler.selected = 2
	
	slider_speed.value_changed.connect(_on_speed_changed)
	slider_unit_size.value_changed.connect(_on_unit_size_changed)
	btn_back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_launcher.tscn"))

func _process(delta: float) -> void:
	if audio_player_3d.doppler_tracking != AudioStreamPlayer3D.DOPPLER_TRACKING_PHYSICS_STEP:
		_update_orbit_movement(delta)
	_update_metrics()

func _physics_process(delta: float) -> void:
	if audio_player_3d.doppler_tracking == AudioStreamPlayer3D.DOPPLER_TRACKING_PHYSICS_STEP:
		_update_orbit_movement(delta)

func _update_orbit_movement(delta: float) -> void:
	if is_orbiting:
		orbit_angle += delta * 1.2 * speed_multiplier
		speaker_mesh.position = Vector3(
			cos(orbit_angle) * orbit_radius,
			sin(orbit_angle * 0.5) * 1.5,
			sin(orbit_angle) * orbit_radius
		)

func _update_metrics() -> void:
	var dist = speaker_mesh.global_position.distance_to(camera_3d.global_position)
	var speed_mps = (1.2 * speed_multiplier * orbit_radius) if is_orbiting else 0.0
	lbl_metrics.text = "3D Distance: %.2f m | Speed: %.1f m/s | Unit Size: %.1f | Model: %s | Doppler: %s" % [
		dist,
		speed_mps,
		audio_player_3d.unit_size,
		option_attenuation.get_item_text(option_attenuation.selected),
		option_doppler.get_item_text(option_doppler.selected)
	]

func _on_play_toggle() -> void:
	if audio_player_3d.playing:
		audio_player_3d.stop()
		btn_play.text = "▶ Play 3D Sound Loop"
	else:
		if audio_stream:
			audio_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			if audio_stream.loop_end <= audio_stream.loop_begin:
				var total_samples = int(audio_stream.get_length() * audio_stream.mix_rate)
				if total_samples > 0:
					audio_stream.loop_end = total_samples
		audio_player_3d.play()
		btn_play.text = "⏹ Stop 3D Sound"


func _on_attenuation_model_changed(idx: int) -> void:
	match idx:
		0: audio_player_3d.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
		1: audio_player_3d.attenuation_model = AudioStreamPlayer3D.ATTENUATION_LOGARITHMIC
		2: audio_player_3d.attenuation_model = AudioStreamPlayer3D.ATTENUATION_DISABLED


func _on_doppler_mode_changed(idx: int) -> void:
	var player_mode: AudioStreamPlayer3D.DopplerTracking
	var camera_mode: Camera3D.DopplerTracking
	match idx:
		0:
			player_mode = AudioStreamPlayer3D.DOPPLER_TRACKING_DISABLED
			camera_mode = Camera3D.DOPPLER_TRACKING_DISABLED
		1:
			player_mode = AudioStreamPlayer3D.DOPPLER_TRACKING_IDLE_STEP
			camera_mode = Camera3D.DOPPLER_TRACKING_IDLE_STEP
		2:
			player_mode = AudioStreamPlayer3D.DOPPLER_TRACKING_PHYSICS_STEP
			camera_mode = Camera3D.DOPPLER_TRACKING_PHYSICS_STEP

	audio_player_3d.doppler_tracking = player_mode
	if camera_3d:
		camera_3d.doppler_tracking = camera_mode


func _on_unit_size_changed(val: float) -> void:
	audio_player_3d.unit_size = val
	lbl_unit_size_val.text = "%.1f" % val


func _on_speed_changed(val: float) -> void:
	speed_multiplier = val
	lbl_speed_val.text = "%.1fx" % val
