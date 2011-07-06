package editor.tools 
{
	public class QuickTool
	{
		static public const CTRL:uint 	= 0;
		static public const MOUSE:uint 	= 1;
		static public const SHIFT:uint	= 2;
		static public const EITHER:uint = 3;
		
		public var tool:Class;
		public var mode:uint;
		
		public function QuickTool( tool:Class, mode:uint ) 
		{
			this.tool 	= tool;
			this.mode 	= mode;
		}
		
	}

}