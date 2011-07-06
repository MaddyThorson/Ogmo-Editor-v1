package editor.ui 
{
	import editor.ui.EnterText;
	
	public class EnterTextNum extends EnterText
	{
		private var min:int;
		private var max:int;
		
		public function EnterTextNum( x:int, y:int, width:int, callback:Function, def:Number, min:Number = int.MIN_VALUE, max:Number = int.MAX_VALUE ) 
		{
			super( x, y, width, callback, String( def ), -1 );
			
			this.min = min;
			this.max = max;
			
			text.restrict 	= "0-9.\\-";
		}
		
		override protected function doCallback():void
		{	
			text.text = String( Math.min( Number( text.text ), max ) );
			text.text = String( Math.max( Number( text.text ), min ) );
			
			if (text.text == "NaN")
				text.text = String( value );
			
			super.doCallback();
		}
		
	}

}