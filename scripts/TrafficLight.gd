class_name TrafficLight
extends Node3D

var road_xin = false
var road_nzin = false
var road_nxin = false
var road_zin = false
var roads = [] #list of roads in crossing
var roadselect = [] #bool of every road, if true let cars through
var lightselect = 0 #selects which road to let through
var iswaiting = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	roads = get_children()
	roads.remove_at(0)
	roadselect.append(road_xin)
	roadselect.append(road_nzin)
	roadselect.append(road_nxin)
	roadselect.append(road_zin)

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func update_trafficlight():
	if iswaiting == false:
		iswaiting = true
		for i in range(roadselect.size()): roadselect[i] = false 
		wait(1)
		roadselect[lightselect-1] = true
		if lightselect < roads.size():
			lightselect = lightselect+1
		else:
			lightselect = 0
		wait(6)
		iswaiting = false
		return
	return
