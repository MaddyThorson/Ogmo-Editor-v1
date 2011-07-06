package
{
	import editor.*;
	import editor.tools.*;
	import editor.tools.object.*;
	import editor.ui.*;
	import editor.definitions.*;
	import editor.events.*;
	import flash.filesystem.File;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.System;
	
	public class Level extends Sprite
	{	
		//Zoom levels
		static public const ZOOMS:Array = [ 0.1, 0.25, 0.5, 0.75, 1, 1.5, 2, 3, 4 ];
		
		//Palettes
		public var selTileset:Tileset;
		public var selTilePoint:Point;
		public var selObject:ObjectDefinition;
		public var selObjectFolder:ObjectFolder;
		
		//The general stuff
		private var _levelWidth:int;
		private var _levelHeight:int;
		private var _currentLayerNum:int = 0;
		public var values:Vector.<Value>;
		public var levelName:String;
		public var saved:Boolean;
		
		//The holder, which holds the layers and the bg
		private var holder:Sprite;		//Holds the layers AND the background
		public var layers:Sprite;		//Parent of all the layers
		public var bg:Sprite;			//The background color layer
		
		//For middle-click panning
		private var spaceHeld:Boolean;
		private var moving:Boolean;
		private var moveX:Number;
		private var moveY:Number;
		
		public function Level( name:String )
		{
			//Init name
			levelName 	= name;
			saved 		= false;
			
			//Init palettes
			selTilePoint 	= new Point;
			selTileset 		= null;
			selObject		= null;
			
			//Not scrolling the view
			moving 		= false;
			spaceHeld 	= false;
			
			//Set up to initialize
			addEventListener( Event.ADDED_TO_STAGE, init );
		}
		
		private function init( e:Event ):void
		{	
			//Delete the event listener
			removeEventListener( Event.ADDED_TO_STAGE, init );	
			
			initListeners();
			
			//Init to default size properties
			_levelWidth 		= Ogmo.project.defaultWidth;
			_levelHeight 		= Ogmo.project.defaultHeight;
			
			//Set tileset and object to the defaults (first ones)
			if (Ogmo.project.tilesets.length > 0)
				setTileset(0);
			if (Ogmo.project.objects.length > 0)
				Ogmo.windows.setObjectFolder( Ogmo.project.objects );
			
			//Init the holder
			holder = new Sprite;
			holder.x = 400;
			holder.y = 300;
			addChild( holder );
			
			//Init the bg color
			bg = new Sprite;
			drawBackground();
			bg.x = -_levelWidth / 2;
			bg.y = -_levelHeight / 2;
			holder.addChild( bg );
			
			//Init layer holder
			holder.addChild( layers = new Sprite );
			layers.x = -_levelWidth / 2;
			layers.y = -_levelHeight / 2;
			
			//Init layers
			var layer:Layer;
			var l:LayerDefinition;
			for ( var i:int = 0; i < Ogmo.project.layers.length; i++ )
			{
				l = Ogmo.project.layers[ i ];
				if (l.type == LayerDefinition.TILES)
				{
					layer = new TileLayer( l.name, l.gridSize, l.gridColor, l.drawGridSize, l.multipleTilesets, l.exportTileSize, l.exportTileIDs );
				}
				else if (l.type == LayerDefinition.GRID)
				{
					layer = new GridLayer( l.name, l.gridSize, l.gridColor, l.drawGridSize, l.color, l.exportAsObjects, l.newLine );
				}
				else if (l.type == LayerDefinition.OBJECTS)
				{
					layer = new ObjectLayer( l.name, l.gridSize, l.gridColor, l.drawGridSize );
				}
				layers.addChild( layer );
			}
			
			//Init values
			if (Ogmo.project.levelValues)
			{
				values = new Vector.<Value>;
				var value:Value;
				for each ( var v:ValueDefinition in Ogmo.project.levelValues )
				{
					value = v.getValue();
					values.push( value );
				}
			}
			
			//Init the mouse co-ords
			addChild( new MouseCoords );
			
			//Set the layer to the first one
			setLayer(0);
				
			Ogmo.windows.updateVisibilities();
		}
		
		private function destroy( e:Event ):void
		{
			removeEventListener( Event.REMOVED_FROM_STAGE, destroy );
			stage.removeEventListener( MouseEvent.MOUSE_WHEEL, onMouseWheel );
			stage.removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			stage.removeEventListener( MouseEvent.MOUSE_UP, onMouseUp );
			stage.removeEventListener( MouseEvent.MIDDLE_MOUSE_DOWN, onMiddleMouseDown );
			stage.removeEventListener( MouseEvent.MIDDLE_MOUSE_UP, onMiddleMouseUp );
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
			stage.removeEventListener( Event.MOUSE_LEAVE, onMouseLeave );
			stage.removeEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );	
			stage.removeEventListener( KeyboardEvent.KEY_UP, onKeyUp );
		}
		
		public function initListeners():void
		{
			//Add the new event listeners
			addEventListener( Event.REMOVED_FROM_STAGE, destroy );
			stage.addEventListener( MouseEvent.MOUSE_WHEEL, onMouseWheel );
			stage.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			stage.addEventListener( MouseEvent.MOUSE_UP, onMouseUp );
			stage.addEventListener( MouseEvent.MIDDLE_MOUSE_DOWN, onMiddleMouseDown );
			stage.addEventListener( MouseEvent.MIDDLE_MOUSE_UP, onMiddleMouseUp );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
			stage.addEventListener( Event.MOUSE_LEAVE, onMouseLeave );
			stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
			stage.addEventListener( KeyboardEvent.KEY_UP, onKeyUp );
		}
		
		public function toggleGrid():void
		{
			Ogmo.gridOn = !Ogmo.gridOn;

			currentLayer.handleGridMode();
			
			Ogmo.windowMenu.refreshState();
		}
		
		public function centerView():void
		{
			holder.x = 400;
			holder.y = 300;
		}
		
		private function drawBackground():void
		{
			bg.graphics.clear();
			bg.graphics.beginFill( 0x000000, 0.5 );
			bg.graphics.drawRect( 6, 6, _levelWidth, _levelHeight );
			bg.graphics.endFill();
			bg.graphics.beginFill( Ogmo.project.bgColor );
			bg.graphics.drawRect( 0, 0, _levelWidth, _levelHeight );
			bg.graphics.endFill();
		}
		
		public function saveScreenshot():void
		{
			currentLayer.active = false;
			
			var bd:BitmapData = new BitmapData( _levelWidth, _levelHeight );
			bd.fillRect( new Rectangle( 0, 0, _levelWidth, _levelHeight ), 0xFF000000 + Ogmo.project.bgColor );
			
			for ( var i:int = 0; i < layers.numChildren; i++ )
				bd.draw( layers.getChildAt( i ) );
			
			var file:File = File.desktopDirectory;
			file.save( PNGEncoder.encode( bd ), "screenshot.png" );
			
			currentLayer.active = true;
		}
		
		/* ========================== SETTING THINGS ========================== */
		
		public function setLayer( to:int ):void
		{
			//Error if invalid layer
			if (to >= layers.numChildren || to < 0)
				throw new Error( "Switching to non-existent layer!" );
				
			//Deactivate old active layer
			if (currentLayerNum != -1)
				currentLayer.active = false;
				
			//Activate the new one
			_currentLayerNum 		= to;
			currentLayer.active 	= true;
			
			//Set alpha values of all layers
			var after:Boolean = false;
			var i:int;
			for ( i = 0; i < layers.numChildren; i++ )
			{
				layers.getChildAt( i ).alpha = 1;
				if (i == to)
				{
					after = true;
					continue;
				}
				if (after)
					layers.getChildAt( i ).alpha = 0.2;
			}
			
			Ogmo.windows.setLayer( to );
			
			//If the layer is a tile layer not allowed multiple tilesets, switch to its current tileset
			if (currentLayer is TileLayer)
			{
				var layer:TileLayer = currentLayer as TileLayer;
				if (layer.onlyTileset)
					setTileset( Ogmo.project.getTilesetNumFromName( layer.onlyTileset.tilesetName ) );
			}
			
			//Refresh menus for undo/redo
			Ogmo.windowMenu.refreshState();
			
			//dispatch the event
			stage.dispatchEvent(new LayerSelectEvent(currentLayer));
		}
		
		public function setTileset( to:int, enforce:Boolean = true ):void
		{
			//Do nothing if that's the current tileset
			if (Ogmo.project.tilesets[ to ] == selTileset)
				return;
			
			//Error if invalid tileset
			if (to >= Ogmo.project.tilesetsCount || to < 0)
				throw new Error( "Switching to non-existent tileset!" );
				
			selTileset			= Ogmo.project.tilesets[ to ];
			selTilePoint.x 		= 0;
			selTilePoint.y 		= 0;
			
			//Set the tileset in the windows
			Ogmo.windows.setTileset( to );
			
			//If the layer is a tile layer not allowed multiple tilesets, switch its tileset
			if (currentLayer is TileLayer && enforce)
			{
				var layer:TileLayer = currentLayer as TileLayer;
				if (layer.onlyTileset)
					layer.onlyTileset = Ogmo.project.tilesets[ to ];
			}
			
			stage.dispatchEvent(new TilesetSelectEvent(selTileset));
		}
		
		public function setSize( newWidth:int, newHeight:int ):void
		{	
			//Exit if no change
			if (newWidth == _levelWidth && newHeight == _levelHeight)
				return;
			
			//Resize all layers
			for ( var i:int = 0; i < layers.numChildren; i++ )
				(layers.getChildAt( i ) as Layer).resizeLevel( newWidth, newHeight );
				
			//Change the actual values
			_levelWidth 	= newWidth;
			_levelHeight 	= newHeight;

			//Readjust positions
			layers.x 	= -_levelWidth / 2;
			layers.y 	= -_levelHeight / 2;
			bg.x 		= -_levelWidth / 2;
			bg.y 		= -_levelHeight / 2;
			
			//Redraw the stage background
			drawBackground();
		}
		
		/* ========================== GETS/SETS ========================== */
		
		public function get zoom():int
		{
			for ( var i:int = 0; i < ZOOMS.length; i++ )
			{
				if (ZOOMS[ i ] == holder.scaleX)
					return i;
			}
			return -1;
		}
		
		public function set zoom( to:int ):void
		{
			var cur:int;
			cur = Utils.within( 0, to, ZOOMS.length - 1 );
			
			holder.scaleX = ZOOMS[ cur ];
			holder.scaleY = holder.scaleX;
			
			Ogmo.showMessage( "Zoom: " + (ZOOMS[ cur ] * 100) + "%" );
			Ogmo.windowMenu.refreshState();
		}
		
		public function get xml():XML
		{
			var temp:XML;
			var ret:XML = <level></level>;
			ret.setName( "level" );
			
			//values
			Reader.writeValues( ret, values );
			
			if (Ogmo.project.exportLevelSize)
			{
				//Stage width
				temp = <width></width>;
				temp.setChildren( _levelWidth );
				ret.appendChild( temp );
				
				//Stage height
				temp = <height></height>;
				temp.setChildren( _levelHeight );
				ret.appendChild( temp );
			}
			
			//Layers
			for ( var i:int = 0; i < layers.numChildren; i++ )
			{
				temp = (layers.getChildAt( i ) as Layer).xml;
				if (temp)
					ret.appendChild( temp );
			}

			return ret;
		}
		
		public function set xml( to:XML ):void
		{	
			//values
			Reader.readValues( to, values );
			
			for each ( var o:XML in to.children() )
			{
				if (o.name().localName == "width")
				{
					//<WIDTH>
					setSize( Reader.readInt( o, Ogmo.project.defaultWidth, "width", Ogmo.project.minWidth, Ogmo.project.maxWidth ), levelHeight );
				}
				else if (o.name().localName == "height")
				{
					//<HEIGHT>
					setSize( levelWidth, Reader.readInt( o, Ogmo.project.defaultHeight, "height", Ogmo.project.minHeight, Ogmo.project.maxHeight ) );
				}
				else
				{
					//Layers!
					var b:Boolean = false;
					for ( var i:int = 0; i < layers.numChildren; i++ )
					{
						var layer:Layer = layers.getChildAt( i ) as Layer;
						if (o.name().localName == layer.layerName)
						{
							layer.xml = o;
							b = true;
							break;
						}
					}
					if (!b)
						throw new Error( "Layer \"" + o.name().localName + "\" not defined for this project!" );
				}
			}
		}
		
		public function get currentLayer():Layer
		{
			if (!layers)
				return null;
			else
				return layers.getChildAt(_currentLayerNum) as Layer;
		}
		
		public function get currentLayerNum():int
		{
			return _currentLayerNum;
		}
		
		public function get levelWidth():int
		{
			return _levelWidth;
		}
		
		public function get levelHeight():int
		{
			return _levelHeight;
		}
		
		/* ========================== EVENTS ========================== */
		
		private function onMouseWheel( e:MouseEvent ):void
		{
			zoom += (e.delta < 0)?( -1):(1);
		}
		
		private function onMouseDown( e:MouseEvent ):void
		{
			if (spaceHeld)
			{
				moving = true;
				moveX = e.stageX - holder.x;
				moveY = e.stageY - holder.y;
			}
		}
		
		private function onMouseUp( e:MouseEvent = null ):void
		{
			moving = false;
		}
		
		private function onMiddleMouseDown( e:MouseEvent ):void
		{
			moving = true;
			moveX = e.stageX - holder.x;
			moveY = e.stageY - holder.y;
		}
		
		private function onMiddleMouseUp( e:MouseEvent = null ):void
		{
			moving = false;
		}
		
		private function onMouseMove( e:MouseEvent ):void
		{
			if (moving)
			{
				holder.x = e.stageX - moveX;
				holder.y = e.stageY - moveY;
			}
		}
		
		private function onMouseLeave( e:Event ):void
		{
			onMiddleMouseUp();
		}
		
		private function onKeyDown( e:KeyboardEvent ):void
		{
			if (Ogmo.missKeys)
				return;
			
			//NUMBER KEYS
			if (e.ctrlKey && e.keyCode >= 49 && e.keyCode <= 57)
			{
				if (Ogmo.project.layers.length >= e.keyCode - 48)
					setLayer( e.keyCode - 49 );
				return;
			}
			else if (e.keyCode == 32)
			{
				layers.mouseChildren = false;
				spaceHeld = true;
			}
		}
		
		private function onKeyUp( e:KeyboardEvent ):void
		{
			if (e.keyCode == 32)
			{
				layers.mouseChildren = true;
				spaceHeld = false;
			}
		}
	}
}