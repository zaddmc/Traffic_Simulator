class_name Car
extends PathFollow3D

# Collective varibles all instances can acces
const my_scene: PackedScene = preload("res://scripts/car.tscn")
static var CARS = []
static var ROAD_DICT = []

# Internal varibles for each car object
var starting_offset: float
var max_speed: float
var speed: float
var current_road: Path3D
var current_roads = []
var cars_on_same_road = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.set_progress(starting_offset)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func update_car(delta: float) -> void:
	var wanted_space = 2
	var own_progress = self.get_progress_ratio()
	#current_road.get_child(0).get_baked_length()

	for car in cars_on_same_road:
		if car == self: continue

		var prog_diff_loop = car.get_progress_ratio() - own_progress
		if prog_diff_loop < 0:
			prog_diff_loop = 1 + prog_diff_loop

		if prog_diff_loop < wanted_space:
			break
		else:
			self.speed = self.max_speed

	if own_progress >= 0.99:
		change_road(ROAD_DICT[current_road].pick_random())

	self.set_progress(self.get_progress()+delta*speed)
	return

func change_road(new_road:Path3D):
	# Empty previous roads
	self.reparent(new_road)
	current_roads = []
	self.set_progress_ratio(0)
	current_road = new_road
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
	
	new_car.starting_offset = starting_offset
	
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
