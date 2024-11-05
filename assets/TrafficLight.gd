class_name TrafficLight
extends Node3D

var road_xin
var road_nzin
var road_nxin
var road_zin
var roads = []

var xin_open = false
var nxin_open = false
var nzin_open = false
var zin_open = false
var roadselect = []

var iswaiting = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	road_xin = get_child(1)
	road_nzin = get_child(2)
	road_nxin = get_child(3)
	road_zin = get_child(4)
	roads.append(road_xin)
	roads.append(road_nxin)
	roads.append(road_zin)
	roads.append(road_nzin)
	roadselect.append(xin_open)
	roadselect.append(nxin_open)
	roadselect.append(zin_open)
	roadselect.append(nzin_open)

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func update_trafficlight() -> void:
	if iswaiting == false:
		for n in range(len(roads)):
			iswaiting = true
			roadselect[n] = true
			print(roadselect[n])
			wait(5)
			roadselect[n] = false
			wait(1)
			iswaiting = false
		
