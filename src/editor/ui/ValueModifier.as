package editor.ui 
{
	import editor.Value;
	import flash.display.Sprite;
	
	public class ValueModifier extends Sprite
	{
		public var valueObject:Value;
		
		public function set value( to:* ):void { }
		public function get value():* { }
		public function giveValue():void { }
		public function takeValue():void { }
		
	}

}