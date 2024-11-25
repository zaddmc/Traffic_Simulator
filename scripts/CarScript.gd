class_name Car
extends PathFollow3D

# Collective varibles all instances can acces
const my_scene: PackedScene = preload("res://prefabs/car.tscn")
static var CARS = []
static var ROAD_DICT
static var INV_ROAD_DICT
static var CROSSINGS_DICT

# Debug related
@export var selected_color:Color
@export var highlighted_color:Color

# Internal varibles for each car object
var max_speed: float
var speed: float
var current_road: Path3D
var current_roads = []
var closest_car = null
var wanted_space_time:float
var wanted_space:float
var velocity_debug:bool
var breaking:bool = false
var material: StandardMaterial3D = StandardMaterial3D.new()
var reaction_time:float # in miliseconds
var next_road:Path3D
var desired_wanted_space:float


func update_car(delta: float) -> void:
	"""Called by MainControl, to update the cars in their new state.
	But it mainly does coloring for the cars and the final call of the solution from 'determine_speed_action'"""
	match determine_speed_action():
		"full_stop":
			material.albedo_color = Color((speed/2)/max_speed+0.5, 0, 1) # Blue
		"brake":
			de_accelerate()
			material.albedo_color = Color((speed/2)/max_speed+0.5, 0, 0) # Red
		"accelerate":
			accelerate()
			material.albedo_color = Color(0, (speed/2)/max_speed+0.5, 0) # Green
		"change_road":
			change_road(next_road)
		"change_next_road":
			change_next_road()
		var others:
			print(others)
			speed = 0
			material.albedo_color = Color(1,1,0) # Yellow

	self.set_progress(self.get_progress()+delta*speed)
	
	if velocity_debug:
		if is_in_group("selected_car"):
			material.albedo_color = selected_color
		if is_in_group("highlighted_car"):
			material.albedo_color = highlighted_color
		update_car_color()
	return

var stuck_count:int = 0

func determine_speed_action() -> String:
	update_wanted_space()

	var crossing_is_open:bool = (is_next_road_crossing() and is_next_crossing_green() and is_next_crossing_open())

	# For debug printout
	if is_in_group("selected_car"):
		#print("open: %s isCrossing: %s freespace: %s" % [crossing_is_open, is_next_road_crossing(), free_space])
		print("wanted space: %.2f and Distance2Road: %.2f and distance to next car: %.2f" % [wanted_space + get_stopping_distance(false), get_distance_next_road(), get_next_car_distance(get_next_car_unsafe())])
		print("Is next car blocking: %s" % is_next_car_blocking())
		print()
		pass

	# The way to add logic is to find all the reasons to brake/hold back for something, and if there is nothing to stop for, allow it drive.
	if self.get_progress_ratio() > 0.99:
		return "change_road"

	if is_next_car_blocking():
		return "brake"

	if is_next_road_crossing() and is_space_to_road_free():
		if is_there_space_to_next_car() and crossing_is_open:
			# To avoid blocks caused by cars attempting to enter full road, resulting in grid locks
			if stuck_count > 60:
				stuck_count = 0
				return "change_next_road"
			stuck_count += 1
			return "accelerate"
		else:
			return "brake"


	return "accelerate"

#==================================================
# Helper Functions to determine next speed setting
#==================================================
func is_space_to_road_free():
	return get_distance_next_road() < wanted_space + get_stopping_distance(false)

func change_next_road() -> bool:
	if len(ROAD_DICT[current_road]) == 1: return false
	next_road = ROAD_DICT[current_road].pick_random()
	return true

var speed_stamps = []
func update_wanted_space():
	speed_stamps.append(speed)
	if len(speed_stamps) > 5:
		speed_stamps.remove_at(0)
	var speed_avg = 0
	for spd in speed_stamps:
		speed_avg += spd
	speed_avg /= len(speed_stamps)
	wanted_space = speed_avg * wanted_space_time + 3
	return

func is_next_car_blocking():
	# Determine wheter next car is a problem or not
	var next_car = get_next_car_safe() # Remember it returns a tuple
	if next_car[1]: # It seems weird to check this, but it so far is saying that if there is another car in the vicinity it can check if its problematic
		return get_next_car_distance(next_car[0]) < wanted_space + get_stopping_distance(false)
	else: return false

func is_there_space_to_next_car():
	var road_after_crossing = ROAD_DICT[next_road][0]
	if road_after_crossing.get_child_count() != 0:
		var next_car = road_after_crossing.get_child(-1) 
		if is_in_group("selected_car"):
			print("road_length: %.3f   needed free space: %.3f" % [next_car.get_parent().get_curve().get_baked_length(), desired_wanted_space * (1 + road_after_crossing.get_child_count() + next_road.get_child_count())])
			print("next road: %s  and road after: %s " % [next_road, road_after_crossing])
		return next_car.get_parent().get_curve().get_baked_length() > desired_wanted_space * (2 + road_after_crossing.get_child_count() + next_road.get_child_count())
	else: 
		return true

func get_distance_to_crossing(road_to_check:Path3D = next_road) -> float:
	return is_next_road_crossing(road_to_check) and get_distance_next_road(road_to_check)

func get_next_car_searchdepth():
	"""To be implemented"""
	return null

func get_next_car_safe(start_car:PathFollow3D = self):
	"""Returns a psuedo tuple where [0] is the resulting car or start_car, and [1] is a bool determining if result is start_car"""
	var result = get_next_car_unsafe(start_car)
	return [result, result != self]

func get_next_car_unsafe(start_car:PathFollow3D = self) -> PathFollow3D:
	"""Returns the closest car with a search depth of next set of roads,
	IMPORTANT! It will return the input car if it doesnt find another, preferbly use 'get_next_car_safe'"""
	var start_car_index = start_car.get_index()
	if start_car_index == 0: # The car is the furthest car ahead on its current road
		return get_next_car_helper(start_car, start_car.current_road)[0]
	else: # Assuming index is a positive integer that is within range
		return start_car.get_parent().get_child(start_car_index - 1)

func get_next_car_helper(original_car:PathFollow3D, road_to_check:Path3D):
	var pot_cars = []
	for road in ROAD_DICT[road_to_check]:
		if road.get_child_count() == 0: continue
		pot_cars.append(road.get_child(-1))
	
	match len(pot_cars):
		0: return [original_car]
		1: return pot_cars
		_: # Cursed way of finding best car
			var pot_cars_length = []
			for car in pot_cars:
				pot_cars_length.append([car, get_next_car_distance(car, original_car)])
			var best_car = pot_cars_length[0]
			for car in pot_cars_length:
				if car[1] < best_car[1]:
					best_car = car
			return best_car

func get_next_car_distance(car_to_check:PathFollow3D, start_car:PathFollow3D = self) -> float:
	if start_car.current_road == car_to_check.current_road:
		return car_to_check.get_progress() - start_car.get_progress()
	else:
		return get_road_length(start_car) - start_car.get_progress() + car_to_check.get_progress()

func get_next_car_distance_long(car_to_check:PathFollow3D, start_car:PathFollow3D = self, roads_inbetween = []) -> float:
	"""An extension of 'get_next_car_distance' that simply adds the length of roads in between the 2 cars
	It is not expected to be used, tho it has been made for any usage it will never see"""
	var distance:float = get_next_car_distance(car_to_check, start_car)
	for road in roads_inbetween:
		distance += get_road_length(road)
	return distance

func get_distance_next_road(road_to_check:Path3D = current_road, car_to_check:PathFollow3D = self) -> float:
	return get_road_length(road_to_check) - car_to_check.get_progress()

func get_road_length(object_to_check = current_road) -> float:
	"""Returns the length of given object assuming it to be either a Path3D or PathFollow3D"""
	if object_to_check is Path3D:
		return object_to_check.get_curve().get_baked_length()
	elif object_to_check is PathFollow3D:
		return object_to_check.get_parent().get_curve().get_baked_length()
	else:
		assert(false, "Function 'get_road_length' was given invalid type: %s" % typeof(object_to_check))
		return -1

func is_next_crossing_green(road_to_check:Path3D = current_roads[1]) -> bool:
	"""Determins whether the next crossing is green"""
	var crossing_own_section = road_to_check.get_parent()
	var crossing = crossing_own_section.get_parent()
	return crossing.call("get_status", crossing_own_section) == "green"

func is_next_crossing_open(road_to_check:Path3D = current_roads[1]) -> bool:
	"""Determins whether next crossing or given crossing (based of road) contains cars other than own direction"""
	#assert(is_next_road_crossing(road_to_check)) # Is the developer trusted to check this before calling this or multiple of similar methods, or should they all call this to insure the safety of the lead developers life, whomever taht may be
	var crossing_own_section = road_to_check.get_parent()
	var crossing = crossing_own_section.get_parent()
	
	for road in CROSSINGS_DICT[crossing]:
		if road in ROAD_DICT[current_road]: continue
		if road.get_child_count() != 0:
			color_cars(road.get_children())
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
	var t = reaction_time * 0.001 # Reaction time is in miliseconds but the formula needs it in seconds
	return (0.278 * t * v) + v*v / (254 * f)

var de_acceleration # def = [0.9, 0.1] # First part of acceleration is multiplier and second is constant aswell as the minimum value before flatlining zero
func de_accelerate(stop:bool = false) -> bool:
	"""Returns true if it changed speed"""
	var old_speed = self.speed
	var new_speed = old_speed * de_acceleration[0] - de_acceleration[1]
	if new_speed >= de_acceleration[1]:
		self.speed = new_speed
		return true
	else:
		self.speed = 0
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
		self.speed = max_speed
		return false

#====================================================================
# Externally called helper functions and other miscellaneous helpers
#====================================================================
static func set_baked_roads(road_dict, inv_road_dict) -> void:
	ROAD_DICT = road_dict
	INV_ROAD_DICT = inv_road_dict
	return

static func set_crossings_dict(crossings_dict) -> void:
	CROSSINGS_DICT = crossings_dict
	return

func change_road(new_road:Path3D):
	if get_parent().get_parent().get_parent().is_in_group("TrafficLights"):
		get_parent().get_parent().get_parent().get_parent().call("add_through", get_parent().get_parent()) # makes the road change count
	self.reparent(new_road)
	self.set_progress_ratio(0)
	current_road = new_road

	current_roads = []
	current_roads.append(new_road)
	current_roads.append_array(ROAD_DICT[new_road])
	
	next_road = ROAD_DICT[current_road].pick_random()
	return

static func new_car(road_:Path3D, starting_offset_:float = 0, max_speed_:float = 13.88, velocity_debug_:bool = false,
wanted_space_time_:float = 2, acceleration_ = [1.1, 0.1], de_acceleration_: = [0.9, 0.1], reaction_time_:float = 50,
desired_wanted_space_:float = 7) -> Car:
	var new_car_: Car = my_scene.instantiate()
	road_.add_child(new_car_)
	new_car_.current_road = road_
	new_car_.change_road(road_)
	
	new_car_.wanted_space_time = wanted_space_time_
	new_car_.velocity_debug = velocity_debug_
	new_car_.set_progress(starting_offset_) 
	new_car_.reaction_time = reaction_time_
	
	if (max_speed_ == 0):
		new_car_.max_speed = randf_range(5, 15)
	else:
		new_car_.max_speed = max_speed_
	new_car_.acceleration = acceleration_
	new_car_.de_acceleration = de_acceleration_
	new_car_.desired_wanted_space = desired_wanted_space_

	new_car_.loop = false
	add_button(new_car_)
	
	CARS.append(new_car_)
	return new_car_

static func add_button(car):
	"""Doesnt actually add a button, it just changes the size of a collision part of the car, tho it doesnt collide with anything but the mouse"""
	var mesh = car.get_child(0).get_child(0)
	var area_node = mesh.get_child(0)
	var collision_node = area_node.get_child(0)
	collision_node.shape.size = mesh.get_aabb().size
	return

func update_car_color():
	self.get_child(0).get_child(0).set_surface_override_material(0, material)

func color_cars(cars_to_color = []):
	if self.is_in_group("selected_car"):
		for car in cars_to_color:
			car.add_to_group("highlighted_car")
	return

func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true:
			if is_in_group("selected_car"):
				remove_from_group("selected_car")
			else:
				add_to_group("selected_car")
