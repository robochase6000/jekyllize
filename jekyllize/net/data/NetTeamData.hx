package jekyllize.net.data;

import haxe.ds.IntMap;

class NetTeamData
{
	/**
	 * static vars to help grab teams by id, etc.
	 */
	static private var s_teams:IntMap<NetTeamData>;
	static public function getById(id:Int):NetTeamData
	{
		if (s_teams != null && s_teams.exists(id))
		{
			return s_teams.get(id);
		}
		return new NetTeamData(id);
	}
	static public function clearStaticData():Void
	{
		s_teams = null;
	}

	public var id(default,null):Int;
	private var _players:Array<NetPlayerData>;

	public function new (id:Int)
	{
		this.id = id;

		if (s_teams == null)
		{
			s_teams = new IntMap<NetTeamData>();
		}
		s_teams.set(this.id, this);
	}

	public function addPlayer(playerData:NetPlayerData):Void
	{
		if (_players == null)
		{
			_players = new Array<NetPlayerData>();
		}
		_players.push(playerData);
	}
}