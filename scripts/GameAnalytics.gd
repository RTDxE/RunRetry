extends Node

#------#------#------ CONFIG ------#------#------#

const ENABLED_INFO_LOG_BY_DEFAULT = false
const ENABLED_VERBOSE_LOG_BY_DEFAULT = false
const EVENT_PROCESS_INTERVAL_BY_DEFAULT = 8

const BUILD_VERSION = "Yandex 1.2"

const GAME_KEY = "b88c5786451157156fb3d080c321df2f"
const SECRET_KEY = "a6279a6a1c94f72ae807c1e9d58cb650feb434dd"

const AVAILABLE_RESOURCE_CURRENCIES = []
const AVAILABLE_RESOURCE_ITEM_TYPES = []
const AVAILABLE_CUSTOM_DIMENSIONS_01 = []
const AVAILABLE_CUSTOM_DIMENSIONS_02 = []
const AVAILABLE_CUSTOM_DIMENSIONS_03 = []

#------#------#------ ENUMS ------#------#------#

const PROGRESSION_STATUS = {
	"Start" : "Start",
	"Fail" : "Fail",
	"Complete" : "Complete"
}

const RESOURCE_FLOW_TYPE = {
	"Sink" : "Sink",
	"Source" : "Source"
}

const ERROR_SEVERITY = {
	"Debug" : "Debug",
	"Info" : "Info",
	"Warning" : "Warning",
	"Error" : "Error",
	"Critical" : "Critical"
}

const GENDER = {
	"Male" : "Male",
	"Female" : "Female"
}

#------#------#------ INTERNAL ------#------#------#

var _js_enabled = OS.has_feature('JavaScript')

func _init() -> void:
	_ga_configurable()
	_ga_init()

func _ga_configurable() -> void:
	set_enabled_info_log(ENABLED_INFO_LOG_BY_DEFAULT)
	set_enabled_verbose_log(ENABLED_VERBOSE_LOG_BY_DEFAULT)
	set_event_process_interval(EVENT_PROCESS_INTERVAL_BY_DEFAULT)
	_ga_configure_build()
	_ga_configure_available_resource_currencies()
	_ga_configure_available_resource_item_types()
	_ga_configure_available_custom_dimensions()

func _ga_configure_build() -> void:
	_eval("""
		GameAnalytics("configureBuild", "%s");
	""" % [BUILD_VERSION], true)

func _ga_configure_available_resource_currencies() -> void:
	_eval("""
		GameAnalytics("configureAvailableResourceCurrencies", %s);
	""" % [_array_to_string(AVAILABLE_RESOURCE_CURRENCIES)], true)

func _ga_configure_available_resource_item_types() -> void:
	_eval("""
		GameAnalytics("configureAvailableResourceItemTypes", %s);
	""" % [_array_to_string(AVAILABLE_RESOURCE_ITEM_TYPES)], true)

func _ga_configure_available_custom_dimensions() -> void:
	_eval("""
		GameAnalytics("configureAvailableCustomDimensions01", %s);
		GameAnalytics("configureAvailableCustomDimensions02", %s);
		GameAnalytics("configureAvailableCustomDimensions03", %s);
	""" % [
		_array_to_string(AVAILABLE_CUSTOM_DIMENSIONS_01),
		_array_to_string(AVAILABLE_CUSTOM_DIMENSIONS_02),
		_array_to_string(AVAILABLE_CUSTOM_DIMENSIONS_03)], true)

func _array_to_string(arr: Array) -> String:
	var s = "["
	var first = true
	for a in arr:
		if not first:
			s += ", "
		first = false
		s += "\"%s\"" % a
	s += "]"
	return s

func _ga_init() -> void:
	_eval("""
		GameAnalytics("initialize", "%s", "%s");
	""" % [GAME_KEY, SECRET_KEY], true)

func _eval(code: String, global: bool) -> void:
	if !_js_enabled: return
	JavaScript.eval(code, global)

#------#------#------ ADDING EVENTS ------#------#------#

func add_bussiness_event(
		currency: String, # ISO 4217 format
		amount: int, # in cents
		itemType: String, 
		itemId: String, 
		cartType: String # Max 10 unique values
		) -> void:
	_eval("""
		GameAnalytics("addBusinessEvent", "%s", %d, "%s", "%s", "%s");
	""" % [currency, amount, 	itemType, itemId, cartType], true)

func add_resource_event(
		flowType: String, # Use RESOURCE_FLOW_TYPE varable
		currency: String, # Use value from AVAILABLE_RESOURCE_CURRENCIES variable
		amount: float, # 0 or negative numbers are not allowed.
		itemType: String,  # Use value from AVAILABLE_RESOURCE_ITEM_TYPES variable
		itemId: String) -> void:
	_eval("""
		GameAnalytics("addResourceEvent", "%s", "%s", %d, "%s", "%s");
	""" % [flowType, currency, amount, itemType, itemId], true)

func add_progression_event(
		status: String, # Use PROGRESSION_STATUS variable
		p1: String, 
		p2: String = "", 
		p3: String = "", 
		score: int = 0
		) -> void:
	_eval("""
		GameAnalytics("addProgressionEvent", "%s", "%s", "%s", "%s", %d);
	""" % [status, p1, p2, p3, score], true)

func add_error_event(
		severity: String, # Use ERROR_SEVERITY variable
		message: String
		) -> void:
	_eval("""
		GameAnalytics("addErrorEvent", "%s", "%s");
	""" % [severity, message], true)

func add_design_event(
		event_id: String, 
		value: float = 0
		) -> void:
	_eval("""
		GameAnalytics("addDesignEvent", "%s", %d);
	""" % [event_id, value], true)

#------#------#------ CUSTOM DIMENSIONS ------#------#------#

func set_custom_dimension_01(
		customDimension: String = "" # Use value from AVAILABLE_CUSTOM_DIMENSIONS_01 variable
		) -> void:
	_eval("""
		GameAnalytics("setCustomDimension01", "%s");
	""" % [customDimension], true)

func set_custom_dimension_02(
		customDimension: String = "" # Use value from AVAILABLE_CUSTOM_DIMENSIONS_02 variable
		) -> void:
	_eval("""
		GameAnalytics("setCustomDimension02", "%s");
	""" % [customDimension], true)

func set_custom_dimension_03(
		customDimension: String = "" # Use value from AVAILABLE_CUSTOM_DIMENSIONS_03 variable
		) -> void:
	_eval("""
		GameAnalytics("setCustomDimension03", "%s");
	""" % [customDimension], true)

#------#------#------ USER INFORMATION ------#------#------#

func set_gender(
		gender: String # Use GENDER variable
		) -> void:
	_eval("""
		GameAnalytics("setGender", "%s");
	""" % [gender], true)

func set_birth_year(
		birth_year: String
		) -> void:
	_eval("""
		GameAnalytics("setBirthYear", "%s");
	""" % [birth_year], true)

func set_facebook_id(
		facebook_id: String
		) -> void:
	_eval("""
		GameAnalytics("setFacebookId", "%s");
	""" % [facebook_id], true)

#------#------#------ MISC ------#------#------#

func set_event_process_interval(interval: int) -> void:
	_eval("""
		GameAnalytics("setEventProcessInterval", %d);
	""" % [interval], true)

func set_enabled_info_log(enable: bool) -> void:
	_eval("""
		GameAnalytics("setEnabledInfoLog", %s);
	""" % [str(enable).to_lower()], true)

func set_enabled_verbose_log(enable: bool) -> void:
	_eval("""
		GameAnalytics("setEnabledVerboseLog", %s);
	""" % [str(enable).to_lower()], true)
