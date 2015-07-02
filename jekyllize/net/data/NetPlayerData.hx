package jekyllize.net.data;

import haxe.ds.IntMap;

import jekyllize.net.data.NetTeamData;

class NetPlayerData
{
	static public var localPlayerData(default,null):NetPlayerData;
	static public var localPlayerId(get,null):Int;
	static private function get_localPlayerId():Int { return localPlayerData.id; }

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

	// quick ghetto thing for getting a team id. presumably team ids would come from the matchmaking server someday.
	static public function getTeamIdFor(playerId:Int):Int
	{
		return playerId % 2;
	}

	public var id(default,null):Int;
	public var serverUrl(default,null):String;
	public var serverPort(default,null):Int;
	public var team(default,null):NetTeamData;

	public function new()
	{

	}
}