package editor.ui 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	public dynamic class TextButton extends Sprite
	{
		
		private var text:TextField;
		private var buttonWidth:int;
		private var id:int;
		private var callback:Function;
		private var _selected:Boolean;
		
		static public const HEIGHT:int 		= 20;
		static private const C_TEXT:uint 	= 0x000000;
		static private const C_BG:uint		= 0x999999;
		static private const C_TEXTH:uint	= 0xFFFFFF;
		static private const C_BGH:uint		= 0x448844;
		static private const C_TEXTS:uint	= 0x000000;
		static private const C_BGS:uint		= 0x33FF33;
		static private const FORMAT:TextFormat = new TextFormat( null, null, null, null, null, null, null, null, TextFormatAlign.CENTER );
		
		public function TextButton( width:int, str:String, callback:Function = null ) 
		{
			buttonWidth 			= width;
			this.callback			= callback;
			
			text 					= new TextField;
			text.selectable 		= false;
			text.text 				= str;
			text.y 					= (Ogmo.mac?2:-2);
			text.textColor			= C_TEXT;
			text.background 		= true;
			text.backgroundColor	= C_BG;
			text.width 				= buttonWidth;
			text.height 			= HEIGHT;
			text.setTextFormat( FORMAT );
			addChild( text );
			
			addEventListener( Event.REMOVED_FROM_STAGE, destroy );
			addEventListener( MouseEvent.MOUSE_OVER, onMouseOver );
			addEventListener( MouseEvent.MOUSE_OUT, onMouseOut );
			if (callback != null)
				addEventListener( MouseEvent.CLICK, onClick );
				
			_selected = false;
		}
		
		private function destroy( e:Event ):void
		{
			removeEventListener( Event.REMOVED_FROM_STAGE, destroy );
			removeEventListener( MouseEvent.MOUSE_OVER, onMouseOver );
			removeEventListener( MouseEvent.MOUSE_OUT, onMouseOut );
			if (callback != null)
				removeEventListener( MouseEvent.CLICK, onClick );
		}
		
		/* ========================== GETS/SETS ========================== */
		
		public function set selected( to:Boolean ):void
		{
			_selected = to;
			
			if (_selected)
			{
				text.textColor			= C_TEXTS;
				text.backgroundColor	= C_BGS;
			}
			else
			{
				text.textColor			= C_TEXT;
				text.backgroundColor	= C_BG;
			}
		}
		
		public function get selected():Boolean
		{
			return _selected;
		}
		
		/* ========================== EVENTS ========================== */
		
		private function onMouseOver( e:MouseEvent ):void
		{
			if (!_selected)
			{
				text.backgroundColor 	= C_BGH;
				text.textColor			= C_TEXTH;
				Mouse.cursor = MouseCursor.BUTTON;
			}		
		}
		
		private function onMouseOut( e:MouseEvent ):void
		{
			if (!_selected)
			{
				text.textColor			= C_TEXT;
				text.backgroundColor	= C_BG;
				Mouse.cursor = MouseCursor.AUTO;
			}		
		}
		
		private function onClick( e:MouseEvent ):void
		{
			if (callback != null)
			{
				Mouse.cursor = MouseCursor.AUTO;
				callback( this );
			}
		}
		
	}

}