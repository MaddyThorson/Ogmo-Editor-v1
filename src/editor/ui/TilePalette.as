package editor.ui 
{
	import editor.*;
	import editor.events.*;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class TilePalette extends Sprite
	{
		private var tileset:Tileset;
		private var bitmap:Bitmap;
		private var selbox:Sprite;
		private var loaded:Boolean;
		
		public function TilePalette(tileset:Tileset) 
		{
			this.tileset = tileset;
				
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function tilesetLoaded(e:Event = null):void
		{	
			bitmap = new Bitmap( tileset.bitmapData );
			bitmap.scaleX = tileset.paletteScale;
			bitmap.scaleY = tileset.paletteScale;
			addChild( bitmap );
			
			selbox = new Sprite;
			selbox.graphics.beginFill(0xFFFFFF);
			selbox.graphics.drawRect(0, 0, tileset.tileWidth * tileset.paletteScale, tileset.tileHeight * tileset.paletteScale);
			selbox.graphics.endFill();
			selbox.alpha = 0.6;
			positionSelbox();
			addChild(selbox);
			
			Ogmo.windows.windowTilesetPalette.bodyWidth 	= bitmap.width + 10;
			Ogmo.windows.windowTilesetPalette.bodyHeight 	= bitmap.height + 10;
			Ogmo.windows.windowTilesetPalette.enforceBounds();
			
			setTilePosition(0, 0);
		}
		
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			addEventListener(MouseEvent.CLICK, onClick);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			if (tileset.loaded)
				tilesetLoaded();
			else
				tileset.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, tilesetLoaded, false, 0, true);
		}
		
		private function destroy(e:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			removeEventListener(MouseEvent.CLICK, onClick);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		public function positionSelbox():void
		{
			selbox.x = Ogmo.level.selTilePoint.x * tileset.paletteScale;
			selbox.y = Ogmo.level.selTilePoint.y * tileset.paletteScale;
		}
		
		private function onClick(e:MouseEvent):void
		{
			var ax:int = Math.floor(e.localX / tileset.paletteScale / tileset.tileWidth) * tileset.tileWidth;
			var ay:int = Math.floor(e.localY / tileset.paletteScale / tileset.tileHeight) * tileset.tileHeight;
			
			setTilePosition(ax, ay);
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			if (Ogmo.missKeys || !Ogmo.windows.windowTilesetPalette.active)
				return;
				
			switch (e.keyCode)
			{
				//LEFT / A
				case (65):
				case (37):
					moveTileSelection( -1, 0 );
					break;
				//UP / W
				case (87):
				case (38):
					moveTileSelection( 0, -1 );
					break;
				//RIGHT / D
				case (68):
				case (39):
					moveTileSelection( 1, 0 );
					break;
				//DOWN / S
				case (83):
				case (40):
					moveTileSelection( 0, 1 );
					break;
			}
		}
		
		public function moveTileSelection(x:int, y:int):void
		{
			var ax:int = Ogmo.level.selTilePoint.x + x * tileset.tileWidth;
			var ay:int = Ogmo.level.selTilePoint.y + y * tileset.tileHeight;
			
			if (ax < 0)
				ax += tileset.bitmapData.width;
			else if (ax >= tileset.bitmapData.width)
				ax -= tileset.bitmapData.width;
				
			if (ay < 0)
				ay += tileset.bitmapData.height;
			else if (ay >= tileset.bitmapData.height)
				ay -= tileset.bitmapData.height;
			
			setTilePosition(ax, ay);
		}
		
		public function setTilePosition(x:int, y:int):void
		{
			Ogmo.level.selTilePoint.x = x;
			Ogmo.level.selTilePoint.y = y;
			
			positionSelbox();		
			stage.dispatchEvent(new TileSelectEvent(Ogmo.level.selTilePoint));
		}
		
	}

}