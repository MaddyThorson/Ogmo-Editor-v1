package editor.definitions 
{

	public class NodesDefinition
	{	
		public var drawObject:Boolean;
		public var limit:uint;
		public var lineMode:uint;
		public var color:uint;
		
		static public const NONE:uint		= 0;
		static public const PATH:uint		= 1;
		static public const CIRCUIT:uint	= 2;
		static public const FAN:uint		= 3;
		
		static public const DEFAULT_COLOR:uint	= 0xFFFF00;
		
		public function NodesDefinition( drawObject:Boolean, limit:uint, lineMode:uint, color:uint ) 
		{
			this.drawObject	= drawObject;
			this.limit		= limit;
			this.lineMode	= lineMode;
			this.color		= color;
		}
		
	}

}