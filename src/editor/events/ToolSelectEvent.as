package editor.events 
{
	import editor.tools.Tool;
	public class ToolSelectEvent extends OgmoEvent 
	{
		public var tool:Tool;
		
		public function ToolSelectEvent(tool:Tool) 
		{
			super(OgmoEvent.SELECT_TOOL);
			this.tool = tool;
		}
		
	}

}