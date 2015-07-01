package jekyllize.net.data;

import haxe.ds.IntMap;

import jekyllize.net.data.NetTeamData;

class NetPlayerData
{
	static private var s_playerDatas:IntMap<NetPlayerData> = new IntMap<NetPlayerData>();

	static public function clearStaticData():Void
	{
		s_playerDatas = null;
	}

	static public function create(id:Int, url:String, port:Int, team:NetTeamData):NetPlayerData
	{
		var output:NetPlayerData = null;

		// this function is called a ton. grab the cached version if it exists.
		if (s_playerDatas.exists(id))
		{
			output = s_playerDatas.get(id);
		}
		else
		{
			output = new NetPlayerData();
		}

		output.id = id;
		output.serverUrl = url;
		output.serverPort = port;

		// todo :: quick ghetto team assignment.
		output.team = team;

		s_playerDatas.set(id, output);

		trace("created NetPlayerData for player " +  output.id);

		return output;
	}

	static public function getById(id:Int):NetPlayerData
	{
		if (s_playerDatas.exists(id)) 
		{
			return s_playerDatas.get(id);
		}
		return null;
	}

	public var id(default,null):Int;
	public var serverUrl(default,null):String;
	public var serverPort(default,null):Int;
	public var team(default,null):NetTeamData;

	public function new()
	{

	}
}