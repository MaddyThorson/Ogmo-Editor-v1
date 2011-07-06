package editor.tools.object
{
	import editor.GameObject;
	import editor.Layer;
	import editor.ObjectLayer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class ToolObjectTransform extends ObjectTool
	{
		private var grabbed:GameObject;
		private var grabbedAt:int;
		private var rotateMode:Boolean;
		
		private const ROTATE_INCREMENT:int = 10;
		
		public function ToolObjectTransform( layer:Layer )
		{
			super( layer ); 		
		}
		
		override protected function activate( e:Event ):void
		{
			super.activate(e);
			layer.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );
			stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
		}
		
		override protected function deactivate( e:Event ):void 
		{
			super.deactivate(e);
			layer.removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );
			stage.removeEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
		}
		
		override public function startQuickMode( mode:uint = 2 ):void
		{
			if (objectLayer.selection.length > 0)	
				grabbed 	= objectLayer.selection[0];
		}
		
		private function onMouseDown( e:MouseEvent ):void
		{
			var p:Point = getMouseCoords( e );
			var objs:Vector.<GameObject> = objectLayer.getObjectsAtPoint( p.x, p.y );
			
			objectLayer.deselectAll();	
			
			if (objs.length > 0)
			{
				objectLayer.selectObject( objs[ 0 ] );	
				grabbed = objs[ 0 ];
				
				if (e.shiftKey)
				{
					rotateMode = true;
					grabbedAt = e.stageX;
				}
				else
					rotateMode = false;
			}
		}
		
		private function onStageMouseMove( e:MouseEvent ):void
		{
			if (grabbed)
			{
				if (rotateMode)
				{
					if (e.stageX >= grabbedAt + ROTATE_INCREMENT)
					{
						grabbedAt = e.stageX;
						objectLayer.rotateObjects( objectLayer.selection, 1 );
					}
					else if (e.stageX <= grabbedAt - ROTATE_INCREMENT)
					{
						grabbedAt = e.stageX;
						objectLayer.rotateObjects( objectLayer.selection, -1 );
					}
					
					if (objectLayer.selection.length >= 1)
						Ogmo.windows.windowObjectInfo.setTarget( objectLayer.selection );
				}
				else
				{
					var p:Point = getMouseCoords( e );
					objectLayer.resizeObjects( objectLayer.selection, p.x - grabbed.x + objectLayer.gridSize, p.y - grabbed.y + objectLayer.gridSize );
					
					if (objectLayer.selection.length >= 1)
						Ogmo.windows.windowObjectInfo.setTarget( objectLayer.selection );
				}
			}
		}
		
		private function onStageMouseUp( e:MouseEvent ):void
		{
			grabbed = null;
		}	
		
	}

}