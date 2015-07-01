package jekyllize.utils;

import haxe.io.Bytes;

class ByteUtils
{
	static public function getBitString(n:UInt, maxBits:Int, separatorCount:Int):String
	{
		var output:String = "";
		for (i in 0 ... maxBits) {
			var result:Bool = (n & (1 << i)) > 0;

			if (i % separatorCount == 0) output = " " + output;
			output = (result ? "1" : "0") + output;
		}
		return output;
	}

	static public function getByteString(b:Bytes, maxBytes:Int):String
	{
		var output:String = "";

		for (i in 0 ... maxBytes) 
		{
			var n:Int = b.get(i);
			var n:Int = b.get(i);
			output = getBitString(n, 8, 8) + " " + output;
		}
		return output;
	}

	
}