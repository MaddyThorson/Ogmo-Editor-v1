package editor.definitions 
{
	import editor.Value;

	public class ValueDefinition
	{
		
		public static const TYPE_BOOL:uint 		= 0;
		public static const TYPE_NUMBER:uint 	= 1;
		public static const TYPE_INT:uint		= 2;
		public static const TYPE_STRING:uint	= 3;
		public static const TYPE_TEXT:uint		= 4;
		public static const TYPE_INTSLIDER:uint	= 5;
		public static const TYPE_NUMSLIDER:uint	= 6;
		
		private static const TYPE_MAP:Array = [ Boolean, Number, int, String, String, int, Number ];
		
		public var type:uint;
		public var name:String;
		public var def:*;
		public var min:Number;
		public var max:Number;
		public var maxLength:uint;
		
		public function ValueDefinition( name:String, type:uint, def:* ) 
		{
			this.name	= name;
			this.type	= type;
			this.def	= def;
		}
		
		public function getValue():Value
		{
			var v:Value 	= new Value( this, TYPE_MAP[ type ] );
			v.value 		= def;
			
			return v;
		}
		
	}

}