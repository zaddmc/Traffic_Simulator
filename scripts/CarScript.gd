class_name Car
extends PathFollow3D

const my_scene: PackedScene = preload("res://scripts/car.tscn")
static var CARS = []

# Internal varibles for each car object
var starting_offset: float
var max_speed: float
var speed: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.set_progress(starting_offset)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var wanted_space = 0.05
	var own_progress = self.get_progress_ratio()
	
	var closest_car = CARS[0] if CARS[0] != self else CARS[1] 
	for car in CARS:
		if car == self:
			continue

		var prog_diff_loop = car.get_progress_ratio() - own_progress
		if prog_diff_loop < 0:
			prog_diff_loop = 1 + prog_diff_loop
		
		if prog_diff_loop < wanted_space:
			closest_car = car
			self.speed = closest_car.speed
			break
		else:
			self.speed = self.max_speed
			
	self.set_progress(self.get_progress()+delta*speed)

static func new_car(starting_offset:float, max_speed:float = 0) -> Car:
	var new_car: Car = my_scene.instantiate()
	new_car.starting_offset = starting_offset
	
	if (max_speed == 0):
		new_car.max_speed = randf_range(5, 15)
	else:
		new_car.max_speed = max_speed
	new_car.speed = new_car.max_speed
		
	CARS.append(new_car)
	return new_car
