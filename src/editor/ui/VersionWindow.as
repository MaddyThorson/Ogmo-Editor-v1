package editor.ui 
{
	import editor.ui.Window;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.getTimer;
	
	public class VersionWindow extends Window
	{
		[Embed(source = '../../../assets/loading.png')]
		static private const ImgLoading:Class;
		[Embed(source = '../../../assets/loading_fail.png')]
		static private const ImgLoadingFail:Class;
		
		private const TICK:int = 200;
		
		private var bitmap:Bitmap;
		private var loader:URLLoader;
		private var time:int;
		private var current:int = 0;
		
		public function VersionWindow() 
		{
			super( 180, 40, "" );
			
			addEventListener( Event.ADDED_TO_STAGE, init );
			addEventListener( Event.REMOVED_FROM_STAGE, destroy );
		}
		
		private function init( e:Event ):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, init );
			stage.addEventListener( Event.RESIZE, onResize );
			addEventListener( Event.ENTER_FRAME, onEnterFrame );
			
			x = 780 - bodyWidth + (stage.stageWidth - 800) / 2;
			y = 580 - bodyHeight + (stage.stageHeight - 600) / 2;
			
			loader = new URLLoader;
			loader.load( new URLRequest( "http://mattmakesgames.com/OgmoEditor/changes.xml" ) );
			loader.addEventListener( Event.COMPLETE, onLoaded );
			loader.addEventListener( IOErrorEvent.IO_ERROR, loadError );
			
			bitmap 		= new ImgLoading;
			bitmap.x 	= 72;
			bitmap.y	= 12;
			
			time = getTimer();
		}
		
		private function destroy( e:Event ):void
		{
			removeEventListener( Event.REMOVED_FROM_STAGE, destroy );
			stage.removeEventListener( Event.RESIZE, onResize );
			removeEventListener( Event.ENTER_FRAME, onEnterFrame );
			
			if (loader)
			{
				loader.removeEventListener( Event.COMPLETE, onLoaded );
				loader.removeEventListener( IOErrorEvent.IO_ERROR, loadError );
				loader.close();
			}
		}
		
		private function onResize( e:Event ):void
		{
			enforceBounds();
		}
		
		private function onLoaded( e:Event ):void
		{
			title = "Version Info";
			
			if (ui.contains( bitmap ))
				ui.removeChild( bitmap );
			
			loader.removeEventListener( Event.COMPLETE, onLoaded );
			loader.removeEventListener( IOErrorEvent.IO_ERROR, loadError );
			var xml:XML = new XML( loader.data );
			loader = null;
			
			ui.addChild( new Label( "Newest Version:", 10, 2, "Left", "Top" ) );
			ui.addChild( new Label( "Your Version:", 10, 19, "Left", "Top" ) );
			
			ui.addChild( new Label( xml.version[0].number[0], 110, 2, "Left", "Top" ) );
			ui.addChild( new Label( Ogmo.version, 110, 19, "Left", "Top" ) );
			
			if (xml.version[0].number[0] != Ogmo.version)
			{
				bodyHeight += 24;
				y -= 24;
				var t:TextButton = new TextButton( 176, "Check Out the New Version", function ( t:TextButton ):void { navigateToURL( new URLRequest( "http://ogmoeditor.com/index.php?p=download" ) ); } );
				t.x = 2;
				t.y = 42;
				ui.addChild( t );
			}
		}
		
		private function loadError( e:IOErrorEvent ):void
		{
			title = "Could Not Connect!";
			
			if (ui.contains( bitmap ))
				ui.removeChild( bitmap );
				
			bitmap = new ImgLoadingFail;
			bitmap.x = 72;
			bitmap.y = 12;
			ui.addChild( bitmap );
			
			loader.removeEventListener( Event.COMPLETE, onLoaded );
			loader.removeEventListener( IOErrorEvent.IO_ERROR, loadError );
			loader.close();
			loader = null;
		}
		
		private function onEnterFrame( e:Event ):void
		{
			if (loader)
			{
				var t:int = getTimer();
				if (t - time > TICK)
				{
					time += TICK;
					current += 1;
					if (current > 3)
						current = 0;
						
					title = "Fetching Version Info";
					for ( var i:int = 0; i < current; i++ )
						title = title + ".";
						
					if (!ui.contains( bitmap))
					{
						if (current == 2)
						{
							ui.addChild( bitmap );
							current = 0;
						}
						return;
					}
						
					bitmap.rotation = current * 90;
					
					if (current == 0)
					{
						bitmap.x = 72;
						bitmap.y = 12;
					}
					else if (current == 1)
					{
						bitmap.x = 88;
						bitmap.y = 12;
					}
					else if (current == 2)
					{
						bitmap.x = 88;
						bitmap.y = 28;
					}
					else
					{
						bitmap.x = 72;
						bitmap.y = 28;
					}
				}
			}
		}
		
	}

}