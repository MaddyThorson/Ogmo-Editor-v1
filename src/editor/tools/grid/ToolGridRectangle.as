package editor.tools.grid 
{
	import editor.Layer;
	import editor.Utils;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	public class ToolGridRectangle extends GridTool
	{
		private var placing:Boolean;
		private var drawMode:Boolean;
		private var startAt:Point = new Point;
		
		public function ToolGridRectangle(layer:Layer) 
		{
			super(layer);
			
			placing = false;
		}
		
		override protected function activate(e:Event):void
		{
			super.activate(e);
			layer.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			layer.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown);
			stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onMouseUp);
			layer.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		override protected function deactivate(e:Event):void 
		{
			super.deactivate(e);
			layer.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			layer.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown);
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
				
				gridLayer.storeUndo();
				Utils.setRectForFill(Ogmo.rect, startAt.x, startAt.y, ax, ay, gridLayer.gridSize);
				gridLayer.grid.setCellsRect(Ogmo.rect.x / gridLayer.gridSize, Ogmo.rect.y / gridLayer.gridSize, Ogmo.rect.width / gridLayer.gridSize, Ogmo.rect.height / gridLayer.gridSize, drawMode);
				
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
				
				Utils.setRectForFill(Ogmo.rect, startAt.x, startAt.y, ax, ay, gridLayer.gridSize);
				
				graphics.clear();
				if (drawMode)
					graphics.beginFill(0x00FF00, 0.5);
				else
					graphics.beginFill(0xFF0000, 0.5);
				graphics.drawRect(Ogmo.rect.x, Ogmo.rect.y, Ogmo.rect.width, Ogmo.rect.height);
				graphics.endFill();
			}
		}
		
	}

}