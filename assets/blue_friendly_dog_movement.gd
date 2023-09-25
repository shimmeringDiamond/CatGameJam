extends CharacterBody2D

@onready var animPlayer: AnimatedSprite2D = $AnimatedSprite2D
@onready var navAgent: NavigationAgent2D = $NavigationAgent2D
@onready var map: TileMap = get_node("../TileMap")

var running: bool = false
var sleepWhenDone: bool = false

var speed: int = 150
var lastDirx: int = 1
var newDirx: int = 1

func _ready():
	var mainMap = get_node("../../TileMap")
	animPlayer.play("idle")
	navAgent.set_navigation_map(map)
	scale.x = -1

func processLaserChange(targetPosition):
	newDirx = sign(targetPosition.x-position.x)

	if newDirx != lastDirx:
		#scale multiplies instead of sets... for some reasont
		scale.x = -1
		
	lastDirx = sign(newDirx)
	navAgent.target_position = targetPosition
	animPlayer.play("running")

func sleep():

	sleepWhenDone = true

func noSleepForU():
	sleepWhenDone = false

func _process(_delta):
	if running:
		animPlayer.play("running")
	
		
func _physics_process(delta):

	if navAgent.is_navigation_finished():
		if sleepWhenDone:
			animPlayer.play("sleeping")
		else:
			animPlayer.play("idle")
	
		
			
		
	else:
		var nextLocation = navAgent.get_next_path_position()
		var newVelocity = (nextLocation - position).normalized() * speed
		velocity = newVelocity
		move_and_slide()
