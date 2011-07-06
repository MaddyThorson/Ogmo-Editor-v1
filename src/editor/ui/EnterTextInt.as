package editor.ui 
{
	import editor.ui.EnterText;
	
	public class EnterTextInt extends EnterText
	{
		private var min:int;
		private var max:int;
		
		public function EnterTextInt( x:int, y:int, width:int, callback:Function, def:int, min:int = int.MIN_VALUE, max:int = int.MAX_VALUE ) 
		{
			super( x, y, width, callback, String( def ), Math.max( String( min ).length, String( max ).length ) );
			
			this.min = min;
			this.max = max;
			
			if (min < 0)
				text.restrict = "0-9\\-";
			else
				text.restrict 	= "0-9";
		}
		
		override protected function doCallback():void
		{	
			text.text = String( Math.min( int( text.text ), max ) );
			text.text = String( Math.max( int( text.text ), min ) );
			
			super.doCallback();
		}
		
	}

}