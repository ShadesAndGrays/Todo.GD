class_name  Todo extends Control
const TODO_ITEM = preload("res://Todo/Scenes/TodoItem.tscn")
@onready var line_edit: LineEdit = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/LineEdit
@onready var todo_container: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/TodoContainer

# Called when the node enters the scene tree for the first time.
@onready var save_container: PanelContainer = $SaveContainer

var tween:Tween

var auto_save_timer:Timer = Timer.new()


func _ready() -> void:
	_clear()
	_add_save_key()
	load_data(load_from_file())
	create_auto_save_timer()

func create_auto_save_timer():
	add_child(auto_save_timer)
	auto_save_timer.wait_time = 15
	auto_save_timer.timeout.connect( func(): save_to_file(save()) )
	auto_save_timer.start()
	
func load_data(content:Dictionary) -> void:
	for key in content:
		var task = content[key]
		var todo_item_instance = TODO_ITEM.instantiate()
		todo_container.add_child(todo_item_instance)
		todo_item_instance.set_task(task['task'],task['status'])

func _add_save_key():
	if !InputMap.has_action("save"): 
		InputMap.add_action("save")  # adds save action
		var save_key = InputEventKey.new() # create new key event
		save_key.physical_keycode = KEY_S # set s to be key
		save_key.ctrl_pressed = true # set ctrl 
		InputMap.action_add_event("save",save_key) # add key event to save action

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		print(save())
	if Input.is_action_just_pressed('save'):
		play_save_animation()
		save_to_file(save())


func take_todo_input() -> String:
	var text = line_edit.text
	line_edit.clear()
	return text


func _on_add_todo_pressed() -> void:
	print(line_edit)
	var todo_text = take_todo_input()
	if todo_text.is_empty():
		return
	var todo_item_instance = TODO_ITEM.instantiate()
	todo_container.add_child(todo_item_instance)
	todo_item_instance.set_task(todo_text)
 

func save() -> Dictionary:
	var dict = {}
	var todos = todo_container.get_children()
	for i in range(len(todos)):
		dict[i] = todos[i].get_task()
		pass
	return dict

func save_to_file(content):
	var file = FileAccess.open("user://save_todo.dat", FileAccess.WRITE)
	var string_content = JSON.stringify(content)
	file.store_string(string_content)
	file.close()

func load_from_file():
	var file = FileAccess.open("user://save_todo.dat", FileAccess.READ)
	if file == null:
		var error = FileAccess.get_open_error()
		match error:
			ERR_FILE_NOT_FOUND:
				print("File not found")
			_:
				print("Failed to open save_todo.dat")
		return {}
	var content = file.get_as_text()
	var dict_content = JSON.parse_string(content)
	file.close()
	return dict_content

func _clear():
	line_edit.clear()
	for i in  todo_container.get_children():
		i.queue_free()

func play_save_animation():
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(save_container,"position:y",25,0.7).set_trans(Tween.TRANS_EXPO)
	tween.tween_interval(1)
	tween.tween_property(save_container,"position:y",-70,0.7).set_trans(Tween.TRANS_EXPO)
