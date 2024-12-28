extends Node

var LastLevel = "res://levels/Level1.tscn"

func get_last_level():
	return LastLevel

func set_last_level(name: String):
	LastLevel = name
