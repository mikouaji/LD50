extends Node

onready var GUI = get_node("GUI")
onready var CAM = get_node("Player")
onready var MAP = get_node("Map")
onready var TIME = get_node("TIME")
onready var MUSIC = get_node("MUSIC")

var RNG : RandomNumberGenerator
enum {PAUSED=0,SLOW=1, NORMAL=2, FAST=3}
var SPEED := NORMAL setget setSpeed, getSpeed
var ORE := 10000 setget setOre, getOre
var DAY := 0 setget setDay, getDay
var MAP_SIZE := 120
enum {SMALL = 100, MEDIUM = 180, LARGE = 320}

const ATTACK_DAY := 10

func _ready():
	connect("AttackDay", GUI, "showAttackDayInfo")
	connect("AttackDay", MAP, "_spawners")
	GUI.connect("BuildButtonPressed", MAP, "setBuildingToBuild")
	MAP.connect("BuildingPlaced", GUI, "updateAfterPlacement")
	
func newGame():
	__reset()
	CAM.init(MAP_SIZE, Vector3(0,120,120))
	MAP.init(MAP_SIZE, RNG)
	
func gameOver():
	pauseWorld(true)
	GUI.get_node("Menus").show()
	GUI.get_node("Menus/GameOver/Items/Days").text = str(DAY)+" DAYS!"
	GUI.get_node("Menus/GameOver").show()
	
func pauseWorld(val):
	setSpeed(PAUSED if val else NORMAL)
	TIME.paused = val
	MAP.PAUSED = val
	for b in MAP.buildings:
		if is_instance_valid(b):
			b.PAUSED = val
			match b.type:
				1:
					b.get_node("AttackTimer").paused = val
					b.get_node("MiningTimer").paused = val
				2:
					b.get_node("MiningTimer").paused = val
				3:
					b.get_node("AttackTimer").paused = val
	for s in MAP.spawners:
		s.get_node("Timer").paused = val
		s.get_node("ReleaseTimer").paused = val
		for e in s.enemies:
			if is_instance_valid(e):
				e.PAUSED = val
				e.get_node("AttackTimer").paused = val

func __reset():
	RNG = RandomNumberGenerator.new()
	setSEED()
	setMapSize()
	setSpeed(NORMAL)
	setOre(10000)
	setDay(1)

func setSounds(val:bool):
	MUSIC.stream_paused = !val
	
func setMapSize():
	var s = GUI.getMapSize()
	match s:
		0:
			MAP_SIZE = SMALL
		1:
			MAP_SIZE = MEDIUM
		2:
			MAP_SIZE = LARGE
	
func setSEED():
	var byteArray = GUI.getSEED().to_ascii()
	var _seed = 1
	for b in byteArray:
		_seed *= b
	RNG.seed = _seed
	pass
	
func setSpeed(v : int) -> void:
	if [PAUSED, SLOW, NORMAL, FAST].has(v):
		SPEED = v
	else:
		SPEED = NORMAL
	GUI._updateSpeed(SPEED)
func getSpeed() -> int:
	return SPEED	
	
func setOre(v : int) -> void:
	ORE = v
	GUI._updateOre(ORE)
func getOre() -> int:
	return ORE

signal AttackDay
func setDay(v : int) -> void:
	DAY=v
	GUI._updateDay(DAY)
	if DAY == ATTACK_DAY:
		emit_signal("AttackDay")
func getDay() -> int:
	return DAY


func _nextDay():
	setDay(DAY+1)
