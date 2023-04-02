extends CharacterBody2D

@export var player_id = 1


const NORMAL_SPEED : int = 600
const JUMP_HEIGHT : int = -1000
const GRAVITY : int = 3000
#const MAX_HEALTH = 100
const MAX_JUMPS : int= 2

var SPEED = NORMAL_SPEED
const Dash_speed = 1600
const dash_length = 0.1


var health : int = 100
var jumps : int = 0

var knockback : Vector2 = Vector2.ZERO
var knockbackTween
@onready var dash = $Dash
@onready var Hp_Bar = $TextureProgressBar
@onready var anim = $AnimationPlayer
@onready var weapon = $Weapon
@onready var animateted_sprite = $Sprite
#@onready var health_bar_scene = preload("res://UI/HealthBar.tscn")


func _ready():
	print(position)

func _physics_process(delta):
	Hp_Bar.value = health
	
	crouch()

	if Input.is_action_just_pressed("dash_%s" % [player_id]) && dash.can_dash && !dash.is_dashing():
#		anim.play("dash")
#		await get_tree().create_timer(0.1).timeout
#		anim.stop()
		dash.start_dash(dash_length)
		set_collision_mask_value(3, false)
		await get_tree().create_timer(2).timeout
		set_collision_mask_value(3, true)
	var SPEED = Dash_speed if dash.is_dashing() else NORMAL_SPEED 

	
	# Add the gravity.
	if not is_on_floor():
		
		if(velocity.y <= 0):
			animateted_sprite.animation = "jump"
		else:
			animateted_sprite.animation = "fall"
	#else:
		
		#if(velocity.x == 0):
			#animateted_sprite.animation = "idle"
		#elif(velocity.x != 0):
			#animateted_sprite.animation = "run"
		
	# Handle Jump.
	if Input.is_action_just_pressed("jump_%s" % [player_id]) and (is_on_floor() or jumps < MAX_JUMPS):
		velocity.y = JUMP_HEIGHT
		jumps += 1
		set_collision_mask_value(3, false)
		await get_tree().create_timer(0.3).timeout
		set_collision_mask_value(3, true)
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left_%s" % [player_id], "right_%s" % [player_id])
	velocity.x = direction * SPEED + knockback.x
	if direction:
		
		
		if(velocity.x < 0):
			scale.x = scale.y * -1 
		elif(velocity.x > 0):
			scale.x = scale.y * 1
			
	#else:
		

	
	# Apply gravity
	velocity.y += GRAVITY * delta
	
	if velocity.y > GRAVITY * delta * 10:
		velocity.y = GRAVITY * delta * 10
	
	# Move the player based on its current velocity
	move_and_slide()
	
	# Clamp the player's velocity to prevent excessive movement
	velocity.x = clamp(velocity.x, -SPEED, SPEED)
	velocity.y = clamp(velocity.y, JUMP_HEIGHT, GRAVITY)
	
	# Reset jumps when landing on the ground
	if is_on_floor():
		jumps = 0
		velocity.y = 0


func crouch():
	if Input.get_action_strength("crouch_%s" % [player_id]):
		set_collision_mask_value(3, false)
		await get_tree().create_timer(0.2).timeout
		set_collision_mask_value(3, true)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("JAB!_%s" % [player_id]):
		weapon.attack()
		await get_tree().create_timer(0.20).timeout
#func _on_Area2D_body_entered(body):
	# Handle collisions with other objects
#	if body.is_in_group("enemy"):
#		take_damage(damage)
#	elif body.is_in_group("powerup"):
#		collect_powerup()


func take_damage(damage : int, knockback_strength : Vector2 = Vector2(0,0), stop_time : float = 0.25):
	health -= damage
	if health <= 0:
		Hp_Bar.value = 0
		health = 0
		animateted_sprite.animation = "dead"
		die()

	elif (knockback_strength != Vector2(0,0)):
		knockback = knockback_strength
		
		knockbackTween = get_tree().create_tween()
		knockbackTween.tween_property(self, "knockback", Vector2(0,0), stop_time)
		
		animateted_sprite.modulate = Color(1,0,0,1)
		knockbackTween.tween_property(animateted_sprite, "modulate", Color(1,1,1,1), stop_time)
	print("Player_%s" % [player_id] + "'s health is: " + str(health))
		
		
	
		
func collect_powerup():
	# Handle player collecting a powerup
	#health = min(MAX_HEALTH, health + 25)
	pass
	
func die():
	# Handle player death
	
	set_physics_process(false)
	set_process_unhandled_input(false)
	$CollisionShape2D.set_deferred("disabled", true)
	$CollisionShape2D2.set_deferred("disabled", false)
	await get_tree().create_timer(2).timeout
	queue_free()
	#get_tree().change_scene_to_file("res://UI/GameOver.tscn")
