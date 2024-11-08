class_name TrafficLight
extends Node3D

var roads = [] #list of roads in crossing
var light_dic = {}
var current_light = 0 #selects which road to let through

# Called when the node enters the scene tree for the first time.
func start() -> void:
	print("rstrst")
	var timer = get_child(-1)
	timer.timeout.connect(update_trafficlight)
	roads = get_children()
	roads.remove_at(-1)
	for n in roads.size():
		light_dic[n] = false
	light_dic[roads[0]] = true

func update_trafficlight():
	print("switching")
	if current_light < len(light_dic):
		light_dic[roads[current_light]] = false
		current_light += 1 
		light_dic[roads[current_light]] = true
	else:
		light_dic[roads[current_light]] = false
		current_light = 0 
		light_dic[roads[current_light]] = true


		
