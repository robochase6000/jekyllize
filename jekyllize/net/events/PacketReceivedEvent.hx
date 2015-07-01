package jekyllize.net.events;

import jekyllize.net.events.INetEvent;
import jekyllize.utils.BitStreamReader;
import jekyllize.utils.BitStreamWriter;

/**
 * event for when a bullet is created.
 */
class PacketReceivedEvent extends NetEvent
{
	override private function get_netEventType():NetEventType
	{
		return NetEventType.PACKET_RECEIVED;
	}

	override private function get_requiresAcknowledgement():Bool { return false; }
	override private function get_requiresRepackingBeforeResend():Bool { return false; }
	override private function get_ignoreOldPackets():Bool { return true; }

	override public function debugString():String
	{
		return "[" + netEventType + " packetIndeces:" + packetIndeces + "]";
	}

	public var packetIndeces:Array<Int>;

	public function new(data:Dynamic)
	{
		super(data);
	}

	override public function init(data:Dynamic):Void
	{
		super.init(data);
		if (data != null)
		{
			packetIndeces = data.packetIndeces;
		}
	}

	override public function asDynamic():Dynamic
	{
		return super.asDynamic();
	}

	override public function pack(bsw:BitStreamWriter, packetIndex:Int):Void
	{
		super.pack(bsw, packetIndex);

		bsw.writeBits(packetIndeces.length, 3);
		for (i in 0 ... packetIndeces.length) 
		{
			bsw.writeBits(packetIndeces[i], 8);
		}
	}

	override public function unpack(bsr:BitStreamReader):Void
	{
		super.unpack(bsr);

		packetIndeces = new Array<Int>();// todo :: optimize

		var packetIndecesCount:Int = bsr.readBits(3);
		for (i in 0 ... packetIndecesCount) 
		{
			packetIndeces.push(bsr.readBits(8));
		}
	}

	override public function execute(senderId:Int, packetIndex:Int, siblingNetworkEvents:Array<INetEvent>):Void
	{
		super.execute(senderId, packetIndex, siblingNetworkEvents);
		
		// look up NetPacket and update its status.
	}	
}