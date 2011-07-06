package editor 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.System;
	
	public class Tilemap extends Sprite
	{
		private var bitmap:Bitmap;
		private var _tilemapWidth:uint;
		private var _tilemapHeight:uint;		
		private var tiles:Vector.<Tile>;	
		private var _onlyTileset:Tileset;
		
		public function Tilemap(width:uint, height:uint, onlyTileset:Tileset) 
		{
			_tilemapWidth 	= width;
			_tilemapHeight 	= height;
			_onlyTileset	= onlyTileset;
			
			bitmap = new Bitmap(new BitmapData(width, height));
			bitmap.bitmapData.fillRect(new Rectangle(0, 0, width, height), 0x00000000);
			addChild(bitmap);
			
			tiles = new Vector.<Tile>;
		}
		
		/* ============================ UTILITIES ============================ */
		
		//Deletes all tiles
		public function clear():void
		{
			tiles.splice(0, tiles.length);
			bitmap.bitmapData.fillRect(new Rectangle(0, 0, _tilemapWidth, _tilemapHeight), 0x00FFFFFF);
			
			System.gc();
		}
		
		//Resizes the tilemap, removing all out-of-bounds tiles
		public function resize(width:uint, height:uint):void
		{
			var bd:BitmapData = new BitmapData(width, height);
			bd.fillRect(new Rectangle(0, 0, width, height), 0x00FFFFFF);
			bd.copyPixels(bitmap.bitmapData, new Rectangle(0, 0, Math.min(_tilemapWidth, width), Math.min(_tilemapHeight, height)), new Point);
			bitmap.bitmapData = bd;
			
			_tilemapWidth 	= width;
			_tilemapHeight 	= height;
			
			//Remove all out-of-bounds tiles
			for each (var t:Tile in tiles)
			{
				if (t.x >= width || t.y >= height)
					removeTile(t);
			}
		}
		
		/* ============================ ADDING ============================ */
		
		//Add a tile to the map
		public function addTile(tile:Tile):Tile
		{
			//Add it to the vector
			tiles.push(tile);
			
			//Remove those that are colliding with it
			removeCollidingWithTile(tile);
			
			//Add it to the bitmap
			Ogmo.point.x = tile.x;
			Ogmo.point.y = tile.y;
			Ogmo.rect.x = Ogmo.rect.y = 0;
			Ogmo.rect.width = tile.bitmapData.width;
			Ogmo.rect.height = tile.bitmapData.height;
			bitmap.bitmapData.copyPixels(tile.bitmapData, Ogmo.rect, Ogmo.point);
			
			return tile;
		}
		
		/* Just adds a tile without checking for collisions or setting its position. Used in undo/redo. */
		public function addTileQuick(tile:Tile):void
		{
			tiles.push(tile);

			Ogmo.point.x = tile.x;
			Ogmo.point.y = tile.y;
			Ogmo.rect.x = Ogmo.rect.y = 0;
			Ogmo.rect.width = tile.bitmapData.width;
			Ogmo.rect.height = tile.bitmapData.height;
			bitmap.bitmapData.copyPixels(tile.bitmapData,Ogmo.rect, Ogmo.point);
		}
		
		/* ============================ REMOVING ============================ */
		
		/* Remove a single tile from the tilemap */
		public function removeTile(tile:Tile):void
		{
			//remove it from the vector
			tiles.splice(tiles.indexOf(tile), 1);
			
			//remove it from the bitmap
			Ogmo.rect.x = tile.x;
			Ogmo.rect.y = tile.y;
			Ogmo.rect.width = tile.bitmapData.width;
			Ogmo.rect.height = tile.bitmapData.height;
			bitmap.bitmapData.fillRect(Ogmo.rect, 0x00000000);
		}
		
		/* Remove a vector of tiles from the tilemap */
		public function removeTiles(toRemove:Vector.<Tile>):void
		{
			for (var i:int = 0; i < toRemove.length; i++)
			{
				//Note: this code is repeated from the function above to avoid the function call overhead
				
				//remove it from the vector
				tiles.splice(tiles.indexOf(toRemove[i]), 1);
				
				//remove it from the bitmap
				Ogmo.rect.x = toRemove[i].x;
				Ogmo.rect.y = toRemove[i].y;
				Ogmo.rect.width = toRemove[i].bitmapData.width;
				Ogmo.rect.height = toRemove[i].bitmapData.height;
				bitmap.bitmapData.fillRect(Ogmo.rect, 0x00000000);
			}
		}
		
		//Remove all tiles colliding with the given tile
		public function removeCollidingWithTile(tile:Tile):void
		{
			var v:Vector.<Tile> = new Vector.<Tile>;
			var t:Tile;
			
			for each (t in tiles)
				if (t.collidesWithTile(tile) && t != tile)
					v.push(t);
					
			for each (t in v)
				removeTile(t);
		}
		
		/* ============================ GETS / SETS ============================ */
		
		//Switch the tileset of every tile
		public function set onlyTileset(ts:Tileset):void
		{
			var v:Vector.<Tile> = new Vector.<Tile>;
			var t:Tile;
			
			for each (t in tiles)
				v.push(t);
				
			clear();
			
			for each (t in v)
			{
				t.tileset = ts;
				addTile(t);
			}
			
			_onlyTileset = ts;
		}
		
		//Get the current only tileset
		public function get onlyTileset():Tileset
		{
			return _onlyTileset;
		}
		
		//Returns whether the tilemap is empty or not
		public function get empty():Boolean
		{
			return (tiles.length == 0);
		}
		
		//Returns the amount of tiles in the tilemap
		public function get amount():uint
		{
			return tiles.length;
		}
		
		//Returns an XML representation of the tilemap
		public function getXML(layerXML:XML, exportTileSize:Boolean, exportTileIDs:Boolean):void
		{
			for each (var t:Tile in tiles)
				layerXML.appendChild(t.getXML(_onlyTileset == null, exportTileSize, exportTileIDs));
		}
		
		//Builds the tilemap from an XML representation
		public function setXML(to:XML, exportTileIDs:Boolean):void
		{
			clear();
			
			var o:XML;
			var p:Point;
			if (_onlyTileset)
			{
				for each (o in to.tile)
				{
					if (exportTileIDs)
						p = _onlyTileset.getTilePositionFromID(o.@id);
					else
						p = new Point(o.@tx, o.@ty);
					addTile(new Tile(_onlyTileset, p, o.@x, o.@y));
				}
				for each (o in to.rect)
				{
					if (exportTileIDs)
						p = _onlyTileset.getTilePositionFromID(o.@id);
					else
						p = new Point(o.@tx, o.@ty);
					addTile(new TileRect(_onlyTileset, p, o.@x, o.@y, o.@w, o.@h));
				}
			}
			else
			{
				var t:Tileset;
				for each (o in to.tile)
				{
					t = Ogmo.project.getTileset(o.@set);
					if (!t)
						throw new Error("Tileset not defined: \"" + o.@set + "\"");
						
					if (exportTileIDs)
						p = t.getTilePositionFromID(o.@id);
					else
						p = new Point(o.@tx, o.@ty);
					addTile(new Tile(t, p, o.@x, o.@y));
				}
				for each (o in to.rect)
				{
					t = Ogmo.project.getTileset(o.@set);
					if (!t)
						throw new Error("Tileset not defined: \"" + o.@set + "\"");
						
					if (exportTileIDs)
						p = t.getTilePositionFromID(o.@id);
					else
						p = new Point(o.@tx, o.@ty);
					addTile(new TileRect(t, p, o.@x, o.@y, o.@w, o.@h));
				}
			}
		}
		
		/* Returns the tile which can be found at the given point (or null if none exists) */
		public function getTileAtPosition(x:int, y:int):Tile
		{
			for each (var t:Tile in tiles)
			{
				if (t.collidesWithPos(x, y))
					return t;
			}
			return null;
		}
		
		/* Returns a vector of all the tiles that collide with the given rectangle */
		public function getTilesAtRectangle(rect:Rectangle):Vector.<Tile>
		{
			var vec:Vector.<Tile> = new Vector.<Tile>;
			for each (var t:Tile in tiles)
			{
				if (t.collidesWithRectangle(rect))
					vec.push(t);
			}
			return vec;
		}
		
	}
	
}