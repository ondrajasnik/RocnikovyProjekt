extends Node

const SUPABASE_URL = "https://wougleacphcpkpwljfxs.supabase.co"
const SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndvdWdsZWFjcGhjcGtwd2xqZnhzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQxODU2MjMsImV4cCI6MjA3OTc2MTYyM30.21H5rbR6Rns4bXmGGoAM9Hv1x4CA3ZXlUf93Uw3OUaI"

var http_request: HTTPRequest

func _ready():
    http_request = HTTPRequest.new()
    add_child(http_request)
    http_request.request_completed.connect(_on_request_completed)

# Přidej/aktualizuj skóre (uloží jen pokud je lepší než předchozí)
func submit_score(player_name: String, score: int, kills: int, time: float):
    check_existing_score(player_name, score, kills, time)

func check_existing_score(player_name: String, new_score: int, kills: int, time: float):
    var headers = [
        "apikey: " + SUPABASE_KEY,
        "Authorization: Bearer " + SUPABASE_KEY
    ]
    
    var url = SUPABASE_URL + "/rest/v1/leaderboard?player_name=eq." + player_name.uri_encode()
    
    print("Checking existing score for: ", player_name)
    
    var check_request = HTTPRequest.new()
    add_child(check_request)
    check_request.request_completed.connect(
        func(result, response_code, headers_resp, body):
            _on_check_completed(result, response_code, headers_resp, body, player_name, new_score, kills, time)
            check_request.queue_free()
    )
    check_request.request(url, headers, HTTPClient.METHOD_GET)

func _on_check_completed(result, response_code, headers_resp, body, player_name: String, new_score: int, kills: int, time: float):
    if response_code == 200:
        var json = JSON.new()
        json.parse(body.get_string_from_utf8())
        var data = json.data
        
        if data.size() > 0:
            var existing_score = data[0]["score"]
            
            if new_score > existing_score:
                print("New score is better! Updating...")
                _update_score(player_name, new_score, kills, time)
            else:
                print("Existing score is better. Not updating.")
                emit_signal("score_submitted", false, "Existing score is higher")
        else:
            print("Player not found. Creating new entry...")
            _insert_score(player_name, new_score, kills, time)
    else:
        print("Error checking existing score: ", response_code)

func _insert_score(player_name: String, score: int, kills: int, time: float):
    var data = {
        "player_name": player_name,
        "score": score,
        "kills": kills,
        "time": time
    }
    
    var headers = [
        "Content-Type: application/json",
        "apikey: " + SUPABASE_KEY,
        "Authorization: Bearer " + SUPABASE_KEY,
        "Prefer: return=representation"
    ]
    
    var url = SUPABASE_URL + "/rest/v1/leaderboard"
    
    print("Inserting new score...")
    http_request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(data))

func _update_score(player_name: String, score: int, kills: int, time: float):
    var data = {
        "score": score,
        "kills": kills,
        "time": time
    }
    
    var headers = [
        "Content-Type: application/json",
        "apikey: " + SUPABASE_KEY,
        "Authorization: Bearer " + SUPABASE_KEY,
        "Prefer: return=representation"
    ]
    
    var url = SUPABASE_URL + "/rest/v1/leaderboard?player_name=eq." + player_name.uri_encode()
    
    print("Updating existing score...")
    http_request.request(url, headers, HTTPClient.METHOD_PATCH, JSON.stringify(data))

func fetch_leaderboard():
    var headers = [
        "apikey: " + SUPABASE_KEY,
        "Authorization: Bearer " + SUPABASE_KEY
    ]
    
    var url = SUPABASE_URL + "/rest/v1/leaderboard?select=*&order=score.desc&limit=10"
    
    print("Fetching leaderboard...")
    http_request.request(url, headers, HTTPClient.METHOD_GET)

func _on_request_completed(result, response_code, headers, body):
    if response_code == 200 or response_code == 201:
        var json = JSON.new()
        json.parse(body.get_string_from_utf8())
        var data = json.data
        
        print("Supabase response: ", data)
        
        if typeof(data) == TYPE_ARRAY and data.size() > 0:
            emit_signal("leaderboard_loaded", data)
        else:
            emit_signal("score_submitted", true, "Score saved!")
    else:
        print("Supabase error: ", response_code)
        print("Response: ", body.get_string_from_utf8())
        emit_signal("score_submitted", false, "Error: " + str(response_code))

signal leaderboard_loaded(data)
signal score_submitted(success: bool, message: String)