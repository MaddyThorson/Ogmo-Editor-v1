package editor.tools.object
{
	import editor.Layer;
	import editor.Node;
	import editor.ObjectLayer;
	import editor.tools.Tool;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class ToolObjectNodes extends ObjectTool
	{
		
		public function ToolObjectNodes( layer:Layer ) 
		{
			super( layer );		
		}
		
		override protected function activate( e:Event ):void
		{
			super.activate(e);
			layer.addEventListener( MouseEvent.CLICK, onClick );
			layer.addEventListener( MouseEvent.RIGHT_CLICK, onRightClick );
			stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
		}
		
		override protected function deactivate( e:Event ):void 
		{
			super.deactivate(e);
			layer.removeEventListener( MouseEvent.CLICK, onClick );
			layer.removeEventListener( MouseEvent.RIGHT_CLICK, onRightClick );
			stage.removeEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
		}
		
		private function onClick( e:MouseEvent ):void
		{
			var p:Point = getMouseCoords( e );
			if (objectLayer.selection.length == 1)
			{
				if (objectLayer.selection[0].hasNodeAt( p.x, p.y ))
					objectLayer.selection[0].removeNodeAt( p.x, p.y );
				else
				{
					if (objectLayer.selection[0].getAmountOfNodes() >= objectLayer.selection[0].definition.nodesDefinition.limit)
						objectLayer.selection[0].removeFirstNode( objectLayer.selection[0].getAmountOfNodes() - objectLayer.selection[0].definition.nodesDefinition.limit + 1 );
					var n:Node = new Node( objectLayer.selection[0], p.x, p.y );
					objectLayer.selection[0].addNode( n );
				}
			}
		}
		
		private function onRightClick( e:MouseEvent ):void
		{
			var p:Point = getMouseCoords( e );
			if (objectLayer.selection.length == 1)
			{
				if (objectLayer.selection[0].hasNodeAt( p.x, p.y ))
					objectLayer.selection[0].removeNodeAt( p.x, p.y );
			}
		}
		
		private function onKeyDown( e:KeyboardEvent ):void
		{
			if (e.keyCode == 46)
			{
				if (objectLayer.selection.length == 1)
					objectLayer.selection[0].removeAllNodes();
			}
		}
		
	}

}