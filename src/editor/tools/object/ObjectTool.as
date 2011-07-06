package editor.tools.object 
{
	import editor.Layer;
	import editor.ObjectLayer;
	import editor.tools.Tool;
	
	
	public class ObjectTool extends Tool
	{
		protected var objectLayer:ObjectLayer;
		
		public function ObjectTool(layer:Layer) 
		{
			super(layer);
			objectLayer = layer as ObjectLayer;
		}
		
	}

}