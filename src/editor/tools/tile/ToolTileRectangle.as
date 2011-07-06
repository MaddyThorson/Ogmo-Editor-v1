package editor.tools.tile 
{
	import editor.Layer;
	import editor.Tile;
	import editor.TileRect;
	import editor.TileUndoState;
	import editor.ui.TilePalette;
	import editor.Utils;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class ToolTileRectangle extends TileTool
	{
		private var placing:Boolean;
		private var drawMode:Boolean;
		private var startAt:Point = new Point;
		
		public function ToolTileRectangle(layer:Layer) 
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
				var vec:Vector.<Tile>;
				
				if (drawMode)
				{
					Utils.setRectForFill(Ogmo.rect, startAt.x, startAt.y, ax, ay, tileLayer.gridSize, Ogmo.level.selTileset.tileWidth, Ogmo.level.selTileset.tileHeight);
					undoState.pushAdded(tileLayer.tilemap.addTile(new TileRect(Ogmo.level.selTileset, Ogmo.level.selTilePoint, Ogmo.rect.x, Ogmo.rect.y, Ogmo.rect.width, Ogmo.rect.height)));
				}
				else
				{
					Utils.setRectForFill(Ogmo.rect, startAt.x, startAt.y, ax, ay, tileLayer.gridSize);
					vec = tileLayer.tilemap.getTilesAtRectangle(Ogmo.rect);
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
					graphics.beginBitmapFill(tileImage.bitmapData);
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
		
	}

}