package editor 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Tile
	{
		
		//The collision rectangle of the tile on the stage
		public var collideRect:Rectangle;
		
		//The rectangle of the tile bitmap pixels on the tileset
		public var tileRect:Rectangle;	
		
		//The tileset this tile is from
		protected var _tileset:Tileset;
		
		protected var tilesetName:String;
		public var bitmapData:BitmapData;
		
		public function Tile(tileset:Tileset, tilePos:Point, x:int, y:int) 
		{
			tileRect = new Rectangle(tilePos.x, tilePos.y);
			
			if (collideRect == null)
				collideRect = new Rectangle;
			
			this.tileset = tileset;
			collideRect.x = x;
			collideRect.y = y;
		}
		
		public function set x(to:int):void
		{
			collideRect.x = to;
		}
		
		public function set y(to:int):void
		{
			collideRect.y = to;
		}
		
		public function get x():int
		{
			return collideRect.x;
		}
		
		public function get y():int
		{
			return collideRect.y;
		}
		
		public function set tileset(to:Tileset):void
		{
			_tileset 		= to;
			tilesetName		= _tileset.tilesetName;
			
			if (_tileset == null)
				throw (new Error("Tile created from non-existent Tileset!"));
				
			tileRect.width 	= _tileset.tileWidth;
			tileRect.height = _tileset.tileHeight;
			
			collideRect.width = tileRect.width;
			collideRect.height = tileRect.height;
			
			updateBitmapData();
		}
		
		public function get tileset():Tileset
		{
			return _tileset;
		}
		
		public function collidesWithTile(tile:Tile):Boolean
		{
			return collideRect.intersects(tile.collideRect);
		}
		
		public function collidesWithRectangle(rect:Rectangle):Boolean
		{
			return collideRect.intersects(rect);
		}
		
		public function collidesWithPoint(point:Point):Boolean
		{
			return collideRect.containsPoint(point);
		}
		
		public function collidesWithPos(x:Number, y:Number):Boolean
		{
			return collideRect.containsPoint(new Point(x, y));
		}
		
		public function getXML(includeTileset:Boolean, exportTileSize:Boolean, exportTileIDs:Boolean):XML
		{
			var ret:XML = <tile />;
			ret.setName("tile");
			if (includeTileset)
				ret.@set 	= tilesetName;
				
			if (exportTileIDs)
			{
				ret.@id		= tileset.getTileIDFromPosition(tileRect.x, tileRect.y);
			}
			else
			{
				ret.@tx 	= tileRect.x;
				ret.@ty 	= tileRect.y;
			}
			
			ret.@x		= collideRect.x;
			ret.@y		= collideRect.y;
			if (includeTileset && exportTileSize)
			{
				ret.@tw		= tileRect.width;
				ret.@th		= tileRect.height;
			}
			return ret;
		}
		
		public function deepCopy():Tile
		{
			return new Tile(tileset, new Point(tileRect.x, tileRect.y), x, y);
		}
		
		protected function updateBitmapData():void
		{
			if (bitmapData == null || bitmapData.width != tileset.tileWidth || bitmapData.height != tileset.tileHeight)
				bitmapData = new BitmapData(tileset.tileWidth, tileset.tileHeight);
				
			Ogmo.point.x = 0;
			Ogmo.point.y = 0;
			bitmapData.copyPixels(tileset.bitmapData, tileRect, Ogmo.point);
		}
		
	}

}