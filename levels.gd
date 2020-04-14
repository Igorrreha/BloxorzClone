extends Node

signal levels_ended()

var levels_ended = false

var levels_path = "res://lvl"

var level_list = []
var current_level


func _enter_tree():
	# создаём объект типа Директория
	var dir = Directory.new()
	
	# открываем папку со сценами-уровнями
	dir.open(levels_path)
	# инициализируем поток дочерних элементов директории (файлов и папок)
	dir.list_dir_begin()
	
	# переходим к первому элементу потока
	var file = dir.get_next()
	while file != "":
		# отсеиваем навигационные строки потока
		if file == "." or file == "..":
			file = dir.get_next()
			continue
		
		# добавляем файл потока в массив уровней 
		level_list.push_back(levels_path.plus_file(file))
		
		# переходим к следующему файлу потока
		file = dir.get_next()
	
	# сортируем список уровней
	level_list.sort()
	
	current_level = -1


func get_next_level():
	current_level += 1
	
	if current_level == level_list.size():
		emit_signal("levels_ended")
		levels_ended = true
		return ""
	return level_list[current_level]
