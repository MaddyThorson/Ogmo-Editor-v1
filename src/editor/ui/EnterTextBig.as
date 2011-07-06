package editor.ui 
{
	import editor.ui.EnterText;

	public class EnterTextBig extends EnterText
	{
		
		static private const HEIGHT:uint	= 50;
		
		public function EnterTextBig( x:int, y:int, width:int, callback:Function = null, defText:String = "", maxChars:int = -1 ) 
		{
			super( x, y, width, callback, defText, maxChars );
			
			text.height		= HEIGHT;
			text.wordWrap	= true;
		}
		
	}

}