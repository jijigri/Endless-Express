extends Node

var online: bool = true

var API_key = ""
var session_token = ""
var version = "0.03.0.0"

var auth_http = HTTPRequest.new()
var get_player_info_http = HTTPRequest.new()
var leaderboard_http = HTTPRequest.new()
var submit_score_http = HTTPRequest.new()
var get_rank_http = HTTPRequest.new()
var set_name_http = HTTPRequest.new()
var get_name_http = HTTPRequest.new()
var get_server_version_http = HTTPRequest.new()
var get_dev_message_http = HTTPRequest.new()

var player_name: String
var player_id

var authentificated: bool = false

var guest_exists: bool = true

signal authentification_complete
signal get_player_info_complete
signal get_leaderboard_complete
signal submit_score_complete
signal get_rank_complete
signal set_name_complete
signal get_name_complete
signal get_server_version_complete
signal get_dev_message_complete

func _ready() -> void:
	version = Global.version + ".0"
	authentification_request()
	await authentification_complete
	var name = await get_player_name().get_name_complete
	print_debug("Name obtained in ready: ", name)
	#if name == "":
		#name = await set_player_name("Player" + OS.get_unique_id()).set_name_complete
	
	player_name = name

func authentification_request() -> void:
	var player_session_exists = false
	
	var file = FileAccess.open("user://LootLocker.data", FileAccess.READ)
	player_id = ""
	
	if file != null:
		player_id = file.get_as_text()
		if player_id.length() > 1:
			player_session_exists = true
		file.close()
	else:
		guest_exists = false
	
	var data = {"game_key": API_key, "game_version": version}
	
	if player_session_exists:
		data = {"game_key": API_key, "player_identifier": player_id, "game_version": version}
	
	var headers = ["Content-Type: application/json"]
	
	auth_http = HTTPRequest.new()
	add_child(auth_http)
	auth_http.request_completed.connect(_on_authentification_request_completed)
	auth_http.request("https://api.lootlocker.io/game/v2/session/guest", headers, HTTPClient.METHOD_POST, JSON.stringify(data))
	
	#print_debug(data)

func _on_authentification_request_completed(result, response_code, headers, body) -> void:
	var json = JSON.parse_string(body.get_string_from_utf8())

	var file = FileAccess.open("user://LootLocker.data", FileAccess.WRITE)
	file.store_string(json.player_identifier)
	file.close()
	
	session_token = json.session_token
	player_id = json.player_id
	
	print_debug(json)
	
	auth_http.queue_free()
	
	authentificated = true
	authentification_complete.emit(json)

func get_player_info() -> Node:
	var url = "https://api.lootlocker.io/game/v1/player/info"
	var headers = ["x-session-token:"+session_token]
	
	get_player_info_http = HTTPRequest.new()
	add_child(get_player_info_http)
	get_player_info_http.request_completed.connect(_on_get_player_info_completed)
	get_player_info_http.request(url, headers, HTTPClient.METHOD_GET)
	
	return self

func _on_get_player_info_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	print_debug("Obtained player info: ", json)
	
	get_player_info_http.queue_free()
	get_player_info_complete.emit(json)

func get_leaderboard(key: String, count: int = 500) -> Node:
	print_debug("GET LEADERBOARD: ", count)
	var url = "https://api.lootlocker.io/game/leaderboards/"+key+"/list?count="+str(count)+"&after=0"
	var headers = ["x-session-token:"+session_token]
	
	leaderboard_http = HTTPRequest.new()
	add_child(leaderboard_http)
	leaderboard_http.request_completed.connect(_on_leaderboard_request_completed)
	leaderboard_http.request(url, headers, HTTPClient.METHOD_GET)
	
	return self

func _on_leaderboard_request_completed(result, response_code, headers, body) -> void:
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	print_debug(json)
	
	print_debug("Found ", json.items.size(), " items in leaderboard")
	
	if leaderboard_http != null:
		leaderboard_http.queue_free()
	
	get_leaderboard_complete.emit(json)

func upload_score(score: int, key: String, metadata: String = "I made it to the top!") -> Node:
	if online == false:
		return self
	
	var data = {"score": str(score), "metadata": metadata}
	var headers = ["Content-Type: application/json", "x-session-token:"+session_token]
	
	submit_score_http = HTTPRequest.new()
	add_child(submit_score_http)
	submit_score_http.request_completed.connect(_on_upload_score_request_completed)
	submit_score_http.request("https://api.lootlocker.io/game/leaderboards/"+key+"/submit", headers, HTTPClient.METHOD_POST, JSON.stringify(data))
	
	print_debug(data)
	
	return self

func _on_upload_score_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	print_debug("Submit score result: ", json)
	
	submit_score_http.queue_free()
	
	submit_score_complete.emit(json)

func get_rank(key: String) -> Node:
	var url = "https://api.lootlocker.io/game/leaderboards/"+key+"/member/"+str(player_id)
	var headers = ["x-session-token:"+session_token]
	
	get_rank_http = HTTPRequest.new()
	add_child(get_rank_http)
	get_rank_http.request_completed.connect(_on_get_rank_completed)
	get_rank_http.request(url, headers, HTTPClient.METHOD_GET, "")
	
	return self

func _on_get_rank_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	print_debug("Player rank: ", json)
	
	if get_rank_http != null:
		get_rank_http.queue_free()
	get_rank_complete.emit(json.score)

func set_player_name(name: String) -> Node:
	
	var data = {"name": name}
	var url = "https://api.lootlocker.io/game/player/name"
	var headers = ["Content-Type: application/json", "x-session-token:"+session_token]
	
	set_name_http = HTTPRequest.new()
	add_child(set_name_http)
	set_name_http.request_completed.connect(_on_set_name_completed)
	set_name_http.request(url, headers, HTTPClient.METHOD_PATCH, JSON.stringify(data))
	
	return self
	

func _on_set_name_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	set_name_http.queue_free()
	
	print_debug("Set name to: ", json.name)
	
	player_name = json.name
	
	set_name_complete.emit(json.name)

func get_player_name() -> Node:
	var url = "https://api.lootlocker.io/game/player/name"
	var headers = ["Content-Type: application/json", "x-session-token:"+session_token]
	
	get_name_http = HTTPRequest.new()
	add_child(get_name_http)
	get_name_http.request_completed.connect(_on_get_name_completed)
	get_name_http.request(url, headers, HTTPClient.METHOD_GET, "")
	
	return self

func _on_get_name_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print_debug("Get name: ", json)
	
	if json == null:
		print_debug("ERROR: NO NAME")
	
	if get_name_http != null:
		get_name_http.queue_free()
	
	get_name_complete.emit(json.name)

func get_server_version() -> Node:
	var uid = "DEKE9CEE"
	
	var url = "https://api.lootlocker.io/game/v1/player/"+uid+"/storage"
	var headers = ["Content-Type: application/json", "x-session-token:"+session_token]
	
	get_server_version_http = HTTPRequest.new()
	add_child(get_server_version_http)
	get_server_version_http.request_completed.connect(_on_get_server_version_completed)
	get_server_version_http.request(url, headers, HTTPClient.METHOD_GET)
	
	return self

func _on_get_server_version_completed(result, response_code, headers, body) -> void:
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	if json == null:
		print_debug("ERROR: NO VERSION FOUND")
	
	if get_server_version_http != null:
		get_server_version_http.queue_free()
	
	print_debug("SERVER VERSION: ", json)
	
	get_server_version_complete.emit(json.payload)

"""
func get_dev_message() -> Node:
	var uid = "DEKE9CEE"
	
	var url = "https://api.lootlocker.io/game/v1/player/"+uid+"/storage"
	var headers = ["Content-Type: application/json", "x-session-token:"+session_token]
	
	get_dev_message_http = HTTPRequest.new()
	add_child(get_dev_message_http)
	get_dev_message_http.request_completed.connect(_on_get_dev_message_completed)
	get_dev_message_http.request(url, headers, HTTPClient.METHOD_GET)
	
	return self

func _on_get_dev_message_completed(result, response_code, headers, body) -> void:
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	if json == null:
		print_debug("ERROR: NO VERSION FOUND")
	
	if get_server_version_http != null:
		get_server_version_http.queue_free()
	
	print_debug("SERVER VERSION: ", json)
	
	get_server_version_complete.emit(json.payload[0].value)
"""
