package editor 
{
	import editor.tools.grid.*;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.System;
	
	public class GridLayer extends Layer implements Undoes
	{
		static private const UNDO_LIMIT:uint = 30;
		
		public var grid:Grid;
		private var exportAsObjects:Boolean;
		private var newLine:String;
		private var color:uint;
		
		private var undoStack:Vector.<BitmapData>;
		private var redoStack:Vector.<BitmapData>;
		
		public function GridLayer( layerName:String, gridSize:int, gridColor:uint, drawGridSize:uint, color:uint, exportAsObjects:Boolean, newLine:String ) 
		{
			super(ToolGridPencil, layerName, gridSize, gridColor, drawGridSize);
			
			this.gridSize 			= gridSize;
			this.exportAsObjects 	= exportAsObjects;
			this.newLine 			= newLine;
			this.color				= color;
			
			//init undo/redo
			undoStack = new Vector.<BitmapData>;
			redoStack = new Vector.<BitmapData>;

			grid = new Grid( Ogmo.level.levelWidth / gridSize, Ogmo.level.levelHeight / gridSize, color, newLine );
			grid.scaleX = grid.scaleY = gridSize;
			addChild( grid );
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
		
		public function storeUndo():void
		{	
			clearRedo();
			undoStack.push( grid.getCopyOfBitmapData() );
			
			if (undoStack.length > UNDO_LIMIT)
				undoStack.splice( 0, undoStack.length - UNDO_LIMIT );
				
			Ogmo.windowMenu.refreshState();
		}
		
		public function undo():void
		{
			if (undoStack.length == 0)
				return;
			
			redoStack.push( grid.getCopyOfBitmapData() );
			if (redoStack.length > UNDO_LIMIT)
				redoStack.splice( 0, redoStack.length - UNDO_LIMIT );
			
			grid.bitmapData = undoStack.pop();
			
			Ogmo.windowMenu.refreshState();
		}
		
		public function redo():void
		{
			if (redoStack.length == 0)
				return;
			
			undoStack.push( grid.getCopyOfBitmapData() );
			
			grid.bitmapData = redoStack.pop();
			
			Ogmo.windowMenu.refreshState();
		}
		
		private function clearUndo():void
		{
			undoStack.splice( 0, undoStack.length );
		}
		
		private function clearRedo():void
		{
			redoStack.splice( 0, redoStack.length );
		}
		
		/* ========================== LAYER STUFF ========================== */
		
		override public function resizeLevel( width:int, height:int ):void
		{	
			clearUndo();
			clearRedo();
			
			var w:int, h:int;
			w = width / gridSize;
			h = height / gridSize;
			
			//Make the new arrays
			grid.resize( w, h );
			
			super.resizeLevel( width, height );
			
			handleGridMode();
		}
		
		override public function clear():void
		{
			storeUndo();
			grid.clear();
			
			System.gc();
		}
		
		override protected function activate():void
		{
			stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
		}
		
		override protected function deactivate():void
		{
			stage.removeEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
		}
		
		/* ========================== GETS/SETS ========================== */
		
		override public function get xml():XML
		{
			var ret:XML = <layer></layer>;
			ret.setName( layerName );
			
			if (exportAsObjects)
			{
				var temp:XML;
				var rects:Vector.<Rectangle> = grid.rectangles;
			
				if (rects.length == 0)
					return null;
				
				for each ( var r:Rectangle in rects )
				{
					temp = <rect></rect>;
					temp.@x = r.x * gridSize;
					temp.@y = r.y * gridSize;
					temp.@w = r.width * gridSize;
					temp.@h = r.height * gridSize;
					ret.appendChild( temp );
				}
			}
			else	
				ret.setChildren( grid.bits );
			
			return ret;
		}
		
		override public function set xml( to:XML ):void
		{
			clear();
			
			if (exportAsObjects)
			{
				var rects:Vector.<Rectangle> = new Vector.<Rectangle>;
				for each ( var o:XML in to.rect )
					rects.push( new Rectangle( o.@x / gridSize, o.@y / gridSize, o.@w / gridSize, o.@h / gridSize ) );
				grid.rectangles = rects;
			}
			else
				grid.bits = to;
		}
		
		/* ========================== EVENTS ========================== */
		
		private function onKeyDown( e:KeyboardEvent ):void
		{
			if (Ogmo.missKeys || !e.ctrlKey)
				return;
				
			switch (e.keyCode)
			{
				//LEFT
				case (37):
					if (!grid.empty())
					{
						storeUndo();
						grid.shift( -1, 0 );
					}
					break;
				//UP
				case (38):
					if (!grid.empty())
					{
						storeUndo();
						grid.shift( 0, -1 );
					}
					break;
				//RIGHT
				case (39):
					if (!grid.empty())
					{
						storeUndo();
						grid.shift( 1, 0 );
					}
					break;
				//DOWN
				case (40):
					if (!grid.empty())
					{
						storeUndo();
						grid.shift( 0, 1 );
					}
					break;
			}
		}
		
	}

}