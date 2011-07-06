package editor.ui 
{
	import editor.GameObject;
	import editor.ObjectLayer;
	import editor.Reader;
	import flash.display.Sprite;
	
	public class ObjectInfoWindow extends Window
	{
		private const WIDTH:int 		= 150;
		private const IMAGE_SIZE:int 	= 64;
		private const IMAGE_OFFSET:int 	= (WIDTH - IMAGE_SIZE) / 2;
		private const TEXT_X:int		= (WIDTH / 2) - 2;
		
		public function ObjectInfoWindow() 
		{
			super(WIDTH, 126, "Selection");
			x = 780 - WIDTH;
			y = 20 + Window.BAR_HEIGHT;

			reset();
		}
		
		public function reset():void
		{
			while ( ui.numChildren > 0 )
				ui.removeChildAt( 0 );
				
			bodyHeight = 24;
		}
		
		public function setTarget(objs:Vector.<GameObject>):void
		{
			reset();
			
			if (objs.length == 0)
				return;
				
			if (objs.length == 1)
				setTargetForOne(objs[ 0 ]);
			else
				setTargetForMany(objs);
		}
		
		private function setTargetForOne(obj:GameObject):void
		{
			var addSize:int = 0;
			var str:String;
			var lbl:Label;
			
			//The object border
			var s:Sprite = new Sprite;
			s.graphics.beginFill( 0x000000 );
			s.graphics.drawRect( IMAGE_OFFSET - 1, 23, 1, IMAGE_SIZE );
			s.graphics.drawRect( IMAGE_OFFSET + IMAGE_SIZE - 1, 23, 1, IMAGE_SIZE );
			s.graphics.drawRect( IMAGE_OFFSET, 23, IMAGE_SIZE - 1, 1 );
			s.graphics.drawRect( IMAGE_OFFSET - 1, 87, IMAGE_SIZE + 1, 1 );
			s.graphics.endFill();
			ui.addChild( s );
			
			//add the sprite
			s = new Sprite;
			s.graphics.beginBitmapFill( obj.definition.bitmapData );
			s.graphics.drawRect( 0, 0, obj.definition.imgWidth, obj.definition.imgHeight );
			s.graphics.endFill();
			s.scaleX = s.scaleY = Math.min(IMAGE_SIZE / obj.definition.imgWidth, IMAGE_SIZE / obj.definition.imgHeight);
			s.x = IMAGE_OFFSET + (IMAGE_SIZE - obj.definition.imgWidth * s.scaleX) / 2;
			s.y = 24 + (IMAGE_SIZE - obj.definition.imgHeight * s.scaleY) / 2;
			ui.addChild( s );
			
			//Object name
			lbl = new Label( obj.definition.name, TEXT_X, 10, "Center", "Center" ); 
			ui.addChild( lbl );
			
			//Object co-ords
			str = "( " + obj.x + ", " + obj.y + " )";
			lbl = new Label( str, TEXT_X, 94, "Center", "Center" );
			ui.addChild( lbl );
			
			//Object width
			if (obj.definition.resizableX)
			{
				lbl = new Label( "width: " + obj.objWidth, TEXT_X, 110, "Center", "Center" );
				ui.addChild( lbl );
				addSize += 16;
			}
			
			//Object height
			if (obj.definition.resizableY)
			{
				lbl = new Label( "height: " + obj.objHeight, TEXT_X, 110 + addSize, "Center", "Center" );
				ui.addChild( lbl );
				addSize += 16;
			}
			
			//Object angle
			if (obj.definition.rotatable)
			{
				lbl = new Label( "angle: " + obj.angle, TEXT_X, 110 + addSize, "Center", "Center" );
				ui.addChild( lbl );
				addSize += 16;
			}
			
			//Object count / limit
			str = "Count: " + (Ogmo.level.currentLayer as ObjectLayer).getAmountType( obj.definition.name );
			if (obj.definition.limit > 0)
				str = str + " / " + obj.definition.limit;
			lbl = new Label( str, TEXT_X, 110 + addSize, "Center", "Center"  );
			ui.addChild( lbl );
			
			//Set size
			bodyHeight = 126 + addSize;
			
			//values
			if (obj.values)
				Reader.addElementsForValues(this, obj.values);
		}
		
		private function setTargetForMany(objs:Vector.<GameObject>):void
		{
			ui.addChild( new Label( objs.length + " objects", TEXT_X, 2, "Center" ) );
		}
		
	}

}