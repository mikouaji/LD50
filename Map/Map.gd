extends Navigation

var RADIUS : int = 100
var RNG : RandomNumberGenerator

var PAUSED = false

func init(_radius : int, _rng : RandomNumberGenerator) -> void:
	RADIUS = _radius
	RNG = _rng
	_ground()
	_ores()
	pass

onready var GROUND : StaticBody = get_node("Elements/Ground")
onready var GroundMaterial : Material = preload("res://Map/Ground.tres")
const GROUND_INVISIBLE_BORDER := 1.3
func _ground() -> void:
	var radius = RADIUS * GROUND_INVISIBLE_BORDER * 2
	var meshDataTool = MeshDataTool.new()
	var mesh = CylinderMesh.new()
	var arrMesh = ArrayMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.rings = 1
	mesh.height = 2
	mesh.rings = 64
	arrMesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh.get_mesh_arrays())
	meshDataTool.create_from_surface(arrMesh, 0)
	GROUND.get_node("Mesh").set_mesh(arrMesh)
	GROUND.get_node("Mesh").set_surface_material(0, GroundMaterial)
	var collision = CylinderShape.new()
	collision.radius = radius
	collision.height = 2
	GROUND.get_node("Collision").set_shape(collision)
	___updateNavigation()
	pass
	
const ORE_RING_WIDTH := 30
onready var OreScene = preload("res://Map/Env/Ore/Ore.tscn")
var ores := []
func _ores() -> void:
	var rings = __ringAmount()
	for r in rings:
		if 0 == r:
			var ore = OreScene.instance()
			
			ore.rotation_degrees = Vector3(0,RNG.randi_range(0,360),0)
			ore.translation = Vector3.ZERO
			ore.init(25000, 0)
			ore.scale = Vector3.ONE * 6.9
			__appendElement(ore)
			ores.append(ore)
			ore.connect("oreMined", self, "__oreMined")
		else:
			var amount = __oreAmountInRing(r)
			for i in amount:
				var ore = OreScene.instance()
				ore.rotation_degrees = Vector3(0,RNG.randi_range(0,360),0)
				var pos = __positionInRing(r)
				ore.translation = Vector3(pos.x, 0, pos.y)
				ore.init(RNG.randi_range(1000, 4000), pos.z)
				__appendElement(ore)
				ores.append(ore)
				ore.connect("oreMined", self, "__oreMined")
	pass

func __oreMined(ore, amount):
	get_parent().setOre(get_parent().getOre() + amount)

func __ringAmount() -> int:
	return int(floor(RADIUS/ORE_RING_WIDTH))
	
const ORES_PER_RING := Vector2(0,1.5)
func __oreAmountInRing(_ring : int) -> int:
	if _ring <= 2:
		return 2
	else:
		return int(floor(_ring * RNG.randf_range(ORES_PER_RING.x, ORES_PER_RING.y)))
	
#returns [x- x position, y - z position, z - distance from center]
func __positionInRing(_ring : int) -> Vector3:
	var r = RNG.randf_range(_ring*ORE_RING_WIDTH, (_ring+1)*ORE_RING_WIDTH)
	var theta = RNG.randf() * 2.0 * PI
	return Vector3(r * cos(theta), r * sin(theta), r)

onready var Elements := get_node("Elements")
func __appendElement(_element, _updateNavigation : bool = false) -> void:
	Elements.add_child(_element)
	if _updateNavigation:
		___updateNavigation()
	
func __removeElement(_element, _updateNavigation : bool = false) -> void:
	Elements.remove_child(_element)
	_element.queue_free()
	if _updateNavigation:
		___updateNavigation()
	
func ___updateNavigation():
	Elements.bake_navigation_mesh()

signal NavigationUpdated
func _navigationMeshUpdated():
	emit_signal("NavigationUpdated")

# BUILDING
onready var PlayerCam : Camera = get_tree().root.get_camera()
onready var BaseScene := preload("res://Map/Buildings/Base/Base.tscn")
onready var MineScene := preload("res://Map/Buildings/Mine/Mine.tscn")
onready var TowerScene := preload("res://Map/Buildings/Tower/Tower.tscn")
onready var WallScene := preload("res://Map/Buildings/Wall/Wall.tscn")
enum {BASE = 1 , MINE = 2, TOWER = 3, WALL = 4}
var toBuild = null
var buildings := []

func setBuildingToBuild(_type : int = 0):
	if null!=toBuild:
		__removeElement(toBuild)
		toBuild.queue_free()
		toBuild = null
	match _type:
		BASE:
			toBuild = BaseScene.instance()
		MINE:
			toBuild = MineScene.instance()
		TOWER:
			toBuild = TowerScene.instance()
		WALL:
			toBuild = WallScene.instance()
		_:
			toBuild = null
	if null!=toBuild:
		toBuild.BUILD_RADIUS = int(RADIUS * 0.9)
		toBuild.set_translation(Vector3(0, -100, 0))
		__appendElement(toBuild)

signal BuildingPlaced
func _input(_event):
	if null != toBuild:
		if _event is InputEventMouseMotion:
			var mousePos = get_viewport().get_mouse_position()
			var dropPlane = Plane(Vector3(0,1,0),0)
			var onMapPos = dropPlane.intersects_ray(
				PlayerCam.project_ray_origin(mousePos),
				PlayerCam.project_ray_normal(mousePos)
				)
			if onMapPos is Vector3:
				toBuild.set_translation(onMapPos)
				if toBuild.type != WALL:
					toBuild.rotateMe(RNG.randf_range(-15,15))
		if _event is InputEventMouseButton and _event.button_index == BUTTON_LEFT and toBuild.canBePlaced:
			var building = toBuild.duplicate()
			building.placed = true
			setBuildingToBuild()
			buildings.append(building)
			__appendElement(building, true)
			building.connect("destroyed", self, "__removeElement", [true])
			building.PAUSED = PAUSED
			match building.type:
				1:
					building.startMining()
					building.connect("hit",get_parent().get_node("GUI"), "updateBaseHP")
					building.connect("GAMEOVER",get_parent(), "gameOver")
					building.get_node("MiningTimer").paused = PAUSED
					building.get_node("AttackTimer").paused = PAUSED
				2:
					building.startMining()
					building.get_node("MiningTimer").paused = PAUSED
				3:
					building.get_node("AttackTimer").paused = PAUSED
				
			emit_signal("BuildingPlaced", building.type)
		if _event.is_action_pressed("ROTATE_BUILDING"):
				toBuild.rotateMe(rad2deg(PI/8))
			


#ENEMIES
const SPAWN_AFTER := 1
onready var Spawner := preload("res://Enemy/Spawner.tscn")
var spawners := []
func _spawners() -> void:
	var amount = __ringAmount()
	for i in amount:
		var s = Spawner.instance()
		__appendElement(s)
		spawners.append(s)
		var pos = __positionInRing(floor(RADIUS * GROUND_INVISIBLE_BORDER / ORE_RING_WIDTH)-1)
		s.init(RNG, SPAWN_AFTER, self)
		s.set_translation(Vector3(pos.x, 0, pos.y))
		s.connect("SpawningEnemies", self, "__appendElement")
		s.connect("DestroyedEnemy", self, "__removeElement")
	pass


