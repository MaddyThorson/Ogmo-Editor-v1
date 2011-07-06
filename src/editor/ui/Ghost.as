package editor.ui 
{
	import editor.definitions.ObjectDefinition;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;

	public class Ghost extends Sprite
	{		
		static private const C_BOX:uint = 0x00FF00;
		
		public function Ghost(objDef:ObjectDefinition)
		{		
			var bitmap:Sprite = new Sprite;
			addChild(bitmap);
			
			if (objDef.tile)
			{
				bitmap.graphics.beginBitmapFill(objDef.bitmapData);
				bitmap.graphics.drawRect(0, 0, objDef.width, objDef.height);
				bitmap.graphics.endFill();
			}
			else
			{
				bitmap.addChild(new Bitmap(objDef.bitmapData));
				bitmap.scaleX = objDef.width / objDef.imgWidth;
				bitmap.scaleY = objDef.height / objDef.imgHeight;
			}
			
			var s:Sprite = new Sprite;
			s.graphics.beginFill(C_BOX, 0.5);
			s.graphics.drawRect(0, 0, objDef.width, objDef.height);
			s.graphics.endFill();
			addChild(s);
		}
		
	}

}