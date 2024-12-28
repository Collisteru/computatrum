extends CharacterBody2D

class_name EnemyBase

@export var myColor : LensColor.LENS_COLOR

@onready var targetNode = $'../Player'
@onready var sprite = $"Sprite"
@onready var hitbox = $"Hitbox"
@onready var timer = $"Timer"

# to be used for turning an enemy on/off
var mode = true
var sprites = {}
# enemies may care about the current lens
var lens = LensColor.LENS_COLOR.RED

var health = 1
var SPEED = 100.0
var ACCELERATION = 10.0
var ENGAGE_DIST = 180.0
var AGRO_RANGE = 300.0

# okay so big thing here: this is overriden by the declaration of _ready() in a 
# child class so if you need the stuff in this function to happen in a child class you need to call 
# the 'super()' function when you want this code to run
func _ready() -> void:
	LensColor.connect("lens_changed", _phase_out)
	var targetColor = LensColor.translate_color(myColor)
	applyColor(targetColor)
	health = 1
	SPEED = 100.0
	ACCELERATION = 10.0
	ENGAGE_DIST = 180.0
	AGRO_RANGE = 300.0
	
func applyColor(color: Color) -> void:
	#print("I, ", self, " am applying shaders to the following with my target of ", color)
	for sprite in sprites:		
		var newMaterial = sprites[sprite].get_material().duplicate()
		newMaterial.set_shader_parameter("TargetColor", Vector4(color.r, color.g, color.b, 1.0))
		sprites[sprite].set_material(newMaterial)
		
		#sprites[sprite].get_material().set_shader_parameter("TargetColor", Vector4(color.r, color.g, color.b, 1.0))

func death() -> void:
	#TODO animation
	# Instance the particle scene
	var particle_scene = preload("res://entities/particles/enemy_explosion.tscn").instantiate()
	
	# Assign position of the particles to be the same as the enemy
	particle_scene.position = self.position
	
	# Add the particle scene to the parent
	get_parent().add_child(particle_scene)
	
	queue_free()

func _physics_process(_delta: float) -> void:	
	if health == 0:
		death()

	if targetNode:
		if can_see(targetNode):
			custom_move(targetNode)
		else:
			velocity.x = move_toward(velocity.x, 0, ACCELERATION)
			velocity.y = move_toward(velocity.y, 0, ACCELERATION)
	else:
		print("AHHHHH, I DON'T KNOW WHAT I'M FOLLOWING")
		# Should only happen if you don't give this node a target node
	
	move_and_slide()


func change_activeness():
	mode = not mode
	if mode:
		set_on()
	else:
		set_off()
	
#TODO make sprite/functionality change here!
func set_off():
	var target = LensColor.translate_color(myColor)
	target = target.darkened(.2)
	applyColor(target)
	
func set_on():
	var target = LensColor.translate_color(myColor)
	applyColor(target)
	
func can_see(target):
	return (self.position - targetNode.position).length() < AGRO_RANGE
	
# note: this is called and a final move_and_slide() is called after
#       So this should just set velocity
# Default was ripped from guard enemy
func custom_move(target):
	look_at(targetNode.position)
	var dist = (self.position - targetNode.position).length()
	
	#-1 to retreat and 1 to approach. Used in figuring out which direction to go
	var approach = 2*int(dist > ENGAGE_DIST) - 1
	
	var direction_x = approach * sign(targetNode.position.x - self.position.x)
	var direction_y = approach * sign(targetNode.position.y - self.position.y)

	#Handle diagonal (xy) movement
	if direction_x != 0 and direction_y != 0:
		velocity.x = move_toward(velocity.x,direction_x * SPEED/sqrt(2),ACCELERATION/sqrt(2))
		velocity.y = move_toward(velocity.y,direction_y * SPEED/sqrt(2),ACCELERATION/sqrt(2))
	# Handles single direction (x or y) movement
	else:	
		# Handle horizontal (x) movement
		if direction_x != 0:
			#velocity.x = direction_x * SPEED
			velocity.x = move_toward(velocity.x,direction_x * SPEED,ACCELERATION)
		else:
			velocity.x = move_toward(velocity.x, 0, ACCELERATION)
		
		# Handle vertical (y) movement
		if direction_y != 0:
			#velocity.y = direction_y * SPEED
			velocity.y = move_toward(velocity.y,direction_y * SPEED,ACCELERATION)
		else:
			velocity.y = move_toward(velocity.y, 0, ACCELERATION)
	
func _on_hitbox_area_entered(_area: Area2D) -> void:
	health -= 1

func _on_timer_timeout() -> void:
	pass

func try_stop() -> void:
	pass

func _phase_out(lens: LensColor.LENS_COLOR):
	if self.myColor != lens:
		#print("Phasing Out")
		self.set_collision_layer_value(3,false)
		hitbox.set_collision_layer_value(3,false)
		hitbox.set_collision_mask_value(4,false)
	else:
		#print("Phasing In")
		self.set_collision_layer_value(3,true)
		hitbox.set_collision_layer_value(3,true)
		hitbox.set_collision_mask_value(4,true)
	pass
