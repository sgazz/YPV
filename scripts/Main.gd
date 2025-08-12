extends Node3D

@onready var player = $Player
@onready var camera = $Player/Camera3D
@onready var score_label = $UI/ScoreLabel
@onready var pole = $Player/Pole

# Podešavanja kretanja
@export var walk_speed: float = 5.0
@export var run_speed: float = 10.0
@export var gravity: float = -20.0
@export var vault_power: float = 12.0
@export var pole_rotate_speed: float = 120.0

# Stanja
var is_vaulting = false
var pole_angle = 60.0  # Promenjen smer - pozitivan ugao za side-view
var mouse_sensitivity = 0.002
var camera_rotation = 0.0
var score = 0
var last_position = Vector3.ZERO

# Debug varijable
var show_timing_indicator = true
var timing_indicator_color = Color.GREEN

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	last_position = player.global_position
	update_score_display()
	
	# Konfigurišemo CharacterBody3D
	player.floor_max_angle = 0.785398  # 45 stepeni
	player.floor_snap_length = 0.3
	player.floor_block_on_wall = true
	
	# Postavljamo početnu poziciju motke
	pole.position = Vector3(3, 1, 0)  # Pomeramo motku 3 jedinice ispred igrača (X osa)
	pole.rotation_degrees = Vector3(0, 0, pole_angle)  # Rotacija oko Z osi za side-view
	pole.scale = Vector3(1, 1, 1)
	
	# Osiguravamo da je motka vidljiva
	pole.visible = true
	pole.get_node("PoleMesh").visible = true
	pole.get_node("PoleTip").visible = true
	
	# Postavljamo side-view kameru
	setup_side_view_camera()
	
	print("XOArena3D: Igra je uspešno inicijalizovana")
	print("XOArena3D: Motka je postavljena na poziciju: ", pole.position)
	print("XOArena3D: Motka je vidljiva: ", pole.visible)
	print("XOArena3D: Kamera je na poziciji: ", camera.global_position)
	print("XOArena3D: Udaljenost motke od kamere: ", pole.global_position.distance_to(camera.global_position))
	print("XOArena3D: Pole angle: ", pole_angle)
	print("XOArena3D: Pole rotation: ", pole.rotation_degrees)

func _input(event):
	# Uklanjamo rotaciju kamere jer je sada side-view
	# if event is InputEventMouseMotion:
	# 	# Rotacija kamere levo-desno
	# 	player.rotate_y(-event.relative.x * mouse_sensitivity)
	# 	
	# 	# Rotacija kamere gore-dole
	# 	camera_rotation -= event.relative.y * mouse_sensitivity
	# 	camera_rotation = clamp(camera_rotation, -PI/2, PI/2)
	# 	camera.rotation.x = camera_rotation
	
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	if not is_vaulting:
		handle_movement()
		
		# Sprint check
		if is_moving() and Input.is_action_pressed("run"):
			# Vault check (RMB + LMB)
			if Input.is_action_pressed("jump_mouse"):
				start_vault()
		# Normal jump
		elif Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("jump") or Input.is_key_pressed(KEY_SPACE):
			if player.is_on_floor():
				player.velocity.y = vault_power * 0.5  # Manji skok
				print("XOArena3D: Normal jump executed")
	else:
		perform_vault(delta)

	# Gravitacija
	if not player.is_on_floor():
		player.velocity.y += gravity * delta
	
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

func handle_movement():
	var dir = Vector3.ZERO
	# Samo levo-desno kretanje (X osa)
	dir.x = Input.get_axis("ui_left", "ui_right")
	# dir.z = Input.get_axis("ui_up", "ui_down")  # Uklanjamo Z kretanje
	dir = dir.normalized()
	
	var speed = walk_speed
	if Input.is_action_pressed("run"):
		speed = run_speed
	
	# Uklanjamo rotaciju input-a jer se igrač ne rotira u side-view
	# var rotated_input = player.transform.basis * dir
	
	player.velocity.x = dir.x * speed
	player.velocity.z = 0.0  # Fiksiramo Z poziciju

func is_moving() -> bool:
	return Input.get_axis("ui_left", "ui_right") != 0  # Samo X kretanje

func start_vault():
	if not player.is_on_floor():
		return
		
	is_vaulting = true
	player.velocity.x *= 0.5
	# player.velocity.z *= 0.5  # Uklanjamo jer je Z fiksiran
	
	# Resetujemo motku u početni položaj pre skoka
	pole.position = Vector3(3, 1, 0)  # Osiguravamo da je motka ispred igrača
	pole_angle = 60.0
	pole.rotation_degrees = Vector3(0, 0, pole_angle)
	pole.scale = Vector3(1, 1, 1)  # Resetujemo scale
	
	print("XOArena3D: Starting vault - angle: ", pole_angle)
	print("XOArena3D: Pole reset to position: ", pole.position)

func perform_vault(delta):
	pole_angle -= pole_rotate_speed * delta  # Rotiramo u suprotnom smeru
	pole.rotation_degrees = Vector3(0, 0, pole_angle)
	
	# Vizuelni efekti tokom skakanja
	update_pole_visual_effects()

	if pole_angle <= -80.0:  # Promenjen uslov za side-view
		player.velocity.y = vault_power
		is_vaulting = false
		
		# Resetujemo motku u početni položaj
		pole.rotation_degrees = Vector3(0, 0, 60.0)  # Resetujemo na početni ugao 60°
		pole.position = Vector3(3, 1, 0)  # Osiguravamo da je motka ispred igrača (X osa)
		pole.scale = Vector3(1, 1, 1)
		
		# Bonus poeni
		var bonus_points = 200
		score += bonus_points
		update_score_display()
		
		print("XOArena3D: Vault completed - bonus: ", bonus_points)
		print("XOArena3D: Pole reset after vault to position: ", pole.position)

func update_pole_visual_effects():
	# Simuliramo savijanje motke tokom rotacije
	var bend_amount = sin(deg_to_rad(pole_angle)) * 0.3
	var compression_scale = 1.0 - abs(sin(deg_to_rad(pole_angle))) * 0.2
	
	# Kombinujemo savijanje i kompresiju
	var final_scale = Vector3(1.0 + bend_amount, compression_scale, 1.0 + bend_amount)
	pole.scale = final_scale
	
	# Timing indikator - zelena boja za optimalan timing
	if show_timing_indicator and pole_angle <= -70.0 and pole_angle >= -85.0:  # Promenjen uslov za side-view
		pole.get_node("PoleMesh").material.albedo_color = timing_indicator_color
	else:
		pole.get_node("PoleMesh").material.albedo_color = Color(0.8, 0.6, 0.2, 1.0)

func update_score_display():
	score_label.text = "Poeni: " + str(score)

func reset_player_position():
	player.global_position = Vector3(0, 2, 0)
	player.velocity = Vector3.ZERO
	
	# Resetujemo motku ako je u animaciji
	if is_vaulting:
		print("XOArena3D: Resetting pole from vault state")
		is_vaulting = false
		pole.rotation_degrees = Vector3(0, 0, 60.0)  # Resetujemo na početni ugao 60°
		pole.position = Vector3(3, 1, 0)  # Pomeramo motku 3 jedinice ispred igrača (X osa)
		pole.scale = Vector3(1, 1, 1)
		
		# Osiguravamo da je motka vidljiva nakon reset-a
		pole.visible = true
		pole.get_node("PoleMesh").visible = true
		pole.get_node("PoleTip").visible = true
		print("XOArena3D: Pole reset completed")
	
	score = max(0, score - 100)  # Gubimo 100 poena za pad
	update_score_display()

func setup_side_view_camera():
	# Postavljamo kameru sa strane (side-view)
	camera.position = Vector3(0, 2, 8)  # Kamera iza igrača, malo iznad
	camera.rotation_degrees = Vector3(0, 0, 0)  # Gleda pravo napred
	camera_rotation = 0.0  # Resetujemo rotaciju kamere
	
	# Kreirajemo 2D platforme za side-view igru
	create_2d_platforms()

func create_2d_platforms():
	# Dodajemo platforme na različitim X pozicijama za 2D side-view
	var platform_positions = [
		Vector3(10, 0, 0),
		Vector3(20, 2, 0),
		Vector3(30, 0, 0),
		Vector3(40, 4, 0),
		Vector3(50, 1, 0),
		Vector3(60, 3, 0),
		Vector3(70, 0, 0),
		Vector3(80, 5, 0),
		Vector3(90, 2, 0),
		Vector3(100, 0, 0)
	]
	
	for i in range(platform_positions.size()):
		var platform = create_platform(platform_positions[i], "Platform" + str(i))
		get_node(".").add_child(platform)

func create_platform(platform_pos: Vector3, platform_name: String) -> StaticBody3D:
	var platform = StaticBody3D.new()
	platform.name = platform_name
	platform.position = platform_pos
	
	var mesh = CSGBox3D.new()
	mesh.size = Vector3(3, 1, 10)  # Široka platforma za side-view
	mesh.material = StandardMaterial3D.new()
	mesh.material.albedo_color = Color(0.4, 0.6, 0.4, 1)
	platform.add_child(mesh)
	
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(3, 1, 10)
	collision.shape = shape
	platform.add_child(collision)
	
	return platform
