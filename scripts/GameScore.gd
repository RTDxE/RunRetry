extends Node

var _gs
signal player_logged

var _cb_player_auth = JavaScript.create_callback(self, "_player_auth")

func _init() -> void:
	if OS.has_feature("JavaScript"):
		_gs = JavaScript.get_interface("_gameScore")

func get_record() -> int:
	if _gs == null: return 0
	return _gs.player.get("score")

func set_record(val) -> void:
	if _gs == null: return
	_gs.player.set("score", val)
	_gs.player.sync()

func add_try() -> void:
	if _gs == null: return
	_gs.player.add("try", 1)
	_gs.player.sync()

func get_lang() -> String:
	if _gs == null: return "en"
	if _gs != null:
		return str(_gs.language)
	return "en"

func player_is_logged() -> bool:
	if _gs == null: return true
	return _gs.player.isLoggedIn

func player_auth() -> void:
	if _gs == null: return
	_gs.player.login()
	_gs.player.on("login", _cb_player_auth)

func show_fullscreen_ads() -> void:
	if _gs == null: return
	_gs.ads.showFullscreen()

func show_leaderboard() -> void:
	if _gs == null: return
	
	var arr = JavaScript.create_object("Array", 1)
	arr[0] = 'score'
	
	var obj = JavaScript.create_object("Object")
	obj.orderBy = arr
	obj.order = "DESC"
	obj.limit = 10
	obj.displayFields = arr
	obj.withMe = "last"
	_gs.leaderboard.open(obj);

func _player_auth(success) -> void:
	emit_signal("player_logged")
