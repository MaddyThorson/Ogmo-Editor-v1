package editor.ui 
{
	import editor.Reader;
	
	public class LevelInfoWindow extends Window
	{
		
		private const WIDTH:int = 150;
		private const SIZE_CENTER:int = (WIDTH / 2) - 6;
		
		public function LevelInfoWindow() 
		{
			super(WIDTH, 50, "Level Settings");
			x = 20;
			y = 600;
		}
		
		public function populate():void
		{
			while (ui.numChildren > 0)
				ui.removeChildAt( 0 );
			bodyHeight = 50;
				
			ui.addChild( new Label( "Width:", SIZE_CENTER - 6, 5, "Right", "Top" ) );
			ui.addChild( new Label( "Height:", SIZE_CENTER - 6, 25, "Right", "Top" ) );
			
			//Stage size
			if (Ogmo.project.defaultWidth > Ogmo.project.minWidth || Ogmo.project.defaultWidth < Ogmo.project.maxWidth)
				ui.addChild( new EnterTextInt( SIZE_CENTER + 6, 5, 50, doChangeWidth, Ogmo.level.levelWidth, Ogmo.project.minWidth, Ogmo.project.maxWidth ) );
			else
				ui.addChild( new Label( String( Ogmo.project.defaultWidth ), SIZE_CENTER + 6, 5, "Left", "Top" ) );
				
			if (Ogmo.project.defaultHeight > Ogmo.project.minHeight || Ogmo.project.defaultHeight < Ogmo.project.maxHeight)
				ui.addChild( new EnterTextInt( SIZE_CENTER + 6, 25, 50, doChangeHeight, Ogmo.level.levelHeight, Ogmo.project.minHeight, Ogmo.project.maxHeight) );
			else
				ui.addChild( new Label( String( Ogmo.project.defaultHeight ), SIZE_CENTER + 6, 25, "Left", "Top" ) );
			
			//values
			if (Ogmo.level.values)
				Reader.addElementsForValues(this, Ogmo.level.values);
		}
		
		private function doChangeWidth( t:ValueModifier ):void
		{
			//Prevent bad input
			if (t.value == "" || int( t.value ) < Ogmo.project.minWidth || int( t.value ) > Ogmo.project.maxWidth)
			{
				t.value = String( Ogmo.level.levelWidth );
				Ogmo.showMessage( "Stage width must be\nwithin " + Ogmo.project.minWidth + "-" + Ogmo.project.maxWidth + ".", 5000 );
				return;
			}
			
			Ogmo.level.setSize( int( t.value ), Ogmo.level.levelHeight );
		}
		
		private function doChangeHeight( t:ValueModifier ):void
		{
			//Prevent bad input
			if (t.value == "" || int( t.value ) < Ogmo.project.minHeight || int( t.value ) > Ogmo.project.maxHeight)
			{
				t.value = String( Ogmo.level.levelHeight );
				Ogmo.showMessage( "Stage height must be\nwithin " + Ogmo.project.minHeight + "-" + Ogmo.project.maxHeight + ".", 5000 );
				return;
			}
			
			Ogmo.level.setSize( Ogmo.level.levelWidth, int( t.value ) );
		}
		
	}

}