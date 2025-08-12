extends Node3D

@onready var player = $Player
@onready var camera = $Player/Camera3D
@onready var score_label = $UI/ScoreLabel
@onready var pole = $Player/Pole

var player_speed = 5.0
var jump_force = 10.0
var mouse_sensitivity = 0.002
var camera_rotation = 0.0
var score = 0
var last_position = Vector3.ZERO

# Pole vaulting variables
var pole_vault_speed = 15.0
var pole_vault_height = 8.0
var is_pole_vaulting = false
var pole_vault_start_pos = Vector3.ZERO
var pole_vault_target = Vector3.ZERO
var pole_vault_progress = 0.0
var running_speed = 0.0
var is_running = false

# Pole animation variables
var pole_plant_progress = 0.0
var is_pole_planting = false
var pole_plant_start_pos = Vector3.ZERO
var pole_plant_target_pos = Vector3.ZERO
var pole_bend_amount = 0.0
var pole_original_length = 4.0

# Pole flexibility variables
var pole_flexibility = 0.8  # Koeficijent savitljivosti (0-1)
var pole_compression = 0.0  # Stepen kompresije motke
var pole_elastic_force = 0.0  # Elastična sila motke
var pole_ground_contact = false  # Da li motka dodiruje zemlju

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	last_position = player.global_position
	update_score_display()
	
	# Konfigurišemo CharacterBody3D za bolje skakanje
	player.floor_max_angle = 0.785398  # 45 stepeni
	player.floor_snap_length = 0.3
	player.floor_block_on_wall = true
	
	# Osiguravamo da je motka u pravilnoj poziciji
	pole.position = Vector3(0, 1, -2)
	pole.rotation = Vector3.ZERO
	pole.scale = Vector3(1, 1, 1)
	
	# Resetujemo varijable za savitljivost
	pole_compression = 0.0
	pole_elastic_force = 0.0
	pole_ground_contact = false

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
	if is_pole_planting:
		handle_pole_plant(delta)
		return
	elif is_pole_vaulting:
		handle_pole_vault(delta)
		return
	
	var input_dir = Vector3.ZERO
	
	# Trčanje - desni klik miša
	is_running = Input.is_action_pressed("run")
	var current_speed = player_speed * (2.0 if is_running else 1.0)
	
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
		running_speed = input_dir.length() * current_speed
	else:
		running_speed = 0.0
	
	# Rotiramo input u odnosu na rotaciju igrača
	var rotated_input = player.transform.basis * input_dir
	
	# Postavljamo brzinu igrača
	player.velocity.x = rotated_input.x * current_speed
	player.velocity.z = rotated_input.z * current_speed
	
	# Skakanje - SPACE za običan skok, levi klik miša za skakanje s motkom
	var normal_jump = Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("jump") or Input.is_key_pressed(KEY_SPACE)
	var pole_vault_jump = Input.is_action_just_pressed("jump_mouse")
	
	if normal_jump and player.is_on_floor():
		# Običan skok
		player.velocity.y = jump_force
	elif pole_vault_jump and player.is_on_floor() and running_speed > 3.0:
		# Skakanje s motkom
		start_pole_vault()
	elif pole_vault_jump and player.is_on_floor():
		# Pokušaj skakanja s motkom bez dovoljne brzine
		player.velocity.y = jump_force * 0.5  # Manji skok
	
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
	
	# Proveravamo da li je igrač pao sa platforme (veća platforma)
	if player.global_position.y < -10:
		reset_player_position()

func update_score_display():
	score_label.text = "Poeni: " + str(score)

func reset_player_position():
	player.global_position = Vector3(0, 2, 0)
	player.velocity = Vector3.ZERO
	
	# Resetujemo motku ako je u animaciji
	if is_pole_planting or is_pole_vaulting:
		is_pole_planting = false
		is_pole_vaulting = false
		pole.rotation.x = 0.0
		pole.rotation.z = 0.0
		pole.rotation.y = 0.0
		pole.position = Vector3(0, 1, -2)
		pole.scale = Vector3(1, 1, 1)
		pole_bend_amount = 0.0
		pole_compression = 0.0
		pole_elastic_force = 0.0
		pole_ground_contact = false
	
	score = max(0, score - 100)  # Gubimo 100 poena za pad
	update_score_display()

func start_pole_vault():
	# Započinjemo sa zabijanjem motke
	is_pole_planting = true
	pole_plant_progress = 0.0
	pole_plant_start_pos = pole.position
	pole_plant_target_pos = pole.position + Vector3(0, -2, 0)  # Zabijamo u zemlju
	
	# Rotiramo motku za zabijanje
	pole.rotation.x = -PI/3  # 60 stepeni napred

func handle_pole_plant(delta):
	pole_plant_progress += delta * 3.0  # Brzina zabijanja
	
	# Proveravamo da li motka dodiruje zemlju
	var pole_tip_y = pole.global_position.y - 2.0  # Pozicija vrha motke
	pole_ground_contact = pole_tip_y <= 0.5  # Dodiruje zemlju
	
	if pole_ground_contact:
		# Simuliramo kompresiju motke
		pole_compression = min(pole_compression + delta * 2.0, pole_flexibility)
		pole_elastic_force = pole_compression * 5.0  # Elastična sila
	else:
		# Motka se oporavlja
		pole_compression = max(pole_compression - delta * 1.0, 0.0)
		pole_elastic_force = 0.0
	
	if pole_plant_progress >= 1.0:
		# Završavamo zabijanje i počinjemo skakanje
		is_pole_planting = false
		is_pole_vaulting = true
		pole_vault_start_pos = player.global_position
		pole_vault_target = player.global_position + player.transform.basis.z * -pole_vault_speed
		pole_vault_progress = 0.0
		pole_bend_amount = 0.0
		pole_compression = 0.0
		pole_elastic_force = 0.0
		return
	
	# Animacija zabijanja motke
	var t = pole_plant_progress
	var current_pole_pos = pole_plant_start_pos.lerp(pole_plant_target_pos, t)
	pole.position = current_pole_pos
	
	# Dodajemo savijanje motke tokom zabijanja
	pole_bend_amount = t * 0.3 + pole_compression * 0.5  # Kombinujemo animaciju i kompresiju
	update_pole_bend()

func handle_pole_vault(delta):
	pole_vault_progress += delta * 2.0  # Brzina animacije
	
	if pole_vault_progress >= 1.0:
		# Završavamo skakanje s motkom
		is_pole_vaulting = false
		pole.rotation.x = 0.0  # Vraćamo motku u normalnu poziciju
		pole.rotation.z = 0.0  # Resetujemo rotaciju
		pole.position = Vector3(0, 1, -2)  # Resetujemo poziciju motke
		pole.scale = Vector3(1, 1, 1)  # Resetujemo scale
		pole_bend_amount = 0.0
		player.global_position = pole_vault_target
		player.velocity = Vector3.ZERO
		score += 200  # Bonus poeni za skakanje s motkom
		update_score_display()
		return
	
	# Interpolacija pozicije
	var t = pole_vault_progress
	var current_pos = pole_vault_start_pos.lerp(pole_vault_target, t)
	
	# Dodajemo paraboličnu putanju (visina)
	var height_offset = sin(t * PI) * pole_vault_height
	current_pos.y = pole_vault_start_pos.y + height_offset
	
	# Dodajemo savijanje motke tokom skakanja
	pole_bend_amount = sin(t * PI) * 0.5  # Maksimalno savijanje 50%
	update_pole_bend()
	
	player.global_position = current_pos

func update_pole_bend():
	# Simuliramo savijanje motke menjanjem scale-a i pozicije
	var bend_scale = 1.0 + pole_bend_amount
	var compression_scale = 1.0 - pole_compression * 0.3  # Kompresija skraćuje motku
	
	# Kombinujemo savijanje i kompresiju
	var final_scale = Vector3(bend_scale, compression_scale, bend_scale)
	pole.scale = final_scale
	
	# Dodajemo rotaciju za realističniji efekat
	pole.rotation.z = pole_bend_amount * 0.2
	
	# Dodajemo oscilaciju tokom kompresije
	if pole_ground_contact and pole_compression > 0.1:
		pole.rotation.y = sin(Time.get_ticks_msec() * 0.01) * pole_compression * 0.1
	
	# Vizuelni indikator kompresije
	if pole_compression > 0.2:
		# Motka postaje crvenija tokom kompresije
		var compression_color = Color(1.0, 1.0 - pole_compression, 1.0 - pole_compression, 1.0)
		pole.get_node("PoleMesh").material.albedo_color = compression_color
	else:
		# Vraćamo originalnu boju
		pole.get_node("PoleMesh").material.albedo_color = Color(0.8, 0.6, 0.2, 1.0)
