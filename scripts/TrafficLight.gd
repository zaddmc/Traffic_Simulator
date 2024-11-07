class_name TrafficLight
extends Node3D

var roads = [] #list of roads in crossing
var roadselect = [] #bool of every road, if true let cars through
var lightselect = 0 #selects which road to let through
var iswaiting = false
var Colorred = Color.hex(0xfa0a0aff)
var Colorgreen = Color.hex(0x1adb14ff)
var new_material = StandardMaterial3D.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	roads = get_children()
	roads.remove_at(0)
	for n in roads.size():
		roadselect.append(false)
	Switch_Ligts_Color()

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
	

func update_trafficlight():
	if iswaiting == false:
		iswaiting = true
		for i in range(roadselect.size()): roadselect[i] = false 
		Switch_Ligts_Color()
		print(roadselect)
		await wait(2)
		roadselect[lightselect-1] = true
		if lightselect < roads.size():
			lightselect = lightselect+1
		else:
			lightselect = 0
		iswaiting = false
		Switch_Ligts_Color()
		print(roadselect)
		return
	return
func Switch_Ligts_Color():
	if true in roadselect:
		new_material.albedo_color = Colorgreen
		get_child(0).get_child(1).material_override = new_material
		print("balls")
	else:
		new_material.albedo_color = Colorred
		get_child(0).get_child(1).material_override = new_material
		print("penis")
	

		
