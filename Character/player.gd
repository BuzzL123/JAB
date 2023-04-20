#This script extends a CharacterBody2D, which is a type of node used for 2D platformer character movement.
extends CharacterBody2D

#This variable sets the player's ID to 1 for multiplayer purposes.
@export var player_id = 1

#These constants define various physics parameters for the character.
const NORMAL_SPEED : int = 600
const NORMAL_JUMP_HEIGHT : int = -1000
const GRAVITY : int = 4000
#const MAX_HEALTH = 100
const MAX_JUMPS : int= 2

const Dash_speed = 1600
const dash_length = 0.1
#These variables define values that can be modified during gameplay.
var SPEED = NORMAL_SPEED
var JUMP_HEIGHT = NORMAL_JUMP_HEIGHT
var health : int = 100
var jumps : int = 0

#These variables are used for knockback effects on the character.
var knockback : Vector2 = Vector2.ZERO
var knockbackTween

#These variables are used to reference child nodes of the character node.
@onready var states = $State
@onready var GroundL = get_node("RayCasts/GroundL")
@onready var GroundR = get_node("RayCasts/GroundR")

@onready var dash = $Dash
@onready var Hp_Bar = $TextureProgressBar
@onready var anim = $AnimationPlayer
@onready var anim_tree = $AnimationTree
@onready var weapon = $Weapon
@onready var sprite = $Sprite
@onready var RayCasts = $RayCasts
#@onready var health_bar_scene = preload("res://UI/HealthBar.tscn")

#The following code contains functions that are not commented. Adding comments to them would make their purpose clear to anyone reading the code.

#func _ready():
#	$AnimationTree.active = true

#This function is called every frame and updates the player's health.
func _process(delta):
	hp()

#This function is called every physics frame and handles the player's movement and gravity.
func _physics_process(delta):
	_apply_gravity(delta)
	_apply_movement()

#This function applies gravity to the player's velocity.
func _apply_gravity(delta):
	# Apply gravity
	velocity.y += GRAVITY * delta
	
#	 The following commented code was likely used to limit the maximum fall speed.
#	if velocity.y > GRAVITY * delta * 10:
#		velocity.y = GRAVITY * delta * 10


#This function handles the player's movement.
func _apply_movement():
	
	# If the player presses the dash button and meets certain 
	if Input.is_action_just_pressed("dash_%s" % [player_id]) && dash.can_dash && !dash.is_dashing():
		dash.start_dash(dash_length)
		
		# The following commented code was likely used to disable collisions during a dash.
		
#		set_collision_mask_value(3, false)
#		await get_tree().create_timer(2).timeout
#		set_collision_mask_value(3, true)

	# Set the player's speed and jump height based on whether they are dashing or not.
	var SPEED = Dash_speed if dash.is_dashing() else NORMAL_SPEED
	var JUMP_HEIGHT = -Dash_speed if dash.is_dashing() else NORMAL_JUMP_HEIGHT
	
	
	
	
	# Add the gravity.
	# Handle Jump.
	# Handle jump and crouch inputs.
	if Input.is_action_just_pressed("jump_%s" % [player_id]) and (is_on_floor() or jumps < MAX_JUMPS):
		
		velocity.y = JUMP_HEIGHT
		jumps += 1
	# Handle crouch
	if Input.is_action_just_pressed("crouch_%s" % [player_id]):
		set_collision_mask_value(3, false)
		$CollisionBox.set_deferred("disabled", true)
		$CollisionBox2.set_deferred("disabled", false)
		
	if Input.is_action_just_released("crouch_%s" % [player_id]):
		set_collision_mask_value(3, true)
		$CollisionBox.set_deferred("disabled", false)
		$CollisionBox2.set_deferred("disabled", true)
	# Move the player and clamp their velocity to prevent excessive movement.
	# Move the player based on its current velocity
	move_and_slide()
	
	# Clamp the player's velocity to prevent excessive movement
	velocity.x = clamp(velocity.x, -SPEED, SPEED)
	velocity.y = clamp(velocity.y, JUMP_HEIGHT, GRAVITY)
	
	# Reset jumps when landing on the ground
	if is_on_floor():
		jumps = 0
		velocity.y = 0



# Get the input direction and handle the movement/deceleration.
# Get the input direction and handle movement and sprite flipping.
	var direction = Input.get_axis("left_%s" % [player_id], "right_%s" % [player_id])
	velocity.x = direction * SPEED + knockback.x
	
	if direction:


		if(velocity.x < 0):
			scale.x = scale.y * -1 
		elif(velocity.x > 0):
			scale.x = scale.y * 1 


func _unhandled_input(event: InputEvent) -> void:
	# Handle unhandled input events
	if event.is_action_pressed("JAB!_%s" % [player_id]):
		weapon.attack()
		# Create a timer to delay the next attack
		await get_tree().create_timer(0.20).timeout
		
		
#func _on_Area2D_body_entered(body):
	# Handle collisions with other objects
#	if body.is_in_group("enemy"):
#		take_damage(damage)
#	elif body.is_in_group("powerup"):
#		collect_powerup()


func hp():
	# Update the health bar
	Hp_Bar.value = health

func take_damage(damage : int, knockback_strength : Vector2 = Vector2(0,0), stop_time : float = 0.25):
	# Reduce the player's health by the damage amount
	health -= damage

	if health <= 0:
		# Player is dead
		Hp_Bar.value = 0
		health = 0
		die()

	elif (knockback_strength != Vector2(0,0)):
		# Apply knockback effect and make the player invulnerable for a short time
		knockback = knockback_strength
		
		knockbackTween = get_tree().create_tween()
		knockbackTween.tween_property(self, "knockback", Vector2(0,0), stop_time)
		
		sprite.modulate = Color(1,0,0,1)
		knockbackTween.tween_property(sprite, "modulate", Color(1,1,1,1), stop_time)
		await get_tree().create_timer(0.21).timeout
		set_physics_process(false)
		set_process_unhandled_input(false)
		await get_tree().create_timer(0.21).timeout
		set_physics_process(true)
		set_process_unhandled_input(true)
		
	print("Player_%s" % [player_id] + "'s health is: " + str(health))

		
	
		
func collect_powerup():
	# Handle player collecting a powerup
	# (not implemented)
	#health = min(MAX_HEALTH, health + 25)
	pass
	
func die():
	# Handle player death
#	velocity.x = 0
#	velocity.y = 0
	Hp_Bar.hide()
	anim.play("Dead")
	set_physics_process(false)
	set_process_unhandled_input(false)
	$CollisionBox.set_deferred("disabled", true)
	$CollisionBox2.set_deferred("disabled", true)
	await get_tree().create_timer(5).timeout
	queue_free()

	#get_tree().change_scene_to_file("res://UI/GameOver.tscn")



