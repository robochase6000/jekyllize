package jekyllize.net;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import hxudp.UdpSocket;
import jekyllize.net.UdpConnection;
import jekyllize.utils.BitStreamReader;

/**
 * tests running as a client.
 */
class UdpServer extends UdpConnection
{
	private var _buffer:Bytes;

	private var _port:Int;
	public var port(get,null):Int;
	private function get_port():Int { return _port; }

	public function new()
	{
		super();
	}

	public function start(port:Int):Void
	{
		if (_buffer == null)
		{
			_buffer = Bytes.alloc(8192);
		}

		_udpSocket = new UdpSocket();
      	_udpSocket.create();
      	_udpSocket.bind(port);
      	_udpSocket.setNonBlocking(true);
	}

	public function stop():Void
	{
		_udpSocket.close();
		_udpSocket = null;
	}

	public function poll():String
	{
		var bytesReceived:Int = _udpSocket.receive(_buffer);
		if (bytesReceived > 0)
		{
			var input:BytesInput = new BytesInput(_buffer, 0, bytesReceived);
			//trace("got data: " + _buffer.toString());
			return _buffer.toString();
		}
		return null;
	}

	public function getBytes():BitStreamReader
	{
		var bytesReceived:Int = _udpSocket.receive(_buffer);
		if (bytesReceived > 0)
		{
			//trace("received " + bytesReceived + " bytes");
			return new BitStreamReader(_buffer, bytesReceived);
		}
		return null;
	}
}