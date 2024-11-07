extends Node3D

var road_dict = {}
var roads = []

# Called when the node enters the scene tree for the first time.

func start():
	roads = recursive_road_finder(self)
	for road in roads:

		var close_roads = []
		var backup_list = []
		for rod in roads:
			var points1 = road.get_curve().get_baked_points()
			var point1 = road.to_global(points1[points1.size()-1])
			var points2 = rod.get_curve().get_baked_points()
			var point2 = rod.to_global(points2[0])
			var space_between = (point1 - point2).length()

			if space_between <= 2:
				close_roads.append(rod)
			elif space_between <= 5:
				backup_list.append(rod)

		if close_roads == []:
			close_roads = backup_list

		road_dict[road] = close_roads

	# Giving the result to the cars
	#print(road_dict)
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
			if result != null:
				return_value.append_array(result)
		return return_value

func spawn_cars(car_spawn_count: int = 10):
	var spawnable_roads = get_tree().get_nodes_in_group("road_allow_spawn")
	var spacing = spawnable_roads[0].get_curve().get_baked_length() / (car_spawn_count / spawnable_roads.size() + 1)
	var itteration = (car_spawn_count / spawnable_roads.size())
	print(spacing)
	var spawned_cars = 0
	while true:
		for road in spawnable_roads:
			if spawned_cars >= car_spawn_count:
				return
			Car.new_car(road, itteration * spacing, 10)
			spawned_cars += 1
		itteration -= 1
	return


@export var point_distance: float = 0.2
func find_divering_paths():
	for road in roads:
		var roadpoints = road.get_curve().get_baked_points()
		if roadpoints.size() > 0:
			var roadpoint1 = road.to_global(roadpoints[0])
		
			for rod in roads:
				if rod != road:
					var rodpoints = rod.get_curve().get_baked_points()
					if rodpoints.size() > 0:
						var rodpoint1 = rod.to_global(rodpoints[0])
						var distance = (rodpoint1 - roadpoint1).length()
						if distance < point_distance:
							if road.get_parent().get_name() == "Roads":
								var DivPath = Node3D.new()
								add_child(DivPath)
								DivPath.add_to_group("div_path")
								rod.reparent(DivPath)
								road.reparent(DivPath)
							else:
								rod.reparent(road.get_parent())
		else:
			print(road.get_name())

func assign_traffic_lights():
	var crossing = get_tree().get_nodes_in_group("TrafficLights")
	for n in crossing:
		var timer = Timer.new()
		timer.autostart = false
		timer.timeout()
		n.set_script("res://scripts/TrafficLight.gd")
		n.add_child(timer)
		n.set_process(true)		


