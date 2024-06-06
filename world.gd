extends Node3D

@export var player_scene : PackedScene

var peer = ENetMultiplayerPeer.new()

var addr = LineEdit.new()
var host = Button.new()
var connect_btn = Button.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	addr.placeholder_text = "0.0.0.0"
	
	host.text = "Host game"
	host.pressed.connect(self._host_game)
	host.position.y += 35
	
	connect_btn.text = "Connect"
	connect_btn.pressed.connect(self._connect)
	connect_btn.position.y += 70
	
	add_child(host)
	add_child(addr)
	add_child(connect_btn)

func _connect():
	peer.create_client(addr.text, 25565)
	multiplayer.multiplayer_peer = peer
	
	remove_child(addr)
	remove_child(host)
	remove_child(connect_btn)

func _host_game():
	peer.create_server(25565, 10)
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(self._on_player_connected)
	multiplayer.peer_disconnected.connect(self._on_player_disconnected)
	
	_on_player_connected()
	
	remove_child(addr)
	remove_child(host)
	remove_child(connect_btn)

func _on_player_connected(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)
	
func _on_player_disconnected(id):
	rpc("_del_player", id)

@rpc("any_peer", "call_local")
func _del_player(id):
	get_node(str(id)).queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
