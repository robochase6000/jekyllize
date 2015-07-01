package jekyllize.net.events;

import jekyllize.entities.Player;
import jekyllize.net.data.NetPlayerData;
import jekyllize.net.events.INetEvent;
import jekyllize.net.NetworkManager;

import jekyllize.utils.BitStreamReader;
import jekyllize.utils.BitStreamWriter;
import jekyllize.utils.EventDispatcherLite;

/**
 * event for when a bullet is created.
 */
class PlayerSyncEvent extends NetEvent
{
	override private function get_netEventType():NetEventType
	{
		return NetEventType.PLAYER_SYNC;
	}

	override private function get_requiresAcknowledgement():Bool { return false; }
	override private function get_requiresRepackingBeforeResend():Bool { return false; }
	override private function get_ignoreOldPackets():Bool { return true; }

	public var player(default, null):Player;

	private var _playerId:Int = -1;
	private var _x:Int = -1;
	private var _y:Int = -1;
	private var _velocityX:Int = -1;
	private var _velocityY:Int = -1;
	private var _aim:Int = -1;

	public function new(data:Dynamic)
	{
		super(data);
	}

	override public function init(data:Dynamic):Void
	{
		super.init(data);
		if (data != null)
		{
			player = cast(data, Player);
		}
	}

	override public function asDynamic():Dynamic
	{
		return super.asDynamic();
	}

	override public function pack(bsw:BitStreamWriter, packetIndex:Int):Void
	{
		super.pack(bsw, packetIndex);

		var playerId:Int = 0;
		var x:Int = 0;
		var y:Int = 0;
		var velocityX:Int = 0;
		var velocityY:Int = 0;
		var aim:Int = 0;

		if (player != null)
		{
			playerId = player.data.id;
			x = Math.floor(player.x);
			y = Math.floor(player.y);
			velocityX = Math.floor(player.velocity.x);
			velocityY = Math.floor(player.velocity.x);
			aim = Math.floor(player.aim);
		}

		bsw.writeBits(playerId, 3);// 3 bits, 8 players max
		bsw.writeBits(x, 24);
		bsw.writeBits(y, 24);
		//bsw.writeBits(velocityX, 24);
		//bsw.writeBits(velocityY, 24);
		bsw.writeBits(aim, 9);// 9 bits - 0-511 for aim.

		//trace("PlayerSyncEvent pack _playerId: " + _playerId + " pos: " + _x + "," + _y + ", aim: " + _aim);
	}

	override public function unpack(bsr:BitStreamReader):Void
	{
		super.unpack(bsr);

		_playerId = bsr.readBits(3);
		_x = bsr.readBits(24);
		_y = bsr.readBits(24);
		//_velocityX = bsr.readBits(24);
		//_velocityY = bsr.readBits(24);
		_aim = bsr.readBits(9);
	}

	override public function execute(senderId:Int, packetIndex:Int, siblingNetworkEvents:Array<INetEvent>):Void
	{
		//trace("PlayerSyncEvent.execute() netEventType: " + netEventType + ", _playerId: " + _playerId + " pos: " + _x + "," + _y + ", aim: " + _aim);
		
		if (NetworkManager.instance.localPlayerId != _playerId)
		{
			var playerData:NetPlayerData = NetPlayerData.getById(_playerId);
			EventDispatcherLite.instance.dispatchEvent(new EventLite("player_sync", {playerData:playerData, position:{x:_x, y:_y}, velocity:{x:_velocityX, y:_velocityY}, weaponFireIndex:-1}));
		}

		super.execute(senderId, packetIndex, siblingNetworkEvents);
	}	
}