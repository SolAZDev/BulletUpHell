@tool
extends Node2D


var auto_pattern_id:String = ""
var auto_start_on_cam:bool = true
var auto_start_after_time:float = 0.0
var auto_start_at_distance:float = 5
var auto_distance_from:NodePath
var trigger_container:NodePath

var trig_container
var trigger_counter = 0
var trigger_timeout = false
var trig_collider
var trig_signal

var rotating_speed = 0.0
var active = true
var shared_area_name = "0"
var pool_amount:int = 50

var r_randomisation_chances:float
var r_active_chances:float
var r_shared_area_choice:String
var r_rotating_variation:Vector3
var r_pattern_choice:String
var r_start_time_choice:String
var r_start_time_variation:Vector3

var auto_call = false
var can_respawn = true

func _ready():
	if Engine.is_editor_hint(): return
	
	if trigger_container:
		trig_container = get_node(trigger_container)
		set_physics_process(false)

	if auto_start_on_cam:
		assert(auto_pattern_id != "")
		var instance = VisibleOnScreenNotifier2D.new()
		instance.connect("screen_entered",Callable(self,"on_screen").bind(true))
		instance.connect("screen_exited",Callable(self,"on_screen").bind(false))
	elif auto_distance_from != NodePath(): set_physics_process(true)
	elif auto_pattern_id:
		if auto_start_after_time > float(0.0):
			await get_tree().create_timer(auto_start_after_time).timeout
		auto_call = true
		set_physics_process(active)
		
	if active and auto_pattern_id:
		if auto_start_after_time > float(0.0):
			await get_tree().create_timer(auto_start_after_time).timeout
		auto_call = true
		set_physics_process(active)
		
	if rotating_speed > 0: set_physics_process(active)
		
	if active and pool_amount > 0:
		var props = Spawning.pattern(auto_pattern_id)["bullet"]
		Spawning.create_pool(props, shared_area_name, pool_amount, !Spawning.bullet(props).has("anim_idle_collision"))

func _physics_process(delta):
	if Engine.is_editor_hint(): return
	if auto_distance_from != NodePath() and global_position.distance_to(get_node(auto_distance_from).global_position) <= auto_start_at_distance:
		active = true
	checkTrigger()
	
	if can_respawn and auto_call and active and auto_pattern_id:
		Spawning.spawn(self, auto_pattern_id, shared_area_name)
		can_respawn = false
		if not rotating_speed > 0: set_physics_process(false)
		
	rotate(rotating_speed)


func on_screen(is_on):
	if is_on and auto_start_after_time > float(0.0):
		await get_tree().create_timer(auto_start_after_time).timeout
	active = is_on
	set_physics_process(active)

func triggerSignal(sig):
	trig_signal = sig
	checkTrigger()

func trig_timeout():
	trigger_timeout = true
	checkTrigger()

func checkTrigger():
	if trig_container: trig_container.checkTriggers(self)

func _get_property_list() -> Array:
	return [
		{
			name = "active",
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "auto_pattern_id",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "shared_area_name",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "rotating_speed",
			type = TYPE_FLOAT,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "pool_amount",
			type = TYPE_INT,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "Autostart & Triggering",
			type = TYPE_NIL,
			hint_string = "auto_",
			usage = PROPERTY_USAGE_GROUP
		},{
			name = "auto_start_on_cam",
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "auto_start_after_time",
			type = TYPE_FLOAT,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "auto_start_at_distance",
			type = TYPE_FLOAT,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "auto_distance_from",
			type = TYPE_NODE_PATH,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "Advanced Triggering",
			type = TYPE_NIL,
			hint_string = "trigger_",
			usage = PROPERTY_USAGE_GROUP
		},{
			name = "trigger_id",
			type = TYPE_NODE_PATH,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "Random",
			type = TYPE_NIL,
			hint_string = "r_",
			usage = PROPERTY_USAGE_GROUP
		},
		{ name = "r_randomisation_chances", type = TYPE_FLOAT,
			hint = PROPERTY_HINT_RANGE, hint_string = "0, 1", usage = PROPERTY_USAGE_DEFAULT },
		{ name = "r_active_chances", type = TYPE_FLOAT,
			hint = PROPERTY_HINT_RANGE, hint_string = "0, 1", usage = PROPERTY_USAGE_DEFAULT },
		{ name = "r_shared_area_choice", type = TYPE_STRING, usage = PROPERTY_USAGE_DEFAULT },
		{ name = "r_rotating_variation", type = TYPE_VECTOR3, usage = PROPERTY_USAGE_DEFAULT },
		{ name = "r_pattern_choice", type = TYPE_ARRAY, usage = PROPERTY_USAGE_DEFAULT },
		{ name = "r_start_time_choice", type = TYPE_STRING, usage = PROPERTY_USAGE_DEFAULT },
		{ name = "r_start_time_variation", type = TYPE_VECTOR3, usage = PROPERTY_USAGE_DEFAULT }]
