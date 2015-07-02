package jekyllize.net;

import haxe.ds.IntMap;
import jekyllize.net.data.NetPlayerData;
import jekyllize.net.data.NetTeamData;
import jekyllize.net.events.INetEvent;
import jekyllize.net.events.PlayerConnectEvent;
import jekyllize.net.PlayerConnection;
import jekyllize.net.PlayerServer;
import jekyllize.utils.EventDispatcherLite;

/**
 * tests running as a server.
 */
class NetworkManager
{
	static private var s_instance:NetworkManager;
	static public var instance(get,null):NetworkManager;
	static function get_instance():NetworkManager
	{
		if (s_instance == null)
		{
			s_instance = new NetworkManager();
		}
		return s_instance;
	}

	public var localPlayerData(default,null):NetPlayerData;
	public var localPlayerId(get,null):Int;
	private function get_localPlayerId():Int { return localPlayerData.id; }

	private var m_server:PlayerServer;
	private var m_connections:Array<PlayerConnection>;
	private var m_connectionsMap:IntMap<PlayerConnection>;// todo :: remove m_connections when i figure out how to iterate a stringmap..need wifi right now.

	public function new()
	{
		m_connections = new Array<PlayerConnection>();
		m_connectionsMap = new IntMap<PlayerConnection>();
	}

	public function update(elapsed:Float):Void
	{
		m_server.update(elapsed);

		for (i in 0 ... m_connections.length) 
		{
			m_connections[i].update(elapsed);
		}
	}

	public function initServer(asPlayerId:Int, port:Int):Void
	{
		trace("---- INIT SERVER asPlayerId: " + asPlayerId);
		localPlayerData = NetPlayerData.create(asPlayerId, "localhost", port, NetTeamData.getById(NetPlayerData.getTeamIdFor(asPlayerId)));

		m_server = new PlayerServer(localPlayerId);
      	m_server.start(port);

      	// just broadcast that the local player just connected.
      	// this will add the player to the game.
      	EventDispatcherLite.instance.dispatchEvent(new EventLite("player_connected", localPlayerData));
	}

	public function killServer():Void
	{
		m_server.stop();
		m_server = null;
	}

	/**
	 * packs up player data and sends it to all connected clients.
	 * @param	Player	the relevant Player object that will be sent.  position and aim will be sent automatically
	 * @param	Array<INetEvent>	list of net events to pass along.  this could be things like 'bullet spawned', 'bullet destroyed', 'health changed', etc
	 */
	public function sendEvents(networkEvents:Array<INetEvent>):Void
	{
		if (m_connections != null && m_connections.length > 0 && networkEvents.length > 0)
		{
			for (i in 0 ... m_connections.length) 
			{
				m_connections[i].queueEvents(networkEvents);
			}
		}
	}

	public function sendEventTo(connection:PlayerConnection, evt:INetEvent):Void
	{
		connection.queueEvent(evt);
	}

	public function sendEventToPlayerId(playerId:Int, evt:INetEvent):Void
	{
		trace("send event " + evt.netEventType + " to player id: " + playerId);
		sendEventTo(m_connectionsMap.get(playerId), evt);		
	}

	public function sendPacketReceivedEventTo(playerId:Int, packetIndex:Int):Void
	{
		m_connectionsMap.get(playerId).queuePacketReceivedEvent(packetIndex);
	}

	public function connectTo(playerId:Int, url:String, port:Int):Void
	{
		trace("connect to playerId: " + playerId + " url:[" + url + "] port:[" + port + "]");

		if (connectedTo(playerId))
		{
			trace("trying to conenct to player id " + playerId + ", but already connected ");
			return;
		}

		var playerConnection:PlayerConnection = new PlayerConnection(playerId);

		// track the connection before we do anything to it.
		m_connections.push(playerConnection);
 		m_connectionsMap.set(playerId, playerConnection);

 		// establish connection
      	playerConnection.connect(url, port);

      	sendEventTo(playerConnection, new PlayerConnectEvent
      	({
      		playerId:localPlayerData.id,
      		serverUrl:localPlayerData.serverUrl,
 			serverPort:localPlayerData.serverPort
      	}));
	}

	public function connectedTo(playerId:Int):Bool
	{
		return m_connectionsMap.exists(playerId);
	}
}