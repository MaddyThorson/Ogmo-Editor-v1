package editor.tools.object
{
	import editor.Layer;
	import editor.tools.*;
	import editor.GameObject;
	import editor.ObjectLayer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	public class ToolObjectSelect extends ObjectTool
	{
		static private const C_RECT:uint = 0xFFFFFF;
		
		private var dragPoint:Point;
		private var rectPoint:Point;
		private var rect:Sprite;
		private var canSwitch:Boolean = true;
		
		public function ToolObjectSelect( layer:Layer )
		{
			super( layer );
			
			addChild( rect = new Sprite );
			rect.alpha = 0.4;
		}
		
		override protected function activate( e:Event ):void
		{
			super.activate(e);
			layer.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );
			layer.addEventListener( MouseEvent.RIGHT_CLICK, onRightClick );
			stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
		}
		
		override protected function deactivate(e:Event):void 
		{
			super.deactivate(e);
			layer.removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );
			layer.removeEventListener( MouseEvent.RIGHT_CLICK, onRightClick );
			stage.removeEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			stage.removeEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
		}
		
		override public function startQuickMode( mode:uint = 2 ):void
		{
			if (mode != QuickTool.MOUSE)
				dragPoint = objectLayer.convertPoint( objectLayer.globalToLocal( new Point( layer.stage.mouseX, layer.stage.mouseY ) ) );
		}
		
		private function drawRect( x:Number, y:Number ):void
		{
			clearRect();
			
			rect.graphics.beginFill( C_RECT );
			rect.graphics.drawRect( rectPoint.x, rectPoint.y, x - rectPoint.x, y - rectPoint.y );
			rect.graphics.endFill();
		}
		
		private function clearRect():void
		{
			rect.graphics.clear();
		}
		
		private function onMouseDown( e:MouseEvent ):void
		{
			var p:Point = getMouseCoords( e );
			var exact:Point = globalToLocal( new Point( e.stageX, e.stageY ) );
			var objs:Vector.<GameObject> = objectLayer.getObjectsAtPoint( exact.x, exact.y );
			
			canSwitch = !e.ctrlKey;
			
			if (objectLayer.anyObjectSelected( objs ) && !e.ctrlKey)
			{
				//Click and drag selected objects to move them
				dragPoint = p;
			}
			else
			{
				//Click non-selected objects to select them (then possibly drag to move them), or click empty space and drag to rectangle-select			
				if (!e.ctrlKey)
					objectLayer.deselectAll();
					
				if (objs.length > 0)
				{
					objectLayer.toggleSelectObjects( objs );
					dragPoint = p;
				}
				else
				{
					rectPoint = p;
				}	

			}
			
		}
		
		private function onStageMouseUp( e:MouseEvent ):void
		{
			var p:Point = getMouseCoords( e );
			
			if (rectPoint)
			{
				var r:Rectangle;
				r = new Rectangle( Math.min( rectPoint.x, p.x ), Math.min( rectPoint.y, p.y ), Math.abs( p.x - rectPoint.x ), Math.abs( p.y - rectPoint.y ) );
				
				objectLayer.toggleSelectObjects( objectLayer.getObjectsAtRect( r ) );
				rectPoint = null;
				clearRect();
			}
			
			dragPoint = null;
		}
		
		private function onStageMouseMove( e:MouseEvent ):void
		{
			var p:Point = getMouseCoords( e );
			
			if (rectPoint)
			{
				drawRect( p.x, p.y );
			}
			else if (dragPoint)
			{
				objectLayer.moveObjects( objectLayer.selection, p.x - dragPoint.x, p.y - dragPoint.y );
				dragPoint = p;
				Ogmo.windows.windowObjectInfo.setTarget( objectLayer.selection );
			}
		}
		
		private function onRightClick( e:MouseEvent ):void
		{
			var p:Point = globalToLocal(new Point(e.stageX, e.stageY));
			objectLayer.removeObject( objectLayer.getFirstAtPoint( p.x, p.y ) );
		}
		
		private function onKeyDown( e:KeyboardEvent ):void
		{
			if (dragPoint && canSwitch && e.keyCode == Ogmo.keycode_ctrl)
			{
				objectLayer.setTool(new ToolObjectTransform(objectLayer));
				objectLayer.tool.startQuickMode();
				objectLayer.quickTools.push( new QuickTool( ToolObjectSelect, QuickTool.EITHER ) );
			}
		}
		
	}

}