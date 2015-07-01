package jekyllize.net.packets;

import haxe.ds.IntMap;
import haxe.ds.ObjectMap;
import haxe.io.Bytes;
import jekyllize.net.events.INetEvent;
import jekyllize.net.PlayerConnection;
import jekyllize.utils.BitStreamWriter;

class NetPacketTransmissionStatus
{
	public var sendAttempts:Int = 0;
	public var lastSendAttemptTime:Float = 0.0;
	public var acknowledgementReceived:Bool = false;

	public function new ()
	{
		
	}
}

class NetPacket
{
	static public function createAndSend(networkEvents:Array<INetEvent>, connections:Array<PlayerConnection>):NetPacket
	{
		var netPacket:NetPacket = new NetPacket(networkEvents, connections);
		netPacket.send();
		return netPacket;
	}

	static public function traceTraffic(messageHeader:String, packetIndex:Int, senderId:Int, networkEvents:Array<INetEvent>):Void
	{
		var debugOutput:String = "[" + messageHeader + "] packetIndex: " + packetIndex + ", senderId: " + senderId + ", # of events: " + networkEvents.length;
		for (eventIndex in 0 ... networkEvents.length) 
		{
			var netEvent:INetEvent = networkEvents[eventIndex];
			debugOutput = debugOutput + "\n\t" + eventIndex + ") " + netEvent.debugString();
		}
		//jekyllize.utils.Logger.logCallstack(debugOutput);
		trace("\n" + debugOutput + "\n");
	}

	private static var s_packets:IntMap<NetPacket>;
	private static var s_packetIndex:Int = 0;

	public var packetIndex(default,null):Int;
	
	private var _bytes:Bytes;
	private var _connections:Array<PlayerConnection>;
	private var _sendAttempts:Int = 0;
	private var _maxSendAttempts:Int = 999999999;// start at ridiculously high number
	private var _networkEvents:Array<INetEvent>;
	private var _requiresAcknowledgement:Bool = false;
	private var _requiresRepackingBeforeResend:Bool = false;
	private var _timeAlive:Float = 0.0;
	private var _transmissionStatuses:ObjectMap<PlayerConnection, NetPacketTransmissionStatus>;

	public function new (networkEvents:Array<INetEvent>, connections:Array<PlayerConnection>)
	{
		// generate new packet index for this guy
		s_packetIndex = (s_packetIndex + 1) % 255;
		packetIndex = s_packetIndex;

		// save the packet to our list so we can look the packet up by id later
		if (s_packets == null) s_packets = new IntMap<NetPacket>();
		s_packets.set(packetIndex, this);

		// save our network events for various calculations.
		_networkEvents = networkEvents;

		// set some options based on the data (Net events!) that we're sending.
		for (eventIndex in 0 ... _networkEvents.length) 
		{
			var netEvent:INetEvent = _networkEvents[eventIndex];

			_maxSendAttempts = (netEvent.maxSendAttempts < _maxSendAttempts ? netEvent.maxSendAttempts : _maxSendAttempts);
			if (!_requiresAcknowledgement) _requiresAcknowledgement = netEvent.requiresAcknowledgement;
			if (!_requiresRepackingBeforeResend) _requiresRepackingBeforeResend = netEvent.requiresRepackingBeforeResend;
		}

		trace("made net packet. send attempts: " + _maxSendAttempts + ", req ack: " + _requiresAcknowledgement + " repack: " + _requiresRepackingBeforeResend);

		// save ref to all our destination connections.
		_connections = connections;

		// build mapping of transmission status objects
		if (_requiresAcknowledgement)
		{
			_transmissionStatuses = new Map<PlayerConnection, NetPacketTransmissionStatus>();
			for (i in 0 ... connections.length) 
			{
				_transmissionStatuses.set(connections[i], new NetPacketTransmissionStatus());
			}
		}
	}

	public function acknowledgementReceivedFrom(connection:PlayerConnection):Void
	{
		var transmissionStatus:NetPacketTransmissionStatus = _transmissionStatuses.get(connection);
		transmissionStatus.acknowledgementReceived = true;

		if (isComplete())
		{
			// handle complete??
		}
	}

	// packs up all our relevant data withe the BitStreamWriter and saves that result to _bytes
	private function writeBytes():Void
	{
		// write header bits - packet index and player id.
		var bitStreamWriter:BitStreamWriter = new BitStreamWriter();
		bitStreamWriter.writeBits(packetIndex, 8);
		bitStreamWriter.writeBits(NetPlayerData.localPlayerId, 3);

		// write event bits.
		for (eventIndex in 0 ... _networkEvents.length) 
		{
			var netEvent:INetEvent = _networkEvents[eventIndex];
			netEvent.pack(bitStreamWriter, packetIndex);
		}

		_bytes = bitStreamWriter.getBytes();
	}

	/**
	 * preferred usage is to use NetPacket.createAndSend, then call update() every frame on the instance until it's complete.
	 */
	public function send():Void
	{
		for (connectionIndex in 0 ... _connections.length) 
		{
			var connection:PlayerConnection = _connections[connectionIndex];

			if (_requiresAcknowledgement)
			{
				var transmissionStatus:NetPacketTransmissionStatus = _transmissionStatuses.get(connection);

				// don't resend the packet if it already got there!!
				if (!transmissionStatus.acknowledgementReceived)
				{
					// try auto resending
					// if we've never sent before or if enough time has passed
					if (transmissionStatus.sendAttempts == 0 || _timeAlive - transmissionStatus.lastSendAttemptTime >= 0.5)
					{
						transmissionStatus.lastSendAttemptTime = _timeAlive;
						transmissionStatus.sendAttempts++;
					}
				}
			}

			if (_requiresRepackingBeforeResend || _bytes == null)
			{
				writeBytes();
			}

			// debug
			NetPacket.traceTraffic("NET SEND", packetIndex, NetPlayerData.localPlayerId, _networkEvents);

			connection.sendBytes(_bytes);
			
		}

		_sendAttempts++;
	}

	public function isComplete():Bool
	{
		// if the data requires acknowledgement, return false if any of our receivers have not acknowledged it yet.
		if (_requiresAcknowledgement)
		{
			for (playerConnection in _transmissionStatuses.keys()) 
			{
				var status:NetPacketTransmissionStatus = _transmissionStatuses.get(playerConnection);
				if (!status.acknowledgementReceived || status.sendAttempts < _maxSendAttempts) 
				{
					return false;
				}
			}
		}
		// if no acknowledgetment is required, only return false if the packet hasn't been sent yet.
		else
		{
			return _sendAttempts > 0;
		}
		return true;
	}

	// call this function every frame. this class will manage sending the data when appropriate.
	public function update(elapsedTime:Float):Void
	{
		_timeAlive += elapsedTime;

		if (!isComplete())
		{
			//send();// turn off for now.
		}
	}
}