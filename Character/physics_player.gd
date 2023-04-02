extends RigidBody2D

@export var player_id = 1


const NORMAL_SPEED : int = 250
const JUMP_HEIGHT : int = -500
const GRAVITY : int = 1500
#const MAX_HEALTH = 100
const MAX_JUMPS : int= 2

const Dash_speed = 800
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



func _process(delta):
	Hp_Bar.value = health
	
func _physics_process(delta): 
	move()

func move():
	



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
		health = 0
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
	$CollisionShape2D.set_deferred("disabled", true)
	animateted_sprite.animation = "dead"
	await get_tree().create_timer(1).timeout
	queue_free()
	#get_tree().change_scene_to_file("res://UI/GameOver.tscn")
