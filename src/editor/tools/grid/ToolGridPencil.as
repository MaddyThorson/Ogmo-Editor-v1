package editor.tools.grid 
{
	import editor.GridLayer;
	import editor.Layer;
	import editor.tools.QuickTool;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	
	public class ToolGridPencil extends GridTool
	{
		private var placing:Boolean;
		private var drawMode:Boolean;
		
		public function ToolGridPencil(layer:Layer) 
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
			stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onRightMouseUp);
			layer.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		override protected function deactivate(e:Event):void 
		{
			super.deactivate(e);
			layer.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			layer.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown);
			stage.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, onRightMouseUp);
			layer.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private function onMouseDown(e:MouseEvent):void
		{
			Ogmo.windows.mouse = false;
			gridLayer.storeUndo();

			placing = true;
			drawMode = true;
			gridLayer.grid.setCell(Math.floor(e.localX / gridLayer.gridSize), Math.floor(e.localY / gridLayer.gridSize), true);
		}
		
		private function onMouseUp(e:MouseEvent):void
		{
			Ogmo.windows.mouse = true;
			
			if (drawMode)
				placing = false;
		}
		
		private function onRightMouseDown(e:MouseEvent):void
		{
			Ogmo.windows.mouse = false;
			gridLayer.storeUndo();
			
			placing = true;
			drawMode = false;
			gridLayer.grid.setCell(Math.floor(e.localX / gridLayer.gridSize), Math.floor(e.localY / gridLayer.gridSize), false);
		}
		
		private function onRightMouseUp(e:MouseEvent):void
		{
			Ogmo.windows.mouse = true;
			
			if (!drawMode)
				placing = false;
		}
		
		private function onMouseMove(e:MouseEvent):void
		{
			var ax:int = Math.floor(e.localX / gridLayer.gridSize);
			var ay:int = Math.floor(e.localY / gridLayer.gridSize);
			if (placing && ax >= 0 && ax < gridLayer.grid.width && ay >= 0 && ay < gridLayer.grid.height)
				gridLayer.grid.setCell(ax, ay, drawMode);
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			if (e.keyCode == Ogmo.keycode_ctrl)
				layer.setTool(new ToolGridFill(layer), new QuickTool(ToolGridPencil, QuickTool.CTRL));
		}
		
	}

}