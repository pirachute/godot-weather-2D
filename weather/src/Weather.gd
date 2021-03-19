extends Node2D

export (String, 'clear', 'rain', 'snow') var weatherType = 'sun'
export (float, -1, 1) var wind = 0
export (float, 0, 1) var size = 0.3
export (int, 100, 3000) var amount = 1500
export (float, 0, 1) var light = 1
export (float, 0, 1) var snow_darkness = 0.2
export (float, 0, 1) var rain_darkness = 0.3
export (float, 1, 10) var lightChangeTime = 2
export (bool) var delayWeatherChange = true # Wait light change before changing weather
export (float, 1, 300) var weatherChangeTime = 2

var nightColor: Color = Color.white # color SUBTRACTED to scene

# You can set this to the Player or another node you want the weather system to "follow".
# This way the weather effect will always be visible
export var followNode: NodePath # = "../Player"

onready var snow = $Snow
onready var rain = $Rain
onready var darkness = $Darkness
onready var tween = $Tween

# Emiter folows position of this node.
onready var follow: Node2D = get_node_or_null(followNode) # Thanks KamiGrave for this tip!!

# Set from WeatherControl to ignores last weather change
var last_control: Control
var last_amount: int


func _ready() -> void:
	change_weather()
	darkness_position()
	position = get_viewport_transform().get_origin() + Vector2(get_viewport_rect().size.x / 2, 0) # Initially positions the emiter in the top center of the screen
	snow.process_material.emission_box_extents.x = get_viewport_rect().size.x * 2 # Sets emiter width to N times the screen size
	rain.process_material.emission_box_extents.x = get_viewport_rect().size.x * 2 # Sets emiter width to N times the screen size
	
func _physics_process(_delta: float) -> void:
	if follow:
		position = follow.position + Vector2(0, -get_viewport_rect().size.y) # Weather follows the position of node in "follow"
		darkness_position() # Darkness follows the viewport
	
func change_weather():
	
	if weatherType == 'clear':
		apply_rain_settings()
		apply_snow_settings()
		if delayWeatherChange: yield(tween, "tween_completed") # Waits weather change before turning off emission and lower light
		change_light(nightColor.darkened(light))
	
	if weatherType == 'snow':
		
		# DARKEN DAY
		change_light(nightColor.darkened(light - snow_darkness * size))
		if delayWeatherChange: yield(tween, "tween_completed") # Waits light change to change weather
		
		change_amount(snow, amount)
		apply_snow_settings()
		snow.emitting = true
		
	else: snow.emitting = false

	if weatherType == 'rain':
		
		# DARKEN DAY
		change_light(nightColor.darkened(light - rain_darkness * size))
		if delayWeatherChange: yield(tween, "tween_completed") # Waits light change to change weather

		change_amount(rain, amount)
		apply_rain_settings()
		rain.emitting = true
		
	else: rain.emitting = false

		
	# SETS LAST_AMOUNT FOR CHANGE CHECK
	last_amount = amount

func change_light(new_color: Color):
	
	# Animation for darkness change
	tween.interpolate_property(darkness, "color",
	darkness.color, new_color, lightChangeTime,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	
func apply_snow_settings():
	
	# SNOW SETTINGS
	change_size(snow, size) # snow.process_material.anim_offset = size
	
	# SNOW WIND SETTINGS
	change_wind_speed(snow, 0.5 + abs(wind) / 2) # snow.speed_scale = 0.5 + abs(wind) / 2
	change_wind_direction(snow, wind) # snow.process_material.direction.x = wind
	snow.process_material.gravity.x = 70 * wind

func apply_rain_settings():
	
	# RAIN SETTINGS
	change_size(rain, size) # rain.process_material.anim_offset = size
	
	# RAIN WIND SETTINGS
	change_wind_speed(rain, 0.5 + abs(wind) / 2 + size / 2) # rain.speed_scale = 0.5 + abs(wind) / 2 + size / 2
	change_wind_direction(rain, wind) # rain.process_material.direction.x = wind
	rain.process_material.gravity.x = 200 * wind
	# rain.process_material.initial_velocity = 200 + 400 * abs(wind)	

func change_size(weather, new_size):
	
	tween.interpolate_property(weather, "process_material:anim_offset",
	weather.process_material.anim_offset, new_size, weatherChangeTime,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func change_amount(weather, new_amount):
	
	if last_amount != amount: # PROBLEM!! Changing amount resets particle emiter!!!
		if weather.emitting == true: weather.preprocess = weather.lifetime * 2
		weather.amount = amount
	else: weather.preprocess = 0

func change_wind_direction(weather, new_wind):
	
	tween.interpolate_property(weather, "process_material:direction:x",
	weather.process_material.direction.x, new_wind, weatherChangeTime,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func change_wind_speed(weather, new_speed):
	
	tween.interpolate_property(weather, "speed_scale",
	weather.speed_scale, new_speed, weatherChangeTime,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func darkness_position():
	
	# DARKNESS 4 TIMES VIEWPORT SIZE AND CENTERED... I THINK
	darkness.rect_size = get_viewport_rect().size * 4
	darkness.rect_position = get_viewport_rect().position - Vector2(get_viewport_rect().size.x*2, get_viewport_rect().size.y)
