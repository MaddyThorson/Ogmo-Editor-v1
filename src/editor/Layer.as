package editor 
{
	import editor.events.*;
	import editor.tools.QuickTool;
	import editor.tools.Tool;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.System;

	public class Layer extends Sprite
	{
		private var _active:Boolean;
		private var _enabled:Boolean;	//User-toggled visibility
		private var grid:Bitmap;
		private var gridColor:uint;
		private var drawGridSize:uint;
		private var defaultTool:Class;
		
		public var tool:Tool; 
		public var quickTools:Vector.<QuickTool>;
		public var layerName:String;
		public var gridSize:uint;
		
		public function Layer(defaultTool:Class, layerName:String, gridSize:uint, gridColor:uint, drawGridSize:uint) 
		{
			this.defaultTool	= defaultTool;
			this.layerName 		= layerName;
			this.gridSize 		= gridSize;
			this.gridColor		= gridColor;
			this.drawGridSize	= drawGridSize;
			
			_active 		= false;
			mouseEnabled 	= false;
			mouseChildren	= false;
			_enabled		= true;
			
			initGrid();
			
			addEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			
			quickTools = new Vector.<QuickTool>;
		}
		
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			setTool(new defaultTool(this));
		}
		
		private function destroy( e:Event ):void 
		{ 
			removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			
			if (active)
				deactivate();
		}
		
		public function resizeLevel( width:int, height:int ):void 
		{ 
			initGrid( width, height );
		}
		
		public function clear():void { }
		
		public function convertNumber( num:int ):int
		{
			return Math.floor( num / gridSize ) * gridSize;
		}
		
		public function convertX( num:int ):int
		{
			num = Math.floor( num / gridSize ) * gridSize;
			num = Math.min( num, Ogmo.level.levelWidth );
			num = Math.max( num, 0 );
			return num;
		}
		
		public function convertY( num:int ):int
		{
			num = Math.floor( num / gridSize ) * gridSize;
			num = Math.min( num, Ogmo.level.levelHeight );
			num = Math.max( num, 0 );
			return num;
		}
		
		public function convertPoint( p:Point ):Point
		{
			return new Point( convertX( p.x ), convertY( p.y ) );
		}
		
		public function set active( to:Boolean ):void
		{
			if (to == _active)
				return;
				
			_active 		= to;
			mouseEnabled 	= to;
			mouseChildren	= to;
			
			if (_active)
			{
				visible = true;
				Ogmo.windows.updateVisibilities();
				activateTool();
				activate();
				
				stage.addEventListener( KeyboardEvent.KEY_UP, quickToolKeyUp );
				stage.addEventListener( MouseEvent.MOUSE_UP, quickToolMouseUp );
			}
			else
			{
				visible = _enabled;
				deactivateTool();
				deactivate();
				
				stage.removeEventListener( KeyboardEvent.KEY_UP, quickToolKeyUp );
				stage.removeEventListener( MouseEvent.MOUSE_UP, quickToolMouseUp );
			}
				
			handleGridMode();
		}
		
		public function set enabled(to:Boolean):void
		{
			_enabled = to;
			if (!active)
				visible = to;
		}
		
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public function get active():Boolean
		{
			return _active;
		}
		
		public function get xml():XML
		{ 
			//OVERRIDE ME!
			return new XML;
		}
		
		public function set xml( to:XML ):void
		{
			//OVERRIDE ME!
		}
		
		public function get layerID():String
		{
			return "Layer " + layerName + ": ";
		}
		
		protected function activate():void { }
		protected function deactivate():void { }
		
		/* =============== GRID STUFF =============== */
		
		private function initGrid( width:int = 0, height:int = 0 ):void
		{	
			var w:int, h:int;
			if (width != 0)
				w = width;
			else
				w = Ogmo.level.levelWidth;
			if (height != 0)
				h = height;
			else
				h = Ogmo.level.levelHeight;
			
			if (grid && contains( grid ))
				removeChild( grid );
				
			grid = new Bitmap( new BitmapData( w, h ) );
			grid.bitmapData.fillRect( new Rectangle( 0, 0, w, h ), 0x00000000 );

			var i:int;
			for ( i = drawGridSize; i < w; i += drawGridSize )
				grid.bitmapData.fillRect( new Rectangle( i, 2, 1, h - 4 ), gridColor );
			for ( i = drawGridSize; i < h; i += drawGridSize )
				grid.bitmapData.fillRect( new Rectangle( 2, i, w - 4, 1 ), gridColor );
			System.gc();
			
			addChildAt( grid, 0 );
			
			handleGridMode();
		}
		
		public function handleGridMode():void
		{
			if (_active)
				grid.visible = Ogmo.gridOn;
			else
				grid.visible = false;
		}
		
		/* ========================== TOOL STUFF ========================== */
		
		private function quickToolMouseUp( e:MouseEvent ):void
		{
			for ( var i:int = 0; i < quickTools.length; i++ )
			{
				if (quickTools[ i ].mode == QuickTool.MOUSE || quickTools[ i ].mode == QuickTool.EITHER)
				{
					setTool( new quickTools[ i ].tool(this) );
					tool.startQuickMode( QuickTool.MOUSE );
					while ( quickTools.length > i )
						quickTools.pop();
					return;
				}
			}
		}
		
		private function quickToolKeyUp( e:KeyboardEvent ):void
		{
			if (e.keyCode == Ogmo.keycode_ctrl)
			{
				for ( var i:int = 0; i < quickTools.length; i++ )
				{
					if (quickTools[ i ].mode == QuickTool.CTRL || quickTools[ i ].mode == QuickTool.EITHER)
					{
						setTool( new quickTools[ i ].tool(this) );
						tool.startQuickMode( QuickTool.CTRL );
						while ( quickTools.length > i )
							quickTools.pop();
						return;
					}
				}
			}
			else if (e.keyCode == 16)
			{
				for ( var j:int = 0; j < quickTools.length; j++ )
				{
					if (quickTools[ j ].mode == QuickTool.SHIFT || quickTools[ j ].mode == QuickTool.EITHER)
					{
						setTool( new quickTools[ j ].tool(this) );
						tool.startQuickMode( QuickTool.SHIFT );
						while ( quickTools.length > j )
							quickTools.pop();
						return;
					}
				}
			}
		}
		
		public function setTool(to:Tool, from:QuickTool = null):void
		{
			destroyTool();			
			tool = to;
			if (_active)
				activateTool();
			if (from != null)
			{
				quickTools.push(from);
				tool.startQuickMode(from.mode);
			}
			
			stage.dispatchEvent(new ToolSelectEvent(to));
		}
		
		private function destroyTool():void
		{
			if (tool)
			{
				if (contains(tool))
					removeChild(tool);
				tool.destroy();
				tool = null;
			}
		}
		
		private function activateTool():void
		{
			if (tool)
				addChild(tool);
			else
				throw new Error("Trying to activate tool when there is none.");
		}
		
		private function deactivateTool():void
		{
			if (tool)
				removeChild(tool);
			else
				throw new Error("Trying to deactivate tool when there is none.");
		}
		
	}

}