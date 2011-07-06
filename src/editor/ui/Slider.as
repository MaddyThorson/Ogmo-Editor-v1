package editor.ui 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public dynamic class Slider extends ValueModifier
	{
		[Embed(source = '../../../assets/slider1.png')]
		static private const ImgSlider1:Class;
		[Embed(source = '../../../assets/slider2.png')]
		static private const ImgSlider2:Class;
		
		static private const SLIDER_OFFSET:uint		= 6;
		static private const DECIMAL_PLACES:uint	= 2;
		static private const C_LINE:uint			= 0x000000;
		static private const C_BG:uint				= 0xFFFFFF;
		
		private var def:Number;
		private var min:Number;
		private var max:Number;
		private var length:int;
		private var onlyInt:Boolean;
		private var callback:Function;
		
		private var bitmap:Bitmap;
		private var bg:Sprite;
		private var dragging:Boolean = false;
		
		public var _value:Number;
		
		public function Slider( x:int, y:int, def:Number, min:Number, max:Number, length:int, onlyInt:Boolean = false, callback:Function = null ) 
		{
			this.x			= x;
			this.y			= y;
			this.def 		= def;
			this.min 		= min;
			this.max 		= max;
			this.length		= length;
			this.onlyInt 	= onlyInt;
			this.callback	= callback;
			
			_value = def;
			
			mouseEnabled = true;
			mouseChildren = true;
			
			addEventListener( Event.ADDED_TO_STAGE, init );
		}
		
		private function init( e:Event ):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, init );
			
			bg = new Sprite;
			addChild( bg );
			
			bg.graphics.beginFill( C_BG );
			bg.graphics.drawRect( 0, 4, length, 6 );
			bg.graphics.endFill();
			bg.graphics.beginFill( C_LINE );
			//the line
			bg.graphics.drawRect( 0, 10, length, 1 );
			//Big seps
			bg.graphics.drawRect( 0, 2, 1, 8 );
			bg.graphics.drawRect( (length / 2) - 1, 2, 1, 8 );
			bg.graphics.drawRect( length - 1, 2, 1, 8 );
			//little seps
			bg.graphics.drawRect( (length / 4) - 1, 6, 1, 4 );
			bg.graphics.drawRect( (length * 3 / 4) - 1, 6, 1, 4 );
			//Tinyseps
			bg.graphics.drawRect( (length / 8) - 1, 8, 1, 2 );
			bg.graphics.drawRect( (length * 3 / 8) - 1, 8, 1, 2 );
			bg.graphics.drawRect( (length * 5 / 8) - 1, 8, 1, 2 );
			bg.graphics.drawRect( (length * 7 / 8) - 1, 8, 1, 2 );
			bg.graphics.endFill();
			
			bitmap 		= new ImgSlider1;
			positionSliderByValue();
			addChild( bitmap );
			
			addEventListener( Event.REMOVED_FROM_STAGE, destroy );
			addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			stage.addEventListener( MouseEvent.MOUSE_UP, onMouseUp );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
		}
		
		private function destroy( e:Event ):void
		{
			removeEventListener( Event.REMOVED_FROM_STAGE, destroy );
			removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			stage.removeEventListener( MouseEvent.MOUSE_UP, onMouseUp );
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
		}
		
		private function setImage( to:Class ):void
		{
			if (to)
				bitmap.bitmapData = (new to).bitmapData;
		}
		
		private function positionSliderByValue():void
		{
			bitmap.x = ((_value - min) / (max - min) * length) - SLIDER_OFFSET;
		}
		
		private function getValueBySlider():void
		{
			change( ((bitmap.x + SLIDER_OFFSET) / length * (max - min)) + min );
		}
		
		private function change( num:Number ):void
		{
			//Calculate the value
			if (onlyInt)
				_value = Math.round( num );	
			else
			{
				var temp:int = Math.pow( 10, DECIMAL_PLACES );
				
				_value *= temp;
				_value = Math.round( num );
				_value /= temp;
			}
			_value = Math.min( max, Math.max( min, _value ) );
			
			//Move the slider and redraw the textfield
			positionSliderByValue();
			
			//Call the bacllback
			if (callback != null)
				callback( this );
		}
		
		/* ======================== EVENTS ======================== */
		
		private function onMouseDown( e:MouseEvent ):void
		{
			dragging = true;		
			bitmap.x = globalToLocal( new Point( e.stageX ) ).x - SLIDER_OFFSET;
			getValueBySlider();
			
			setImage( ImgSlider2 );
		}
		
		private function onMouseUp( e:MouseEvent ):void
		{
			dragging = false;		
			
			setImage( ImgSlider1 );
		}
		
		private function onMouseMove( e:MouseEvent ):void
		{
			if (dragging)
			{
				bitmap.x = globalToLocal( new Point( e.stageX ) ).x - SLIDER_OFFSET;
				getValueBySlider();
			}
		}
		
		/* ================ VALUE STUFF ================ */
		
		override public function get value():*
		{
			return _value;
		}
		
		override public function set value( to:* ):void
		{
			_value = to;
			positionSliderByValue();
		}
		
		public function giveValue():void
		{
			valueObject.value = _value;
		}
		
		public function takeValue():void
		{
			value = valueObject.value;
		}
		
	}

}