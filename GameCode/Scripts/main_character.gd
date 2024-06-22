extends CharacterBody2D

# Define constants for movement properties
const ACCELERATION = 800  # How quickly the character accelerates
const FRICTION = 500       # Amount of friction applied to slow down
const MAX_SPEED = 120       # Maximum speed the character can reach

# Define an enumeration for character states
enum { IDLE, MOVE }
var state = IDLE  # Current state of the character

# References to animation tree and state machine
@onready var animationTree = $AnimationTree
@onready var state_machine = animationTree["parameters/playback"]

# Variable to store the previous position for smooth animation blending
var blend_position : Vector2 = Vector2.ZERO  

# Array to store blend space parameter paths for position blending
var blend_pos_paths = [
	"parameters/idle/idle_blendspace2d/blend_position",  # Path for idle animation
	"parameters/move/move_blendspace2d/blend_position"   # Path for move animation
]

# Array to store animation tree state names
var animTree_state_keys = [
	"idle",
	"move"
]

# Main physics process function called every frame
func _physics_process(delta):
	move(delta)  # Handle movement logic
	animate()   # Update animation state

# Function to handle character movement
func move(delta):
	# Get movement direction based on input keys
	var input_vector = Input.get_vector("A", "D", "W", "S")

	# If no input is detected, switch to idle state and apply friction
	if input_vector == Vector2.ZERO:
		state = IDLE
		apply_friction(FRICTION * delta)
	# Otherwise, switch to move state, apply acceleration, and store input direction
	else:
		state = MOVE
		apply_movement(input_vector * ACCELERATION * delta)
		blend_position = input_vector

	# Move the character and handle collisions
	move_and_slide()

# Function to apply acceleration to the character
func apply_movement(amount) -> void:
	# Increase velocity based on acceleration
	velocity += amount
	# Limit velocity to the maximum speed
	velocity = velocity.limit_length(MAX_SPEED)

# Function to apply friction to slow down the character
func apply_friction(amount) -> void:
	# If velocity is greater than friction amount, reduce velocity in the opposite direction
	if velocity.length() > amount:
		velocity -= velocity.normalized() * amount
	# Otherwise, set velocity to zero (character stops)
	else:
		velocity = Vector2.ZERO

# Function to update the animation state
func animate() -> void:
	# Set the state machine to the appropriate animation based on current state
	state_machine.travel(animTree_state_keys[state])
	# Set the blend position parameter in the animation tree based on the stored input direction
	animationTree.set(blend_pos_paths[state], blend_position)
