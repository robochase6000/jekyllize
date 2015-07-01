package jekyllize.net;

import jekyllize.net.events.INetEvent;
import jekyllize.net.events.PacketReceivedEvent;
import jekyllize.net.packets.NetPacket;
import jekyllize.net.UdpClient;

class PlayerConnection extends UdpClient
{
	private var m_playerId:Int = -1;
	public var playerId(get,null):Int;
	private function get_playerId():Int { return m_playerId; }

	private var _eventQueue:Array<INetEvent>;
	private var _activePackets:Array<NetPacket>;
	private var _packetsRequiringAcknowledgement:Array<Int>;
	
	public function new(playerId:Int)
	{
		m_playerId = playerId;
		_eventQueue = new Array<INetEvent>();
		_activePackets = new Array<NetPacket>();
		_packetsRequiringAcknowledgement = new Array<Int>();
		super();
	}

	public function queueEvent(evt:INetEvent):Void
	{
		_eventQueue.push(evt);
	}

	public function queueEvents(networkEvents:Array<INetEvent>):Void
	{
		for (i in 0 ... networkEvents.length) 
		{
			queueEvent(networkEvents[i]);
		}
	}

	public function queuePacketReceivedEvent(packetIndex:Int):Void
	{
		if (_packetsRequiringAcknowledgement.indexOf(packetIndex) == -1)
		{
			_packetsRequiringAcknowledgement.push(packetIndex);
		}
	}

	public function update(elapsedTime:Float):Void
	{
		// update active packets
		for (i in 0 ... _activePackets.length) 
		{
			var packet:NetPacket = _activePackets[i];
			packet.update(elapsedTime);
			if (packet.isComplete())
			{
				_activePackets.splice(i, 1);
			}
		}

		// a chance to clean up our events before we send them out.
		consolidateQueue();

		// any events in the queue should be converted into a NetPacket and sent out.
		processQueue();
	}

	private function consolidateQueue():Void
	{
		// make one packet received event that references multiple packets at once.
		if (_packetsRequiringAcknowledgement.length > 0)
		{
			var indeces:Array<Int> = _packetsRequiringAcknowledgement.slice(0, 4);// just take 4 from the list every time to keep the data slim.
			for (i in 0 ... indeces.length) {
				_packetsRequiringAcknowledgement.shift();
			}

			var packetReceivedEvent:PacketReceivedEvent = new PacketReceivedEvent
			({
				packetIndeces:indeces
			});
			_eventQueue.push(packetReceivedEvent);
		}
	}

	// converts queued events into a packet that will continue to be monitored until it's done being sent.
	private function processQueue():Void
	{
		if (_eventQueue.length > 0)
		{
			var packet:NetPacket = new NetPacket(_eventQueue, [this]);
			packet.send();
			if (!packet.isComplete())
			{
				_activePackets.push(packet);
			}
			_eventQueue = new Array<INetEvent>();
		}
	}
}