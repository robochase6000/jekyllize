package jekyllize.net.data;

interface IPlayerData
{
	public var id(default,null):Int;
	public var serverUrl(default,null):String;
	public var serverPort(default,null):Int;
	public var team(default,null):Team;
}