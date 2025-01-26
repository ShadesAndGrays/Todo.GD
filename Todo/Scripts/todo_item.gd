class_name TodoItem extends PanelContainer

@onready var task: Label = $MarginContainer/HBoxContainer/Control/task

@onready var indicator: Button = $MarginContainer/HBoxContainer/Control/indicator

@onready var progress_bar: ProgressBar = $MarginContainer/HBoxContainer/Control/task/ProgressBar

var done = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    set_state()
    DisplayServer.window_set_min_size(Vector2i(300,300))

func set_task(task_name:String,is_done = false) -> void:
    task.text = task_name
    done = is_done
    set_state()

func get_task() -> Dictionary:
    return {'task': task.text , 'status' : done }

func set_state():
    if done:
        task.self_modulate.a = 0.5
        indicator.text = 'X'
    else:
        task.self_modulate.a = 1.0
        indicator.text = ' '
    play_change_animation(done)


func _on_indicator_pressed() -> void:
    done = !done
    set_state()

func play_change_animation(cross:bool):
    var tween = create_tween()
    if cross:
        tween.tween_property(progress_bar,'value',100,0.3)
    else:
        tween.tween_property(progress_bar,'value',0,0.3)
        
    pass


func _on_delete_pressed() -> void:
    queue_free()
    pass # Replace with function body.
