package jekyllize.net.events;

import jekyllize.net.events.INetEvent;
import jekyllize.utils.BitStreamReader;
import jekyllize.utils.BitStreamWriter;

/**
 * event for when a bullet is created.
 */
class PlayerDisconnectEvent extends NetEvent
{
	override private function get_netEventType():NetEventType
	{
		return NetEventType.PLAYER_DISCONNECT;
	}

	override private function get_requiresAcknowledgement():Bool { return true; }
	override private function get_requiresRepackingBeforeResend():Bool { return false; }
	override private function get_ignoreOldPackets():Bool { return false; }

	public function new(data:Dynamic)
	{
		super(data);
	}

	override public function init(data:Dynamic):Void
	{
		super.init(data);
	}

	override public function asDynamic():Dynamic
	{
		return super.asDynamic();
	}

	override public function pack(bsw:BitStreamWriter, packetIndex:Int):Void
	{
		super.pack(bsw, packetIndex);
	}

	override public function unpack(bsr:BitStreamReader):Void
	{
		super.unpack(bsr);
	}
}