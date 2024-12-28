extends CharacterBody2D

#signal lens_changed(c: LensColor.LENS_COLOR)

const SPEED = 300.0
const ACCELERATION = 30.0
var player_is_alive

# Import child nodes
#@onready var sprite = $PlayerSprite # TODO: remove when done debugging
#@onready var pointer = $Pointer # TODO: remove when done debugging
@onready var body = $BodySprite
@onready var player_camera = $Camera2D
@onready var color_hud = $CanvasLayer/HUD/HBoxContainer/HudSprite
@onready var eyes = [] # eyes right to left
@onready var eye_trail_scene = load("res://entities/player/eye_trail.tscn")
@onready var eye_trails = [] # eyes right to left
@onready var laser_scene = load("res://entities/player_laser/playerLaser.tscn")

# Preload HUD textures
@onready var hud_red = preload('res://assets/hud_color_r.png')
@onready var hud_blue = preload('res://assets/hud_color_b.png')
@onready var hud_green = preload('res://assets/hud_color_g.png')

# Preload HUD inverse textures
@onready var hud_iblue = preload('res://assets/hud_inverse_b.png')
@onready var hud_ired = preload('res://assets/hud_inverse_r.png')
@onready var hud_igreen = preload('res://assets/hud_inverse_g.png')

# Preload HUD tilted textures
@onready var hud_ltilt_r = preload('res://assets/hud_ltilrt_r.png')
@onready var hud_rtilt_r = preload('res://assets/hud_rtilt_r.png')
@onready var hud_ltilt_g = preload('res://assets/hud_ltilt_g.png')
@onready var hud_rtilt_g = preload('res://assets/hud_rtilt_g.png')
@onready var hud_ltilt_b = preload('res://assets/hud_ltilt_b.png')
@onready var hud_rtilt_b = preload('res://assets/hud_rtilt_b.png')


func _ready():
	# Set player living/death flag
	player_is_alive = true
	LensColor.connect("lens_changed", _on_lens_changed)
	eyes.append($HeadSprite/Eyes/EyeGlowAmbient_R)
	eyes.append($HeadSprite/Eyes/EyeGlowAmbient_L)
	
	for n in eyes.size():
		var trail = eye_trail_scene.instantiate()
		eye_trails.append(trail)
		add_child(trail)
		
# TODO: remove if not being used
#func translate_to_center(position: Vector2) -> Vector2:
		## Get the size of the viewport
		#var screen_size = get_viewport().get_visible_rect().size
		## Calculate the center of the screen
		#var screen_center = screen_size / 2
		## Translate the position to be relative to the center
		#return position - screen_center

#func fire():
	#var projectile = projectile_scene.instantiate()
	#
	#projectile.global_position = global_position
	#projectile.direction = Vector2.RIGHT.rotated(global_rotation)
	#get_parent().add_child(projectile)

func create_laser():
	var newLaser = laser_scene.instantiate()
	var laser_length = 1000
	
	newLaser.name = str(2)
	newLaser.position = self.position
	newLaser.target_position = laser_length * (get_parent().get_local_mouse_position() - self.position).normalized()
	newLaser.bounces = 2
	get_parent().add_child(newLaser)

func is_default_color_locked() -> bool:
	if LensColor.lens == LensColor.LENS_COLOR.WHITE:
		return true
	else:
		return false

func _input(event: InputEvent) -> void:
	if player_is_alive:
		# Get player's response to mouse events
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			# By default, the click position is done with reference to the screen. We want it to be done with reference to the player position
			
			# Get positions
			# Get the player's global position
			#var global_position = self.to_global(Vector2.ZERO)

			# Convert the global position to screen space to get player position with reference to camera
			#var global_player_position = self.position
			
			# Get player position with ref to scene
			#var camera_player_position = self.get_global_transform_with_canvas().get_origin()
			
			#var click_position: Vector2 = get_local_mouse_position();
			
			#var screensize = get_viewport().size 
			
			# Get position w/ ref to player
			#click_position.x = (event.position.x - camera_player_position.x)#/screensize.x
			#click_position.y = (event.position.y - camera_player_position.y)#/screensize.y
			create_laser()
			#laser.fire_laser(self)


			#pointer.move(click_position, global_position)
			
			#print("\n position: ", self.position)
			#print("\n calc'd click: ", click_position)
			#print("\n camera_player_position: ", camera_player_position)
			#print("\n click: ", get_viewport().get_mouse_position())
			
		# Get player's response to key events
		if event is InputEventKey and event.pressed:
			# Handle changing lens colors
			match event.keycode:
				KEY_Q: # (blue to green, green to red, red to blue
					# Rotates lens triangle counterclockwise
					if not is_default_color_locked():
						if (LensColor.lens == LensColor.LENS_COLOR.BLUE):
							LensColor.change_lens(LensColor.LENS_COLOR.GREEN)
							change_hud('B', 'G')
						elif (LensColor.lens == LensColor.LENS_COLOR.GREEN):
							LensColor.change_lens(LensColor.LENS_COLOR.RED)
							change_hud('G', 'R')
						elif (LensColor.lens == LensColor.LENS_COLOR.RED):
							LensColor.change_lens(LensColor.LENS_COLOR.BLUE)
							change_hud('R', 'B')
				KEY_E: # (blue to red, red to green, green to blue
					# Rotates lens triangle clockwise
					if not is_default_color_locked():
						if (LensColor.lens == LensColor.LENS_COLOR.BLUE):
							LensColor.change_lens(LensColor.LENS_COLOR.RED)
							change_hud('B', 'R')
						elif (LensColor.lens == LensColor.LENS_COLOR.RED):
							LensColor.change_lens(LensColor.LENS_COLOR.GREEN)
							change_hud('R', 'G')
						elif (LensColor.lens == LensColor.LENS_COLOR.GREEN):
							LensColor.change_lens(LensColor.LENS_COLOR.BLUE)
							change_hud('G', 'B')
				# This is for zooming
				KEY_BRACKETRIGHT:
					if player_camera.zoom.x < 10:
						player_camera.zoom.x += 1
						player_camera.zoom.y += 1
				KEY_BRACKETLEFT:
					if player_camera.zoom.x > 2:
						player_camera.zoom.x -= 1
						player_camera.zoom.y -= 1

				# TODO: Remove this before shipping (but leave until the end so we can test)
				KEY_K:
					# Kill self (debugging purposes)
					# TODO: Remove
					self.die()

func change_hud(old_color, new_color):
	var tick = 0.07
	if old_color == 'R':
		if new_color == 'G':
			color_hud.set_texture(hud_rtilt_r)
			await get_tree().create_timer(tick).timeout
			color_hud.set_texture(hud_iblue)
			await get_tree().create_timer(tick).timeout
			color_hud.set_texture(hud_ltilt_g)
			await get_tree().create_timer(tick).timeout
			color_hud.set_texture(hud_green)
		elif new_color == 'B':
			color_hud.set_texture(hud_ltilt_r)
			await get_tree().create_timer(tick).timeout
			color_hud.set_texture(hud_igreen)
			await get_tree().create_timer(tick).timeout
			color_hud.set_texture(hud_rtilt_b)
			await get_tree().create_timer(tick).timeout
			color_hud.set_texture(hud_blue)
	if old_color == 'G':
		if new_color == 'R':
			color_hud.set_texture(hud_ltilt_g)
			await get_tree().create_timer(tick).timeout
			color_hud.set_texture(hud_iblue)
			await get_tree().create_timer(tick).timeout
			color_hud.set_texture(hud_rtilt_r)
			await get_tree().create_timer(tick).timeout
			color_hud.set_texture(hud_red)
		elif new_color == 'B':
			color_hud.set_texture(hud_rtilt_g)
			await get_tree().create_timer(tick).timeout
			color_hud.set_texture(hud_ired)
			await get_tree().create_timer(tick).timeout
			color_hud.set_texture(hud_ltilt_b)
			await get_tree().create_timer(tick).timeout
			color_hud.set_texture(hud_blue)
	if old_color == 'B':
		if new_color == 'G':
			color_hud.set_texture(hud_ltilt_b)
			await get_tree().create_timer(tick).timeout
			color_hud.set_texture(hud_ired)
			await get_tree().create_timer(tick).timeout
			color_hud.set_texture(hud_rtilt_g)
			await get_tree().create_timer(tick).timeout
			color_hud.set_texture(hud_green)
		elif new_color == 'R':
			color_hud.set_texture(hud_rtilt_b)
			await get_tree().create_timer(tick).timeout
			color_hud.set_texture(hud_igreen)
			await get_tree().create_timer(tick).timeout
			color_hud.set_texture(hud_ltilt_r)
			await get_tree().create_timer(tick).timeout
			color_hud.set_texture(hud_red)


func die(_camera = player_camera) -> void:
	
	# Set player_is_alive flag to false, making it impossible to perform player actions
	player_is_alive = false
	
	# TODO: remove this if player isn't queue freed for death
	## Duplicate camera
	## (the player camera is a child of the original class, so we need to create a new one with the same properites to 
	## properly play the death animation)
	#var new_camera = camera.duplicate() as Camera2D
#
	## Set the new camera's position and properties to match the original
	#new_camera.global_position = camera.global_position
	#new_camera.zoom = camera.zoom
	#new_camera.offset = camera.offset
	#get_parent().add_child(new_camera)
	#
	## Switch to this camera
	#new_camera.make_current()
	

	# Spawn playerdeathparticles
	
	# Instance the particle scene
	var particle_scene = preload("res://entities/particles/player_explosion_node.tscn").instantiate()
	
	# Make player invisible.
	self.visible = false
	
	# Assign position of the particles to be the same as the player
	particle_scene.position = self.position
	
	# Add the particle scene to the parent
	get_parent().add_child(particle_scene)
	
	# Clear player from scene
	# Wait for a time equal to the duration of the particle effect then 
	
	var tree = get_tree()
	
	await tree.create_timer(3.0).timeout

	tree.change_scene_to_file("res://screens/lose/lose.tscn")
	#tree.change_scene_to_file("res://levels/Shield Intro Vic/Shielder Intro.tscn")

func _physics_process(_delta: float) -> void:
	##get the viewport size and divide by 2 since this is where the camera is positioned
	#var view = get_viewport_rect().size / 2
	#var view_pos = get_viewport_transform()
	##print("VIew pos x: ", view_pos.x)
	##print("View pos y:", view_pos.y)
#
	##get the camera position
	#var camera_pos = player_camera.global_position
	#
#
	## TODO: Figure out cause of incorrent left bound bug
	#var bounds_left = camera_pos.x - view.x #the camera bounds at the left
	#
	#var bounds_right = camera_pos.x + view.x #the camera bounds at the right
	#var bounds_top = camera_pos.y + view.y #the camera bounds at the top
	#var bounds_bottom = camera_pos.y - view.y #the camera bounds at the top
#
	##after the character is moved clamp its position to the end of the camera bounds
	#self.global_position.x = clamp(self.global_position.x, bounds_left, bounds_right)
	#self.global_position.y = clamp(self.global_position.y, bounds_bottom, bounds_top)
	
	
	# Get the input direction
	if player_is_alive:
		var direction_x := Input.get_axis("ui_left", "ui_right")
		var direction_y := Input.get_axis("ui_up", "ui_down")

		# Handle diagonal (xy) movement
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
		
		var is_moving = false
		if(velocity.length() != 0):
			is_moving = true
			body.pointForwards(velocity.angle())
			body.play("walk")
		else:
			body.tryStop()

		move_and_slide()
		
		for n in eye_trails.size():
			eye_trails[n].tick(eyes[n].global_position, is_moving)

func change_eye_color(lens):
	var cPrime
	match lens:
		LensColor.LENS_COLOR.RED:
			cPrime = Color(255, 0, 0)
		LensColor.LENS_COLOR.GREEN:
			cPrime = Color(0, 255, 0)
		LensColor.LENS_COLOR.BLUE:
			cPrime = Color(0, 0, 255)
		LensColor.LENS_COLOR.WHITE:
			cPrime = Color(255, 255, 255)
	
	for n in eyes.size():
		eyes[n].self_modulate = cPrime
		eye_trails[n].default_color = cPrime

# Handle bullet death
# TODO: rename function?
func _on_area_2d_area_entered(_area: Area2D) -> void:
	self.die()

func _on_area_2d_body_entered(_body: Node2D) -> void:
	self.die()


func _on_lens_changed(lens: LensColor.LENS_COLOR) -> void:
	#print("Signal received")
	change_eye_color(lens)
	match lens:
		LensColor.LENS_COLOR.RED:
			color_hud.set_texture(hud_red)
		LensColor.LENS_COLOR.GREEN:
			color_hud.set_texture(hud_green)
		LensColor.LENS_COLOR.BLUE:
			color_hud.set_texture(hud_blue)
	pass # Replace with function body.
