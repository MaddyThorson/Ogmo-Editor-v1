package editor.ui 
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	public class EnterText extends ValueModifier
	{		
		static private const HEIGHT:uint 	= 18;
		static private const C_TEXT:uint 	= 0x000000;
		static private const C_BG:uint		= 0xFFFFFF;
		static private const C_TEXTH:uint	= 0xFFFFFF;
		static private const C_BGH:uint		= 0x448844;
		static private const C_TEXTS:uint	= 0x000000;
		static private const C_BGS:uint		= 0x33FF33;
		
		protected var text:TextField;
		private var callback:Function;
		private var focus:Boolean;
		
		public function EnterText( x:int, y:int, width:int, callback:Function = null, defText:String = "", maxChars:int = -1 ) 
		{
			this.x = x;
			this.y = y;
			
			text = new TextField;
			text.background 		= true;
			text.backgroundColor 	= C_BG;
			text.textColor			= C_TEXT;
			text.selectable 		= true;
			text.type 				= TextFieldType.INPUT;
			text.text				= defText;
			text.width				= width;
			text.focusRect			= 0xFFFF0000;
			addChild( text );
			
			this.callback			= callback;
			
			if (maxChars > 0)
				text.maxChars = maxChars;
			
			text.height = HEIGHT;
			
			focus = false;
			addEventListener( Event.REMOVED_FROM_STAGE, destroy );
			text.addEventListener( FocusEvent.FOCUS_IN, onFocusIn );
			text.addEventListener( FocusEvent.FOCUS_OUT, onFocusOut );
			addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
		}
		
		private function destroy( e:Event ):void
		{
			removeEventListener( Event.REMOVED_FROM_STAGE, destroy );
			text.removeEventListener( FocusEvent.FOCUS_IN, onFocusIn );
			text.removeEventListener( FocusEvent.FOCUS_OUT, onFocusOut );
			removeEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
		}
		
		private function onKeyDown( e:KeyboardEvent ):void
		{
			//on ENTER press
			if (focus && e.keyCode == 13)
			{
				stage.focus = null;
				doCallback();
			}
		}
		
		private function onFocusIn( e:Event ):void
		{
			focus = true;
			Ogmo.missKeys = true;
		}
		
		private function onFocusOut( e:Event ):void
		{
			focus = false;
			Ogmo.missKeys = false;
			doCallback();
		}
		
		protected function doCallback():void
		{
			if (callback != null)
				callback( this );
		}
		
		/* ================ VALUE STUFF ================ */
		
		override public function get value():*
		{
			return text.text;
		}
		
		override public function set value( to:* ):void
		{
			text.text = to;
		}
		
		override public function giveValue():void
		{
			valueObject.value = text.text;
		}
		
		override public function takeValue():void
		{
			text.text = valueObject.value;
		}
		
	}
	
}