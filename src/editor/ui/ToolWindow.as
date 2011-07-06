package editor.ui 
{
	import editor.events.LayerSelectEvent;
	import editor.GridLayer;
	import editor.ObjectLayer;
	import editor.events.OgmoEvent;
	import editor.TileLayer;
	import editor.tools.grid.*;
	import editor.tools.object.*;
	import editor.tools.tile.*;
	import flash.events.Event;
	import flash.events.KeyboardEvent;

	public class ToolWindow extends Window
	{
		[Embed(source = '../../../assets/tool_paint.png')]
		static private const ImgPaint:Class;
		[Embed(source = '../../../assets/tool_select.png')]
		static private const ImgSelect:Class;
		[Embed(source = '../../../assets/tool_transform.png')]
		static private const ImgTransform:Class;
		[Embed(source = '../../../assets/tool_nodes.png')]
		static private const ImgNodes:Class;
		[Embed(source = '../../../assets/tool_fillrect.png')]
		static private const ImgFillRect:Class;
		[Embed(source = '../../../assets/tool_emptyrect.png')]
		static private const ImgEmptyRect:Class;
		[Embed(source = '../../../assets/tool_specialrect.png')]
		static private const ImgSpecialRect:Class;
		[Embed(source = '../../../assets/tool_eyedrop.png')]
		static private const ImgEyedrop:Class;
		[Embed(source = '../../../assets/tool_fill.png')]
		static private const ImgFill:Class;
		[Embed(source = '../../../assets/tool_selectarea.png')]
		static private const ImgSelectArea:Class;
		
		private const GRID_TOOLS:Array 		= [ToolGridPencil, ToolGridFill, ToolGridRectangle];
		private const GRID_IMAGE:Array		= [ImgPaint, ImgFill, ImgFillRect];
		
		private const TILE_TOOLS:Array 		= [ToolTilePlace, ToolTileEyedrop, ToolTileRectangle, ToolTileSpecialRect];
		private const TILE_IMAGE:Array		= [ImgPaint, ImgEyedrop, ImgFillRect, ImgSpecialRect];
		
		private const OBJECT_TOOLS:Array	= [ToolObjectPaint, ToolObjectSelect, ToolObjectTransform, ToolObjectNodes];
		private const OBJECT_IMAGE:Array	= [ImgPaint, ImgSelect, ImgTransform, ImgNodes];
		
		private var tools:Array;
		
		public function ToolWindow() 
		{
			super(38, 38, "Tools");
			this.x = 400;
			this.y = 20 + Window.BAR_HEIGHT;
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			stage.addEventListener(OgmoEvent.SELECT_LAYER, onSelectLayer);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private function destroy(e:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			stage.removeEventListener(OgmoEvent.SELECT_LAYER, onSelectLayer);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private function onSelectLayer(e:LayerSelectEvent):void
		{
			emptyUI();
			
			var arrI:Array;
			if (e.layer is GridLayer)
			{
				tools = GRID_TOOLS;
				arrI = GRID_IMAGE;
			}
			else if (e.layer is TileLayer)
			{
				tools = TILE_TOOLS;
				arrI = TILE_IMAGE;
			}
			else if (e.layer is ObjectLayer)
			{
				tools = OBJECT_TOOLS;
				arrI = OBJECT_IMAGE;
			}
				
			bodyWidth = 3 + 35 * tools.length;
			
			var t:ToolButton;
			for (var i:int = 0; i < tools.length; i++)
			{
				t = new ToolButton(3 + i * 35, 3, arrI[i], tools[i]);
				ui.addChild(t);
			}
			
			active = (tools.length > 1);
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			if (Ogmo.missKeys)
				return;
			
			if (!e.ctrlKey)
			{
				for (var i:int = 0; i < tools.length; i++)
				{
					if (e.keyCode == String("1").charCodeAt() + i)
						Ogmo.level.currentLayer.setTool(new tools[i](Ogmo.level.currentLayer));
				}
			}
		}
		
	}

}
