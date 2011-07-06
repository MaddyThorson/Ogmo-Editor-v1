package editor.ui 
{
	import flash.display.Sprite;
	import flash.text.TextField;

	public class Label extends Sprite
	{
		static private const TEXT_COLOR:uint = 0xFFFFFF;
		
		private var field:TextField;
		private var justify_h:String;
		private var justify_v:String;
		private var wrapWidth:int;
		
		public function Label( text:String, x:int = 0, y:int = 0, justify_h:String = "Left", justify_v:String = "Top", wrapWidth:int = -1 ) 
		{
			this.x = x;
			this.y = y;
			
			this.justify_h = justify_h;
			this.justify_v = justify_v;
			this.wrapWidth = wrapWidth;
			
			if (justify_h != "Left" && justify_h != "Right" && justify_h != "Center")
				throw new Error( "Horizontal justification must be 'Left', 'Right' or 'Center'." );
				
			if (justify_v != "Top" && justify_v != "Bottom" && justify_v != "Center")
				throw new Error( "Vertical justification must be 'Top', 'Bottom' or 'Center'." );
			
			field 				= new TextField;
			field.selectable 	= false;
			field.textColor		= TEXT_COLOR;
			addChild( field );
			
			if (wrapWidth != -1)
			{
				field.wordWrap 	= true;
				field.width		= wrapWidth;
			}
			
			this.text = text;
		}
		
		public function set text( to:String ):void
		{
			field.text 			= to;
			field.height		= field.textHeight * 1.5;
			if (wrapWidth == -1)
				field.width			= field.textWidth*1.5;

			//H Justify
			if (justify_h == "Left")
				field.x = 0;
			else if (justify_h == "Right")
				field.x = -field.textWidth;
			else if (justify_h == "Center")
				field.x = -(field.textWidth / 2);
			
			//V Justify
			if (justify_v == "Top")
				field.y = 0;
			else if (justify_v == "Bottom")
				field.y = -field.textHeight;
			else if (justify_v == "Center")
				field.y = -(field.textHeight / 2);
		}
		
		public function get text():String
		{
			return field.text;
		}
		
	}

}