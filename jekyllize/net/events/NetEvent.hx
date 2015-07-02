package jekyllize.net.events;

import jekyllize.net.events.INetEvent;

import jekyllize.utils.BitStreamNumber;
import jekyllize.utils.BitStreamReader;
import jekyllize.utils.BitStreamWriter;



/**
 * base class for all INetEvents, if we want common behaviour.
 */
class NetEvent implements INetEvent
{
	static public function create(bsr:BitStreamReader):Array<INetEvent>
	{
		var output:Array<INetEvent> = new Array<INetEvent>();

		while(bsr.bitsLeftToRead() >= NetEvent.boilerPlateSizeInBits())// keep going if we have at least enough data to figure out the boilerplate event stuff
		{
			var netEventTypeRaw:Int = bsr.peek(5);
			var netEventType:NetEventType = Type.createEnumIndex(NetEventType, netEventTypeRaw);

			//trace("create, netEventTypeRaw: " + netEventTypeRaw + ", netEventType: " + netEventType);

			var evt:INetEvent = null;

			switch(netEventType)
			{
				case NetEventType.PLAYER_CONNECT:
					evt = new PlayerConnectEvent(null);
				case NetEventType.PLAYER_DISCONNECT:
					evt = new PlayerDisconnectEvent(null);
				case NetEventType.PLAYER_SYNC:
					// todo :: factory pattern?
					//evt = new PlayerSyncEvent(null);
				case NetEventType.BULLET_CREATED:
					// todo :: factory pattern?
					//evt = new BulletCreatedEvent(null);
				case NetEventType.BULLET_DESTROYED:
					//output.push(PlayerSyncEvent.create(bsr));
				case NetEventType.INVALID:
					//

				// "system" type stuff
				case NetEventType.PACKET_RECEIVED:
					evt = new PacketReceivedEvent(null);
			}

			if (evt != null)
			{
				evt.unpack(bsr);
				output.push(evt);
			}
			else{
				//trace("evt is null");
				break;
			}
		}
		
		return output;
	}

	static public function boilerPlateSizeInBits():Int
	{
		var output:Int = 0;

		output += 5;// event type is 5 bits.
		//output += 5;// add another boiler plate piece of data here.

		return output;
	}

	public function debugString():String
	{
		return "[" + netEventType + "]";
	}

	public var netEventType(get,null):NetEventType;
	private function get_netEventType():NetEventType { return NetEventType.INVALID; }

	public var requiresAcknowledgement(get,null):Bool;
	private function get_requiresAcknowledgement():Bool { return false; }

	public var requiresRepackingBeforeResend(get,null):Bool;
	private function get_requiresRepackingBeforeResend():Bool { return false; }

	public var ignoreOldPackets(get,null):Bool;
	private function get_ignoreOldPackets():Bool { return true; }

	public var maxSendAttempts(get,null):Int;
	private function get_maxSendAttempts():Int { return 3; }

	// event index for checking packet sequences.
	static private var s_eventIndex:Int = 0;

	private var m_eventIndex:BitStreamNumber;
	private var m_eventIndexMaxSize:Int = 256;
	private function setEventIndex(index:Int):Void
	{
		m_eventIndex = new BitStreamNumber(index, m_eventIndexMaxSize);
	}
	public var sendEventIndex(get,null):Bool;
	private function get_sendEventIndex():Bool { return false; }

	// some events that are resent require the original packet index they were sent in, so you can gauge a sense of elapsed time.
	public var sendOriginalPacketIndex(get,null):Bool;
	private function get_sendOriginalPacketIndex():Bool { return false; }
	private var m_originalPacketIndex:Int = -1;

	public function new(data:Dynamic)
	{
		init(data);
	}

	public function init(data:Dynamic):Void
	{
		setEventIndex(s_eventIndex);
	}

	public function asDynamic():Dynamic
	{
		return {};
	}

	public function pack(bsw:BitStreamWriter, packetIndex:Int):Void
	{
		// pack boilerplate stuff every net event has in common.
		// override this and pack yourstuff after calling super.pack
		bsw.writeBits(Type.enumIndex(netEventType), 5);

		if (sendEventIndex)
		{
			bsw.writeBits(m_eventIndex.value, m_eventIndex.maxSizeInBits);
		}

		if (sendOriginalPacketIndex)
		{
			if (m_originalPacketIndex == -1)
			{
				m_originalPacketIndex = packetIndex;
			}
			bsw.writeBits(m_originalPacketIndex, 8);// todo :: get this 8 from somewhere..
		}
	}

	public function unpack(bsr:BitStreamReader):Void
	{
		//jekyllize.utils.Logger.logCallstack("unpack " + debugString);

		// unpack boilerplate stuff.
		var netEventTypeRaw:Int = bsr.readBits(5);
		var netEventType:NetEventType = Type.createEnumIndex(NetEventType, netEventTypeRaw);

		if (sendEventIndex)
		{
			m_eventIndex.value = bsr.readBits(m_eventIndex.maxSizeInBits);
		}

		if (sendOriginalPacketIndex)
		{
			m_originalPacketIndex = bsr.readBits(8);// todo :: get this 8 from somewhere..
		}
	}

	public function execute(senderId:Int, packetIndex:Int, siblingNetworkEvents:Array<INetEvent>):Void
	{
		trace("NetEvent.execute() netEventType: " + netEventType + " senderId: " + senderId + " packetIndex: " + packetIndex);

		/*
		// todo :: figure out what to do about NetworkManager

		// if we just ran this event and it requires acknowledgement, we need to queue up an acknowledgement event for the sender.
		if (requiresAcknowledgement)
		{
			NetworkManager.instance.sendPacketReceivedEventTo(senderId, packetIndex);

			// note to self :: this line was commented out in the original code.
			//NetworkManager.instance.sendEventToPlayerId(senderId, new PacketReceivedEvent({playerId:senderId, packetIndex:packetIndex}));
		}
		*/
	}
}