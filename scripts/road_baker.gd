extends Node3D

var road_dict = {}
var roads = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("_on_all_loaded")

func _on_all_loaded():
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
			#print(str(point1) + str(point2))
			#print(space_between)
			if space_between <= 1:
				close_roads.append(rod)
			elif space_between <= 5:
				backup_list.append(rod)

		if close_roads == []:
			close_roads = backup_list
			
		road_dict[road] = close_roads

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

	

func _process(delta: float) -> void:
	thread_update_cars(delta)
	
	
func thread_update_cars(delta):
	for x in Car.CARS:
		x.update_car(delta)
		
