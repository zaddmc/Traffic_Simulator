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
	var best_diff: float = 10
	for car in CARS:
		if car == self:
			continue
		var prog_diff_loop = car.get_progress_ratio() - own_progress
		if prog_diff_loop < 0:
			prog_diff_loop = 1 + prog_diff_loop

		if best_diff > prog_diff_loop:
			closest_car = car
		
	# Get the diffrence in closet car and self, and insure its a positive number between 0 to 1
	var prog_diff = closest_car.get_progress_ratio() - own_progress
	if prog_diff < 0:
		prog_diff = 1 + prog_diff

	if  prog_diff < wanted_space:
		self.speed = closest_car.speed if self.max_speed >= closest_car.speed else self.max_speed
		if self == CARS[0]:
			print(str(speed) + " and prog_diff " + str(prog_diff) + " option 2")
	elif prog_diff > wanted_space*2:
		self.speed = self.max_speed
		
		if self == CARS[0]:
			print(str(speed) + " and prog_diff " + str(prog_diff) + " option 3")
			
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
