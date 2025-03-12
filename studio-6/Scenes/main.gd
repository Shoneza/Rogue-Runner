extends Node
#preload obstacles
var spike_scene = preload('res://Scenes/spike.tscn')
var slime_scene = preload('res://Scenes/slime.tscn')
var fly_scene = preload('res://Scenes/fly.tscn')
var worm_scene = preload('res://Scenes/worm.tscn')
var obstacle_type = [spike_scene,slime_scene,worm_scene]
var static_obs = [spike_scene]
var obstacles: Array
var fly_height = [200,390]

const ROGUE_START_POS : = Vector2i(150,485)
const CAM_START_POS := Vector2i(576,324)

const START_SPEED : float = 450
const MAX_SPEED : int = 800

var screen_size : Vector2i
var ground_height: int
var speed: float
var score: int
#var high_score: int
const SCORE_MODIFIER: int  =10
const SPEED_MODIFIER: int  =5000
var difficulty
const MAX_DIFFICULTY : int = 2
var game_running : bool = false
var last_obs
# Called when the node enters the scene tree for the first time.
var is_game_over : bool  = false
func _ready() -> void:
	screen_size = get_window().size
	ground_height = $Ground.get_node('Sprite2D').texture.get_height()
	$GameOver.get_node("Button").pressed.connect(new_game)
	reset_variable()
	Engine.max_fps = 60
	
func reset_variable():
		#reset varible
	score = 0
	game_running = false
	is_game_over =false
	difficulty = 0
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
	$Rogue.position = ROGUE_START_POS
	$Rogue.velocity = Vector2i(0,0)
	$Rogue.is_attacking = false
	$Rogue.is_double_jump = false
	$Rogue/AttackArea/CollisionShape2D.disabled = true
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0,0)
	$HUD.get_node("TapLabel").visible = true
	$GameOver.visible = false
func new_game():
	#reset varible
	get_tree().reload_current_scene()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_running:
		
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficulty()
		shown_score()
		#check_high_score()
		generate_obs()
		#move rogue
		if not $Rogue.is_attacking:
			$Rogue.position.x += speed  * delta
			$Camera2D.position.x += speed  * delta

		#add score
		score += speed  * delta
		#update ground position
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x
		
		#remove obstacles
		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x -screen_size.x):
				remove_obs(obs)
	else:
		if Input.is_action_just_pressed("ui_accept") and not is_game_over:
			game_running = true
			$HUD.get_node("TapLabel").visible = false

func shown_score():
	$HUD.get_node('ScoreLabel').text = "SCORE: " + str(score / SCORE_MODIFIER)

#func check_high_score():
	#if score > high_score:
		#high_score = score
		#$HUD.get_node('HighScoreLabel').text = "HIGH SCORE: " + str(high_score / SCORE_MODIFIER)
		#

func generate_obs():
	#generate ground obstacles
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 500):
		var obs_type = obstacle_type[randi() % obstacle_type.size()]
		var obs
		var max_obs = difficulty + 1
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = $Camera2D.position.x + screen_size.x / 2 + 100 + (i * 100)
			var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) + 5
			last_obs = obs
			add_obs(obs, obs_x, obs_y)
			#additionally random chance to spawn a bird
		if difficulty == MAX_DIFFICULTY:
			if (randi() % 2) == 0:
				#generate bird obstacles
				obs = fly_scene.instantiate()
				var obs_x : int = $Camera2D.position.x + screen_size.x + 100
				var obs_y : int = fly_height[randi() % fly_height.size()]
				add_obs(obs, obs_x, obs_y)


func add_obs(obs,x,y):
	obs.position = Vector2i(x,y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)

func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)

func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY

func hit_obs(body):
	if body.name == 'Rogue':
		game_over()
		
func game_over():
	$Rogue.get_node('DeathSound').play()
	game_running = false
	$GameOver.visible = true
	is_game_over = true
