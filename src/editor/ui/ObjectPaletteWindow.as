package editor.ui 
{
	import editor.ObjectFolder;
	
	public class ObjectPaletteWindow extends Window
	{
		private var label:Label;
		
		public function ObjectPaletteWindow(x:int) 
		{
			super(132, 100, "Objects");
			this.x = x;
			this.y = 20 + Window.BAR_HEIGHT;
			
			label = new Label("", 66, bodyHeight - 14, "Center", "Center");
			ui.addChild(label);
		}
		
		public function setFolder(to:ObjectFolder):void
		{
			var button:ObjectButton;
			var j:int = 0;
			var perRow:int = Math.floor( 128 / ObjectButton.SIZE );
			
			//Empty the window
			while (ui.numChildren > 0)
				ui.removeChildAt( 0 );
			addChild(label);
				
			//Set the title
			title = to.name;
			
			//Add the back button if necessary
			if (to != Ogmo.project.objects)
			{
				j = 1;
				button = new ObjectButton( ObjectButton.BACK, to.parent );
				button.x = 2;
				button.y = 2;
				ui.addChild( button );
			}
			
			//Add all the buttons
			for ( var i:int = 0; i < to.length; i++ )
			{
				if (to.contents[ i ] is ObjectFolder)
					button = new ObjectButton( ObjectButton.FOLDER, to.contents[ i ] );
				else
					button = new ObjectButton( ObjectButton.OBJECT, to.contents[ i ] );
					
				button.x = 2 + (j % perRow) * ObjectButton.SIZE;
				button.y = 2 + Math.floor( j / perRow ) * ObjectButton.SIZE;
				ui.addChild( button );
				j++;
			}
			
			//Adjust the height
			bodyHeight = 24 + (Math.floor( (j - 1) / perRow ) + 1) * ObjectButton.SIZE;
			
			//Move the label
			label.y = bodyHeight - 14;
		}
		
		public function set mouseText(to:String):void
		{
			label.text = to;
		}
		
	}

}