class_name Car
extends PathFollow3D

# Collective varibles all instances can acces
const my_scene: PackedScene = preload("res://scripts/car.tscn")
static var CARS = []
static var ROAD_DICT = []

# Internal varibles for each car object
var max_speed: float
var speed: float
var current_road: Path3D
var current_roads = []
var cars_on_same_road = []

# Called every frame. 'delta' is the elapsed time since the previous frame.
func update_car(delta: float) -> void:
	var wanted_space = 5
	var current_road_length = current_road.get_curve().get_baked_length()

	var closest_car = null
	var space_to_next_car_best: float = 1000
	for car in cars_on_same_road:
		if car == self: continue

		var space_to_next_car
		if car.current_road == self.current_road:
			space_to_next_car = car.get_progress() - self.get_progress()
		else:
			space_to_next_car = (car.get_progress() + current_road_length) - self.get_progress()

		if space_to_next_car < space_to_next_car_best:
			space_to_next_car_best = space_to_next_car
			closest_car = car


	var crossing_own_section = current_roads[1].get_parent()
	var crossing = crossing_own_section.get_parent()
	var crossing_name = crossing.get_child(0).get_name()
	var hold_back_for_traffic_light:bool = false
	var space_to_crossing = current_road_length - self.get_progress()
	if crossing_name == "kryds":# or crossing_name == "Tkryds":
		hold_back_for_traffic_light = not crossing.get("roadselect")[crossing_own_section.get_index() - 1]
			
			
	if space_to_crossing > wanted_space and hold_back_for_traffic_light:
		self.speed = 0
	elif space_to_next_car_best < wanted_space:
		if self.speed > 1:
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

static func new_car(road:Path3D, starting_offset:float = 0, max_speed:float = 0) -> Car:
	var new_car: Car = my_scene.instantiate()
	road.add_child(new_car)
	new_car.current_road = road
	new_car.change_road(road)
	
	new_car.set_progress(starting_offset) 
	
	if (max_speed == 0):
		new_car.max_speed = randf_range(5, 15)
	else:
		new_car.max_speed = max_speed
	new_car.speed = new_car.max_speed
	
	new_car.loop = false
	
	CARS.append(new_car)
	return new_car

static func set_baked_roads(road_dict) -> void:
	ROAD_DICT = road_dict
	return
