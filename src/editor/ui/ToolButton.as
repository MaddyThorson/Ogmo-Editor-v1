package editor.ui 
{
	import editor.events.OgmoEvent;
	import editor.events.ToolSelectEvent;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	public dynamic class ToolButton extends Sprite
	{
		[Embed(source = '../../../assets/button1.png')]
		static private const ImgButton1:Class;
		[Embed(source = '../../../assets/button2.png')]
		static private const ImgButton2:Class;
		[Embed(source = '../../../assets/button3.png')]
		static private const ImgButton3:Class;
		
		private var bitmap:Bitmap;
		private var inside:Bitmap;
		private var mouseDown:Boolean = false;
		private var callback:Function;		
		private var _selected:Boolean = false;
		private var tool:Class;
		
		public function ToolButton( x:int, y:int, insideImage:Class, tool:Class ) 
		{
			this.x 			= x;
			this.y 			= y;
			this.tool		= tool;
			
			addEventListener( Event.ADDED_TO_STAGE, init );
			
			setImage( ImgButton1 );
			
			inside = new insideImage;
			inside.scaleX = 2;
			inside.scaleY = 2;
			inside.alpha = 1;
			addChild( inside );
		}
		
		private function init( e:Event ):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, init );
			
			addEventListener( Event.REMOVED_FROM_STAGE, destroy );
			addEventListener( MouseEvent.MOUSE_OVER, onMouseOver );
			addEventListener( MouseEvent.MOUSE_OUT, onMouseOut );
			addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			addEventListener( MouseEvent.MOUSE_UP, onMouseUp );
			stage.addEventListener(OgmoEvent.SELECT_TOOL, onSelectTool);
			
			onSelectTool();
		}
		
		private function destroy( e:Event ):void
		{
			removeEventListener( Event.REMOVED_FROM_STAGE, destroy );
			removeEventListener( MouseEvent.MOUSE_OVER, onMouseOver );
			removeEventListener( MouseEvent.MOUSE_OUT, onMouseOut );
			removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			removeEventListener( MouseEvent.MOUSE_UP, onMouseUp );
			stage.removeEventListener(OgmoEvent.SELECT_TOOL, onSelectTool);
		}
		
		private function setImage( to:Class ):void
		{
			if (bitmap)
				removeChild( bitmap );
				
			if (inside)
			{
				if (to == ImgButton3)
				{
					inside.x = 1;
					inside.y = 1;
				}
				else
				{
					inside.x = 0;
					inside.y = 0;
				}
			}
				
			addChildAt( bitmap = new to, 0 );
		}
		
		private function onMouseOver( e:MouseEvent ):void
		{
			if (!_selected)
			{
				Mouse.cursor = MouseCursor.BUTTON;
				setImage( ImgButton2 );
			}
		}
		
		private function onMouseOut( e:MouseEvent ):void
		{
			if (!_selected)
			{
				Mouse.cursor = MouseCursor.AUTO;
				setImage( ImgButton1 );
				mouseDown = false;
			}
		}
		
		private function onMouseDown( e:MouseEvent ):void
		{
			if (!_selected)
			{
				setImage( ImgButton3 );
				mouseDown = true;
			}
		}
		
		private function onMouseUp( e:MouseEvent ):void
		{
			if (mouseDown && !_selected)
			{
				mouseDown = false;
				setImage( ImgButton2 );
				Ogmo.level.currentLayer.setTool(new tool(Ogmo.level.currentLayer));
			}
		}
		
		public function set selected( to:Boolean ):void
		{
			_selected = to;
			if (_selected)
			{
				Mouse.cursor = MouseCursor.AUTO;
				setImage( ImgButton3 );
			}
			else
				setImage( ImgButton1 );
		}
		
		public function get selected():Boolean
		{
			return _selected;
		}
		
		private function onSelectTool(e:ToolSelectEvent = null):void
		{
			if (e == null)
				selected = false;
			else
				selected = (e.tool is tool);
		}
		
	}

}