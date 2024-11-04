extends Node3D

var road_dict = {}
var roads = []
@onready var temp_car = self.get_child(0) #preload("res://scripts/car.tscn").instantiate()
@onready var temp_car_2 = self.get_child(1) #preload("res://scripts/car.tscn").instantiate() 

# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	call_deferred("_on_all_loaded")

func _on_all_loaded():
	roads = recursive_road_finder(self)
	self.remove_child(temp_car)
	self.remove_child(temp_car_2)
	for road in roads:
		road.add_child(temp_car)
		temp_car.set_progress_ratio(1)
		
		var close_roads = []
		for rod in roads:
			rod.add_child(temp_car_2)
			temp_car_2.set_progress_ratio(0)
			var space_between = (temp_car_2.get_child(0).global_position - temp_car.get_child(0).global_position).length()
			print(str(temp_car_2.global_position) + str(temp_car.global_position))
			if space_between <= 0.1:
				close_roads.append(rod)
			rod.remove_child(temp_car_2)

		road_dict[road] = close_roads
		road.remove_child(temp_car)

	# Giving the result to the cars
	print(road_dict)
	Car.set_baked_roads(road_dict)

	spawn_cars()
	return

func recursive_road_finder(input):
	if input is Path3D:
		return [input]
	elif input is MeshInstance3D:
		return null
	else: # Presumably Node3D, that is kind of treated as a list
		var return_value = []
		for child in input.get_children():
			var result = recursive_road_finder(child)
			if result != null:
				return_value.append_array(result)
		return return_value

@export var car_spawn_count: int = 10
func spawn_cars():
	for i in car_spawn_count:
		Car.new_car(roads.pick_random(), 0, 10)
	return
