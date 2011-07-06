package editor.tools.grid 
{
	import editor.GridLayer;
	import editor.Layer;
	import editor.tools.Tool;
	
	
	public class GridTool extends Tool
	{
		protected var gridLayer:GridLayer;
		
		public function GridTool(layer:Layer) 
		{
			super(layer);
			gridLayer = layer as GridLayer;
		}
		
	}

}