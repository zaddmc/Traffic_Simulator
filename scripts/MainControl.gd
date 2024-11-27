extends Node3D
@export var car_spawn_count: int = 10
@export var wanted_space: float = 3
@export var light_time: float = 10 
@export var lights_on: bool = false
@export var velocity_debug: bool = false
@export var spacing_multiplier: int = 2
@export_range(0,1) var percent_fast_cars: float = 0.5
@export var scale_int: float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_on_all_loaded")
	return

func _on_all_loaded():
	var roads = get_node("road_paths") # Gets road_baker.gd script
	roads.bake_roads()
	roads.assign_traffic_lights(light_time, lights_on, scale_int)
	var args = Array(OS.get_cmdline_args())
	roads.spawn_cars(car_spawn_count, wanted_space, velocity_debug, spacing_multiplier, percent_fast_cars, scale_int)
	return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_cars(delta)
	return

func update_cars(delta: float):
	for car in Car.CARS:
		car.update_car(delta)
	return
