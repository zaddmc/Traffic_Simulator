extends Node3D

var road_dict = {}
var temp_car = preload("res://scripts/car.tscn").instantiate()
var temp_car_2 = preload("res://scripts/car.tscn").instantiate() 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var roads = recursive_road_finder(self)
	for road in roads:
		road.add_child(temp_car)
		temp_car.set_progress_ratio(1)
		
		var close_roads = []
		for rod in roads:
			rod.add_child(temp_car_2)
			var space_between = (temp_car.global_position - temp_car_2.global_position).length()
			rod.remove_child(temp_car_2)
			if space_between <= 3:
				close_roads.append(rod)

		road_dict[road] = close_roads
		road.remove_child(temp_car)

	# Giving the result to the cars
	print(road_dict)
	Car.set_baked_roads(road_dict)
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
			if result != null:# or result == []:
				return_value.append_array(result)
		return return_value	
