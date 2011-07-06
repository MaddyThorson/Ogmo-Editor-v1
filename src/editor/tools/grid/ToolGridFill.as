package editor.tools.grid 
{
	import editor.Layer;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class ToolGridFill extends GridTool
	{
		
		public function ToolGridFill(layer:Layer) 
		{
			super(layer);
		}
		
		override protected function activate(e:Event):void
		{
			super.activate(e);
			layer.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			layer.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown);
		}
		
		override protected function deactivate(e:Event):void 
		{
			super.deactivate(e);
			layer.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			layer.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown);
		}
		
		private function onMouseDown(e:MouseEvent):void
		{
			gridLayer.grid.fillCell(Math.floor(e.localX / gridLayer.gridSize), Math.floor(e.localY / gridLayer.gridSize), true); 
		}
		
		private function onRightMouseDown(e:MouseEvent):void
		{
			gridLayer.grid.fillCell(Math.floor(e.localX / gridLayer.gridSize), Math.floor(e.localY / gridLayer.gridSize), false); 
		}
		
	}

}