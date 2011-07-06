package editor 
{
	import flash.geom.Rectangle;

	public class Utils
	{
		
		static public function within( min:Number, num:Number, max:Number ):Number
		{
			return Math.min( Math.max( min, num ), max );
		}
		
		static public function isWithin( min:Number, num:Number, max:Number ):Boolean
		{
			return (num >= min && num <= max);
		}
		
		static public function traceArray( array:Array ):String
		{
			var ret:String = "[ ";
			var arr:Array = new Array;
			for ( var i:int = 0; i < array.length; i++ )
			{
				if (array[ i ] is Array)
					arr.push( traceArray( array[ i ] ) );
				else if (array[ i ] is Object)
					arr.push( array[ i ].toString() );
				else
					arr.push( array[ i ] );
			}
			ret = ret + arr.join( ", " ) + " ]";
			return ret;
		}
		
		static public function degToRad( degrees:Number ):Number
		{
			return degrees / -180 * Math.PI;
		}
		
		static public function radToDeg( radians:Number ):Number
		{
			return radians * -180 / Math.PI;
		}
		
		static public function isColor24(str:String):Boolean
		{
			if (str.length == 6)
			{
				str = "0x" + str;
			}
			else if (str.length == 7 && str.charAt() == "#")
			{
				str = "0x" + str.substr( 1 );
			}
			else if (str.length != 8)
			{
				return false;
			}
			
			if (!str.match( "0x[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]" ))
				return false;
			
			return true;
		}
		
		static public function getColor24(str:String):uint
		{
			if (str.length == 6)
			{
				str = "0x" + str;
			}
			else if (str.length == 7 && str.charAt() == "#")
			{
				str = "0x" + str.substr( 1 );
			}
			else if (str.length != 8)
			{
				throw new Error("Passed string is not a 24-bit color!");
			}
			
			if (!str.match( "0x[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]" ))
				throw new Error("Passed string is not a 24-bit color!");
			
			return (uint)(str);
		}
		
		static public function isColor32(str:String):Boolean
		{
			if (str.length == 8)
			{
				str = "0x" + str;
			}
			else if (str.length == 9 && str.charAt() == "#")
			{
				str = "0x" + str.substr( 1 );
			}
			else if (str.length != 10)
			{
				return false;
			}
			
			if (!str.match( "0x[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]" ))
				return false;
			
			return true;
		}
		
		static public function getColor32(str:String):uint
		{
			if (str.length == 8)
			{
				str = "0x" + str;
			}
			else if (str.length == 9 && str.charAt() == "#")
			{
				str = "0x" + str.substr( 1 );
			}
			else if (str.length != 10)
			{
				throw new Error("Passed string is not a 32-bit color!");
			}
			
			if (!str.match( "0x[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]" ))
				throw new Error("Passed string is not a 32-bit color!");
			
			return (uint)(str);
		}
		
		/* Sets a rectangle to be the correct size for a given fill area */
		static public function setRectForFill(rect:Rectangle, startX:int, startY:int, endX:int, endY:int, gridSize:int, cellX:int = -1, cellY:int = -1):void
		{
			var temp:int;
			if (cellX == -1)
				cellX = gridSize;
			if (cellY == -1)
				cellY = gridSize;
			
			if (startX <= endX)
			{
				rect.x = startX;
				rect.width = Math.floor((endX - startX + cellX) / cellX) * cellX;
			}
			else
			{
				rect.x = endX;
				rect.width = Math.floor((startX - endX + gridSize) / gridSize) * gridSize;
				
				temp = rect.width % cellX;
				rect.x += temp;
				rect.width -= temp;
			}
			
			if (startY <= endY)
			{
				rect.y = startY;
				rect.height = Math.floor((endY - startY + cellY) / cellY) * cellY;
			}
			else
			{
				rect.y = endY;
				rect.height = Math.floor((startY - endY + gridSize) / gridSize) * gridSize;
				
				temp = rect.height % cellY;
				rect.y += temp;
				rect.height -= temp;
			}
			
			boundRect(rect, Ogmo.level.levelWidth, Ogmo.level.levelHeight);
		}
		
		static public function boundRect(rect:Rectangle, width:int, height:int):void
		{
			if (rect.x < 0)
			{
				rect.width += rect.x;
				rect.x = 0;
			}
			
			if (rect.y < 0)
			{
				rect.height += rect.y;
				rect.y = 0;
			}
			
			if (rect.x + rect.width > width)
			{
				rect.width = width - rect.x;
			}
			
			if (rect.y + rect.height > height)
			{
				rect.height = height - rect.y;
			}
		}
		
	}

}