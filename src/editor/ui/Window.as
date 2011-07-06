package editor.ui
{
	import editor.*;
	import flash.text.TextField;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class Window extends Sprite
	{
		private var _bodyWidth:int;
		private var _bodyHeight:int;
		private var dragging:Boolean;
		private var moveX:Number;
		private var moveY:Number;
		private var _active:Boolean;
		private var minimized:Boolean;
		protected var oldWidth:uint;
		protected var oldHeight:uint;
		
		//Contained stuff
		private var bg:Sprite;
		private var bar:Sprite;
		private var border:Sprite;
		private var _title:TextField;
		public var ui:Sprite;
		
		//Constants
		static public const BAR_HEIGHT:int		= 24;
		static private const BORDER:uint		= 2;
		static private const C_BG:uint 			= 0x666666;
		static private const C_BAR:uint			= 0xBB8888;
		static private const C_BARHOLD:uint		= 0xFF6666;
		static private const C_BORDER:uint 		= 0x000000;
		static private const C_BARM:uint		= 0x774444;
		static private const C_BARMHOLD:uint	= 0xBB2222;
		static private const C_TITLE:uint		= 0xFFFFFF;

		public function Window( bodyWidth:int, bodyHeight:int, titleText:String ) 
		{
			_bodyWidth 	= bodyWidth;
			_bodyHeight = bodyHeight;
			
			addChild( bg = new Sprite );
			addChild( bar = new Sprite );
			addChild( border = new Sprite );
			
			bar.doubleClickEnabled = true;
			
			hitArea = new Sprite;
			hitArea.width 	= _bodyWidth;
			hitArea.height	= _bodyHeight;
			
			drawBG();
			drawBar();
			drawBorder();
			
			_title 					= new TextField();
			_title.mouseEnabled		= false;
			_title.selectable 		= false;
			_title.text 			= titleText;
			_title.y 				= (-BAR_HEIGHT / 2) - (_title.textHeight / 2) + (Ogmo.mac?2:-2);
			_title.textColor		= C_TITLE;
			_title.width 			= _bodyWidth;
			_title.height 			= BAR_HEIGHT;
			_title.x				= 10;
			addChild( _title );
			
			addChild( ui = new Sprite );
			
			alpha 		= 0.8;
			dragging 	= false;
			minimized 	= false;
			
			_active = false;
			
			addEventListener( Event.ADDED_TO_STAGE, init );
		}
		
		private function init( e:Event ):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, init );
			
			addEventListener( Event.REMOVED_FROM_STAGE, destroy );
			stage.addEventListener( MouseEvent.MOUSE_UP, onMouseUp );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
			bar.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			bar.addEventListener( MouseEvent.DOUBLE_CLICK, onDoubleClick );
			addEventListener( MouseEvent.MOUSE_DOWN, onClickAnywhere );
			
			oldWidth 	= stage.stageWidth;
			oldHeight 	= stage.stageHeight;
			enforceBounds();
		}
		
		private function destroy( e:Event ):void
		{
			removeEventListener( Event.REMOVED_FROM_STAGE, destroy );
			stage.removeEventListener( MouseEvent.MOUSE_UP, onMouseUp );
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
			bar.removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			bar.removeEventListener( MouseEvent.DOUBLE_CLICK, onDoubleClick );
			removeEventListener( MouseEvent.MOUSE_DOWN, onClickAnywhere );
		}
		
		private function drawBG():void
		{
			bg.graphics.clear();
			bg.graphics.beginFill( C_BG );
			if (minimized)
				bg.graphics.drawRect( 0, -BAR_HEIGHT, _bodyWidth, BAR_HEIGHT );
			else
				bg.graphics.drawRect( 0, -BAR_HEIGHT, _bodyWidth, _bodyHeight + BAR_HEIGHT );
			bg.graphics.endFill();
		}
		
		private function drawBar():void
		{
			bar.graphics.clear();
			if (minimized)
				bar.graphics.beginFill( C_BARM );
			else
				bar.graphics.beginFill( C_BAR );
			bar.graphics.drawRect( 0, -BAR_HEIGHT, _bodyWidth, BAR_HEIGHT );
				bar.graphics.endFill();
		}
		
		private function drawBarHold():void
		{
			bar.graphics.clear();
			if (minimized)
				bar.graphics.beginFill( C_BARMHOLD );
			else
				bar.graphics.beginFill( C_BARHOLD );
			bar.graphics.drawRect( 0, -BAR_HEIGHT, _bodyWidth, BAR_HEIGHT );
				bar.graphics.endFill();
		}
		
		private function drawBorder():void
		{
			border.graphics.clear();
			border.graphics.beginFill( C_BORDER );
			if (minimized)
			{
				border.graphics.drawRect( 0, -BAR_HEIGHT + BORDER, BORDER, BAR_HEIGHT - BORDER*2 );
				border.graphics.drawRect( _bodyWidth - BORDER, -BAR_HEIGHT + BORDER, BORDER, BAR_HEIGHT - BORDER*2 );
				border.graphics.drawRect( 0, -BAR_HEIGHT, _bodyWidth, BORDER );
				border.graphics.drawRect( 0, -BORDER, _bodyWidth, BORDER );
			}
			else
			{
				border.graphics.drawRect( 0, -BAR_HEIGHT + BORDER, BORDER, _bodyHeight + BAR_HEIGHT - BORDER*2 );
				border.graphics.drawRect( _bodyWidth - BORDER, -BAR_HEIGHT + BORDER, BORDER, _bodyHeight + BAR_HEIGHT - BORDER*2 );
				border.graphics.drawRect( 0, -BAR_HEIGHT, _bodyWidth, BORDER );
				border.graphics.drawRect( 0, _bodyHeight - BORDER, _bodyWidth, BORDER );
			}
			border.graphics.endFill();
		}
		
		public function enforceBounds():void
		{	
			//Calculate the distance to the edge
			var edgeX:int 	= (stage.stageWidth - Ogmo.STAGE_DEFAULT_WIDTH) / 2;
			var edgeY:int	= (stage.stageHeight - Ogmo.STAGE_DEFAULT_HEIGHT) / 2;
			
			//Stick to edges
			stickToEdges( oldWidth, oldHeight );
			
			//Actually enforce the bounds
			x = Utils.within( -edgeX, x, Ogmo.STAGE_DEFAULT_WIDTH + edgeX - _bodyWidth );
			y = Utils.within( -edgeY + BAR_HEIGHT, y, Ogmo.STAGE_DEFAULT_HEIGHT + edgeY );
		}
		
		public function stickToEdges( oldWidth:int, oldHeight:int ):void
		{	
			if (x + (_bodyWidth/2) < Ogmo.STAGE_DEFAULT_WIDTH / 2)
				x -= (stage.stageWidth - oldWidth) / 2;
			else
				x += (stage.stageWidth - oldWidth) / 2;
				
			if (y + (_bodyHeight/2) < Ogmo.STAGE_DEFAULT_HEIGHT / 2)
				y -= (stage.stageHeight - oldHeight) / 2;
			else
				y += (stage.stageHeight - oldHeight) / 2;
				
			//update
			this.oldWidth 	= stage.stageWidth;
			this.oldHeight 	= stage.stageHeight;
		}
		
		public function emptyUI():void
		{
			while (ui.numChildren > 0)
				ui.removeChildAt(0);
		}
		
		/* ========================== GETS/SETS ========================== */
		
		public function set title( to:String ):void
		{
			_title.text = to;
			_title.y = (-BAR_HEIGHT / 2) - (_title.textHeight / 2) - 2;
		}
		
		public function get title():String
		{
			return _title.text;
		}
		
		public function set active( to:Boolean ):void
		{
			_active = to;
			visible 		= to;
			mouseEnabled	= to;
		}
		
		public function get active():Boolean
		{
			return _active;
		}
		
		public function set bodyWidth( to:int ):void
		{
			_bodyWidth = to;
			hitArea.width = _bodyWidth;
			
			drawBG();
			drawBar();
			drawBorder();
			
			_title.x = (_bodyWidth / 2) - (_title.textWidth / 2) - 3;
		}
		
		public function get bodyWidth():int
		{
			return _bodyWidth;
		}
		
		public function set bodyHeight( to:int ):void
		{
			_bodyHeight = to;
			hitArea.height = _bodyHeight;
			
			drawBG();
			drawBar();
			drawBorder();
		}
		
		public function get bodyHeight():int
		{
			return _bodyHeight;
		}
		
		/* ========================== EVENTS ========================== */
		
		private function onMouseDown( e:MouseEvent ):void
		{
			dragging = true;
			moveX = e.localX;
			moveY = e.localY;
			
			drawBarHold();
		}
		
		private function onMouseMove( e:MouseEvent ):void
		{
			if (dragging)
			{
				x = e.stageX - moveX;
				y = e.stageY - moveY;
				enforceBounds();
			}
		}
		
		private function onMouseUp( e:MouseEvent ):void
		{
			dragging = false;
			
			drawBar();
		}
		
		private function onDoubleClick( e:MouseEvent ):void
		{
			minimized = !minimized;
			
			ui.visible 			= !minimized;
			ui.mouseChildren 	= !minimized;
			ui.mouseEnabled 	= !minimized;
			
			drawBG();
			drawBar();
			drawBorder();
		}
		
		private function onClickAnywhere( e:MouseEvent ):void
		{
			parent.setChildIndex( this, parent.numChildren - 1 );
		}
		
		
		
	}

}