package editor.ui 
{
	import editor.events.OgmoEvent;
	import editor.TileLayer;
	import editor.TilesetRectangle;
	import editor.tools.tile.ToolTileSpecialRect;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class TileRectangleWindow extends Window
	{
		[Embed(source = '../../../assets/no_tile.png')]
		static private const ImgNoTile:Class;
		
		private const SIZE:int 			= 130;
		private const TILE_OFFSET:int 	= 10;
		private const TILE_SIZE:int 	= 32;
		private const TILE_SEP:int 		= (SIZE - (TILE_OFFSET * 2) - (TILE_SIZE * 3)) / 2;
		
		private var _rect:TilesetRectangle;
		private var tiles:Vector.<Sprite>;
		
		public function TileRectangleWindow() 
		{
			super(SIZE, SIZE, "Tile Rectangle");
			
			x = 780 - SIZE;
			y = 20 + Window.BAR_HEIGHT;
			
			//Init the tile sprites
			tiles = new Vector.<Sprite>;
			for (var i:int = 0; i < 9; i++)
			{
				tiles[i] = new Sprite;
				//tiles[i].width = tiles[i].height = TILE_SIZE;
				
				tiles[i].x = TILE_OFFSET + (i % 3) * (TILE_SIZE + TILE_SEP);
				tiles[i].y = TILE_OFFSET + Math.floor(i / 3) * (TILE_SIZE + TILE_SEP);
				
				ui.addChild(tiles[i]);
			}
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			stage.addEventListener(OgmoEvent.SELECT_LAYER, chooseVisibility);
			stage.addEventListener(OgmoEvent.SELECT_TOOL, chooseVisibility);
			
			//Init the tile sprites
			for (var i:int = 0; i < 9; i++)
			{
				tiles[i].addEventListener(MouseEvent.CLICK, clickTile);
				tiles[i].addEventListener(MouseEvent.RIGHT_CLICK, rightClickTile);
			}
			
			active = false;
		}
		
		private function destroy(e:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			stage.removeEventListener(OgmoEvent.SELECT_LAYER, chooseVisibility);
			stage.removeEventListener(OgmoEvent.SELECT_TOOL, chooseVisibility);
			for (var i:int = 0; i < 9; i++)
			{
				tiles[i].removeEventListener(MouseEvent.CLICK, clickTile);
				tiles[i].removeEventListener(MouseEvent.RIGHT_CLICK, rightClickTile);
			}
		}
		
		private function clickTile(e:MouseEvent):void
		{
			var tile:int = -1;
			for (var i:int = 0; i < ui.numChildren; i++)
			{
				if (e.target == ui.getChildAt(i))
				{
					tile = i;
					break;
				}
			}
			
			var pt:Point = Ogmo.level.selTilePoint;
			setTile(tile, Ogmo.level.selTileset.getTileIDFromPosition(pt.x, pt.y));
		}
		
		private function rightClickTile(e:MouseEvent):void
		{
			var tile:int = -1;
			for (var i:int = 0; i < ui.numChildren; i++)
			{
				if (e.target == ui.getChildAt(i))
				{
					tile = i;
					break;
				}
			}
				
			setTile(tile, -1);
		}
		
		public function get rectangle():TilesetRectangle
		{
			return _rect;
		}
		
		public function set rectangle(to:TilesetRectangle):void
		{
			_rect = to;
				
			//Add the new images
			for (var i:int = 0; i < 9; i++)
				setImage(i, _rect.tiles[i]);
		}
		
		public function setTile(tile:uint, id:int):void
		{
			_rect.tiles[tile] = id;
			setImage(tile, id);
		}
		
		private function setImage(tile:uint, id:int):void
		{
			//Remove old image
			if (tiles[tile].numChildren == 1)
				tiles[tile].removeChildAt(0);
				
			//Add the new one
			if (id == -1)
			{
				tiles[tile].addChild(new ImgNoTile);
			}
			else
			{
				var pt:Point = Ogmo.level.selTileset.getTilePositionFromID(id);
				
				var bd:BitmapData = new BitmapData(Ogmo.level.selTileset.tileWidth, Ogmo.level.selTileset.tileHeight);
				bd.copyPixels(Ogmo.level.selTileset.bitmapData, new Rectangle(pt.x, pt.y, bd.width, bd.height), new Point);
				
				var b:Bitmap = new Bitmap(bd);
				b.scaleX = TILE_SIZE / bd.width;
				b.scaleY = TILE_SIZE / bd.height;
				tiles[tile].addChild(b);
			}
		}
		
		private function chooseVisibility(e:OgmoEvent):void
		{
			active = (Ogmo.level.currentLayer is TileLayer && Ogmo.level.currentLayer.tool is ToolTileSpecialRect);
		}
		
	}

}