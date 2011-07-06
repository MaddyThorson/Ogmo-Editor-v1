package editor
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	public class ObjectFolder
	{
		private var filename:String;
		private var imgWidth:int;
		private var imgHeight:int;
		private var imgOffsetX:int;
		private var imgOffsetY:int;
		
		public var name:String;
		public var parent:ObjectFolder;
		public var contents:Array;
		public var bitmapData:BitmapData;
		public var loaded:Boolean; 
		public var loader:Loader;
		
		public function ObjectFolder( name:String, filename:String = "", imgWidth:int = -1, imgHeight:int = -1, imgOffsetX:int = 0, imgOffsetY:int = 0, parent:ObjectFolder = null )
		{
			this.name 		= name;
			this.filename	= filename;
			this.parent 	= parent;
			this.imgWidth	= imgWidth;
			this.imgHeight	= imgHeight;
			this.imgOffsetX	= imgOffsetX;
			this.imgOffsetY = imgOffsetY;
			
			contents = new Array;
			
			//Image loading stuff
			if (filename != "")
			{
				var file:File = Ogmo.project.workingDirectory.resolvePath( filename );
				if (!file.exists)
					throw new Error( "Object \"" + name + "\" given nonexistent image:\n" + file.url );
				
				loaded = false;
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, imgLoadError );
				loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onLoadComplete );
				loader.load( new URLRequest( file.url ) );
			}
			else
				loaded = true;
		}
		
		public function get length():int
		{
			return contents.length;
		}
		
		private function imgLoadError( e:IOErrorEvent ):void
		{
			loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, onLoadComplete );
			loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, imgLoadError );
			throw new Error( "Image load error in object folder." );	
		}
		
		private function onLoadComplete( e:Event ):void
		{
			if (imgWidth == -1)
				imgWidth = (loader.content as Bitmap).bitmapData.width;
			if (imgHeight == -1)
				imgHeight = (loader.content as Bitmap).bitmapData.height;
				
			loaded = true;
			bitmapData = new BitmapData( imgWidth, imgHeight );
			bitmapData.copyPixels( (loader.content as Bitmap).bitmapData, new Rectangle( imgOffsetX, imgOffsetY, imgWidth, imgHeight ), new Point );
			
			loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, onLoadComplete );
			loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, imgLoadError );
			loader = null;
		}
	}
}