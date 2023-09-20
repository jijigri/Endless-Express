class_name Challenge
extends Node2D

@export var display_name: String
@export_multiline var description: String
@export var goal: int = 10
@export var progress: int = 0
@export var reward: Reward

var achieved: bool = false
var claimed: bool = false

var manager

func initialize(manager):
	self.manager = manager

func start_recording_event():
	pass

func progress_challenge():
	if manager != null:
		manager.progress_challenge(name, goal, progress)

func complete_challenge():
	if manager != null:
		manager.complete_challenge(name)

func set_data(data):
	display_name = data["name"]
	description = data["description"]
	if data.has("goal"):
		goal = data["goal"]
		progress = data["progress"]
	achieved = data["achieved"]
	claimed = data["claimed"]

func get_data():
	var data = {}
	data["name"] = display_name
	data["description"] = description
	if goal != 0:
		data["goal"] = goal
		data["progress"] = progress
	data["achieved"] = achieved
	data["claimed"] = claimed
	
	return data
