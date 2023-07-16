extends Node

var API_key = "dev_cb375b22f1c244c1ac8909ca6053b633"
var development_mode = true
var session_token = ""
var version = "0.03.0.0"

var auth_http = HTTPRequest.new()
var leaderboard_http = HTTPRequest.new()
var submit_score_http = HTTPRequest.new()

var authentificated: bool = false

signal authentification_complete
signal get_leaderboard_complete
signal submit_score_complete

func _ready() -> void:
	authentification_request()

func authentification_request() -> void:
	var player_session_exists = false
	
	var file = FileAccess.open("user://LootLocker.data", FileAccess.READ)
	var player_identifier = ""
	
	if file != null:
		player_identifier = file.get_as_text()
		if player_identifier.length() > 1:
			player_session_exists = true
		file.close()
	
	var data = {"game_key": API_key, "game_version": version, "development_mode": development_mode}
	
	if player_session_exists:
		data = {"game_key": API_key, "player_identifier": player_identifier, "game_version": version, "development_mode": development_mode}
	
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
	
	print_debug(json)
	
	auth_http.queue_free()
	
	authentificated = true
	authentification_complete.emit(json)

func get_leaderboard(key: String) -> Node:
	var url = "https://api.lootlocker.io/game/leaderboards/"+key+"/list?count=10&after=0"
	var headers = ["Content-Type: application/json", "x-session-token:"+session_token]
	
	leaderboard_http = HTTPRequest.new()
	add_child(leaderboard_http)
	leaderboard_http.request_completed.connect(_on_leaderboard_request_completed)
	leaderboard_http.request(url, headers, HTTPClient.METHOD_GET)
	
	return self

func _on_leaderboard_request_completed(result, response_code, headers, body) -> void:
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	print_debug(json)
	
	print_debug("Found ", json.items.size(), " items in leaderboard")
	
	leaderboard_http.queue_free()
	
	get_leaderboard_complete.emit(json)

func upload_score(score: int, key: String) -> Node:
	var data = {"score": str(score)}
	var headers = ["Content-Type: application/json", "x-session-token:"+session_token]
	
	submit_score_http = HTTPRequest.new()
	add_child(submit_score_http)
	submit_score_http.request_completed.connect()
	submit_score_http.request("https://api.lootlocker.io/game/leaderboards/"+key+"/submit", headers, HTTPClient.METHOD_POST, JSON.stringify(data))
	
	print_debug(data)
	
	return self

func _on_upload_score_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	print_debug(json.result)
	
	submit_score_http.queue_free()
	
	submit_score_complete.emit(json)
