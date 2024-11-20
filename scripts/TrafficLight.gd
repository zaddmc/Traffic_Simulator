class_name TrafficLight
extends Node3D

var roads = [] #list of roads in crossing
var light_dic = {}
var current_light = 0
var material_green = StandardMaterial3D.new()
var material_red = StandardMaterial3D.new()#selects which road to let through
var material_yellow = StandardMaterial3D.new()
var timer
# Called when the node enters the scene tree for the first time.
func start() -> void:
	material_green.albedo_color = Color(0,1,0)
	material_red.albedo_color = Color(1,0,0)
	material_yellow.albedo_color = Color(1,1,0)
	timer = get_child(-1)
	timer.timeout.connect(update_trafficlight)
	timer.start(10)
	roads = get_children()
	roads.remove_at(roads.size()-1)
	for n in roads:
		light_dic[n] = "red"
		n.get_child(-1).get_child(0).set_surface_override_material(0, material_red)

func update_trafficlight():
	light_dic[roads[current_light]] = "yellow"
	roads[current_light].get_child(-1).get_child(0).set_surface_override_material(0, material_yellow)
	timer.start(10)
	light_dic[roads[current_light]] = "red"
	roads[current_light].get_child(-1).get_child(0).set_surface_override_material(0, material_red)
	if current_light < len(roads)-1:
		current_light += 1
	else:
		current_light = 0
	light_dic[roads[current_light]] = "green"
	roads[current_light].get_child(-1).get_child(0).set_surface_override_material(0, material_green)

func get_status(node: Node3D) -> String:
	return(light_dic[node])
