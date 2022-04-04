extends Spatial

onready var Player := get_node("Player")
onready var Map := get_node("Map")
onready var GUI := get_node("GUI")
func _ready():
	var r = 80
	Player.init(r)
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	Map.init(r, rng)
	GUI.connect("BuildButtonPressed", Map, "setBuildingToBuild")
	Map.connect("BuildingPlaced", GUI, "updateAfterPlacement")
	pass

