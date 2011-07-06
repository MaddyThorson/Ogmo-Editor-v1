package editor.ui 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class BG extends Sprite
	{
		[Embed(source = '../../../assets/logo.png')]
		static public const ImgSplash:Class;
		[Embed(source = '../../../assets/bg.png')]
		static public const ImgBG:Class;
		
		private var bg:Sprite;
		private var bitmapData:BitmapData;
		
		public function BG() 
		{
			addEventListener( Event.ADDED_TO_STAGE, init );
		}
		
		private function init( e:Event ):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, init );
			stage.addEventListener( Event.RESIZE, drawBG );
			
			bitmapData = (new ImgBG).bitmapData;
			bg = new Sprite;
			addChild( bg );
			
			drawBG();
			
			var splash:Bitmap = new ImgSplash;
			splash.scaleX = 3;
			splash.scaleY = 3;
			splash.x = 400 - splash.width / 2;
			splash.y = 300 - splash.height / 2;
			addChild( splash );
		}
		
		private function drawBG( e:Event = null ):void
		{
			bg.graphics.beginBitmapFill( bitmapData );
			bg.graphics.drawRect( -((stage.stageWidth - 800) / 2), -((stage.stageHeight - 600) / 2), stage.stageWidth, stage.stageHeight );
			bg.graphics.endFill();
		}
		
	}

}