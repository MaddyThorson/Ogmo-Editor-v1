package editor 
{
	import adobe.utils.CustomActions;
	import editor.definitions.ValueDefinition;

	public class Value
	{
		
		public var datatype:Class;
		public var definition:ValueDefinition;
		
		private var _value:*;
		
		public function Value( definition:ValueDefinition, datatype:Class ) 
		{
			this.definition	= definition;
			this.datatype	= datatype;
		}
		
		public function get value():*
		{
			return (datatype)(_value);
		}
		
		public function set value( to:* ):void
		{
			_value = (datatype)(to);
		}
		
	}

}