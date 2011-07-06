package editor.ui 
{
	import editor.ui.Window;
	import flash.events.Event;
	import flash.system.System;
	import flash.utils.getTimer;
	
	public class DebugWindow extends Window
	{
		static private const FRAMERATE_SAMPLE:uint = 10;
		
		private var lastTime:int;
		private var timeVector:Vector.<int>;
		
		private var lblFrameRate:Label;
		private var lblMemUse:Label;
		
		public function DebugWindow() 
		{
			super( 150, 50, "Program Info" );
			
			addEventListener( Event.ADDED_TO_STAGE, init );
		}
		
		private function init( e:Event ):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, init );
			
			addEventListener( Event.ENTER_FRAME, onEnterFrame );
			addEventListener( Event.REMOVED_FROM_STAGE, destroy );
			
			//Position
			x = 780 - bodyWidth + (stage.stageWidth - 800) / 2;
			y = 580 - bodyHeight + (stage.stageHeight - 600) / 2;
			
			//Frame rate
			lblFrameRate = new Label( "Frame Rate: --", 5, 5 );
			ui.addChild( lblFrameRate );
			
			//Memory use
			lblMemUse = new Label( "Memory Use: " + Number( System.totalMemory / 1048576 ).toFixed( 2 ) + " MB", 5, 25 );
			ui.addChild( lblMemUse );
			
			//Init timer
			timeVector = new Vector.<int>;
			lastTime = getTimer();
		}
		
		private function destroy( e:Event ):void
		{
			removeEventListener( Event.ENTER_FRAME, onEnterFrame );
			removeEventListener( Event.REMOVED_FROM_STAGE, destroy );
		}
		
		private function onEnterFrame( e:Event ):void
		{
			var time:int = getTimer();
			
			//Update frame rate
			timeVector.push( time - lastTime );
			if (timeVector.length == FRAMERATE_SAMPLE)
			{
				var avg:int = 0;
				while ( timeVector.length > 0 )
					avg += timeVector.pop();
				lblFrameRate.text = "Frame Rate: " + Number( 1000 / (avg / FRAMERATE_SAMPLE) ).toFixed();
			}
			
			//Update mem use
			lblMemUse.text = "Memory Use: " + Number( System.totalMemory / 1048576 ).toFixed( 2 ) + " MB";
			
			lastTime = getTimer();
		}
		
	}

}