package editor
{
	
	public class TilesetRectangle
	{
		public var tiles:Vector.<int>;
		
		public function TilesetRectangle() 
		{
			tiles = new Vector.<int>(9);
			
			for (var i:int = 0; i < 9; i++)
				tiles[i] = -1;
		}
		
	}

}