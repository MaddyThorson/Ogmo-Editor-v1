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
	import flash.utils.getTimer;

	public class Message extends Sprite
	{
		
		private var timeMade:int;
		private var message:String;
		private var time:int;
		private var large:Boolean;
		
		private var clickToClose:Boolean;
		private var closing:Boolean;
		private var closeButton:TextField;
		
		private const START_FADE:int	= 500;
		private const CTC_FADE:uint		= 300;
		private const WIDTH:int			= 260;
		private const HEIGHT:int		= 60;
		private const LARGE_WIDTH:int	= 600;
		private const LARGE_HEIGHT:int	= 80;
		private const YOFFSET:int		= 300;
		private const C_BG:uint			= 0xBB8888;
		private const C_BORDER:uint		= 0x000000;
		private const C_TEXT:uint		= 0xFFFFFF;
		private const C_BUTTON:uint		= 0x000000;
		private const C_BUTTONOVER:uint	= 0xFFFFFF;
		
		public function Message( message:String, time:int, large:Boolean ) 
		{
			this.message 	= message;
			this.large		= large;
			
			if (time == -1)
			{
				clickToClose = true;
				closing = false;
				this.time = 0;
			}
			else
				this.time = time;
			
			addEventListener( Event.ADDED_TO_STAGE, init, false, 0, true );
		}
		
		private function init( e:Event ):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, init );
			addEventListener( Event.REMOVED_FROM_STAGE, destroy );
			addEventListener( Event.ENTER_FRAME, onEnterFrame );
			
			var w:int = (large)?(LARGE_WIDTH):(WIDTH);
			var h:int = (large)?(LARGE_HEIGHT):(HEIGHT);
			
			x = (800 - w) / 2;
			y = (600 - h) / 2 + 200;
			
			timeMade 		= getTimer();
			
			var format:TextFormat = new TextFormat;
			format.align = TextFormatAlign.CENTER;
			format.size = 14;
			
			var text:TextField = new TextField;
			text.text 			= message;
			text.textColor 		= C_TEXT;
			text.width			= w;
			text.height			= h;
			text.y				= (h - text.textHeight - 4) / 2;
			text.setTextFormat( format );
			
			var bg:Sprite = new Sprite;
			bg.graphics.beginFill( 0x000000, 0.5 );
			bg.graphics.drawRect( 6, 6, w, h );
			bg.graphics.endFill();
			bg.graphics.beginFill( C_BG );
			bg.graphics.drawRect( 0, 0, w, h );
			bg.graphics.endFill();
			bg.graphics.beginFill( C_BORDER );
			bg.graphics.drawRect( 0, 1, 1, h-1 );
			bg.graphics.drawRect( 0, 0, w, 1 );
			bg.graphics.drawRect( w, 0, 1, h+1 );
			bg.graphics.drawRect( 0, h, w, 1 );
			bg.graphics.endFill();
			
			addChild( bg );
			addChild( text );
			
			mouseEnabled 	= clickToClose;
			mouseChildren	= clickToClose;
			text.selectable = clickToClose;
			
			if (clickToClose)
			{
				text.backgroundColor = 0xFFFFFF;
				
				closeButton = new TextField;
				closeButton.selectable = false;
				closeButton.text = "X";
				closeButton.textColor = C_BUTTON;
				closeButton.x = w - 20;
				closeButton.y = 4;
				closeButton.width = closeButton.textWidth*1.5;
				closeButton.height = closeButton.textHeight*1.5;
				closeButton.setTextFormat( format );
				addChild( closeButton );
				
				closeButton.addEventListener( MouseEvent.CLICK, onClick );
				closeButton.addEventListener( MouseEvent.MOUSE_OVER, onMouseOver );
				closeButton.addEventListener( MouseEvent.MOUSE_OUT, onMouseOut );
			}
		}
		
		private function destroy( e:Event ):void
		{
			removeEventListener( Event.REMOVED_FROM_STAGE, destroy );
			removeEventListener( Event.ENTER_FRAME, onEnterFrame );
			
			if (clickToClose)
			{
				closeButton.removeEventListener( MouseEvent.CLICK, onClick );
				closeButton.removeEventListener( MouseEvent.MOUSE_OVER, onMouseOver );
				closeButton.removeEventListener( MouseEvent.MOUSE_OUT, onMouseOut );
			}
		}
		
		private function onEnterFrame( e:Event ):void
		{
			var t:int = getTimer();
			
			if (clickToClose)
			{
				if (closing)
				{
					if (t - timeMade >= CTC_FADE)
					{
						remove();
						return;
					}
					alpha = Math.max( 0, 1 - ((t - timeMade) / CTC_FADE) );
				}
				else
					alpha = Math.min( 1, (t - timeMade) / CTC_FADE );
			}
			else
			{
				if (t - timeMade >= time)
				{
					remove();
					return;
				}
				
				alpha = Math.min( 1, (time - (t - timeMade)) / START_FADE );
			}
			
		}
		
		private function remove():void
		{
			Ogmo.ogmo.removeChild( this );
			Ogmo.message = null;
		}
		
		private function onClick( e:MouseEvent ):void
		{
			closing = true;
			timeMade = getTimer();
		}
		
		private function onMouseOver( e:MouseEvent ):void
		{
			closeButton.textColor = C_BUTTONOVER;
			Mouse.cursor = MouseCursor.BUTTON;
		}
		
		private function onMouseOut( e:MouseEvent ):void
		{
			closeButton.textColor = C_BUTTON;
			Mouse.cursor = MouseCursor.AUTO;
		}
		
	}

}