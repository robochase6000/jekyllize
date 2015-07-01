package jekyllize.utils;

import haxe.ds.StringMap;

class EventDispatcherLite
{
	// static instance if you want a global event dispatcher out of the box.
	static private var s_instance:EventDispatcherLite;
	static public var instance(get,null):EventDispatcherLite;
	static function get_instance():EventDispatcherLite
	{
		if (s_instance == null)
		{
			s_instance = new EventDispatcherLite();
		}
		return s_instance;
	}

	private var m_eventMap:StringMap<Array<Dynamic->Void>>;

	public function new()
	{

	}

	public function addEventListener(type:String, callback:Dynamic->Void):Void
	{
		if (m_eventMap == null) 
		{
			m_eventMap = new StringMap<Array<Dynamic->Void>>();
		}

		if (!m_eventMap.exists(type))
		{
			var list:Array<Dynamic->Void> = new Array<Dynamic->Void>();
			list.push(callback);
			m_eventMap.set(type, list);
		}
		else
		{
			var list:Array<Dynamic->Void> = m_eventMap.get(type);
			for (i in 0 ... list.length) 
			{
				if (Reflect.compareMethods(list[i], callback)) return;
			}
			list.push(callback);
		}
	}

	public function removeEventListener(type:String, callback:Dynamic->Void):Void
	{
		if (m_eventMap != null && m_eventMap.exists(type))
		{
			var list:Array<Dynamic->Void> = m_eventMap.get(type);
			for (i in 0 ... list.length) 
			{
				if (Reflect.compareMethods(list[i], callback))
				{
					list.splice(i, 1);
					break;
				}
			}
			if (list.length == 0)
			{
				m_eventMap.remove(type);
			}

			if (m_eventMap.iterator().hasNext())
			{
				m_eventMap = null;
			}
		}
	}

	public function hasListener(type:String):Bool
	{
		if (m_eventMap != null)
		{
			return m_eventMap.exists(type);
		}
		return false;
	}

	public function dispatchEvent(event:EventLite):Void
	{
		if (m_eventMap != null && event != null && m_eventMap.exists(event.type))
		{
			var list:Array<Dynamic->Void> = m_eventMap.get(event.type);
			for (i in 0 ... list.length) 
			{
				list[i](event);
			}
		}
	}
}

class EventLite
{
	private var m_type:String;
	public var type(get,null):String;
	private function get_type():String { return m_type; }

	private var m_data:Dynamic;
	public var data(get,null):Dynamic;
	private function get_data():Dynamic { return m_data; }

	public function new(eventType:String, data:Dynamic)
	{
		m_type = eventType;
		m_data = data;
	}
}