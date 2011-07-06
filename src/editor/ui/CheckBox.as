package editor.ui 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	public dynamic class CheckBox extends ValueModifier
	{
		[Embed(source = '../../../assets/checkbox1.png')]
		static private const Img1:Class;
		[Embed(source = '../../../assets/checkbox2.png')]
		static private const Img2:Class;
		[Embed(source = '../../../assets/checkbox1b.png')]
		static private const Img1b:Class;
		[Embed(source = '../../../assets/checkbox2b.png')]
		static private const Img2b:Class;
		
		private var def:Boolean;
		private var callback:Function;
		private var bitmap:Bitmap;	
		private var _value:Boolean;
		private var hover:Boolean;
		
		public function CheckBox( x:int, y:int, def:Boolean = false, callback:Function = null ) 
		{
			this.x			= x;
			this.y			= y;
			this.def 		= def;
			this.callback 	= callback;
			
			_value 	= def;
			hover 	= false;
			
			addEventListener( Event.ADDED_TO_STAGE, init );
		}
		
		private function init( e:Event ):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, init );
			
			addEventListener( Event.REMOVED_FROM_STAGE, destroy );
			addEventListener( MouseEvent.CLICK, onClick );
			addEventListener( MouseEvent.MOUSE_OVER, onMouseOver );
			addEventListener( MouseEvent.MOUSE_OUT, onMouseOut );
			
			setImage();
		}
		
		private function destroy( e:Event ):void
		{
			removeEventListener( Event.REMOVED_FROM_STAGE, destroy );
			removeEventListener( MouseEvent.CLICK, onClick );
		}
		
		private function onClick( e:MouseEvent ):void
		{
			_value = !_value;
			setImage();
			
			if (callback != null)
				callback( this );
		}
		
		private function onMouseOver( e:MouseEvent ):void
		{
			Mouse.cursor 	= MouseCursor.BUTTON;
			hover 			= true;
			setImage();
		}
		
		private function onMouseOut( e:MouseEvent ):void
		{
			Mouse.cursor 	= MouseCursor.AUTO;
			hover 			= false;
			setImage();
		}
		
		private function setImage():void
		{
			if (bitmap)
				removeChild( bitmap );
			
			if (_value)
			{
				if (hover)
					bitmap = new Img2b;
				else
					bitmap = new Img2;
			}
			else
			{
				if (hover)
					bitmap = new Img1b;
				else
					bitmap = new Img1;
			}
			bitmap.x = -8;
			bitmap.y = -8;
			addChild( bitmap );
		}
		
		/* ================ VALUE STUFF ================ */
		
		override public function get value():*
		{
			return _value;
		}
		
		override public function set value( to:* ):void
		{
			if (!(to is Boolean))
				throw new Error( "Checkbox passed non-boolean in value set." );
			
			_value = to;
			setImage();
		}
		
		override public function giveValue():void
		{
			valueObject.value = value;
		}
		
		override public function takeValue():void
		{
			value = valueObject.value;
		}
		
	}

}