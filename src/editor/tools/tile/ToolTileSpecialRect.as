package editor.tools.tile 
{
	import editor.Layer;
	import editor.Tile;
	import editor.Tilemap;
	import editor.TileRect;
	import editor.Tileset;
	import editor.TileUndoState;
	import editor.Utils;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class ToolTileSpecialRect extends TileTool
	{
		private var placing:Boolean;
		private var drawMode:Boolean;
		private var startAt:Point = new Point;
		
		public function ToolTileSpecialRect(layer:Layer) 
		{
			super(layer);
			
			placing = false;
		}
		
		override protected function activate(e:Event):void 
		{
			super.activate(e);
			layer.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			layer.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onMouseUp);
			layer.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		override protected function deactivate(e:Event):void 
		{
			super.deactivate(e);
			layer.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			layer.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, onMouseUp);
			layer.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		private function onMouseDown(e:MouseEvent):void
		{
			var ax:int = Math.floor(e.localX / layer.gridSize) * layer.gridSize;
			var ay:int = Math.floor(e.localY / layer.gridSize) * layer.gridSize;
			
			if (ax >= 0 && ax < Ogmo.level.levelWidth && ay >= 0 && ay < Ogmo.level.levelHeight)
			{
				Ogmo.windows.mouse = false;
				drawMode = true;
				placing = true;
				startAt.x = ax;
				startAt.y = ay;
			}
		}
		
		private function onRightMouseDown(e:MouseEvent):void
		{
			var ax:int = Math.floor(e.localX / layer.gridSize) * layer.gridSize;
			var ay:int = Math.floor(e.localY / layer.gridSize) * layer.gridSize;
			
			if (ax >= 0 && ax < Ogmo.level.levelWidth && ay >= 0 && ay < Ogmo.level.levelHeight)
			{
				Ogmo.windows.mouse = false;
				drawMode = false;
				placing = true;
				startAt.x = ax;
				startAt.y = ay;
			}
		}
		
		private function onMouseUp(e:MouseEvent):void
		{
			if (placing)
			{
				Ogmo.windows.mouse = true;
				
				var ax:int = Math.floor(e.localX / layer.gridSize) * layer.gridSize;
				var ay:int = Math.floor(e.localY / layer.gridSize) * layer.gridSize;
				
				var undoState:TileUndoState = new TileUndoState;

				if (drawMode)
				{
					Utils.setRectForFill(Ogmo.rect2, startAt.x, startAt.y, ax, ay, tileLayer.gridSize, Ogmo.level.selTileset.tileWidth, Ogmo.level.selTileset.tileHeight);
					addTiles(Ogmo.rect2, undoState);
				}
				else
				{
					Utils.setRectForFill(Ogmo.rect2, startAt.x, startAt.y, ax, ay, tileLayer.gridSize);
					var vec:Vector.<Tile> = tileLayer.tilemap.getTilesAtRectangle(Ogmo.rect2);
					tileLayer.tilemap.removeTiles(vec);
					
					for each (var t:Tile in vec)
						undoState.pushRemoved(t);
				}
				
				tileLayer.storeUndo(undoState);
				
				placing = false;
				graphics.clear();
			}
		}
		
		private function onMouseMove(e:MouseEvent):void
		{
			if (placing)
			{
				var ax:int = Math.floor(e.localX / layer.gridSize) * layer.gridSize;
				var ay:int = Math.floor(e.localY / layer.gridSize) * layer.gridSize;
				
				graphics.clear();
				if (drawMode)
				{
					Utils.setRectForFill(Ogmo.rect, startAt.x, startAt.y, ax, ay, tileLayer.gridSize, Ogmo.level.selTileset.tileWidth, Ogmo.level.selTileset.tileHeight);
					graphics.beginFill(0x00FF00, 0.5);
				}
				else
				{
					Utils.setRectForFill(Ogmo.rect, startAt.x, startAt.y, ax, ay, tileLayer.gridSize);
					graphics.beginFill(0xFF0000, 0.5);
				}
				graphics.drawRect(Ogmo.rect.x, Ogmo.rect.y, Ogmo.rect.width, Ogmo.rect.height);
				graphics.endFill();
			}
		}
		
		private function addTiles(rect:Rectangle, undoState:TileUndoState):void
		{
			//Multi-tile rectangle
			var long:int = 0;
			var tall:int = 0;
			var tileset:Tileset = Ogmo.level.selTileset;
			var tileWidth:uint = Ogmo.level.selTileset.tileWidth;
			var tileHeight:uint = Ogmo.level.selTileset.tileHeight;
			var tilemap:Tilemap = tileLayer.tilemap;
			
			//Top left
			if (tileset.rectangle.tiles[0] != -1)
				undoState.pushAdded(tilemap.addTile(new Tile(tileset, tileset.getTilePositionFromID(tileset.rectangle.tiles[0]), rect.x, rect.y)));
			
			//Top right and top
			if (rect.width > tileWidth)
			{
				long++;
				if (tileset.rectangle.tiles[2] != -1)
					undoState.pushAdded(tilemap.addTile(new Tile(tileset, tileset.getTilePositionFromID(tileset.rectangle.tiles[2]), rect.x + rect.width - tileWidth, rect.y)));
				if (rect.width > tileWidth * 2)
				{
					long++;
					if (tileset.rectangle.tiles[1] != -1)
						undoState.pushAdded(tilemap.addTile(new TileRect(tileset, tileset.getTilePositionFromID(tileset.rectangle.tiles[1]), rect.x + tileWidth, rect.y, rect.width - tileWidth * 2, tileHeight)));
				}
			}
			
			//Bottom left and left
			if (rect.height > tileHeight)
			{
				tall++;
				if (tileset.rectangle.tiles[6] != -1)
					undoState.pushAdded(tilemap.addTile(new Tile(tileset, tileset.getTilePositionFromID(tileset.rectangle.tiles[6]), rect.x, rect.y + rect.height - tileHeight)));
				if (rect.height > tileHeight * 2)
				{
					tall++;
					if (tileset.rectangle.tiles[3] != -1)
						undoState.pushAdded(tilemap.addTile(new TileRect(tileset, tileset.getTilePositionFromID(tileset.rectangle.tiles[3]), rect.x, rect.y + tileHeight, tileWidth, rect.height - tileWidth * 2)));
				}
			}
			
			//Bottom right and middle
			if (long > 0 && tall > 0)
			{
				if (tileset.rectangle.tiles[8] != -1)
					undoState.pushAdded(tilemap.addTile(new Tile(tileset, tileset.getTilePositionFromID(tileset.rectangle.tiles[8]), rect.x + rect.width - tileWidth, rect.y + rect.height - tileHeight)));
				if (long > 1 && tall > 1 && tileset.rectangle.tiles[4] != -1)
					undoState.pushAdded(tilemap.addTile(new TileRect(tileset, tileset.getTilePositionFromID(tileset.rectangle.tiles[4]), rect.x + tileWidth, rect.y + tileHeight, rect.width - tileWidth * 2, rect.height - tileHeight * 2)));
			}
			
			//Right
			if (long > 0 && tall > 1 && tileset.rectangle.tiles[5] != -1)
				undoState.pushAdded(tilemap.addTile(new TileRect(tileset, tileset.getTilePositionFromID(tileset.rectangle.tiles[5]), rect.x + rect.width - tileWidth, rect.y + tileHeight, tileWidth, rect.height - tileHeight * 2)));
				
			//Bottom
			if (long > 1 && tall > 0 && tileset.rectangle.tiles[7] != -1)
				undoState.pushAdded(tilemap.addTile(new TileRect(tileset, tileset.getTilePositionFromID(tileset.rectangle.tiles[7]), rect.x + tileWidth, rect.y + rect.height - tileHeight, rect.width - tileWidth * 2, tileHeight)));
			
		}
		
	}

}