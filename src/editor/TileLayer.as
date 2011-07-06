package editor
{
	import editor.tools.tile.*;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.System;
	import editor.ui.TilePalette;
	
	public class TileLayer extends Layer implements Undoes
	{
		static private const UNDO_LIMIT:uint = 15;
		
		private var _onlyTileset:Tileset;
		private var exportTileSize:Boolean;
		private var exportTileIDs:Boolean;
		
		public var tilemap:Tilemap;
		
		private var undoStack:Vector.<TileUndoState>;
		private var redoStack:Vector.<TileUndoState>;
		
		public function TileLayer(layerName:String, gridSize:int, gridColor:uint, drawGridSize:uint, multipleTilesets:Boolean, exportTileSize:Boolean, exportTileIDs:Boolean)
		{
			super(ToolTilePlace, layerName, gridSize, gridColor, drawGridSize);
			this.exportTileSize = exportTileSize;
			this.exportTileIDs	= exportTileIDs;
			
			//Init the only tileset
			if (multipleTilesets)
				_onlyTileset = null;
			else
				_onlyTileset = Ogmo.project.tilesets[ 0 ];

			//Init the tilemap
			tilemap = new Tilemap(Ogmo.level.levelWidth, Ogmo.level.levelHeight, _onlyTileset);
			addChild(tilemap);

			//init undo/redo
			undoStack = new Vector.<TileUndoState>;
			redoStack = new Vector.<TileUndoState>;
		}
		
		/* ========================== UNDO / REDO ========================== */
		
		public function canUndo():Boolean
		{
			return (undoStack.length > 0);
		}
		
		public function canRedo():Boolean
		{
			return (redoStack.length > 0);
		}
		
		private function replaceTilemap(t:Tilemap):void
		{
			addChildAt(t, getChildIndex(tilemap));
			removeChild(tilemap);
			tilemap = t;
		}
		
		public function storeUndo(state:TileUndoState):void
		{
			if (state.empty)
				return;
			
			clearRedo();
			undoStack.push(state);
			
			if (undoStack.length > UNDO_LIMIT)
				undoStack.splice(0, undoStack.length - UNDO_LIMIT);
				
			Ogmo.windowMenu.refreshState();
		}
		
		public function undo():void
		{
			if (undoStack.length == 0)
				return;
			
			var t:TileUndoState = undoStack.pop();
			t.undo(tilemap);
			redoStack.push(t);
				
			if (redoStack.length > UNDO_LIMIT)
				redoStack.splice(0, redoStack.length - UNDO_LIMIT);
			
			if (_onlyTileset)
			{
				_onlyTileset = tilemap.onlyTileset;
				Ogmo.level.setTileset(Ogmo.project.getTilesetNumFromName(tilemap.onlyTileset.tilesetName), false);
			}
			
			Ogmo.windowMenu.refreshState();
		}
		
		public function redo():void
		{
			if (redoStack.length == 0)
				return;
				
			var t:TileUndoState = redoStack.pop();
			t.redo(tilemap);
			undoStack.push(t);

			if (_onlyTileset)
			{
				_onlyTileset = tilemap.onlyTileset;
				Ogmo.level.setTileset(Ogmo.project.getTilesetNumFromName(tilemap.onlyTileset.tilesetName), false);
			}
			
			Ogmo.windowMenu.refreshState();
		}
		
		private function clearUndo():void
		{
			undoStack.splice(0, undoStack.length);
		}
		
		private function clearRedo():void
		{
			redoStack.splice(0, redoStack.length);
		}
		
		/* ========================== LAYER STUFF ========================== */
		
		override public function resizeLevel(width:int, height:int):void
		{
			clearUndo();
			clearRedo();
			
			tilemap.resize(width, height);
			
			super.resizeLevel(width, height);
		}
		
		override public function clear():void
		{
			tilemap.clear();
			
			System.gc();
		}
		
		/* ========================== GETS/SETS ========================== */
		
		public function set onlyTileset(to:Tileset):void
		{
			if (_onlyTileset == null)
				throw new Error("Tileset allowed multiple tilesets being assigned a tileset.");
				
			if (!tilemap.empty)
			{
				var undoState:TileUndoState = new TileUndoState;
				undoState.setTilesetChange(_onlyTileset, to);
				storeUndo(undoState);
			}
				
			tilemap.onlyTileset = to;
			_onlyTileset = to;
		}
		
		public function get onlyTileset():Tileset
		{
			return _onlyTileset;
		}
		
		override public function get xml():XML
		{
			if (tilemap.empty)
				return null;
			
			var ret:XML = <layer></layer>;
			ret.setName(layerName);
			if (onlyTileset != null)
			{
				ret.@set = onlyTileset.tilesetName;
				if (exportTileSize)
				{
					ret.@tileWidth 	= _onlyTileset.tileWidth;
					ret.@tileHeight	= _onlyTileset.tileHeight;
				}
			}
			
			tilemap.getXML(ret, exportTileSize, exportTileIDs);
			
			return ret;
		}
		
		override public function set xml(to:XML):void
		{
			if (_onlyTileset)
			{
				_onlyTileset = Ogmo.project.getTileset(to.@set);
				if (!_onlyTileset)
					throw new Error("Tileset not defined: \"" + to.@set + "\"");
				tilemap.onlyTileset = _onlyTileset;
			}
				
			tilemap.setXML(to, exportTileIDs);
		}
		
	}
}