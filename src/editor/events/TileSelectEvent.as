package editor.events 
{
	import flash.geom.Point;
	
	public class TileSelectEvent extends OgmoEvent 
	{
		public var tilePosition:Point;
		
		public function TileSelectEvent(tilePosition:Point) 
		{
			super(OgmoEvent.SELECT_TILE);
			this.tilePosition = tilePosition;
		}
		
	}

}