extends StaticBody

class_name Building

var hp : int = 100
var hpMax : int = 100
var atk : int = 0
var dist : int = 0

var type = 0

var HPBAR = true

var PAUSED = false
var BUILD_RADIUS = 0
	

func initHPBar():
	if HPBAR:
		var Bar3d = get_node("HP")
		var Bar3dViewport = get_node("HP/Viewport")
		Bar3d.texture = Bar3dViewport.get_texture()
		updateBar()

onready var Bullet := get_node("Bullet")
onready var AttackTween := get_node("AttackTween")
func attack(_target : Enemy) -> void:
	if not PAUSED and null != _target and atk>0:
		var bullet = Bullet.duplicate()
		add_child(bullet)
		AttackTween.interpolate_property(
			bullet, "global_transform:origin",
			bullet.global_transform.origin, _target.global_transform.origin,
			0.25, Tween.TRANS_LINEAR, Tween.EASE_OUT
			)
		AttackTween.start()
		_target.hit(atk)
		
		
func __dealDmg(_bullet, _prop)->void:
	remove_child(_bullet)
	_bullet.queue_free()
	pass

signal destroyed
func hit(_dmg : int) -> void:
	hp -= _dmg
	updateBar()
	if hp <= 0:
		emit_signal("destroyed", self)

func rotateMe(_degree: float) -> void:
	rotation_degrees.y += _degree

var placed := false
var canBePlaced := true
onready var CannotPlaceMaterial : Material = preload("res://Map/Buildings/cannotPlaceMaterial.tres")
onready var Ground = get_parent().get_node("Ground")
onready var Model : MeshInstance = get_node("Model")
func updatePlacement(_body, _left : bool = false) -> void:
	if not placed:
		if not [self, Ground].has(_body):
			canBePlaced = _left
		Model.set_surface_material(0, null if canBePlaced else CannotPlaceMaterial)
		

func updateBar():
	if HPBAR:
		var Bar2d = get_node("HP/Viewport/ProgressBar")
		Bar2d.max_value = hpMax
		Bar2d.value = hp
		
func __amBuilding() -> void:
	pass
