extends Node3D

var road_dict = {}
var roads = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("_on_all_loaded")
	setup_traffic_light_timer()

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


func update_trafficlight():
	for fish in get_tree().get_nodes_in_group("TrafficLights"):
		fish.update_trafficlight()

func setup_traffic_light_timer():
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1
	timer.one_shot = false
	timer.start()
	timer.connect("timeout", _on_traffic_light_timer_timeout)


func _on_traffic_light_timer_timeout():
	print("i am a timer")
	update_trafficlight()

func _process(delta: float) -> void:
	thread_update_cars(delta)

func thread_update_cars(delta):
	for x in Car.CARS:
		x.update_car(delta)
