package editor.tools 
{
	import editor.*;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class Tool extends Sprite
	{
		protected var layer:Layer;
		private var _active:Boolean = false;
		
		public function Tool( layer:Layer ):void
		{
			this.layer 		= layer;
			
			mouseEnabled = mouseChildren = false;
			
			addEventListener( Event.ADDED_TO_STAGE, activate );
			addEventListener( Event.REMOVED_FROM_STAGE, deactivate );
		}
		
		protected function activate(e:Event):void 
		{ 
			_active = true;
		}
		
		protected function deactivate(e:Event):void 
		{ 
			_active = false;
		}
		
		public function get active():Boolean
		{
			return _active;
		}
		
		public function destroy():void
		{
			removeEventListener( Event.ADDED_TO_STAGE, activate );
			removeEventListener( Event.REMOVED_FROM_STAGE, deactivate );
		}
		
		protected function getMouseCoords( e:MouseEvent ):Point
		{
			return layer.convertPoint( globalToLocal( new Point( e.stageX, e.stageY ) ) );
		}
		
		public function startQuickMode( mode:uint = 2 ):void
		{
			//override me!
		}
		
	}

}