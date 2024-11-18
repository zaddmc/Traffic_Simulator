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
var closest_car = null
var wanted_space:float
var velocity_debug:bool
var breaking:bool = false
var material: StandardMaterial3D = StandardMaterial3D.new()
var reaction_time:float # in miliseconds


func update_car(delta: float) -> void:
	match determine_speed_action(delta):
		"full_stop":
			self.speed = 0
			material.albedo_color = Color(speed/max_speed,0,1) # Blue
		"light_brake":
			de_accelerate()
			material.albedo_color = Color(speed/max_speed,0,0) # Red
		"hard_brake":
			self.speed *= 0.6*delta
			material.albedo_color = Color(speed/max_speed,0,0) # Red
		"stop":
			self.speed = 0
		"accelerate":
			accelerate()
			material.albedo_color = Color(0,speed/max_speed,0) # Green
		"max_speed":
			self.speed = self.max_speed
			material.albedo_color = Color(0,speed/max_speed,0) # Green
		"change_road":
			change_road(ROAD_DICT[current_road].pick_random())
		var others:
			print(others)
			self.speed = 0 
			material.albedo_color = Color(1,1,0) # Yellow

	self.set_progress(self.get_progress()+delta*speed)
	if velocity_debug:
		update_car_color()
	return

var de_acceleration # def = [0.9, 0.1] # First part of acceleration is multiplier and second is constant aswell as the minimum value before flatlining zero
func de_accelerate() -> bool:
	"""Returns true if it changed speed"""
	var old_speed = self.speed
	var new_speed = old_speed * de_acceleration[0] - de_acceleration[1]
	if new_speed >= de_acceleration[1]:
		self.speed = new_speed
		return true
	else:
		return false

var acceleration # def = [1.1, 0.1] # First part of acceleration is multiplier and second is constant
func accelerate() -> bool:
	"""Returns true if it changed speed"""
	var old_speed = self.speed
	var new_speed = old_speed * acceleration[0] + acceleration[1]
	if new_speed <= max_speed:
		self.speed = new_speed
		return true
	else:
		return false

func change_road(new_road:Path3D):
	self.reparent(new_road)
	self.set_progress_ratio(0)
	current_road = new_road

	current_roads = []
	current_roads.append(new_road)
	current_roads.append_array(ROAD_DICT[new_road])
	return

static func new_car(road_:Path3D, starting_offset_:float = 0, max_speed_:float = 13.88, velocity_debug_:bool = false,
wanted_space_:float = 2, acceleration_ = [1.1, 0.1], de_acceleration_: = [0.9, 0.1], reaction_time_:float = 50) -> Car:
	var new_car_: Car = my_scene.instantiate()
	road_.add_child(new_car_)
	new_car_.current_road = road_
	new_car_.change_road(road_)
	
	new_car_.wanted_space = wanted_space_
	new_car_.velocity_debug = velocity_debug_
	new_car_.set_progress(starting_offset_) 
	new_car_.reaction_time = reaction_time_
	
	if (max_speed_ == 0):
		new_car_.max_speed = randf_range(5, 15)
	else:
		new_car_.max_speed = max_speed_
	new_car_.speed = new_car_.max_speed
	new_car_.acceleration = acceleration_
	new_car_.de_acceleration = de_acceleration_

	new_car_.loop = false
	
	CARS.append(new_car_)
	return new_car_

func update_car_color():
	self.get_child(0).get_child(0).set_surface_override_material(0, material)

func get_car_action() -> String:
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
	# merging
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
	var next_road_is_full:bool = false
	if crossing.is_in_group("TrafficLights"):
		for road in CROSSINGS_DICT[crossing]:
			if road in ROAD_DICT[current_road]: continue
			for roads_connected in ROAD_DICT[current_road]:
				if (roads_connected.get_parent().is_in_group("TrafficLights") == false 
				and roads_connected != current_road and roads_connected.get_child_count() != 0):
					if self.position.distance_to(roads_connected.get_child(-1).position) < 1500:
						next_road_is_full = true
						material.albedo_color = Color(1,0,1) # Pink
						break

	if self.get_progress_ratio() >= 0.99:
		return "change_road"
	# Determine if next traffic light is green
	if crossing.is_in_group("TrafficLights"):
		is_light_green = crossing.call("get_status", crossing_own_section)

	# Logic for speed settings
	if (distance_to_crossing < wanted_space and not is_light_green 
		or not shortest_incoming 
		or distance_to_crossing < wanted_space and next_road_is_full):
		return "full_stop"

	elif shortest_distance - self.get_progress() < get_stopping_distance() and shortest_distance - self.get_progress() > wanted_space and self.speed > 2:
		return "light_brake"

	elif shortest_distance - self.get_progress() < wanted_space:
		if self.speed > 1.5:
			return "hard_brake"
		elif self.speed <= 1:
			return "stop"

	else:
		if self.speed > self.max_speed:
			return "accelerate"
		else:
			return "max_speed"
	return "11"

func determine_speed_action(delta:float) -> String:
	var crossing_is_open:bool = (is_next_road_crossing() and is_next_crossing_green() and is_next_crossing_open())
	
	
	
	return "Case not handled fix it"



func is_next_crossing_green(road_to_check:Path3D = current_roads[1]) -> bool:
	"""Determins whether the next crossing is green"""
	var crossing_own_section = road_to_check.get_parent()
	var crossing = crossing_own_section.get_parent()
	return crossing.call("get_status", crossing_own_section)

func is_next_crossing_open(road_to_check:Path3D = current_roads[1]) -> bool:
	"""Determins whether next crossing or given crossing (based of road) contains cars other than own direction"""
	#assert(is_next_road_crossing(road_to_check)) # Is the developer trusted to check this before calling this or multiple of similar methods, or should they all call this to insure the safety of the lead developers life, whomever taht may be
	var crossing_own_section = road_to_check.get_parent()
	var crossing = crossing_own_section.get_parent()
	
	for road in CROSSINGS_DICT[crossing]:
		if road in ROAD_DICT[current_road]: continue
		if road.get_child_count() != 0:
			return false
	return true

func is_next_road_crossing(road_to_check:Path3D = current_roads[1]) -> bool:
	"""Returns bool determining if next road segemnt or given road is a crossing 
	assuming the potential crossing is part of group traficlights"""
	var crossing_own_section = road_to_check.get_parent()
	var crossing = crossing_own_section.get_parent()
	return crossing.is_in_group("TrafficLights")

func get_stopping_distance(is_max_distance:bool = false) -> float:
	var v = self.speed if not is_max_distance else self.max_speed
	var f = de_acceleration[0]
	return (0.278 * reaction_time * v) + v*v / (254 * f)

static func set_baked_roads(road_dict, inv_road_dict) -> void:
	ROAD_DICT = road_dict
	INV_ROAD_DICT = inv_road_dict
	return

static func set_crossings_dict(crossings_dict) -> void:
	CROSSINGS_DICT = crossings_dict
	return
