extends Path3D

var CARS = []
@export var car_spawn_count: int = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(car_spawn_count):
		var car = Car.new_car(-5*i, 10)
		CARS.append(car)
		add_child(car)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
