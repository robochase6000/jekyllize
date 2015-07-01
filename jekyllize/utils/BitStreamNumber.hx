package jekyllize.utils;

import haxe.ds.IntMap;

import jekyllize.utils.ByteUtils;

// helper that lets you figure out how many bits a number takes. hides and caches some repetitious and verbose math.
class BitStreamNumber
{
	private var m_maxSize:Int = 256;
	private var m_maxSizeInBits:Int = 8;
	private var m_value:Int = 0;

	public function new(Value:Int, MaxSize:Int)
	{
		this.maxSize = MaxSize;
		this.value = Value;
	}

	/**
	 * Max Size
	 */
	public var maxSize(get,set):Int;
	private function get_maxSize():Int
	{
		return m_maxSize;
	}
	private function set_maxSize(value:Int):Int
	{
		m_maxSize = value;
		m_maxSizeInBits = Math.floor(Math.log(m_maxSize) / Math.log(2));
		return value;
	}

	/**
	 * Max Size In Bits
	 */
	public var maxSizeInBits(get,set):Int;
	private function get_maxSizeInBits():Int
	{
		return m_maxSizeInBits;
	}
	private function set_maxSizeInBits(value:Int):Int
	{
		m_maxSizeInBits = value;
		m_maxSize = Math.floor(Math.pow(2, value));
		return value;
	}

	/**
	 * Current Value
	 */
	public var value(get,set):Int;
	private function get_value():Int
	{
		return m_value;
	}
	private function set_value(v:Int):Int
	{
		m_value = v % maxSize;
		return m_value;
	}
}