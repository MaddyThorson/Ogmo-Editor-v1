package editor.ui 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Rectangle;

	public class SelBox extends Bitmap
	{
		private var color:uint;
		private var thickness:int;
		private var boxWidth:int;
		private var boxHeight:int;
		
		static public const OBJECT_SELECTED:uint 		= 0x8800FF00;
		static public const OBJECT_NOTSELECTED:uint		= 0x88FFFF00;
		
		public function SelBox( width:int, height:int, thickness:int = 3, color:uint = 0xFF00FF00 ) 
		{	
			this.color 		= color;
			this.thickness 	= thickness;
			
			setSize( width, height );
		}
		
		public function setSize( width:int, height:int ):void
		{
			boxWidth 	= width;
			boxHeight 	= height;
			
			drawBox();
		}
		
		public function setColor( color:uint ):void
		{
			this.color = color;
			
			drawBox();
		}
		
		private function drawBox():void
		{
			bitmapData = new BitmapData( boxWidth, boxHeight );
			bitmapData.fillRect( new Rectangle( 0, 0, boxWidth, boxHeight ), 0x00000000 );		
			bitmapData.fillRect( new Rectangle( 0, 0, thickness, boxHeight ), color );
			bitmapData.fillRect( new Rectangle( boxWidth - thickness, 0, thickness, boxHeight ), color );
			bitmapData.fillRect( new Rectangle( 0, 0, boxWidth, thickness ), color );
			bitmapData.fillRect( new Rectangle( 0, height-thickness, boxWidth, thickness ), color );
		}
		
	}

}