package editor.definitions 
{

	public dynamic class LayerDefinition
	{
		
		static public const TILES:uint 		= 0;
		static public const GRID:uint		= 1;
		static public const OBJECTS:uint	= 2;
		
		public var type:uint;
		public var name:String;
		public var gridSize:uint;
		public var gridColor:uint;
		public var drawGridSize:uint;
		
		public function LayerDefinition( type:uint, name:String, gridSize:uint, gridColor:uint, drawGridSize:uint ) 
		{
			this.type 			= type;
			this.name			= name;
			this.gridSize		= gridSize;
			this.gridColor		= gridColor;
			this.drawGridSize	= drawGridSize;
		}
		
	}

}