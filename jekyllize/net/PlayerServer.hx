package jekyllize.net;

import jekyllize.net.events.INetEvent;
import jekyllize.net.events.NetEvent;
import jekyllize.net.packets.NetPacket;
import jekyllize.net.UdpClient;
import jekyllize.utils.BitStreamReader;

class PlayerServer extends UdpServer
{
	private var m_playerId:Int = -1;
	public var playerId(get,null):Int;
	private function get_playerId():Int { return m_playerId; }
	
	public function new(playerId:Int)
	{
		m_playerId = playerId;
		super();
	}

	public function update(elapsed:Float):Void
	{
		pollServer();
	}

	private function pollServer():Void
	{
		if (activated())
		{
			var bsr:BitStreamReader = getBytes();
			if (bsr != null)
			{
				var packetIndex:Int = bsr.readBits(8);
				var senderId:Int = bsr.readBits(3);
				var networkEvents:Array<INetEvent> = NetEvent.create(bsr);

				// debug
				NetPacket.traceTraffic("NET RECEIVE", packetIndex, senderId, networkEvents);

				for (eventIndex in 0 ... networkEvents.length) 
				{
					var netEvent:INetEvent = networkEvents[eventIndex];
					netEvent.execute(senderId, packetIndex, networkEvents);
				}
			}
		}
	}
}