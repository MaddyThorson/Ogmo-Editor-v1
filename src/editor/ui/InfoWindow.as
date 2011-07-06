package editor.ui 
{
	import flash.events.Event;
	
	public class InfoWindow extends Window
	{
		
		public function InfoWindow() 
		{
			super( 200, 145, "" );
			
			addEventListener( Event.ADDED_TO_STAGE, init );
		}
		
		private function init( e:Event ):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, init );
			
			addEventListener( Event.REMOVED_FROM_STAGE, destroy );
			stage.addEventListener( Event.RESIZE, onResize );
			
			x = 780 - bodyWidth + (stage.stageWidth - 800) / 2;
			y = 20 + Window.BAR_HEIGHT - (stage.stageHeight - 600) / 2;
			
			ui.addChild( new Label( "Ogmo Editor by Matt Thorson", 100, 5, "Center" ) );
			ui.addChild( new Label( "Version " + Ogmo.version, 100, 20, "Center" ) );
			ui.addChild( new Label( "This program is free to use and open source! If you want to report a bug, contribute to development, or make a donation check out the website!", 5, 45, "Left", "Top", 190 ) );
			
			var t:TextButton = new TextButton( 190, "Website", onWebsite );
			t.x = 5;
			t.y = bodyHeight - 4 - TextButton.HEIGHT;
			ui.addChild( t );
		}
		
		private function destroy( e:Event ):void
		{
			removeEventListener( Event.REMOVED_FROM_STAGE, destroy );
			stage.removeEventListener( Event.RESIZE, onResize );
		}
		
		private function onResize( e:Event ):void
		{
			enforceBounds();
		}
		
		private function onWebsite( t:TextButton ):void
		{
			Ogmo.openWebsite();
		}
		
	}

}