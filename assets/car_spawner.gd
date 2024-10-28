extends Path3D

var CARS = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(200):
		var car = load("res://scripts/car.tscn").instantiate()
		car.starting_offset = 3 * i
		CARS.append(car)
		add_child(car)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
