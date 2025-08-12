extends Node3D

@onready var player = $Player
@onready var camera = $Player/Camera3D
@onready var score_label = $UI/ScoreLabel

var player_speed = 5.0
var jump_force = 10.0
var mouse_sensitivity = 0.002
var camera_rotation = 0.0
var score = 0
var last_position = Vector3.ZERO

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	last_position = player.global_position
	update_score_display()
	
	# Konfigurišemo CharacterBody3D za bolje skakanje
	player.floor_max_angle = 0.785398  # 45 stepeni
	player.floor_snap_length = 0.3
	player.floor_block_on_wall = true

func _input(event):
	if event is InputEventMouseMotion:
		# Rotacija kamere levo-desno
		player.rotate_y(-event.relative.x * mouse_sensitivity)
		
		# Rotacija kamere gore-dole
		camera_rotation -= event.relative.y * mouse_sensitivity
		camera_rotation = clamp(camera_rotation, -PI/2, PI/2)
		camera.rotation.x = camera_rotation
	
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	var input_dir = Vector3.ZERO
	
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("move_right"):
		input_dir.x += 1
	if Input.is_action_pressed("ui_up") or Input.is_action_pressed("move_forward"):
		input_dir.z -= 1
	if Input.is_action_pressed("ui_down") or Input.is_action_pressed("move_backward"):
		input_dir.z += 1
	
	# Normalizujemo input vektor
	if input_dir.length() > 0:
		input_dir = input_dir.normalized()
	
	# Rotiramo input u odnosu na rotaciju igrača
	var rotated_input = player.transform.basis * input_dir
	
	# Postavljamo brzinu igrača
	player.velocity.x = rotated_input.x * player_speed
	player.velocity.z = rotated_input.z * player_speed
	
	# Skakanje
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("jump") or Input.is_key_pressed(KEY_SPACE):
		if player.is_on_floor():
			player.velocity.y = jump_force
	
	# Primena gravitacije
	if not player.is_on_floor():
		player.velocity.y -= 20.0 * delta
	
	player.move_and_slide()
	
	# Dodajemo poene za kretanje
	var distance_moved = player.global_position.distance_to(last_position)
	if distance_moved > 0.1:
		score += int(distance_moved * 10)
		update_score_display()
	last_position = player.global_position
	
	# Proveravamo da li je igrač pao sa platforme
	if player.global_position.y < -10:
		reset_player_position()

func update_score_display():
	score_label.text = "Poeni: " + str(score)

func reset_player_position():
	player.global_position = Vector3(0, 2, 0)
	player.velocity = Vector3.ZERO
	score = max(0, score - 100)  # Gubimo 100 poena za pad
	update_score_display()
