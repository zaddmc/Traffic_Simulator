extends Path3D

var CARS = []
@export var car_spawn_count: int = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var length = curve.get_baked_length() # gets the length of the road/path

	var fast_car = Car.new_car(10, 50)
	CARS.append(fast_car)
	add_child(fast_car)

	var fast_car2 = Car.new_car(100, 40)
	CARS.append(fast_car2)
	add_child(fast_car2)

	for i in range(car_spawn_count):
		var car = Car.new_car(-20*i)
		CARS.append(car)
		add_child(car)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
