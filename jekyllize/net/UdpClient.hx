package jekyllize.net;

import hxudp.UdpSocket;
import jekyllize.net.UdpConnection;

class UdpClient extends UdpConnection
{
	public function new()
	{
		super();
	}

	public function connect(url:String, port:Int):Void
	{
		_udpSocket = new UdpSocket();
		_udpSocket.create();
      	_udpSocket.connect(url, port);
      	_udpSocket.setNonBlocking(true);
	}

	public function disconnect():Void
	{
		_udpSocket.close();
		_udpSocket = null;
	}
}