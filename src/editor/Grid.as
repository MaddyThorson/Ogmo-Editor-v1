package editor 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class Grid extends Bitmap
	{
		private const CLEAR:uint = 0x00000000;
		
		private var content:Vector.<Vector.<Boolean>>;
		private var _gridWidth:uint;
		private var _gridHeight:uint;
		
		public var color:uint;
		public var newLine:String;
		
		public function Grid( width:uint, height:uint, color:uint, newLine:String ) 
		{
			this._gridWidth  	= width;
			this._gridHeight 	= height;
			this.color   		= color;
			this.newLine 		= newLine;
			
			clear();
		}
		
		//Sets the cell at position (x, y) to the given boolean 
		public function setCell( x:int, y:int, to:Boolean ):void
		{
			if (x >= _gridWidth || x < 0 || y >= _gridHeight || y < 0)
				return;
			
			bitmapData.setPixel32( x, y, (to)?(color):(CLEAR) );
		}
		
		//Returns the status of the cell at position (x, y)
		public function getCell( x:int, y:int ):Boolean
		{
			if (x >= _gridWidth || x < 0 || y >= _gridHeight || y < 0)
				return false;
				
			return !(bitmapData.getPixel32( x, y ) == CLEAR);
		}
		
		//Sets all cells within the given rectangle to the given boolean
		public function setCellsRect( x:int, y:int, w:int, h:int, to:Boolean ):void
		{
			for ( var ax:int = 0; ax < w; ax++ )
				for ( var ay:int = 0; ay < h; ay++ )
					setCell( x + ax, y + ay, to );
		}
		
		//Returns whether all the given cells in the given rectangle are true
		public function getCellsRect( x:int, y:int, w:int, h:int ):Boolean
		{
			for ( var ax:int = 0; ax < w; ax++ )
			{
				for ( var ay:int = 0; ay < h; ay++ )
				{
					if (!getCell( x + ax, y + ay ))
						return false;
				}		
			}
			return true;
		}
		
		//Does a flood fill on the specified cell
		public function fillCell( x:int, y:int, to:Boolean ):void
		{
			bitmapData.floodFill( x, y, (to)?(color):(CLEAR) );
		}
		
		//Sets every cell in the grid to false
		public function clear():void
		{
			bitmapData = new BitmapData( _gridWidth, _gridHeight );
			bitmapData.fillRect( new Rectangle( 0, 0, _gridWidth, _gridHeight ), CLEAR );
		}
		
		//Returns another grid with the same contents as this grid
		public function deepCopy():Grid
		{
			var copy:Grid = new Grid( width, height, color, newLine );
			
			copy.bitmapData = bitmapData.clone();
					
			return copy;
		}
		
		//Returns whether the grid is empty
		public function empty():Boolean
		{
			for ( var i:int = 0; i < _gridWidth; i++ )
			{
				for ( var j:int = 0; j < _gridHeight; j++ )
				{
					if (bitmapData.getPixel32( i, j ) != CLEAR)
						return false;
				}
			}
			return true;	
		}
		
		//Sets a new size for the grid; new cells default to false
		public function resize( width:int, height:int ):void
		{
			var old:BitmapData = bitmapData.clone();
			
			_gridWidth 	= width;
			_gridHeight	= height;
			clear();
			
			bitmapData.copyPixels( old, new Rectangle( 0, 0, Math.min( old.width, width ), Math.min( old.height, height ) ), new Point );
		}
		
		//Shifts the whole grid in this direction
		public function shift( h:int, v:int ):void
		{
			bitmapData.scroll( h, v );
		}
		
		//The width of the grid in cells
		public function get gridWidth():uint
		{
			return _gridWidth;
		}
		
		//The height of the grid in cells
		public function get gridHeight():uint
		{
			return _gridHeight;
		}
		
		//Returns a vector of Rectangles representing the grid
		public function get rectangles():Vector.<Rectangle>
		{
			var p:Point;
			
			var rects:Vector.<Rectangle> = new Vector.<Rectangle>;
			var copy:Grid = deepCopy();
			
			while( p = copy.getFirstCell() )
			{
				copy.setCell( p.x, p.y, false );
				
				var w:int = 1;
				var h:int = 1;
				
				//Check cells to the right
				while ( (p.x+w) < width && copy.getCell( p.x + w, p.y ) )
				{
					copy.setCell( p.x + w, p.y, false );	
					w++;
				}
				
				//Check cells below
				while ( (p.y+h) < height && copy.getCellsRect( p.x, p.y + h, w, 1 ) )
				{
					copy.setCellsRect( p.x, p.y + h, w, 1, false );
					h++;
				}
				
				rects.push( new Rectangle( p.x, p.y, w, h ) );
			}
			
			return rects;
		}
		
		//Takes a vector of Rectangles and rebuilds the grid according to it
		public function set rectangles( rects:Vector.<Rectangle> ):void
		{
			clear();
			for each ( var r:Rectangle in rects )
				setCellsRect( r.x, r.y, r.width, r.height, true );
		}
		
		//Returns a bitstring representing the grid
		public function get bits():String
		{
			var str:String;
			var a:String;
			var b:Array = new Array;
			for ( var i:int = 0; i < _gridHeight; i++ )
			{
				a = "";
				for ( var j:int = 0; j < _gridWidth; j++ )
				{
					if (getCell( j, i ))
						a = a + "1";
					else
						a = a + "0";
				}
				b.push( a );
			}
			str = b.join( newLine );
			return str;
		}
		
		//Takes a bitstring and rebuilds the grid according to it
		public function set bits( str:String ):void
		{
			var x:int = 0;
			var y:int = 0;
			while (str.length > 0)
			{
				if (str.indexOf( newLine ) == 0)
				{
					y++;
					x = 0;
					str = str.substr( newLine.length );
				}
				else
				{
					if (str.charAt( 0 ) != "0" && str.charAt( 0 ) != "1")
						throw new Error( "Unexpected character in grid bitstring!" );
					setCell( x, y, (str.charAt( 0 ) == "1") );
					x++;
					str = str.substr( 1 );
				}
			}
		}
		
		//Returns a Point where the first found true cell in the grid is
		public function getFirstCell():Point
		{
			for ( var i:int = 0; i < width; i++ )
			{
				for ( var j:int = 0; j < height; j++ )
				{
					if (getCell( i, j ))
						return new Point( i, j );
				}
			}	
			return null;
		}
		
		//Copies from the given bitmapdata
		public function getCopyOfBitmapData():BitmapData
		{
			var bd:BitmapData = new BitmapData( _gridWidth, _gridHeight );
			bd.copyPixels( bitmapData, new Rectangle( 0, 0, _gridWidth, _gridHeight ), new Point );
			return bd;
		}
		
	}

}