extends TileMap

var mousePos = Vector2()
var lastMousePos = Vector2()

var rotateCount: int = 0

var tileLimitX: int = 74
var tileLimitY: int = 48
var mirrorIDs: PackedInt32Array = [6,7]
var solidIDs: PackedInt32Array = [5]

var blueLaserPlaceMode: bool = false
var mirrorPlaceMode: bool = false
var mirrorBlockerPlaceMode: bool = false
var deletePlaceMode: bool = false

var lasersInDrawOrder = []

var placing: bool = false

var dog
var dogs: Array[CharacterBody2D]


# Called when the node enters the scene tree for the first time.
func _ready():
	dog = preload("res://assets/blue_friendly_dog.tscn")
	spawnDog("blueFriendlyDog")
	
	var camera = get_node("../Camera2D")
	camera.laserButtonPlacing.connect(setBlueLaserPlaceMode)
	camera.mirrorButtonPlacing.connect(setMirrorPlaceMode)
	camera.dogButtonPlacing.connect(spawnDog)
	camera.mirrorBlockerButtonPlacing.connect(setMirrorBlockerPlaceMode)
	camera.deleteButtonPlacing.connect(setdeletePlaceMode)
	
	
	pass # Replace with function body.


func setBlueLaserPlaceMode():
	blueLaserPlaceMode = true
	placing = true

func setMirrorPlaceMode():
	mirrorPlaceMode = true
	placing = true
func spawnDog(name = "@CharacterBody2D@"+str(dogs.size()+2)):
	#dog.instantiate()
	add_child(dog.instantiate())
	var doggo = get_node(name)
	dogs.append(doggo)
	
	dogs[-1].position = Vector2(595,347)
	dogs[-1].processLaserChange(Vector2(395+randf()*300, 147+randf()*347))
	tellDogsWhereToGo()
	
	
func setMirrorBlockerPlaceMode():
	mirrorBlockerPlaceMode = true
	placing = true

func setdeletePlaceMode():
	deletePlaceMode = true
	placing = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#previews tile
	
	if blueLaserPlaceMode and placing:
		clear_layer(3)
		mousePos = get_global_mouse_position()/16
		mousePos = Vector2(clamp(mousePos.x, 0, tileLimitX), clamp(mousePos.y, 0, tileLimitY))
		set_cell(3,mousePos,2,Vector2i(0,0),rotateCount)
	
	if mirrorPlaceMode and placing:
		clear_layer(3)
		mousePos = get_global_mouse_position()/16
		mousePos = Vector2(clamp(mousePos.x, 0, tileLimitX), clamp(mousePos.y, 0, tileLimitY))
		if rotateCount <=1:
			set_cell(3,mousePos,7,Vector2i(0,0),rotateCount)
		else:
			set_cell(3,mousePos,6,Vector2i(0,0),rotateCount-2)
	
	if mirrorBlockerPlaceMode and placing:
		clear_layer(3)
		mousePos = get_global_mouse_position()/16
		mousePos = Vector2(clamp(mousePos.x, 0, tileLimitX), clamp(mousePos.y, 0, tileLimitY))
		set_cell(3,mousePos, 5, Vector2i(0,0),0)

	if deletePlaceMode and placing:
		clear_layer(3)
		mousePos = get_global_mouse_position()/16
		mousePos = Vector2(clamp(mousePos.x, 0, tileLimitX), clamp(mousePos.y, 0, tileLimitY))
		set_cell(3,mousePos,8,Vector2i(0,0),0)
		

func _unhandled_input(event):
	
	if event.is_action_pressed("select") and blueLaserPlaceMode:
		blueLaserPointer(get_global_mouse_position()/16)
		blueLaserPlaceMode = false
		placing = false
	
	if event.is_action_pressed("select") and mirrorPlaceMode:
		mirror(get_global_mouse_position()/16)
		mirrorPlaceMode = false
		placing = false
		
	if event.is_action_pressed("select") and mirrorBlockerPlaceMode:
		mirrorBlocker(get_global_mouse_position()/16)
		mirrorBlockerPlaceMode = false
		placing = false
	
	if event.is_action_pressed("select") and deletePlaceMode:
		Delete(get_global_mouse_position()/16)
		deletePlaceMode = false
		placing = false
		clear_layer(3)
		
	if event.is_action_pressed("cancel_place") and placing:
		placing = false
		mirrorPlaceMode = false
		blueLaserPlaceMode = false
		clear_layer(3)
		
	if event.is_action_pressed("rotate") and placing:
		rotateCount =(rotateCount +1)%4
	
			
#returns teh location of all current lasers in tilemap
func getCurrentLaserPointers():
	var currentLaserPointers =[[],[],[],[]]
	currentLaserPointers[0] =get_used_cells_by_id(4,4,Vector2i(0,0),0)
	currentLaserPointers[1] = get_used_cells_by_id(4,4,Vector2i(0,0),1)
	currentLaserPointers[2] =get_used_cells_by_id(4,4,Vector2i(0,0),2)
	currentLaserPointers[3] = get_used_cells_by_id(4,4,Vector2i(0,0),3)
	return currentLaserPointers


func getCurrentLasers():
	var currentLasers = get_used_cells_by_id(4,3,Vector2i(0,0),0)
	for i in get_used_cells_by_id(4,3,Vector2i(0,0),1):
		currentLasers.append(i)
	return currentLasers

func recomputeLasers():
	lasersInDrawOrder = []
	print("importantMessage"+str(lasersInDrawOrder))
	for i in getCurrentLasers():
		set_cell(4,i,-1,Vector2i(-1,-1),0)
		
	var count = 0
	for i in getCurrentLaserPointers():
		for x in i:
			blueLaserPointer(x, count)
		count += 1
	print("EvenMoreimportantMessage"+str(lasersInDrawOrder))
	tellDogsWhereToGo()
	
func tellDogsWhereToGo():
	
	randomizeDogsAndSleep()

	var prev
	if lasersInDrawOrder.size() >= 1:
		prev = lasersInDrawOrder[0]

	var toset: Vector2
	
	var posindex = 2
	var curr = 0
	for i in range(dogs.size()):
		if curr >= lasersInDrawOrder.size():
			break
		lasersInDrawOrder[curr] = Vector2i(lasersInDrawOrder[i].x,lasersInDrawOrder[i].y)
		
		if lasersInDrawOrder[curr].x == prev.x+ 1:
			toset.x += posindex
		if lasersInDrawOrder[curr].x == prev.x -1:
			toset.x -= posindex
		if lasersInDrawOrder[curr].y == prev.y-1:
			toset.y -= posindex
		if lasersInDrawOrder[curr].y == prev.y+1:
			toset.y += posindex
		
		
		dogs[i].processLaserChange(Vector2((lasersInDrawOrder[curr].x+toset.x)*16, (lasersInDrawOrder[curr].y+toset.y)*16))
		dogs[i].noSleepForU()
		
		print("eee")
		print(lasersInDrawOrder[curr])
		print(toset)
		print(Vector2((lasersInDrawOrder[curr].x+toset.x)*16, (lasersInDrawOrder[curr].y+toset.y)*16))
		
		prev = lasersInDrawOrder[curr]
		curr += posindex

	print()
		
		
		
		
func randomizeDogsAndSleep():
	for i in dogs:
		i.processLaserChange(Vector2(395+randf()*300, 147+randf()*347))
		i.sleep()
	
#places and fires the blue laser Pointer
func blueLaserPointer(pos, setRotation = -1):
	
	
		
	var tileLimitToUse: int
	var rotationToUse: int
	var keepGoing: bool = true
	#spawn laser pointer
	
	if setRotation != -1:
		rotateCount = setRotation
	
	#check if vertical
	if rotateCount == 0 or rotateCount == 2:
		tileLimitToUse = tileLimitY
		rotationToUse = 0
	else:
		tileLimitToUse = tileLimitX
		rotationToUse = 1
	
	#direction true means positive direction
	var direction = true if rotateCount == 2 or rotateCount == 3 else false
	
	#places laser pointer
	set_cell(4,pos,4,Vector2i(0,0),rotateCount)
		
	#spawn laser tiles in direction

	
	var i = pos
	var iPrev = pos
	var laserInteractibleID: int =-1
	var laserInteractibleAlt: int = -1


	
	while keepGoing:
		
		#move to new position to check for mirriors and place
		if rotationToUse == 0 and direction:
			i.y += 1
		if rotationToUse == 0 and not direction:
			i.y -= 1
		if rotationToUse == 1 and direction:
			i.x += 1
		if rotationToUse == 1 and not direction:
			i.x -= 1
		
		if i.x < 0 or i.x > tileLimitX or i.y < 0 or i.y > tileLimitY:
			keepGoing = false
			
		laserInteractibleID = get_cell_source_id(4,i)
		laserInteractibleAlt = get_cell_alternative_tile(4, i)
		
		if get_cell_source_id(2,i) != -1:
			keepGoing = false
		
		if laserInteractibleID in mirrorIDs:
			var laserDir = iPrev - i
			if laserInteractibleID == 6:
				if laserInteractibleAlt == 0:
					if laserDir.y == -1:
						direction = true
						rotationToUse = 1
						i = Vector2(i.x+1, i.y)
					elif laserDir.x == 1:
						direction = false
						rotationToUse = 0
						i = Vector2(i.x, i.y-1)
					else: keepGoing = false
				if laserInteractibleAlt == 1:
					if laserDir.y == -1:
						direction = false
						rotationToUse = 1
						i = Vector2(i.x-1, i.y)
					elif laserDir.x == -1:
						direction = false
						rotationToUse = 0
						i = Vector2(i.x, i.y-1)
					else: keepGoing = false
			elif laserInteractibleID == 7:
				if laserInteractibleAlt == 0:
					if laserDir.y == 1:
						direction = false
						rotationToUse = 1
						i = Vector2(i.x-1, i.y)
					elif laserDir.x == -1:
						direction = true
						rotationToUse = 0
						i = Vector2(i.x, i.y+1)
					else: keepGoing = false
				if laserInteractibleAlt == 1:
					if laserDir.y == 1:
						direction = true
						rotationToUse = 1
						i = Vector2(i.x+1, i.y)
					elif laserDir.x == 1:
						direction = true
						rotationToUse = 0
						i = Vector2(i.x, i.y+1)
					else: keepGoing = false
		elif laserInteractibleID in solidIDs:
			keepGoing = false
		if keepGoing:

			lasersInDrawOrder.append(i)
			set_cell(4,i,3,Vector2i(0,0),rotationToUse)
		iPrev = i
	tellDogsWhereToGo()


#places the mirrors and checks if in contact with laser and recomptues lasers
func mirror(pos):
	if rotateCount <=1:
		set_cell(4,pos,7,Vector2i(0,0),rotateCount)
	else:
		set_cell(4,pos,6,Vector2i(0,0),rotateCount-2)
	recomputeLasers()
	
	

#places mirrorBlocker and checks if it is in contact with a laser. If so it recomputes that laser
#because im lasy i will recompute all laser pointers in the scene instead

func mirrorBlocker(pos):
	set_cell(4,pos, 5, Vector2i(0,0), 0)
	recomputeLasers()

func Delete(pos):
	set_cell(4,pos,-1,Vector2(0,0),0)
	recomputeLasers()
