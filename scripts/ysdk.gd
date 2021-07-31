extends Node

var _cb_initialized = JavaScript.create_callback(self, "_initialized")
var _cb_adv_fs_close = JavaScript.create_callback(self, "_adv_fs_close")
var _cb_adv_fs_error = JavaScript.create_callback(self, "_adv_fs_error")

var console
var window
var ysdk

var adv_fs_cb

var last_show = 0

func _init() -> void:
	if !OS.has_feature('JavaScript'):
		return
	
	console = JavaScript.get_interface("console")
	window = JavaScript.get_interface("window")
	
	init_fullscreen_adv_callbacks()
	
	init()
	show_fullscreen_adv()


func init_fullscreen_adv_callbacks() -> void:
	if !OS.has_feature('JavaScript'):
		return
	
	adv_fs_cb = JavaScript.create_object("Object")
	adv_fs_cb["callbacks"] = JavaScript.create_object("Object")
	adv_fs_cb.callbacks.onClose = _cb_adv_fs_close
	adv_fs_cb.callbacks.onError = _cb_adv_fs_error


func init() -> void:
	if !OS.has_feature('JavaScript'):
		return
	
	var yagames = JavaScript.get_interface("YaGames")
	if yagames:
		yagames.init().then(_cb_initialized)


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
		return "en"
	return ysdk.environment.lang

func _cb_initialized(args) -> void:
#	console.log('Yandex SDK initialized')
	window.ysdk = args[0]
	ysdk = window.ysdk

func _adv_fs_close(ergs) -> void:
	console.log("Adv closed")

func _adv_fs_error(ergs) -> void:
	console.log("Adv error")
