package editor.tools.tile 
{
	import editor.events.TileSelectEvent;
	import editor.Layer;
	import editor.events.OgmoEvent;
	import editor.TileLayer;
	import editor.tools.Tool;
	import editor.ui.TilePalette;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	
	
	public class TileTool extends Tool
	{
		protected var tileLayer:TileLayer;
		protected var tileImage:Bitmap;
		
		public function TileTool(layer:Layer) 
		{
			super(layer);
			tileLayer = layer as TileLayer;
			
			addChild(tileImage = new Bitmap);
			tileImage.visible = false;
			updateTileImage();
		}
		
		override protected function activate(e:Event):void 
		{
			super.activate(e);
			stage.addEventListener(OgmoEvent.SELECT_TILE, onSelectTile);
		}
		
		override protected function deactivate(e:Event):void 
		{
			super.deactivate(e);
			stage.removeEventListener(OgmoEvent.SELECT_TILE, onSelectTile);
		}
		
		protected function onSelectTile(e:TileSelectEvent):void
		{
			updateTileImage();
		}
		
		private function updateTileImage(e:Event = null):void
		{
			if (tileImage.bitmapData != null)
				tileImage.bitmapData.dispose();
			
			if (!Ogmo.level.selTileset.loaded)
			{
				tileImage.bitmapData = new BitmapData(Ogmo.level.selTileset.tileWidth, Ogmo.level.selTileset.tileHeight, true, 0xAA00FF00);
				Ogmo.level.selTileset.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, updateTileImage, false, 0, true);
				return;
			}
				
			tileImage.bitmapData = new BitmapData(Ogmo.level.selTileset.tileWidth, Ogmo.level.selTileset.tileHeight);
			
			Ogmo.rect.x = Ogmo.level.selTilePoint.x;
			Ogmo.rect.y = Ogmo.level.selTilePoint.y;
			Ogmo.rect.width = Ogmo.level.selTileset.tileWidth;
			Ogmo.rect.height = Ogmo.level.selTileset.tileHeight;
			
			Ogmo.point.x = 0;
			Ogmo.point.y = 0;
			
			tileImage.bitmapData.copyPixels(Ogmo.level.selTileset.bitmapData, Ogmo.rect, Ogmo.point);
			
			Ogmo.rect.x = Ogmo.rect.y = 0;
			tileImage.bitmapData.colorTransform(Ogmo.rect, new ColorTransform(1, 1, 1, 0.5));
		}
		
	}

}