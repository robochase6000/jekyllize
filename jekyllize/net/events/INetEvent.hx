package jekyllize.net.events;

import jekyllize.utils.BitStreamReader;
import jekyllize.utils.BitStreamWriter;

interface INetEvent
{
	public var ignoreOldPackets(get,null):Bool;
	public var maxSendAttempts(get,null):Int;
	public var netEventType(get,null):NetEventType;
	public var requiresAcknowledgement(get,null):Bool;
	public var requiresRepackingBeforeResend(get,null):Bool;
	public var sendEventIndex(get,null):Bool;
	public var sendOriginalPacketIndex(get,null):Bool;
	
	function asDynamic():Dynamic;

	function pack(bsw:BitStreamWriter, packetIndex:Int):Void;
	function unpack(bsr:BitStreamReader):Void;

	function execute(senderId:Int, packetIndex:Int, siblingNetworkEvents:Array<INetEvent>):Void;

	function debugString():String;
}

enum NetEventType
{
	INVALID;
	PLAYER_CONNECT;	
	PLAYER_DISCONNECT;	
	PLAYER_SYNC;	
	BULLET_CREATED;	
	BULLET_DESTROYED;	
	PACKET_RECEIVED;
}