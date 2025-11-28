@tool
extends Node

enum LOG_LEVEL {ERROR,INFO,WARN,DEBUG,NONE}
const LOG_LEVEL_NAMES: Array[String] = ["ERROR","INFO","WARN","DEBUG","NONE"]

##Settings root
const SETTINGS_ROOT: String = "aceLog"
## Get the default logging level if a folder or file is not specified
const SELECTED_LOG_LEVEL: String = "settings/logLevel"
## Folder level logging level
const FOLDER_DEBUG_LOG_LEVEL: String = "settings/folder/debug"
const FOLDER_INFO_LOG_LEVEL: String = "settings/folder/info"
const FOLDER_WARN_LOG_LEVEL: String = "settings/folder/warn"
const FOLDER_ERROR_LOG_LEVEL: String = "settings/folder/error"
## File level logging level
const FILE_DEBUG_LOG_LEVEL: String = "settings/file/debug"
const FILE_INFO_LOG_LEVEL: String = "settings/file/info"
const FILE_WARN_LOG_LEVEL: String = "settings/file/warn"
const FILE_ERROR_LOG_LEVEL: String = "settings/file/error"

## Empty String Array
const EMPTY_ARRAY: Array[String] = []

# "hint_string": "%s/%s:%s" % [TYPE_ARRAY, PROPERTY_HINT_RESOURCE_TYPE, "DirectoryPathResource"]

var  SETTINGS_CONFIGURATION : Dictionary[String, AceSettingConfig] = {
	SELECTED_LOG_LEVEL: AceSettingConfig.new(SELECTED_LOG_LEVEL, TYPE_STRING, "INFO", PROPERTY_HINT_ENUM, "ERROR,INFO,WARN,DEBUG"),
	FOLDER_DEBUG_LOG_LEVEL: AceSettingConfig.new(SELECTED_LOG_LEVEL, TYPE_ARRAY, EMPTY_ARRAY, PROPERTY_HINT_TYPE_STRING, "%s/%s:" % [TYPE_STRING, PROPERTY_HINT_DIR]),
	FOLDER_INFO_LOG_LEVEL: AceSettingConfig.new(SELECTED_LOG_LEVEL, TYPE_ARRAY, EMPTY_ARRAY, PROPERTY_HINT_TYPE_STRING, "%s/%s:" % [TYPE_STRING, PROPERTY_HINT_DIR]),
	FOLDER_WARN_LOG_LEVEL: AceSettingConfig.new(SELECTED_LOG_LEVEL, TYPE_ARRAY, EMPTY_ARRAY, PROPERTY_HINT_TYPE_STRING, "%s/%s:" % [TYPE_STRING, PROPERTY_HINT_DIR]),
	FOLDER_ERROR_LOG_LEVEL: AceSettingConfig.new(SELECTED_LOG_LEVEL, TYPE_ARRAY, EMPTY_ARRAY, PROPERTY_HINT_TYPE_STRING, "%s/%s:" % [TYPE_STRING, PROPERTY_HINT_DIR]),
	FILE_DEBUG_LOG_LEVEL: AceSettingConfig.new(SELECTED_LOG_LEVEL, TYPE_ARRAY, EMPTY_ARRAY, PROPERTY_HINT_TYPE_STRING, "%s/%s:%s" % [TYPE_STRING, PROPERTY_HINT_FILE, "*.gd"]),
	FILE_INFO_LOG_LEVEL: AceSettingConfig.new(SELECTED_LOG_LEVEL, TYPE_ARRAY, EMPTY_ARRAY, PROPERTY_HINT_TYPE_STRING, "%s/%s:%s" % [TYPE_STRING, PROPERTY_HINT_FILE, "*.gd"]),
	FILE_WARN_LOG_LEVEL: AceSettingConfig.new(SELECTED_LOG_LEVEL, TYPE_ARRAY, EMPTY_ARRAY, PROPERTY_HINT_TYPE_STRING, "%s/%s:%s" % [TYPE_STRING, PROPERTY_HINT_FILE, "*.gd"]),
	FILE_ERROR_LOG_LEVEL: AceSettingConfig.new(SELECTED_LOG_LEVEL, TYPE_ARRAY, EMPTY_ARRAY, PROPERTY_HINT_TYPE_STRING, "%s/%s:%s" % [TYPE_STRING, PROPERTY_HINT_FILE, "*.gd"])
}

var _log: Log

var settings: AceSettings

var selected_log_level: LOG_LEVEL = LOG_LEVEL.INFO
var debug_folders: Array[String] = []
var info_folders: Array[String] = []
var warn_folders: Array[String] = []
var error_folders: Array[String] = []
var debug_files: Array[String] = []
var info_files: Array[String] = []
var warn_files: Array[String] = []
var error_files: Array[String] = []

var _LOG_LEVEL_DICT: Dictionary[String, AceLogLevelInfo] = {
	LOG_LEVEL_NAMES[LOG_LEVEL.ERROR]: AceLogLevelInfo.new(),
	LOG_LEVEL_NAMES[LOG_LEVEL.INFO]: AceLogLevelInfo.new(),
	LOG_LEVEL_NAMES[LOG_LEVEL.WARN]: AceLogLevelInfo.new(),
	LOG_LEVEL_NAMES[LOG_LEVEL.DEBUG]: AceLogLevelInfo.new()

}


func _ready() -> void:
	if Engine.is_editor_hint():
		call_deferred("_initalize_settings")

func _process(delta: float) -> void:
	if settings != null:
		_process_settings(settings)


func printLog(stmnt: Array, input_log_level: LOG_LEVEL = LOG_LEVEL.NONE):
	var call_stack: Array = get_stack()
	# The first element of the stack array (index 0) represents the current function's information.
	# The second element (index 1) typically represents the function that called the current one.
	if call_stack.size() > 1:
		var caller_info = call_stack[1]
		var calling_script: String = caller_info["source"]
		var log_level: LOG_LEVEL = input_log_level if input_log_level != LOG_LEVEL.NONE else _get_script_log_level(calling_script)

		if log_level <= selected_log_level:
			var log_level_tag = "[%s]" % LOG_LEVEL_NAMES[log_level]
			stmnt.push_front(log_level_tag)
			print_rich(Log.to_printable(stmnt, {"stack": call_stack}))



func _initalize_settings() -> void:
	if settings == null:
		settings = AceSettings.new()
		settings.initialize_settings(SETTINGS_CONFIGURATION, SETTINGS_ROOT)
		_process_settings(settings)
		settings.prepare()
		printLog(["Intial Settings:", _LOG_LEVEL_DICT])
		

func _process_settings(settings: AceSettings):
	#Default Log Level
	if selected_log_level != LOG_LEVEL[settings.get_setting(SELECTED_LOG_LEVEL, "INFO")]:
		selected_log_level = LOG_LEVEL[settings.get_setting(SELECTED_LOG_LEVEL, "INFO")]
		printLog(["Default Log Level Changed to: %s" % LOG_LEVEL_NAMES[selected_log_level]], LOG_LEVEL.DEBUG)

	#Folders
	if debug_folders != settings.get_setting(FOLDER_DEBUG_LOG_LEVEL, []):
		debug_folders = settings.get_setting(FOLDER_DEBUG_LOG_LEVEL, [])
		_LOG_LEVEL_DICT.get(LOG_LEVEL_NAMES[LOG_LEVEL.DEBUG]).folder_arr = debug_folders
		printLog(["Debug Folders Changed to: %s" % str(debug_folders)], LOG_LEVEL.DEBUG)
	
	if info_folders != settings.get_setting(FOLDER_INFO_LOG_LEVEL, []):
		info_folders = settings.get_setting(FOLDER_INFO_LOG_LEVEL, [])
		_LOG_LEVEL_DICT.get(LOG_LEVEL_NAMES[LOG_LEVEL.INFO]).folder_arr = info_folders
		printLog(["Info Folders Changed to: %s" % str(info_folders)], LOG_LEVEL.DEBUG)
	
	if warn_folders != settings.get_setting(FOLDER_WARN_LOG_LEVEL, []):
		warn_folders = settings.get_setting(FOLDER_WARN_LOG_LEVEL, [])
		_LOG_LEVEL_DICT.get(LOG_LEVEL_NAMES[LOG_LEVEL.WARN]).folder_arr = warn_folders
		printLog(["Warn Folders Changed to: %s" % str(warn_folders)], LOG_LEVEL.DEBUG)
	if error_folders != settings.get_setting(FOLDER_ERROR_LOG_LEVEL, []):
		error_folders = settings.get_setting(FOLDER_ERROR_LOG_LEVEL, [])
		_LOG_LEVEL_DICT.get(LOG_LEVEL_NAMES[LOG_LEVEL.ERROR]).folder_arr = error_folders
		printLog(["Error Folders Changed to: %s" % str(error_folders)], LOG_LEVEL.DEBUG)

	#Files
	if debug_files != settings.get_setting(FILE_DEBUG_LOG_LEVEL, []):
		debug_files = settings.get_setting(FILE_DEBUG_LOG_LEVEL, [])
		_LOG_LEVEL_DICT.get(LOG_LEVEL_NAMES[LOG_LEVEL.DEBUG]).files_arr = debug_files
		printLog(["Debug Files Changed to: %s" % str(debug_files)], LOG_LEVEL.DEBUG)
	
	if info_files != settings.get_setting(FILE_INFO_LOG_LEVEL, []):
		info_files = settings.get_setting(FILE_INFO_LOG_LEVEL, [])
		_LOG_LEVEL_DICT.get(LOG_LEVEL_NAMES[LOG_LEVEL.INFO]).files_arr = info_files
		printLog(["Info Files Changed to: %s" % str(info_files)], LOG_LEVEL.DEBUG)
	if warn_files != settings.get_setting(FILE_WARN_LOG_LEVEL, []):
		warn_files = settings.get_setting(FILE_WARN_LOG_LEVEL, [])
		_LOG_LEVEL_DICT.get(LOG_LEVEL_NAMES[LOG_LEVEL.WARN]).files_arr = warn_files
		printLog(["Warn Files Changed to: %s" % str(warn_files)], LOG_LEVEL.DEBUG)
	
	if error_files != settings.get_setting(FILE_ERROR_LOG_LEVEL, []):
		error_files = settings.get_setting(FILE_ERROR_LOG_LEVEL, [])
		_LOG_LEVEL_DICT.get(LOG_LEVEL_NAMES[LOG_LEVEL.ERROR]).files_arr = error_files
		printLog(["Error Files Changed to: %s" % str(error_files)], LOG_LEVEL.DEBUG)






func _get_script_log_level(script: String) -> LOG_LEVEL:

	var script_name: String = script.get_file()

	for level in _LOG_LEVEL_DICT:
		#Check File Level First
		if script_name in _LOG_LEVEL_DICT[level].file_arr:
			return LOG_LEVEL[level]
		if _LOG_LEVEL_DICT[level].folder_arr.any(func(folder: String) -> bool: return folder in script):
			return LOG_LEVEL[level]

	printLog(["No matching log level found for script: %s returning log level: %s" % [script, LOG_LEVEL_NAMES[LOG_LEVEL.INFO]]], LOG_LEVEL.WARN)
	return LOG_LEVEL.INFO
