package jekyllize.utils;

import haxe.io.Bytes;

import jekyllize.utils.ByteUtils;

class BitStreamReader
{
	static public var END_OF_STRING:String = "\n";

	public var bytes(default,null):Bytes;
	public var bytesReceived(default,null):Int;
	private var _currentBitIndex:Int = 0;

	public function new(bytes:Bytes, bytesReceived:Int)
	{
		this.bytes = bytes;
		this.bytesReceived = bytesReceived;

		/*
		if (this.bytes != null && this.bytesReceived > 0 && this.bytesReceived < 11)
		{
			trace("bsr: " + ByteUtils.getByteString(this.bytes, this.bytesReceived));
		}
		*/
	}

	// call this when you want to see the next number of bits but you don't want to advance the internal counter.
	public function peek(count:Int):Int
	{
		var previousBitIndex:Int = _currentBitIndex;
		var output:Int = readBits(count);

		// return index so we don't lose our place
		_currentBitIndex = previousBitIndex;
		return output;
	}

	// read a range of bits without tampering with internal counter.
	public function readBitsFrom(start:Int, count:Int):Int
	{
		var previousBitIndex:Int = _currentBitIndex;
		_currentBitIndex = start;
		var output:Int = readBits(count);

		// return index so we don't lose our place
		_currentBitIndex = previousBitIndex;
		return output;
	}

	public function readBit():Int
	{
		var byteIndex:Int = Math.floor(_currentBitIndex / 8);
		var bitIndex:Int = _currentBitIndex - (byteIndex * 8);

		var byte:Int = bytes.get(byteIndex);
		var output:Int = byte & (1 << bitIndex);
		_currentBitIndex++;
		return output > 0 ? 1 : 0;
	}

	public function readBits(count:Int):Int
	{
		var output:Int = 0;
		for (i in 0 ... count) {
			var bit:Int = readBit();
			output |= (bit << i);
		}
		return output;
	}

	// for now, string MUST end with \n
	public function readString(maxBytes:Int):String
	{
		var output:Bytes = Bytes.alloc(maxBytes);
		for (i in 0 ... maxBytes) 
		{
			output.set(i, readBits(8));
		}
		// data clean up.  figure out where the message ends and only return the good bits.
		var output:Array<String> = output.toString().split(BitStreamReader.END_OF_STRING);
		output.pop();
		return output.join(BitStreamReader.END_OF_STRING);
	}

	public function complete():Bool
	{
		return _currentBitIndex >= bytesReceived * 8;
	}

	public function bitsLeftToRead():Int
	{
		return Math.floor(Math.max(0,(bytesReceived * 8) - _currentBitIndex));
	}
}