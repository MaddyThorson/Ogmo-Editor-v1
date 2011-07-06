package editor.ui 
{
	import editor.*;
	import editor.definitions.*;
	import editor.tools.*;
	import editor.tools.object.*;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	
	public class Windows extends Sprite
	{
		//Windows
		public var windowLevelInfo:LevelInfoWindow;
		public var windowLayers:Window;
		public var windowTilesets:Window;
		public var windowTilesetPalette:Window;
		public var windowTileRect:TileRectangleWindow;
		public var windowObjectPalette:ObjectPaletteWindow;
		public var windowObjectInfo:ObjectInfoWindow;
		public var windowTools:ToolWindow;
		
		public var tilePalette:TilePalette;
		
		public var windowLayersVisibilities:Sprite;
		
		public function Windows() 
		{
			addEventListener( Event.ADDED_TO_STAGE, init );
		}
		
		private function init( e:Event = null ):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, init );
			addEventListener( Event.REMOVED_FROM_STAGE, destroy );
			stage.addEventListener( Event.RESIZE, onResize );
			
			var i:int;
			var button:TextButton;
			var layer:LayerDefinition;
			var func:Function;
			var value:ValueDefinition;
			var offsetX:uint = 0;
			
			//Level info window
			windowLevelInfo = new LevelInfoWindow;
			addChild( windowLevelInfo );
			windowLevelInfo.active = true;
			
			//The Layer Window
			if (Ogmo.project.layers.length > 1)
			{
				offsetX = 110;
				
				windowLayers 	= new Window( 100, (TextButton.HEIGHT + 2) * Ogmo.project.layers.length + 3, "Layers" );
				windowLayers.x	= 20;
				windowLayers.y	= 20 + Window.BAR_HEIGHT;
				
				windowLayersVisibilities = new Sprite;
				windowLayersVisibilities.x = 80;
				
				for ( i = 0; i < Ogmo.project.layers.length; i++ )
				{
					layer = Ogmo.project.layers[ i ];
					
					button = new TextButton( 74, layer.name, buttonSetLayer );
					button.x = 3;
					button.y = 3 + (i * (TextButton.HEIGHT + 2));
					button.layerNum = i;
					windowLayers.ui.addChild( button );
					
					var visButton:LayerVisibilityButton = new LayerVisibilityButton( i );
					visButton.y = 3 + (22 * i);
					windowLayersVisibilities.addChild( visButton );
				}
				windowLayers.addChild( windowLayersVisibilities );
				
				addChild( windowLayers );
				windowLayers.active = true;
			}
			
			//The Tileset Selector Window
			if (Ogmo.project.tilesetsCount > 1)
			{
				windowTilesets 		= new Window( 80, (TextButton.HEIGHT + 2) * Ogmo.project.tilesetsCount + 3, "Tilesets" );
				windowTilesets.x	= 20 + offsetX;
				windowTilesets.y	= 20 + Window.BAR_HEIGHT;
				
				for ( i = 0; i < Ogmo.project.tilesets.length; i++ )
				{
					button = new TextButton( 74, Ogmo.project.tilesets[ i ].tilesetName, buttonSetTilesetPalette );
					button.x = 3;
					button.y = 3 + (i * (TextButton.HEIGHT + 2));
					button.tilesetNum = i;
					windowTilesets.ui.addChild( button );
				}
				
				addChild( windowTilesets );
			}
			
			//The Tileset Palette Window
			if (Ogmo.project.tilesetsCount > 0)
			{
				windowTilesetPalette 	= new Window( 100, 100, "Palette" );
				windowTilesetPalette.x	= 20 + offsetX + (Ogmo.project.tilesetsCount > 1 ? 90 : 0);
				windowTilesetPalette.y	= 20 + Window.BAR_HEIGHT;
				
				addChild( windowTilesetPalette );
			}
			
			//Tile rect window
			if (Ogmo.project.tilesetsCount > 0)
			{
				windowTileRect		= new TileRectangleWindow;
				
				addChild( windowTileRect );
			}
			
			
			if (Ogmo.project.objectsCount > 0)
			{
				//The Object Palette Window
				windowObjectPalette		= new ObjectPaletteWindow(20 + offsetX);
				
				addChild( windowObjectPalette );
			
				//The Object Info Window
				windowObjectInfo = new ObjectInfoWindow;
				addChild( windowObjectInfo );
			}
			
			//Tool window
			addChild(windowTools = new ToolWindow);
			
			for ( i = 0; i < numChildren; i++ )
			{
				(getChildAt( i ) as Window).stickToEdges( Ogmo.STAGE_DEFAULT_WIDTH, Ogmo.STAGE_DEFAULT_HEIGHT );
				(getChildAt( i ) as Window).enforceBounds();
			}
		}
		
		private function destroy( e:Event ):void
		{
			removeEventListener( Event.REMOVED_FROM_STAGE, destroy );
			stage.removeEventListener( Event.RESIZE, onResize );
		}
		
		/* ========================== UTILITIES ========================== */
		
		public function set mouse( to:Boolean ):void
		{
			mouseChildren 	= to;
			mouseEnabled 	= to;
		}
		
		public function setLayer( to:int ):void
		{
			//Set selected in layer window buttons
			if (windowLayers)
			{
				for ( var i:int = 0; i < windowLayers.ui.numChildren; i++ )
				{
					if (i == to)
						(windowLayers.ui.getChildAt( i ) as TextButton).selected = true;
					else
						(windowLayers.ui.getChildAt( i ) as TextButton).selected = false;
				}
			}
			
			//Activate and deactivate windows correctly
			if (Ogmo.level.currentLayer is TileLayer)
			{
				if (windowTilesets)
					windowTilesets.active = true;
				if (windowTilesetPalette)
					windowTilesetPalette.active = true;
				if (windowObjectPalette)
					windowObjectPalette.active = false;
				if (windowObjectInfo)
					windowObjectInfo.active = false;
			}
			else if (Ogmo.level.currentLayer is GridLayer)
			{
				if (windowTilesets)
					windowTilesets.active = false;
				if (windowTilesetPalette)
					windowTilesetPalette.active = false;
				if (windowObjectPalette)
					windowObjectPalette.active = false;
				if (windowObjectInfo)
					windowObjectInfo.active = false;
			}
			else if (Ogmo.level.currentLayer is ObjectLayer)
			{
				if (windowTilesets)
					windowTilesets.active = false;
				if (windowTilesetPalette)
					windowTilesetPalette.active = false;
				if (windowObjectPalette)
					windowObjectPalette.active = true;
				if (windowObjectInfo)
					windowObjectInfo.active = true;
			}
		}
		
		public function setTileset( to:int ):void
		{
			//Set selected in tilesets window buttons
			if (windowTilesets)
			{
				for ( var i:int = 0; i < windowTilesets.ui.numChildren; i++ )
				{
					if (i == to)
						(windowTilesets.ui.getChildAt( i ) as TextButton).selected = true;
					else
						(windowTilesets.ui.getChildAt( i ) as TextButton).selected = false;
				}
			}
			
			//Create the palette in the palette window
			if (windowTilesetPalette.ui.numChildren > 0)
				windowTilesetPalette.ui.removeChildAt( 0 );
			var t:TilePalette = new TilePalette( Ogmo.level.selTileset );
			t.x = 5;
			t.y = 5;
			tilePalette = t;
			windowTilesetPalette.ui.addChild( t );
			
			//Update the tileset rectangle
			windowTileRect.rectangle = Ogmo.project.tilesets[to].rectangle;
		}
		
		public function setObjectFolder( to:ObjectFolder ):void
		{
			Ogmo.level.selObjectFolder = to;
			windowObjectPalette.setFolder(to);
		}
		
		public function resetObjectsSelected():void
		{
			for ( var i:int = 0; i < windowObjectPalette.ui.numChildren; i++ )
				(windowObjectPalette.ui.getChildAt( i ) as ObjectButton).selected = false;
		}
		
		public function updateVisibilities():void
		{
			if (windowLayersVisibilities == null)
				return;
			
			for ( var i:int = 0; i < windowLayersVisibilities.numChildren; i++ )
			{
				(windowLayersVisibilities.getChildAt( i ) as LayerVisibilityButton).setImage();
			}
		}
		
		/* ========================== EVENTS ========================== */
		
		private function addedToStage( e:Event ):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, addedToStage );
			stage.addEventListener( Event.RESIZE, onResize, false, 0, true );
		}
		
		private function onResize( e:Event ):void
		{
			for ( var i:int = 0; i < numChildren; i++ )
				(getChildAt( i ) as Window).enforceBounds();
		}
		
		private function buttonSetLayer( obj:TextButton ):void
		{
			Ogmo.level.setLayer( obj.layerNum );
		}
		
		private function buttonSetTilesetPalette( obj:TextButton ):void
		{
			Ogmo.level.setTileset( obj.tilesetNum );
		}
		
	}

}