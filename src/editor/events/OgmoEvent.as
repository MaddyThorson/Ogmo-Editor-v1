package editor.events 
{
	import flash.events.Event;
	
	public class OgmoEvent extends Event
	{
		static public const SELECT_TILE:String 		= "oe_select_tile";
		static public const SELECT_TILESET:String	= "oe_select_tileset";
		static public const SELECT_LAYER:String 	= "oe_select_layer";
		static public const SELECT_TOOL:String 		= "oe_select_tool";
		
		public function OgmoEvent(type:String) 
		{
			super(type);
		}
		
	}

}