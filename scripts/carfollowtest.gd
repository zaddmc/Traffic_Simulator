class_name Car
extends PathFollow3D

const my_scene: PackedScene = preload("res://scripts/car.tscn")

# Internal varibles for each car object
var starting_offset: float = 0
var max_speed: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.set_progress(starting_offset)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.set_progress(self.get_progress()+delta*max_speed)
	

static func new_car(starting_offset:float, max_speed:float = 0) -> Car:
	var new_car: Car = my_scene.instantiate()
	new_car.starting_offset = starting_offset
	
	if (max_speed == 0):
		new_car.max_speed = randf_range(5, 15)
	else:
		new_car.max_speed = max_speed
		
	return new_car
