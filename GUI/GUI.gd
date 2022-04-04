extends Control

onready var Menus:=get_node("Menus")
onready var MainMenu:=get_node("Menus/Main")
onready var MainMenuPlay:=get_node("Menus/Main/Items/Play")
onready var MainMenuCont:=get_node("Menus/Main/Items/Continue")
onready var Panels:=get_node("Panels")
onready var SizeOption:=get_node("Menus/NewGame/Items/Size")
func _ready():
	SizeOption.add_item("SMALL",0)
	SizeOption.add_item("MEDIUM",1)
	SizeOption.add_item("LARGE",2)
	SizeOption.selected = 1

func getMapSize()->int:
	return SizeOption.selected

var gamePaused:bool=false
var previousSpeed := 0
func _input(_event):
	if _event.is_action_pressed("PAUSE"):
		_pauseMenu()
		
func _pauseMenu():
	if get_parent().getDay() > 0:
		gamePaused = !gamePaused
		if !gamePaused:
			Menus.hide()
			MainMenu.hide()
			MainMenuCont.hide()
			MainMenuPlay.show()
			get_parent().setSpeed(previousSpeed)
			Panels.show()
			_setPause(false)
		else:
			Panels.hide()
			previousSpeed = get_parent().getSpeed()
			get_parent().setSpeed(0)
			MainMenuCont.show()
			MainMenuPlay.hide()
			MainMenu.show()
			Menus.show()
			_setPause(true)

signal BuildButtonPressed
func _onBuildButtonPressed(type : int) -> void:
	emit_signal("BuildButtonPressed", type)


func __BuildMenuMouseEntered():
	emit_signal("BuildButtonPressed", 0)

onready var ButtonBase = get_node("Panels/BuildMenu/Button/Base")
onready var ButtonMine = get_node("Panels/BuildMenu/Button/Mine")
onready var ButtonTower = get_node("Panels/BuildMenu/Button/Tower")
onready var ButtonWall = get_node("Panels/BuildMenu/Button/Wall")
enum {BASE=1, MINE=2, TOWER=3, WALL =4}
enum {BASE_COST=0, MINE_COST=1500, TOWER_COST=1000, WALL_COST =250}
func updateAfterPlacement(_type : int) ->void:
	var cost = 0
	match _type:
		BASE:
			ButtonBase.disabled = true
			ButtonBase.visible = false
			BaseHP.show()
			get_parent().get_node("TIME").start()
			ButtonWall.show()
			ButtonMine.show()
			ButtonTower.show()
		MINE:
			cost = MINE_COST
		TOWER:
			cost = TOWER_COST
		WALL:
			cost = WALL_COST
	get_parent().setOre(get_parent().getOre() - cost)

onready var DayLabel = get_node("Panels/ResourceInfo/Items/Day")
onready var OreLabel = get_node("Panels/ResourceInfo/Items/Ore")
onready var SpeedLabel = get_node("Panels/TimeMenu/Items/Speed")
enum {PAUSED=0,SLOW=1, NORMAL=2, FAST=3}
func _updateDay(_val : int) -> void:
	DayLabel.text = str(_val)
	pass
func _updateOre(_val : int) -> void:
	OreLabel.text = str(_val)
	ButtonMine.disabled = _val < MINE_COST
	ButtonWall.disabled = _val < WALL_COST
	ButtonTower.disabled = _val < TOWER_COST
	pass
func _updateSpeed(_val : int) -> void:
	match _val:
		PAUSED:
			SpeedLabel.text = "PAUSED"
		SLOW:
			SpeedLabel.text = "SLOW"
		NORMAL:
			SpeedLabel.text = "NORMAL"
		FAST:
			SpeedLabel.text = "FAST"
	pass

onready var AttackInfo = get_node("Menus/AttackInfo")
func showAttackDayInfo():
	Menus.show()
	AttackInfo.show()

onready var Tooltip := get_node("Tooltip")
onready var TooltipBase := get_node("Tooltip/Base")
onready var TooltipMine := get_node("Tooltip/Mine")
onready var TooltipTower := get_node("Tooltip/Tower")
onready var TooltipWall := get_node("Tooltip/Wall")
func _showTooltip(type : int):
	Tooltip.visible = true
	match type:
		1:
			TooltipBase.visible = true
		2:
			TooltipMine.visible = true
		3:
			TooltipTower.visible = true
		4:
			TooltipWall.visible = true

func _hideTooltip():
	Tooltip.visible = false
	TooltipBase.visible = false
	TooltipMine.visible = false
	TooltipTower.visible = false
	TooltipWall.visible = false


func _quit():
	get_tree().quit()

onready var InfoPopup := get_node("Menus/InfoPopup")
func _showInfo():
	InfoPopup.show()

onready var HowtoPopup := get_node("Menus/HowtoPopup")
func _showHowto():
	HowtoPopup.show()

onready var SeedInput := get_node("Menus/NewGame/Items/Seed")
func getSEED()->String:
	return SeedInput.text

onready var NewGameSettings := get_node("Menus/NewGame")
func showNewGameSettings():
	NewGameSettings.show()
func hideNewGameSettings():
	NewGameSettings.hide()
	
onready var BG := get_node("BG")
func startNewGame():
	hideNewGameSettings()
	Panels.show()
	MainMenu.hide()
	BG.hide()
	Menus.hide()
	get_parent().newGame()

onready var BaseHP := get_node("Panels/BaseHP")
func updateBaseHP(val, mval):
	var bar = BaseHP.get_node("Items/Bar")
	bar.max_value = mval
	bar.value = val


func closeAttackInfo():
	Menus.hide()


func _setPause(val : bool):
	get_parent().pauseWorld(val)


func _toggleSounds(val):
	get_parent().setSounds(val)
