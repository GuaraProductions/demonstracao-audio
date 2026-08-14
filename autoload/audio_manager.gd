extends Node

## AudioManager — Autoload Singleton
## Persists at the root of the Scene Tree across scene transitions.
## Manages BGM crossfading, seamless playback, and global sound effects.

enum BGMMode {
	SEAMLESS,   ## Keeps track playing without restarting if already active
	CROSSFADE   ## Smoothly crossfades between current and new background track
}

signal bgm_changed(stream_name: String)

@onready var _bgm_player_a: AudioStreamPlayer = $BGMPlayerA
@onready var _bgm_player_b: AudioStreamPlayer = $BGMPlayerB
@onready var _sfx_player: AudioStreamPlayer = $SFXPlayer

var _active_player: AudioStreamPlayer
var _inactive_player: AudioStreamPlayer

var _current_tween: Tween

func _ready() -> void:
	_bgm_player_a.finished.connect(func(): if _active_player == _bgm_player_a and _bgm_player_a.stream: _bgm_player_a.play())
	_bgm_player_b.finished.connect(func(): if _active_player == _bgm_player_b and _bgm_player_b.stream: _bgm_player_b.play())
	
	_active_player = _bgm_player_a
	_inactive_player = _bgm_player_b


## Play BGM stream with specified transition mode
func play_bgm(stream: AudioStream, mode: BGMMode = BGMMode.SEAMLESS, fade_duration: float = 1.0) -> void:
	if stream == null:
		stop_bgm(fade_duration)
		return

	# Enable looping for AudioStreamWAV if applicable
	if stream is AudioStreamWAV:
		var wav = stream as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		if wav.loop_end <= wav.loop_begin:
			var total_samples = int(wav.get_length() * wav.mix_rate)
			if total_samples > 0:
				wav.loop_end = total_samples


	# Check if current stream is already playing on active player
	if _active_player.playing and _active_player.stream == stream:
		if mode == BGMMode.SEAMLESS:
			# Continuous playback — do nothing, keep music flowing cleanly!
			return

	var track_name = stream.resource_path.get_file()

	if mode == BGMMode.SEAMLESS or not _active_player.playing:
		# Immediate/Direct switch on active player
		if _current_tween and _current_tween.is_running():
			_current_tween.kill()

		_active_player.stream = stream
		_active_player.volume_db = 0.0
		_active_player.play()

		if _inactive_player.playing:
			_inactive_player.stop()

		bgm_changed.emit(track_name)

	elif mode == BGMMode.CROSSFADE:
		# Crossfade from _active_player to _inactive_player
		if _current_tween and _current_tween.is_running():
			_current_tween.kill()

		_inactive_player.stream = stream
		_inactive_player.volume_db = -80.0
		_inactive_player.play()

		_current_tween = create_tween().set_parallel(true)
		
		# Fade out current active player
		_current_tween.tween_property(_active_player, "volume_db", -80.0, fade_duration)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			
		# Fade in target inactive player
		_current_tween.tween_property(_inactive_player, "volume_db", 0.0, fade_duration)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		# Swap active player reference once fade completes
		_current_tween.chain().tween_callback(func():
			_active_player.stop()
			var temp = _active_player
			_active_player = _inactive_player
			_inactive_player = temp
		)

		bgm_changed.emit(track_name)


## Stop background music
func stop_bgm(fade_duration: float = 0.5) -> void:
	if _current_tween and _current_tween.is_running():
		_current_tween.kill()

	if fade_duration <= 0.0:
		_active_player.stop()
		_inactive_player.stop()
	else:
		_current_tween = create_tween().set_parallel(true)
		if _active_player.playing:
			_current_tween.tween_property(_active_player, "volume_db", -80.0, fade_duration)
		if _inactive_player.playing:
			_current_tween.tween_property(_inactive_player, "volume_db", -80.0, fade_duration)
		_current_tween.chain().tween_callback(func():
			_active_player.stop()
			_inactive_player.stop()
		)
	bgm_changed.emit("None")


## Play a one-shot global SFX sound
func play_sfx(stream: AudioStream, pitch_scale: float = 1.0, volume_db: float = 0.0) -> void:
	if stream == null:
		return
	_sfx_player.stream = stream
	_sfx_player.pitch_scale = pitch_scale
	_sfx_player.volume_db = volume_db
	_sfx_player.play()


## Adjust bus volume using linear (0.0 to 1.0) value
func set_bus_volume(bus_name: String, linear_value: float) -> void:
	var bus_idx = AudioServer.get_bus_index(bus_name)
	if bus_idx != -1:
		var db_val = linear_to_db(clampf(linear_value, 0.0001, 1.0))
		AudioServer.set_bus_volume_db(bus_idx, db_val)


## Get bus volume using linear (0.0 to 1.0) value
func get_bus_volume(bus_name: String = "Master") -> float:
	var bus_idx = AudioServer.get_bus_index(bus_name)
	if bus_idx != -1:
		return db_to_linear(AudioServer.get_bus_volume_db(bus_idx))
	return 1.0


## Check if BGM is currently playing
func is_bgm_playing() -> bool:
	return _active_player != null and _active_player.playing and _active_player.stream != null


## Get active BGM track filename
func get_active_bgm_name() -> String:
	if _active_player and _active_player.playing and _active_player.stream:
		return _active_player.stream.resource_path.get_file()
	return "None"


## Get current playback position in seconds
func get_bgm_playback_position() -> float:
	if _active_player and _active_player.playing:
		return _active_player.get_playback_position()
	return 0.0
