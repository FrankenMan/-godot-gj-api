extends Node

var trophies_list
var trophy_no = 0
var gj

func _ready():
	gj = get_node("gjapi")
	gj.connect("api_authenticated", self, "on_gj_auth")
	gj.connect("api_user_fetched", self, "on_gj_fetch_user")
	gj.connect("api_session_opened", self, "on_session_opened")
	gj.connect("api_trophy_fetched", self, "trophies_fetched")
	pass
	
func trophies_fetched(data):
	var d = {}
	d.parse_json(data)
	trophies_list = d["response"]["trophies"]
	if trophies_list.empty():
		return
	get_node("downloader").set_download_file("res://trophy_icon" + str(trophy_no) + ".jpg")
	get_node("downloader").request(trophies_list[0]["image_url"].replace("https", "http"))
	get_node("trophies").show()
	pass
	
func on_session_opened(data):
	print(data)
	pass

func _on_auth_pressed():
	gj.auth_user(get_node("ui/token").get_text(), get_node("ui/username").get_text())
	pass # replace with function body

func on_gj_auth(data):
	get_node("ui/open_s").set_disabled(false)
	get_node("ui/close_s").set_disabled(false)
	get_node("ui/list_trophies").set_disabled(false)
	print(data)
	gj.fetch_user_by_name(gj.get_username())
	pass
	
func on_gj_fetch_user(data):
	var res = get_node("response")
	var d = {} # declare a dictionary
	d.parse_json(data) # parse the json string
	d = d["response"]["users"][0] # the api outputs everything in one dictionary so fetch it
	for i in d.keys(): # get all information
		res.set_text(res.get_text() + "\n" + i + ": " + d[i])
	pass

func _on_open_s_pressed():
	gj.open_session()
	pass # replace with function body


func _on_close_s_pressed():
	gj.close_session()
	pass # replace with function body


func _on_list_trophies_pressed():
	gj.fetch_trophies()
	pass # replace with function body


func _on_downloader_request_completed(result, response_code, headers, body):
	var i = load("res://trophy_icon" + str(trophy_no) + ".jpg")
	get_node("trophies").add_item(trophies_list[trophy_no]["title"] + " - " + trophies_list[trophy_no]["description"], i)
	trophy_no += 1
	if trophy_no >= trophies_list.size():
		return
	get_node("downloader").set_download_file("res://trophy_icon" + str(trophy_no) + ".jpg")
	get_node("downloader").request(trophies_list[trophy_no]["image_url"].replace("https", "http"))
	pass # replace with function body
