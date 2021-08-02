extends Node

signal player_logged

var _cb_initialized = JavaScript.create_callback(self, "_initialized")
var _cb_player_auth = JavaScript.create_callback(self, "_player_auth")
var _cb_player_anonymous = JavaScript.create_callback(self, "_player_anon")
var _cb_player_login = JavaScript.create_callback(self, "_player_login")
var _cb_adv_fs_close = JavaScript.create_callback(self, "_adv_fs_close")
var _cb_adv_fs_error = JavaScript.create_callback(self, "_adv_fs_error")
var adv_fs_cb
var last_show = 0

var console
var window
var ysdk
var player
var storage

var _local_record = 0


func _init() -> void:
	if !OS.has_feature('JavaScript'):
		return
	
	console = JavaScript.get_interface("console")
	window = JavaScript.get_interface("window")
	
	_ya_init_fullscreen_adv_callbacks()
	
	_ya_init()
	connect("player_logged", self, "_ya_init_storage")


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
	
	if window.yandexStorage:
		storage = window.yandexStorage 
		storage.init(window.ysdk)

func _ya_init_player(scopes: bool) -> void:
	if !OS.has_feature('JavaScript') or !ysdk:
		return

	var o = JavaScript.create_object("Object")
	o.scopes = scopes
	ysdk.getPlayer(o).then(_cb_player_auth).catch(_cb_player_anonymous)

func show_auth_popup() -> void:
	if !OS.has_feature('JavaScript') or !ysdk:
		return
	
	ysdk.auth.openAuthDialog().then(_cb_player_login);

func show_fullscreen_adv() -> void:
	if !OS.has_feature('JavaScript') or !ysdk:
		return
	
	if last_show != 0 and OS.get_unix_time() - last_show < 180:
		return
	last_show = OS.get_unix_time()
	
	ysdk.adv.showFullscreenAdv(adv_fs_cb)

func get_lang() -> String:
	if !OS.has_feature('JavaScript') or !ysdk:
		return "en"
	return ysdk.environment.i18n.lang

func get_record() -> int:
	if !OS.has_feature('JavaScript') or !ysdk or !storage:
		return _local_record
	
	var arr = JavaScript.create_object("Array", 1)
	arr[0] = "record"
	var record = storage.get(arr).record
	if (record == null):
		return 0
	
	return int(record)

func set_record(value: int) -> void:
	if !OS.has_feature('JavaScript') or !ysdk or !storage:
		_local_record = value
		return
	
	var o = JavaScript.create_object("Object")
	o.record = value
	storage.set(o, true)

# Callbacks

func _initialized(args) -> void:
	window.ysdk = args[0]
	ysdk = window.ysdk
	_ya_init_player(false)
	TranslationServer.set_locale("ru" if get_lang() == "ru" else "en")
	# Why not?
	show_fullscreen_adv()
	

func _player_auth(args) -> void:
	window.player = args[0]
	player = window.player
	emit_signal("player_logged")

func _player_anon(args) -> void:
	emit_signal("player_logged")

func _player_login(_args) -> void:
	_ya_init_player(false)

func _adv_fs_close(_args) -> void:
	pass

func _adv_fs_error(_args) -> void:
	pass
