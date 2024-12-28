extends "res://entities/enemy_base/enemy_base.gd"

#@onready var hitbox = $Hitbox
#@onready hitbox.connect
@onready var projectile_scene = load("res://entities/projectile/projectile.tscn")

var direction_x = 0
var direction_y = 0
var direction = Vector2.ZERO

var previousSpeed = Vector2.ZERO

var charging = false
var CHARGING_ACCELERATION = 4*ACCELERATION
const CHARGING_SPEED = 300.0

func _ready() -> void:
	sprites["sprite"] = $"Sprite"
	super()
	SPEED = 0.0
	
func _physics_process(_delta: float) -> void:	
	if health <= 0:
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
	
# TODO: remove after debugging
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_4:
				fire()

func can_see(target):
	return (target.player_is_alive) and (self.position - targetNode.position).length() < AGRO_RANGE

func custom_move(target):
	look_at(target.position)
	if not charging:
		direction = (target.position - self.position).normalized()
		direction_x = sign(direction.x)
		direction_y = sign(direction.y)
	#print("direction", direction)

	var accelerationMagnitude = ACCELERATION
	var topSpeed = SPEED
	
	if charging:
		accelerationMagnitude = CHARGING_ACCELERATION
		topSpeed = CHARGING_SPEED
	

	
	var targetSpeed = direction * topSpeed
	
	
	var currentAcceleration = abs(direction) * accelerationMagnitude
	
	#print("accel", currentAcceleration)
	
	previousSpeed = velocity
	
	velocity.x = move_toward(velocity.x,targetSpeed.x,currentAcceleration.x+1)
	velocity.y = move_toward(velocity.y,targetSpeed.y,currentAcceleration.y+1)
	
	#print(velocity.length())

	if velocity.length() >= topSpeed or velocity.length() == 0 or previousSpeed.x == velocity.x or previousSpeed.y == velocity.y:
		charging = false
	
	
	
func fire():
	var projectile = projectile_scene.instantiate()
	
	projectile.global_position = global_position
	projectile.direction = Vector2.RIGHT.rotated(global_rotation)
	get_parent().add_child(projectile)
	
func _on_hitbox_area_entered(_area: Area2D) -> void:
	super._on_hitbox_area_entered(_area)

func _on_timer_timeout() -> void:
	charging = true
	sprite.play()
	pass
	#fire()
