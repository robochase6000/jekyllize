package jekyllize.net;

import haxe.io.Bytes;
import hxudp.UdpSocket;

class UdpConnection
{
	private var _udpSocket:UdpSocket;

	public function new()
	{

	}

	public function activated():Bool
	{
		return _udpSocket != null;
	}

	public function sendBytes(buffer:Bytes):Void
	{
		if (activated())
		{
			//trace("sending " + buffer.length + " bytes");
			_udpSocket.send(buffer);
		}
	}

	public function sendString(message:String):Void
	{
		if (activated())
		{
			sendBytes(Bytes.ofString(message));
		}
	}
}