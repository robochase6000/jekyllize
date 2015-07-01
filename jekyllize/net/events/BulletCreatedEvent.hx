package jekyllize.net.events;

import jekyllize.entities.Bullet;
import jekyllize.net.events.INetEvent;

import jekyllize.utils.BitStreamReader;
import jekyllize.utils.BitStreamWriter;

/**
 * event for when a bullet is created.
 */
class BulletCreatedEvent extends NetEvent
{
	override private function get_netEventType():NetEventType
	{
		return NetEventType.BULLET_CREATED;
	}

	override private function get_requiresAcknowledgement():Bool { return true; }
	override private function get_requiresRepackingBeforeResend():Bool { return true; }
	override private function get_ignoreOldPackets():Bool { return false; }

	public var bullet(default,null):Bullet;

	public function new(data:Dynamic)
	{
		super(data);
	}

	override public function init(data:Dynamic):Void
	{
		super.init(data);
		if (data != null)
		{
			bullet = cast(data, Bullet);
		}
	}

	override public function asDynamic():Dynamic
	{
		var output:Dynamic = super.asDynamic();
		output.bulletId = bullet.id;
		return output;
	}

	override public function pack(bsw:BitStreamWriter, packetIndex:Int):Void
	{
		super.pack(bsw, packetIndex);
	}

	override public function unpack(bsr:BitStreamReader):Void
	{
		super.unpack(bsr);
	}

	override public function execute(senderId:Int, packetIndex:Int, siblingNetworkEvents:Array<INetEvent>):Void
	{
		super.execute(senderId, packetIndex, siblingNetworkEvents);
	}
}