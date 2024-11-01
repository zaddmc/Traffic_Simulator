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

func shit():
	for road_part in self.get_children():
		for road in road_part.get_children():
			match road_part.get_child(0).name:
				"kryds":
					if road.get_parent().name == "kryds": continue
					for sub_road in road.get_children():
						road_dict[sub_road] = helper(sub_road)
				"road":
					if road.get_parent().name == "road": continue
					road_dict[road] = helper(road)
				_:
					print("not Good")
	
	# Giving the result to the cars
	print(road_dict)
	Car.set_baked_roads(road_dict)
	return
func helper(road):
	road.add_child(temp_car)
	temp_car.set_progress_ratio(1)
	var result = find_closest_road()
	road.remove_child(temp_car)
	return result

func find_closest_road():
	var result = []
	for road_part in self.get_children(): # Takes from top level i.e all roads and connections
		for road in road_part.get_children(): # Takes from singular cell i.e a crossing or straight
			match road_part.get_child(0).name: # Takes from direction i.e either a direction that is straight or what incomming lane in crossing
				"kryds":
					if road.get_parent().name == "kryds": continue
					for sub_road in road.get_children(): # Takes from incomming lane in crossing i.e where the incomming lane goes
						if find_closest_road_helper(sub_road):
							result.append(sub_road)
				"road":
					if road.get_parent().name == "road": continue
					if find_closest_road_helper(road):
						result.append(road)
				_:
					print("Not good")				
	return result
	
func find_closest_road_helper(road):
	road.add_child(temp_car_2)
	var space_between = (temp_car.global_position - temp_car_2.global_position).length()
	road.remove_child(temp_car_2)
	return space_between <= 3

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
