package editor.events 
{
	import editor.Tileset;
	public class TilesetSelectEvent extends OgmoEvent 
	{
		public var tileset:Tileset;
		
		public function TilesetSelectEvent(tileset:Tileset) 
		{
			super(OgmoEvent.SELECT_TILESET);
			this.tileset = tileset;
		}
		
	}

}