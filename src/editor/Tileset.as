package editor 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	public class Tileset
	{
		public var loader:Loader;
		public var loaded:Boolean;
		public var tileHeight:int;
		public var tileWidth:int;
		public var tilesetName:String;
		public var bitmapData:BitmapData;
		public var paletteScale:Number;
		public var rectangle:TilesetRectangle;
		
		private var filename:String;
		
		public function Tileset( name:String, filename:String, tileWidth:int, tileHeight:int, paletteScale:Number ) 
		{	
			loaded 				= false;
			this.filename 		= filename;
			this.paletteScale 	= paletteScale;
			
			var file:File = Ogmo.project.workingDirectory.resolvePath( filename );
			if (!file.exists)
				throw new Error( "Tileset \"" + name + "\" given nonexistent image:\n" + file.url );
				
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, imgLoadError );
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onLoadComplete );
			loader.load( new URLRequest( file.url ) );
			
			this.tileHeight 	= tileHeight;
			this.tileWidth 		= tileWidth;
			tilesetName 		= name;
			
			rectangle = new TilesetRectangle;
		}
		
		private function imgLoadError( e:IOErrorEvent ):void
		{
			loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, onLoadComplete );
			loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, imgLoadError );
			throw new Error( "Image load error in tileset." );
		}
		
		private function onLoadComplete( e:Event ):void
		{
			loaded = true;
			bitmapData = ( loader.content as Bitmap ).bitmapData;
				
			loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, onLoadComplete );
			loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, imgLoadError );
			loader = null;
		}
		
		public function getTilePositionFromID( id:uint ):Point
		{
			var p:Point = new Point;
			
			var w:uint = Math.floor( bitmapData.width / tileWidth );
			
			p.x = (id % w) * tileWidth;
			p.y = Math.floor( id / w ) * tileHeight;
			
			return p;
		}
		
		public function getTileIDFromPosition( x:uint, y:uint ):uint
		{
			var w:uint = Math.floor( bitmapData.width / tileWidth );
			
			return (x / tileWidth) + (y / tileHeight * w);
		}
		
		public function get totalTiles():int
		{
			if (!loaded)
				throw new Error("Getting total tiles from tileset before it is loaded!");
			
			return Math.floor( bitmapData.width / tileWidth ) * Math.floor( bitmapData.height / tileHeight );
		}
		
	}

}