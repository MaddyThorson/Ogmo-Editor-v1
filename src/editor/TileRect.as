package editor 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class TileRect extends Tile
	{
		
		public function TileRect(tileset:Tileset, tilePos:Point, x:int, y:int, width:int, height:int) 
		{
			collideRect = new Rectangle;
			collideRect.width = width;
			collideRect.height = height;
			
			super(tileset, tilePos, x, y);
		}
		
		override public function set tileset(to:Tileset):void
		{
			_tileset 		= to;
			tilesetName		= _tileset.tilesetName;
			
			if (_tileset == null)
				throw (new Error("Tile created from non-existent Tileset!"));
				
			tileRect.width 	= _tileset.tileWidth;
			tileRect.height = _tileset.tileHeight;
			
			collideRect.width = Math.floor(collideRect.width / _tileset.tileWidth) * _tileset.tileWidth;
			collideRect.height = Math.floor(collideRect.height / _tileset.tileHeight) * _tileset.tileHeight;
			
			updateBitmapData();
		}
		
		override protected function updateBitmapData():void
		{
			if (bitmapData == null || bitmapData.width != collideRect.width || bitmapData.height != collideRect.height)
				bitmapData = new BitmapData(collideRect.width, collideRect.height);
				
			for (Ogmo.point.x = 0; Ogmo.point.x < bitmapData.width; Ogmo.point.x += tileset.tileWidth)
				for (Ogmo.point.y = 0; Ogmo.point.y < bitmapData.height; Ogmo.point.y += tileset.tileHeight)
					bitmapData.copyPixels(tileset.bitmapData, tileRect, Ogmo.point);
					
			for (var i:int = 0; i < bitmapData.width; i++)
			{
				bitmapData.setPixel(i, 0, 0x000000);
				bitmapData.setPixel(i, 1, 0xFFFFFF);
				bitmapData.setPixel(i, bitmapData.height - 1, 0x000000);
				bitmapData.setPixel(i, bitmapData.height - 2, 0xFFFFFF);
			}
			
			for (var j:int = 1; j < bitmapData.height - 1; j++)
			{
				bitmapData.setPixel(0, j, 0x000000);
				bitmapData.setPixel(1, j, 0xFFFFFF);
				bitmapData.setPixel(bitmapData.width - 1, j, 0x000000);
				bitmapData.setPixel(bitmapData.width - 2, j, 0xFFFFFF);
			}
		}
		
		override public function getXML(includeTileset:Boolean, exportTileSize:Boolean, exportTileIDs:Boolean):XML
		{
			var ret:XML = <tile />;
			ret.setName("rect");
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
			ret.@w		= collideRect.width;
			ret.@h		= collideRect.height;
			if (includeTileset && exportTileSize)
			{
				ret.@tw		= tileRect.width;
				ret.@th		= tileRect.height;
			}
			return ret;
		}
		
	}

}