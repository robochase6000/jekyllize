package jekyllize.utils;

import haxe.io.Bytes;
import jekyllize.utils.BitStreamReader;
import jekyllize.utils.ByteUtils;

class BitStreamWriter
{
	private var _bytes:Array<UInt>;
	private var _currentBitIndex:Int = 0;

	public function new()
	{
		_bytes = new Array<UInt>();
	}

	public function writeBit(b:Int):Void
	{
		if (_currentBitIndex == 0)
		{
			_bytes.push(0);
		}

		var bit:Int = b > 0 ? 1 : 0;
		var current:UInt = _bytes[_bytes.length-1];
		current |= (bit << _currentBitIndex);
		_bytes[_bytes.length-1] = current;

		_currentBitIndex++;
		if (_currentBitIndex >= 8)
		{
			_currentBitIndex = 0;
		}
	}

	public function writeByte(byte:Int):Void
	{
		writeBits(byte, 8);
	}

	public function writeBits(n:UInt, bitCount:Int):Void
	{		
		if (bitCount > 32) bitCount = 32;
		if (bitCount < 0) bitCount = 0;

		for (i in 0 ... bitCount) 
		{
			writeBit(n & (1 << i));
		}
	}

	public function writeString(s:String, maxBytes:Int):Void
	{
		// the bitstream reader class relies on \n being at the end of your string to determine where in the buffer to stop reading.
		// so add it!!
		s = s + BitStreamReader.END_OF_STRING;

		var stringBytes:Bytes = Bytes.ofString(s);

		for (i in 0 ... maxBytes) 
		{
			var byte:Int = 0;
			if (i < stringBytes.length)
			{
				byte = stringBytes.get(i);
			}
			writeByte(byte);
		}
	}
	
	public function toString():String
	{
		var output:String = "";
		for (i in 0 ... _bytes.length) 
		{
			output = ByteUtils.getBitString(_bytes[i], 8, 8) + " " + output;
		}
		return output;
	}

	public function getBytes():Bytes
	{
		var output:Bytes = Bytes.alloc(_bytes.length);
		for (i in 0 ... output.length) {
			output.set(i, _bytes[i]);
		}
		return output;
	}
}