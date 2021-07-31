extends Node

var _cb_initialized = JavaScript.create_callback(self, "_initialized")
#var _cb_player_auth = JavaScript.create_callback(self, "_player_auth")
var _cb_adv_fs_close = JavaScript.create_callback(self, "_adv_fs_close")
var _cb_adv_fs_error = JavaScript.create_callback(self, "_adv_fs_error")
var adv_fs_cb
var last_show = 0

var console
var window
var ysdk
#var player
var storage

var _local_record = 0


func _init() -> void:
	if !OS.has_feature('JavaScript'):
		return
	
	console = JavaScript.get_interface("console")
	window = JavaScript.get_interface("window")
	
	_ya_init_fullscreen_adv_callbacks()
	
	_ya_init()
	_ya_init_storage()


func _ya_init_fullscreen_adv_callbacks() -> void:
	if !OS.has_feature('JavaScript'):
		return
	
	adv_fs_cb = JavaScript.create_object("Object")
	adv_fs_cb["callbacks"] = JavaScript.create_object("Object")
	adv_fs_cb.callbacks.onClose = _cb_adv_fs_close
	adv_fs_cb.callbacks.onError = _cb_adv_fs_error


func _ya_init() -> void:
	if !OS.has_feature('JavaScript'):
		return
	
	var yagames = JavaScript.get_interface("YaGames")
	if yagames:
		yagames.init().then(_cb_initialized)

func _ya_init_storage() -> void:
	if !OS.has_feature('JavaScript') or !ysdk:
		return
	
	var yStorage = JavaScript.get_interface("YandexStorage")
	if yStorage:
		window.storage = yStorage.new(JavaScript.create_object("Object"), false)
		storage = window.storage
		storage.init(window.ysdk)

#func _ya_init_player() -> void:
#	if !OS.has_feature('JavaScript') or !ysdk:
#		return
#
#	ysdk.getPlayer().then(_cb_player_auth)


func show_fullscreen_adv() -> void:
	if !OS.has_feature('JavaScript') or !ysdk:
		return
	
	console.log("Try to how fullscreen adv")
	
	if last_show != 0 and OS.get_unix_time() - last_show < 180:
		return
	last_show = OS.get_unix_time()
	
	console.log("Show fullscreen adv")
	
	ysdk.adv.showFullscreenAdv(adv_fs_cb)

func get_lang() -> String:
	if !OS.has_feature('JavaScript') or !ysdk:
		return "ru"
	return ysdk.environment.lang

func get_record() -> int:
	if !OS.has_feature('JavaScript') or !ysdk or !storage:
		return _local_record
	
	
	var record = storage.get("record")[0]
	if (record == null):
		return 0
	
	return int(record)

func set_record(value: int) -> void:
	if !OS.has_feature('JavaScript') or !ysdk or !storage:
		_local_record = value
		return
	
	var o = JavaScript.create_object("Object")
	o.record = value
	storage.set(o, false)

# Callbacks

func _initialized(args) -> void:
	console.log('Yandex SDK initialized')
	window.ysdk = args[0]
	ysdk = window.ysdk
	# Why not?
	show_fullscreen_adv()

#func _player_auth(args) -> void:
#	console.log('Player initialized')
#	window.player = args[0]
#	player = window.player

func _adv_fs_close(ergs) -> void:
	console.log("Adv closed")

func _adv_fs_error(ergs) -> void:
	console.log("Adv error")
