# extends "res://src/WeatherControl.gd"
extends Control

var weatherType = ["clear", "rain", "snow"]
onready var weatherTypeList = $weatherTypeList

export var weatherNode: NodePath = "../Weather"
onready var weather: Node2D = get_node(weatherNode)

func _ready() -> void:
	weatherTypeList.add_item(weatherType[0])
	weatherTypeList.add_item(weatherType[1])
	weatherTypeList.add_item(weatherType[2])

func _on_windSlider_value_changed(value: float) -> void:
	# print("Wind: ", value)
	weather.wind = value
	weather.change_weather()

func _on_sizeSlider_value_changed(value: float) -> void:
	# print("Weather Size: ", value)
	weather.size = value
	weather.change_weather()

func _on_amountSlider_value_changed(value: float) -> void:
	# print("Weather Size: ", value)
	weather.amount = value
	weather.change_weather()

func _on_lightSlider_value_changed(value: float) -> void:
		# print("Weather Size: ", value)
	weather.light = value
	weather.change_weather()

func _on_snowDarkSlider_value_changed(value: float) -> void:
	weather.snow_darkness = value
	weather.change_weather()

func _on_rainDarkSlider_value_changed(value: float) -> void:
	weather.rain_darkness = value
	weather.change_weather()

func _on_lightTimeSlider_value_changed(value: float) -> void:
	weather.lightChangeTime = value
	weather.change_weather()

func _on_weatherTimeSlider_value_changed(value: float) -> void:
	weather.weatherChangeTime = value
	weather.change_weather()


func _on_weatherTypeList_item_selected(index: int) -> void:
	weather.weatherType = weatherType[index]
	weather.change_weather()
