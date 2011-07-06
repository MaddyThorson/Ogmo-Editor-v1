package editor.ui 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class MouseCoords extends Sprite
	{
		private const C_BG:uint		= 0xBB8888;
		private const C_BORDER:uint	= 0x000000;
		private const C_TEXT:uint	= 0xFFFFFF;
		private const WIDTH:int		= 80;
		private const HEIGHT:int	= 16;
		
		private var mX:int;
		private var mY:int;
		private var bg:Sprite;
		private var text:TextField;
		private var format:TextFormat;
		
		public function MouseCoords() 
		{
			addEventListener( Event.ADDED_TO_STAGE, init );
		}
		
		private function init( e:Event ):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, init );
			
			addEventListener( Event.REMOVED_FROM_STAGE, destroy );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
			stage.addEventListener( Event.RESIZE, onResize );
			
			visible = false;
			
			//Set position
			updatePosition();
			
			//Background
			bg = new Sprite;
			bg.graphics.beginFill( C_BG );
			bg.graphics.drawRect( 0, 0, WIDTH, HEIGHT );
			bg.graphics.endFill();
			
			//Border
			bg.graphics.beginFill( C_BORDER );
			bg.graphics.drawRect( 1, 0, WIDTH, 1 );
			bg.graphics.drawRect( 0, 0, 1, HEIGHT );
			bg.graphics.endFill();
			addChild( bg );
			
			//Init text
			text = new TextField;
			text.selectable 	= false;
			text.textColor 		= C_TEXT;
			text.width			= WIDTH;
			text.height			= HEIGHT;
			text.x 				= 4;
			text.y				= -1;
			
			addChild( text );
		}
		
		private function destroy( e:Event ):void
		{
			removeEventListener( Event.REMOVED_FROM_STAGE, destroy );
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
			stage.removeEventListener( Event.RESIZE, onResize );
		}
		
		private function updatePosition():void
		{
			x = ((stage.stageWidth - Ogmo.STAGE_DEFAULT_WIDTH) / 2) + Ogmo.STAGE_DEFAULT_WIDTH - WIDTH;
			y = ((stage.stageHeight - Ogmo.STAGE_DEFAULT_HEIGHT) / 2) + Ogmo.STAGE_DEFAULT_HEIGHT - HEIGHT;
		}
		
		private function updateText():void
		{
			text.text = "( " + mX + ", " + mY + " )";
			text.x = (WIDTH - text.textWidth) / 2;
		}
		
		private function onMouseMove( e:MouseEvent ):void
		{
			var obj:Object 	= e.target;
			var ax:Number 	= e.localX;
			var ay:Number 	= e.localY;
			
			while ( obj != stage && obj != Ogmo.level.layers )
			{
				ax *= obj.scaleX;
				ay *= obj.scaleY;
				ax += obj.x;
				ay += obj.y;
				obj = obj.parent;
			}
			
			if (obj == stage)
				visible = false;
			else
			{
				visible = true;
				mX = Ogmo.level.currentLayer.convertX( ax );
				mY = Ogmo.level.currentLayer.convertY( ay );
				updateText();
			}
		}
		
		private function onResize( e:Event ):void
		{
			updatePosition();
		}
		
	}

}