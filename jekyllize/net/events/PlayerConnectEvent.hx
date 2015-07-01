package jekyllize.net.events;

import jekyllize.entities.Player;
import jekyllize.net.data.NetPlayerData;
import jekyllize.net.data.NetTeamData;
import jekyllize.net.events.INetEvent;

import jekyllize.utils.BitStreamReader;
import jekyllize.utils.BitStreamWriter;
import jekyllize.utils.EventDispatcherLite;

/**
 * event for when a bullet is created.
 */
class PlayerConnectEvent extends NetEvent
{
	override private function get_netEventType():NetEventType
	{
		return NetEventType.PLAYER_CONNECT;
	}

	override private function get_requiresAcknowledgement():Bool { return true; }
	override private function get_requiresRepackingBeforeResend():Bool { return false; }
	override private function get_ignoreOldPackets():Bool { return false; }

	override public function debugString():String
	{
		return "[" + netEventType + " playerId:" + playerId + " serverUrl:" + serverUrl + " serverPort:" + serverPort + "]";
	}

	public var playerId(default, null):Int;
	public var serverUrl(default, null):String;
	public var serverPort(default, null):Int;

	public function new(data:Dynamic)
	{
		playerId = 0;
		serverUrl = "";
		serverPort = 0;

		super(data);
	}

	override public function init(data:Dynamic):Void
	{
		super.init(data);
		if (data != null)
		{
			playerId = data.playerId;
			serverUrl = data.serverUrl;
			serverPort = data.serverPort;
		}
	}

	override public function asDynamic():Dynamic
	{
		return super.asDynamic();
	}

	override public function pack(bsw:BitStreamWriter, packetIndex:Int):Void
	{
		super.pack(bsw, packetIndex);

		bsw.writeBits(playerId, 3);
		bsw.writeString(serverUrl, 25);
		bsw.writeBits(serverPort, 16);
	}

	override public function unpack(bsr:BitStreamReader):Void
	{
		super.unpack(bsr);
		playerId = bsr.readBits(3);
		serverUrl = bsr.readString(25);
		serverPort = bsr.readBits(16);
	}

	override public function execute(senderId:Int, packetIndex:Int, siblingNetworkEvents:Array<INetEvent>):Void
	{
		trace("PlayerConnectEvent.execute() netEventType: " + netEventType + " playerId: " + playerId + " senderId: " + senderId + " packetIndex: " + packetIndex);
		
		var playerData:NetPlayerData = NetPlayerData.create(playerId, serverUrl, serverPort, NetTeamData.getById(playerId % 2));
		/*
		// todo :: figure out what to do about NetworkManager
		if (playerData.id != NetPlayerData.localPlayerId)
		{
			EventDispatcherLite.instance.dispatchEvent(new EventLite("player_connected", playerData));

			if (!NetworkManager.instance.connectedTo(playerData.id))
			{
				NetworkManager.instance.connectTo(playerData.id, playerData.serverUrl, playerData.serverPort);
			}
		}
		*/

		super.execute(senderId, packetIndex, siblingNetworkEvents);
	}
}