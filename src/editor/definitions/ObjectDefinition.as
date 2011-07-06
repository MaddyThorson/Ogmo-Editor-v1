package editor.definitions 
{
	import editor.Utils;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;

	public class ObjectDefinition
	{
		public var name:String
		public var width:int;
		public var height:int;
		public var imgWidth:int;
		public var imgHeight:int;
		public var imgOffsetX:int;
		public var imgOffsetY:int;
		public var originX:int;
		public var originY:int;
		public var resizableX:Boolean;
		public var resizableY:Boolean;
		public var rotatable:Boolean;
		public var rotationPrecision:Number;
		public var exportRadians:Boolean;
		public var limit:int;
		public var tile:Boolean;
		public var filename:String;
		public var values:Vector.<ValueDefinition>;
		public var nodesDefinition:NodesDefinition;
		
		public var bitmapData:BitmapData;
		public var loaded:Boolean;
		public var loader:Loader;
		
		public function ObjectDefinition(name:String, filename:String, width:int, height:int, imgWidth:int, imgHeight:int, imgOffsetX:int, imgOffsetY:int)
		{
			this.name 			= name;
			this.filename 		= filename;
			this.width			= width;
			this.height			= height;
			this.imgWidth		= imgWidth;
			this.imgHeight		= imgHeight;
			this.imgOffsetX		= imgOffsetX;
			this.imgOffsetY		= imgOffsetY;
			
			var file:File = Ogmo.project.workingDirectory.resolvePath( filename );
			if (!file.exists)
			{
				if (Utils.isColor32(filename))
				{
					//Given a color, initialize bitmapdata to that color (rather than using an image)
					loaded = true;
					this.imgWidth = width;
					this.imgHeight = height;
					imgOffsetX = imgOffsetY = 0;
					bitmapData = new BitmapData(width, height, true, Utils.getColor32(filename));
					return;
				}
				else
					throw new Error( "Object \"" + name + "\" given nonexistent image:\n" + file.url );
			}
			
			loaded = false;
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, imgLoadError);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.load(new URLRequest(file.url));
		}
		
		private function imgLoadError(e:IOErrorEvent):void
		{
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, imgLoadError);
			throw new Error("Image load error in object.");	
		}
		
		private function onLoadComplete(e:Event):void
		{
			if (imgWidth == -1)
				imgWidth = (loader.content as Bitmap).bitmapData.width;
			if (imgHeight == -1)
				imgHeight = (loader.content as Bitmap).bitmapData.height;
			
			loaded = true;
			bitmapData = new BitmapData(imgWidth, imgHeight);
			bitmapData.copyPixels((loader.content as Bitmap).bitmapData, new Rectangle( imgOffsetX, imgOffsetY, imgWidth, imgHeight ), new Point);
			
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, imgLoadError);
			loader = null;
		}
	}
}