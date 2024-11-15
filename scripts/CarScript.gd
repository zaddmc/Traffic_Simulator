class_name Car
extends PathFollow3D

# Collective varibles all instances can acces
const my_scene: PackedScene = preload("res://scenes/car.tscn")
static var CARS = []
static var ROAD_DICT
static var INV_ROAD_DICT
static var CROSSINGS_DICT

# Internal varibles for each car object
var max_speed: float
var speed: float
var current_road: Path3D
var current_roads = []
var cars_on_same_road = []
var closest_car = null
var wanted_space:float

# Called every frame. 'delta' is the elapsed time since the previous frame.
func update_car(delta: float) -> void:
	var current_road_length = current_road.get_curve().get_baked_length()

	var self_index = self.get_index()
	var shortest_distance:float = 1000
	if self_index <= 0: # Front runner on own road
		for first_road in current_roads:
			if first_road == current_road: continue
			if first_road.get_child_count() <= 0:
				continue
			var distance = first_road.get_child(-1).get_progress()
			if distance < shortest_distance:
				shortest_distance = distance + current_road_length
	else:
		shortest_distance = current_road.get_child(self_index - 1).get_progress()

	var current_distance = self.get_progress()
	var current_remaing_distance = current_road_length - current_distance
	var incoming_roads = INV_ROAD_DICT[current_roads[1]]
	var shortest_incoming:bool = true
	for iroad in incoming_roads:
		if iroad == current_road: continue
		if iroad.get_child_count() == 0: continue
		var hello = iroad.get_curve().get_baked_length() - iroad.get_child(0).get_progress()
		if hello < current_remaing_distance:
			shortest_incoming = false

	# Get information about next crossing
	var crossing_own_section = current_roads[1].get_parent()
	var crossing = crossing_own_section.get_parent()
	var is_light_green:bool = true
	var distance_to_crossing = current_road_length - self.get_progress()
	
	# Determine if next crossing contains cars on other paths
	var crossings_contains_invalid_cars:bool = false
	if crossing.is_in_group("TrafficLights"):
		for road in CROSSINGS_DICT[crossing]:
			if road in ROAD_DICT[current_road]: continue
			if road.get_child_count() != 0:
				crossings_contains_invalid_cars = true
				break

	# Determine if next traffic light is green
	if crossing.is_in_group("TrafficLights"):
		is_light_green = crossing.call("get_status", crossing_own_section)
	
	# Logic for speed settings
	if (distance_to_crossing < wanted_space and not is_light_green 
		or not shortest_incoming 
		or distance_to_crossing < wanted_space and crossings_contains_invalid_cars):
		self.speed = 0
		
	elif shortest_distance - self.get_progress() < wanted_space:
		if self.speed > 1.5:
			self.speed = 0
		elif self.speed > 1:
			self.speed *= 0.9
			
	else:
		self.speed = self.max_speed

	if self.get_progress_ratio() >= 0.99:
		change_road(ROAD_DICT[current_road].pick_random())

	self.set_progress(self.get_progress()+delta*speed)
	return

func change_road(new_road:Path3D):
	self.reparent(new_road)
	self.set_progress_ratio(0)
	current_road = new_road

	cars_on_same_road = []
	current_roads = []
	current_roads.append(new_road)
	current_roads.append_array(ROAD_DICT[new_road])
	
	for road in current_roads:
		var road_children = road.get_children() 
		cars_on_same_road.append_array(road_children)

	return

static func new_car(road:Path3D, starting_offset:float = 0, max_speed:float = 0, wanted_space:float = 2) -> Car:
	var new_car: Car = my_scene.instantiate()
	road.add_child(new_car)
	new_car.current_road = road
	new_car.change_road(road)
	
	new_car.wanted_space = wanted_space
	
	new_car.set_progress(starting_offset) 
	
	if (max_speed == 0):
		new_car.max_speed = randf_range(5, 15)
	else:
		new_car.max_speed = max_speed
	new_car.speed = new_car.max_speed
	
	new_car.loop = false
	
	CARS.append(new_car)
	return new_car

static func set_baked_roads(road_dict, inv_road_dict) -> void:
	ROAD_DICT = road_dict
	INV_ROAD_DICT = inv_road_dict
	return

static func set_crossings_dict(crossings_dict):
	CROSSINGS_DICT = crossings_dict
	return
